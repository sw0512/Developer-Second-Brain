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

echo
echo "Done. Restart Claude Code and both the 'second-brain' skill and /document are live."
echo "Because these are symlinks, further edits in this repo take effect on the next run."
