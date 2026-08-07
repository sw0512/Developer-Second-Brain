#!/usr/bin/env python3
"""Add or remove this project's hooks in ~/.claude/settings.json for the dev (symlink) install.

Plugin installs get the hooks automatically from hooks/hooks.json. The symlink dev install has
no plugin manifest to read, so they have to be written into user settings directly — this
script is that step, factored out of install-dev.sh so add and remove share one implementation
and cannot drift apart.

Two hooks are wired, and they are wired together on purpose: the PostToolUse detector proposes,
the PreToolUse guard enforces that a proposal happened. Installing the detector alone would
reproduce the exact v0.4.2 field failure — a proposal path with nothing behind it.

Contract:
  add <detect-script> <guard-script>   idempotent; replaces any previously wired entry
  remove                               removes only entries this script added

Safety: settings.json holds the user's whole Claude Code configuration. Every write goes
through a .bak copy first, and a malformed existing file aborts rather than being overwritten.
"""

import json
import os
import shutil
import sys
from pathlib import Path

# Overridable so tests can exercise the merge against a scratch file instead of the user's
# real configuration — this script is the one place that rewrites it.
SETTINGS = Path(os.environ.get("SECOND_BRAIN_SETTINGS",
                               Path.home() / ".claude" / "settings.json"))
# Identifies entries owned by this project. One substring per hook script rather than a single
# looser pattern: ownership decides what `remove` is allowed to delete from the user's settings,
# so it should match this project's files and nothing else.
MARKERS = ("detect-on-", "guard-vault-")

# v0.4 registered a Stop hook; v0.4.1 uses PostToolUse; v0.4.2 adds PreToolUse. Every event this
# project has ever used is swept, so an upgrade removes stale registrations instead of leaving
# them firing alongside the current ones.
EVENTS = ("PreToolUse", "PostToolUse", "Stop")

MATCHER = "Edit|Write|NotebookEdit"


def ours(command: str) -> bool:
    return any(m in command for m in MARKERS)


def load() -> dict:
    if not SETTINGS.exists():
        return {}
    try:
        return json.loads(SETTINGS.read_text())
    except json.JSONDecodeError as e:
        sys.exit(f"❌ {SETTINGS} is not valid JSON ({e}).\n"
                 f"   Fix it first — refusing to overwrite a broken config.")


def save(data: dict) -> None:
    if SETTINGS.exists():
        shutil.copy2(SETTINGS, SETTINGS.with_suffix(".json.bak"))
    SETTINGS.parent.mkdir(parents=True, exist_ok=True)
    SETTINGS.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")


def strip_ours(entries: list) -> list:
    """Drop hook entries pointing at this project, keeping every unrelated hook."""
    kept = []
    for entry in entries:
        hooks = [h for h in entry.get("hooks", []) if not ours(str(h.get("command", "")))]
        if hooks:
            kept.append({**entry, "hooks": hooks})
        elif not entry.get("hooks"):
            kept.append(entry)  # unrecognized shape — preserve rather than discard
    return kept


def _write_events(data: dict, remaining: dict) -> None:
    """Put back each swept event, dropping keys that ended up empty."""
    for ev, kept in remaining.items():
        if kept:
            data.setdefault("hooks", {})[ev] = kept
        else:
            data.get("hooks", {}).pop(ev, None)
    if not data.get("hooks"):
        data.pop("hooks", None)


def main() -> None:
    if len(sys.argv) < 2 or sys.argv[1] not in ("add", "remove"):
        sys.exit("usage: hook-wiring.py add <detect-script> <guard-script> | remove")

    action = sys.argv[1]
    data = load()
    events = EVENTS
    for ev in events:
        if not isinstance(data.get("hooks", {}).get(ev, []), list):
            sys.exit(f"❌ hooks.{ev} in settings.json is not a list — leaving it untouched.")

    had_ours = False
    remaining = {}
    for ev in events:
        entries = data.get("hooks", {}).get(ev, [])
        kept = strip_ours(entries)
        if any(ours(str(h.get("command", ""))) for e in entries for h in e.get("hooks", [])):
            had_ours = True
        remaining[ev] = kept

    if action == "add":
        if len(sys.argv) < 4:
            sys.exit("usage: hook-wiring.py add <detect-script> <guard-script>")
        detect, guard = (str(Path(p).resolve()) for p in sys.argv[2:4])
        # Invoked through `bash <path>` rather than relying on the file's executable bit, so
        # the hooks still run if a checkout or copy drops the permission. Matches how the
        # first-party plugins register their hooks.
        for ev, script in (("PostToolUse", detect), ("PreToolUse", guard)):
            remaining[ev].append({
                "matcher": MATCHER,
                "hooks": [{
                    "type": "command",
                    "command": f'bash "{script}"',
                    "timeout": 10,
                }]
            })
        _write_events(data, remaining)
        save(data)
        verb = "updated" if had_ours else "added"
        print(f"✅ PostToolUse hook {verb}: {detect}")
        print(f"✅ PreToolUse guard {verb}: {guard}")
    else:
        if not had_ours:
            print("ℹ️  No Second Brain hooks in settings.json — nothing to do.")
            return
        _write_events(data, remaining)
        save(data)
        print("✅ Hooks removed.")


if __name__ == "__main__":
    main()
