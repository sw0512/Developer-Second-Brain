#!/usr/bin/env bash
#
# Developer Second Brain — Stop hook (v0.4)
#
# WHY THIS EXISTS
# ---------------
# The detection engine (skills/second-brain/references/) can judge whether work is worth
# recording, but nothing ever asked it to run. A skill is model-invoked: it fires when the
# user's request maps onto the skill description. "After you finish solving a problem" is not
# a request — so at the end of real dev work, nothing prompted the judgment and the engine
# stayed silent. Only `/document` reliably reached it.
#
# This hook supplies the missing trigger. On Stop, it decides *cheaply* whether the session
# plausibly contained real development work, and if so blocks the stop once so the model runs
# the detection engine before ending the turn.
#
# WHAT IT DOES NOT DO
# -------------------
# It never judges documentation value itself — that stays in references/, the single source of
# truth. It only answers "is it worth spending a model turn asking?". And it never writes to
# the vault: the hard rule (no save without explicit approval) is untouched.
#
# FAILURE POSTURE
# ---------------
# Every unexpected condition exits 0 (stay silent). A knowledge-capture tool must never break
# the user's session; a missed proposal is recoverable via /document, a broken Stop hook is not.

set -uo pipefail

# Exit silently on any unexpected error rather than surfacing a hook failure to the user.
trap 'exit 0' ERR

# --- Tunables -----------------------------------------------------------------------------
# Each threshold answers "is this session substantial enough to be worth one model turn?".
# They are deliberately loose: the real judgment lives in the detection engine, and this gate
# only filters out sessions that obviously contain no development work (pure Q&A, a one-line
# read, an aborted start). Raising them trades missed proposals for fewer interruptions.

MIN_EDITS=1        # at least one file actually changed — the strongest "work happened" signal
MIN_BASH=8         # ...or heavy shell use, which is what pure-debugging sessions look like
MIN_TRANSCRIPT=12  # assistant/user message count; filters out trivially short exchanges

STATE_DIR="${SECOND_BRAIN_STATE_DIR:-$HOME/.claude/second-brain-state}"

# --- Kill switch --------------------------------------------------------------------------
[ "${SECOND_BRAIN_HOOK_DISABLED:-0}" = "1" ] && exit 0

command -v jq >/dev/null 2>&1 || exit 0   # no jq → stay silent rather than guess

input=$(cat)

# stderr is suppressed throughout: malformed input must produce silence, not a visible error.
session_id=$(printf '%s' "$input"  | jq -r '.session_id       // empty' 2>/dev/null)
transcript=$(printf '%s' "$input"  | jq -r '.transcript_path  // empty' 2>/dev/null)
stop_active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)

# --- Loop guard ---------------------------------------------------------------------------
# When we block a stop, the model runs again and Stop fires again. Without this the session
# would never terminate.
[ "$stop_active" = "true" ] && exit 0

[ -n "$session_id" ] || exit 0
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# --- Per-session cap ----------------------------------------------------------------------
# references/interruption-policy.md caps unprompted proposals per session. The marker is
# written BEFORE emitting the block, so a crash downstream still cannot cause a loop.
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
marker="$STATE_DIR/${session_id}.fired"
[ -e "$marker" ] && exit 0

# --- Cheap work gate ----------------------------------------------------------------------
# Count tool calls in the JSONL transcript. This is a "did work happen" question, not a
# "was it valuable" question — value is the engine's job.
counts=$(jq -rs '
  [ .[]
    | select(type == "object")
    | .message?.content? // []
    | if type == "array" then .[] else empty end
    | select(type == "object" and .type == "tool_use")
    | .name
  ] as $tools
  | {
      edits: ([ $tools[] | select(. == "Edit" or . == "Write" or . == "NotebookEdit") ] | length),
      bash:  ([ $tools[] | select(. == "Bash") ] | length),
      msgs:  length
    }
  | "\(.edits) \(.bash) \(.msgs)"
' "$transcript" 2>/dev/null) || exit 0

read -r edits bash_calls _msgs <<< "$counts"
msgs=$(wc -l < "$transcript" 2>/dev/null | tr -d ' ')

: "${edits:=0}"; : "${bash_calls:=0}"; : "${msgs:=0}"

[ "$msgs" -ge "$MIN_TRANSCRIPT" ] || exit 0
[ "$edits" -ge "$MIN_EDITS" ] || [ "$bash_calls" -ge "$MIN_BASH" ] || exit 0

# --- Fire ---------------------------------------------------------------------------------
touch "$marker" 2>/dev/null || exit 0

# `decision: block` keeps the turn alive and hands `reason` to the model as its instruction.
# The instruction deliberately restates the two invariants the hook must not erode: the engine
# decides (not the hook), and silence is a valid, common outcome.
jq -nc '{
  decision: "block",
  reason: (
    "A Stop hook from the Developer Second Brain plugin fired. The session just ended and it " +
    "contained real development work (file edits or heavy shell use), so evaluate — once — " +
    "whether any of it is worth recording.\n\n" +
    "Run the `second-brain` skill now: apply its eligibility gate, build the Evidence object, " +
    "derive the documentation Assessment, then apply references/interruption-policy.md to " +
    "decide propose / hold / silent.\n\n" +
    "CRITICAL:\n" +
    "- Staying silent is the correct and most common outcome. This hook only detected that " +
    "work happened; it did NOT judge that the work is valuable. Do not treat it as a hint " +
    "that something should be recorded.\n" +
    "- If the gate rejects or the policy says hold/silent, end the turn immediately with no " +
    "commentary. Do not tell the user the hook ran, and do not explain why you stayed silent.\n" +
    "- Never write to the vault without explicit user approval. Propose only; wait for the answer.\n" +
    "- This fires at most once per session, so do not schedule a re-check."
  )
}'
