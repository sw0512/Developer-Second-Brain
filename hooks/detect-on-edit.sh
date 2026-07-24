#!/usr/bin/env bash
#
# Developer Second Brain — PostToolUse hook (v0.4.1)
#
# WHY NOT A Stop HOOK (the v0.4 design, reverted)
# -----------------------------------------------
# v0.4 used a Stop hook that emitted `decision: block` + `reason` to make the model run the
# detection engine. It worked — and was unusable. Claude Code renders a blocked Stop's `reason`
# to the user, so the instruction telling the model to stay quiet was itself printed on screen
# at every fire. There was no silent path to have.
#
# This is not tunable, it is structural: `Stop` is not a member of Claude Code's
# hookSpecificOutput union, so a Stop hook cannot use `additionalContext` — the channel that
# reaches the model without reaching the user. `PostToolUse` IS a member. Hence this rewrite:
# same job, different event, and the guidance is injected silently.
#
# WHAT IT DOES NOT DO
# -------------------
# It never judges documentation value — that stays in references/, the single source of truth.
# It only answers "is it worth spending a model turn asking?". It never writes to the vault.
#
# FAILURE POSTURE
# ---------------
# Every unexpected condition exits 0 (stay silent). This now runs after every matching edit,
# so it must be both cheap and incapable of breaking the session.

set -uo pipefail
trap 'exit 0' ERR

# --- Tunables -----------------------------------------------------------------------------
# These filter out sessions with no development work. The real judgment lives in the detection
# engine; this gate only decides whether asking is worth a model turn.

MIN_EDITS=3        # edits so far — higher than v0.4's 1: PostToolUse fires per edit, so a
                   # single stray edit should not arm the trigger
MIN_MESSAGES=12    # conversation messages; filters out trivially short exchanges
COOLDOWN_HOURS=6   # per project, NOT per session — see the cooldown block below

STATE_DIR="${SECOND_BRAIN_STATE_DIR:-$HOME/.claude/second-brain-state}"

# --- Kill switch --------------------------------------------------------------------------
[ "${SECOND_BRAIN_HOOK_DISABLED:-0}" = "1" ] && exit 0

command -v jq >/dev/null 2>&1 || exit 0   # no jq → stay silent rather than guess

input=$(cat)

# stderr suppressed throughout: malformed input must produce silence, not a visible error.
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
cwd=$(printf '%s' "$input"        | jq -r '.cwd            // empty' 2>/dev/null)

[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0
[ -n "$cwd" ] || exit 0

# --- Cooldown, keyed on the PROJECT ---------------------------------------------------------
# v0.4 keyed this on session_id and that was the second defect: one stretch of work spans
# several sessions (a background job and the interactive session have different ids), so a
# "once per session" cap still fired repeatedly from the user's point of view — two markers
# with different UUIDs for one piece of work.
#
# The unit the user actually perceives is "this project, right now", so the marker is keyed on
# cwd and expires on a time cooldown. Every session working in the same directory shares it.
#
# Checked BEFORE reading the transcript: once armed, later edits cost a single stat().
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
key=$(printf '%s' "$cwd" | shasum 2>/dev/null | cut -d' ' -f1)
[ -n "$key" ] || exit 0
marker="$STATE_DIR/proj-${key}.fired"

if [ -e "$marker" ]; then
  # -mmin is portable across GNU and BSD find, unlike `find -newermt`.
  recent=$(find "$marker" -mmin "-$((COOLDOWN_HOURS * 60))" 2>/dev/null)
  [ -n "$recent" ] && exit 0
fi

find "$STATE_DIR" -name '*.fired' -mtime +30 -delete 2>/dev/null || true

# --- Cheap work gate ----------------------------------------------------------------------
# Streamed, never slurped: `jq -s` on a 149MB transcript measured 516MB RSS, and this runs far
# more often than the old Stop hook did. Streaming holds it at ~3MB regardless of length.
#
# Messages are counted as entries carrying `.message`, NOT as raw lines: transcripts also hold
# snapshots, hook records and attachments (564 raw lines vs 309 real messages in a sample
# session), so line counting would silently loosen the gate past what it claims to check.
counts=$(jq -r '
  select(.message != null)
  | "MSG",
    ( .message.content? // []
      | if type == "array" then .[] else empty end
      | select(type == "object" and .type == "tool_use")
      | .name )
' "$transcript" 2>/dev/null | awk '
  $0 == "MSG" { m++; next }
  $0 == "Edit" || $0 == "Write" || $0 == "NotebookEdit" { e++ }
  END { printf "%d %d", e + 0, m + 0 }
') || exit 0

read -r edits msgs <<< "$counts"
: "${edits:=0}"; : "${msgs:=0}"

[ "$msgs" -ge "$MIN_MESSAGES" ] || exit 0
[ "$edits" -ge "$MIN_EDITS" ] || exit 0

# --- Arm the trigger ------------------------------------------------------------------------
touch "$marker" 2>/dev/null || exit 0

# `hookSpecificOutput.additionalContext` reaches the model and NOT the user — the whole reason
# this hook is on PostToolUse instead of Stop. The note is deliberately soft: it asks the model
# to consider the question at the end of its turn rather than interrupting the work in flight,
# and it restates that the hook detected activity, never value.
jq -nc '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: (
      "[Developer Second Brain] This session has accumulated real development work.\n\n" +
      "When the current task reaches a natural stopping point — not mid-task — consider once " +
      "whether any of it is worth recording, using the `second-brain` skill: its eligibility " +
      "gate, then the Evidence object, then the documentation Assessment, then " +
      "references/interruption-policy.md for propose / hold / silent.\n\n" +
      "CRITICAL:\n" +
      "- This note reports only that activity happened. It is NOT a judgment that the work is " +
      "valuable, and must never be treated as evidence for should_document.\n" +
      "- Staying silent is the correct and most common outcome. If the gate rejects or the " +
      "policy says hold/silent, say nothing at all — never mention this note, the hook, or " +
      "why you stayed quiet.\n" +
      "- Do not interrupt the task you are currently doing to act on this.\n" +
      "- Never write to the vault without explicit user approval. Propose only.\n" +
      "- This is throttled per project, so no re-check is needed."
    )
  }
}'
