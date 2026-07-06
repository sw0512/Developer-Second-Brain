#!/usr/bin/env bash
#
# Remove the dev symlinks created by install-dev.sh.
# Only removes them if they are actually symlinks (never deletes real files).
#
set -euo pipefail

unlink_if_symlink() {
  local target="$1" label="$2"
  if [ -L "$target" ]; then
    rm "$target"
    echo "✅ Removed $label symlink: $target"
  elif [ -e "$target" ]; then
    echo "⚠️  $target exists but is NOT a symlink — leaving it untouched." >&2
  else
    echo "ℹ️  No $label symlink at $target — nothing to do."
  fi
}

unlink_if_symlink "$HOME/.claude/skills/second-brain" "skill"
unlink_if_symlink "$HOME/.claude/commands/document.md" "command"
