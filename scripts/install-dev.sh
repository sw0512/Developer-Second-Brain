#!/usr/bin/env bash
#
# Dev install — symlink the skill AND the /document command into ~/.claude for
# instant local testing.
#
# This is the FAST iteration loop: edit files in this repo and they take effect
# immediately (a symlink means no copy, no reinstall). Use this while developing.
# For real/distributable installation, use the plugin marketplace instead:
#
#     /plugin marketplace add Snagwoo/Developer-Second-Brain
#     /plugin install developer-second-brain
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# source -> destination pairs (skill dir, command file)
SKILL_SRC="$REPO_ROOT/skills/second-brain"
SKILL_LINK="$HOME/.claude/skills/second-brain"
CMD_SRC="$REPO_ROOT/commands/document.md"
CMD_LINK="$HOME/.claude/commands/document.md"

if [ ! -f "$SKILL_SRC/SKILL.md" ]; then
  echo "❌ SKILL.md not found at $SKILL_SRC — run this from the repo." >&2
  exit 1
fi

# link <src> <dst> <label> — safely (re)create a symlink, never clobber real files.
link() {
  local src="$1" dst="$2" label="$3"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "❌ $dst already exists and is NOT a symlink — leaving it untouched." >&2
    echo "   Move or remove it first to avoid clobbering real files." >&2
    exit 1
  fi
  ln -s "$src" "$dst"
  echo "✅ $label: $dst -> $src"
}

link "$SKILL_SRC" "$SKILL_LINK" "skill"
link "$CMD_SRC"   "$CMD_LINK"   "command (/document)"

# The hooks cannot be symlinked — they have to be registered in settings.json. Plugin installs
# pick them up from hooks/hooks.json; the dev install wires them here. Two of them: the
# PostToolUse detector (v0.4.1) that proposes, and the PreToolUse guard (v0.4.2) that refuses a
# vault write the user was never shown. --no-hook skips both; at runtime they have separate kill
# switches (SECOND_BRAIN_HOOK_DISABLED / SECOND_BRAIN_GUARD_DISABLED) because silencing
# suggestions is a different request from dropping the approval gate.
if [ "${1:-}" = "--no-hook" ]; then
  echo "⏭  Hooks skipped (--no-hook)."
else
  python3 "$REPO_ROOT/scripts/hook-wiring.py" add \
    "$REPO_ROOT/hooks/detect-on-edit.sh" \
    "$REPO_ROOT/hooks/guard-vault-write.sh"
fi

echo
echo "Done. Restart Claude Code — the 'second-brain' skill, /document, and the hooks are live."
echo "Because the skill and command are symlinks, further edits take effect on the next run."
