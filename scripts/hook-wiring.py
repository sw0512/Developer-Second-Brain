#!/usr/bin/env python3
"""Add or remove the Stop hook in ~/.claude/settings.json for the dev (symlink) install.

Plugin installs get the hook automatically from hooks/hooks.json. The symlink dev install has
no plugin manifest to read, so the hook has to be written into user settings directly — this
script is that step, factored out of install-dev.sh so add and remove share one implementation
and cannot drift apart.

Contract:
  add <script-path>     idempotent; replaces any previously wired entry for this repo
  remove                removes only entries this script added; leaves everything else alone

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
MARKER = "detect-on-"  # identifies entries owned by this project (any hook script)


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


def strip_ours(stop_entries: list) -> list:
    """Drop hook entries pointing at this project, keeping every unrelated Stop hook."""
    kept = []
    for entry in stop_entries:
        hooks = [h for h in entry.get("hooks", []) if MARKER not in str(h.get("command", ""))]
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
        sys.exit("usage: hook-wiring.py add <script-path> | remove")

    action = sys.argv[1]
    data = load()
    # v0.4 registered a Stop hook; v0.4.1 uses PostToolUse. Both events are swept so an
    # upgrade removes the old registration instead of leaving it firing alongside the new one.
    events = ("PostToolUse", "Stop")
    for ev in events:
        if not isinstance(data.get("hooks", {}).get(ev, []), list):
            sys.exit(f"❌ hooks.{ev} in settings.json is not a list — leaving it untouched.")

    had_ours = False
    remaining = {}
    for ev in events:
        entries = data.get("hooks", {}).get(ev, [])
        kept = strip_ours(entries)
        if any(MARKER in str(h.get("command", "")) for e in entries for h in e.get("hooks", [])):
            had_ours = True
        remaining[ev] = kept

    if action == "add":
        if len(sys.argv) < 3:
            sys.exit("usage: hook-wiring.py add <script-path>")
        # Invoked through `bash <path>` rather than relying on the file's executable bit, so
        # the hook still runs if a checkout or copy drops the permission. Matches how the
        # first-party plugins register their hooks.
        script = str(Path(sys.argv[2]).resolve())
        remaining["PostToolUse"].append({
            "matcher": "Edit|Write|NotebookEdit",
            "hooks": [{
                "type": "command",
                "command": f'bash "{script}"',
                "timeout": 10,
            }]
        })
        _write_events(data, remaining)
        save(data)
        print(f"✅ PostToolUse hook {'updated' if had_ours else 'added'}: {script}")
    else:
        if not had_ours:
            print("ℹ️  No Second Brain hook in settings.json — nothing to do.")
            return
        _write_events(data, remaining)
        save(data)
        print("✅ Hook removed.")


if __name__ == "__main__":
    main()
