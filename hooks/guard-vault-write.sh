#!/usr/bin/env bash
#
# Developer Second Brain — PreToolUse guard (v0.4.2)
#
# WHY THIS EXISTS
# ---------------
# PROJECT_PRINCIPLES §3.2 calls "never auto-save without user confirmation" the project's hard
# line, and §4 says the hook layer exists so "automation can never bypass the user-approval
# gate". Until now that was a *declaration*: SKILL.md step 4 told the model to propose and wait,
# and nothing enforced it.
#
# It failed in the field. A real session (2026-08-04) went: hook arms silently → model says
# "기록하겠습니다" → `Write` into the vault in the same turn, no proposal, no approval. What
# actually stopped it was Claude Code's own permission prompt — the harness, not this system.
# Under pre-approved Write or bypass mode the document would have landed unasked.
#
# This hook closes that path. It denies a *new* vault document unless the user has been shown
# where it would go and has spoken since.
#
# WHAT IT DOES NOT DO
# -------------------
# It never judges documentation value — that stays in references/, the single source of truth
# (same rule as detect-on-edit.sh). It judges *procedure only*: was there an approval turn?
#
# THE RULE
# --------
#   The target's filename must appear in ASSISTANT TEXT that precedes the most recent real
#   USER turn.
#
# Two properties make this the right test:
#
#   1. It is language-independent. Anchoring on the Korean proposal wording ("기록할까요?") would
#      break the moment the model paraphrases, and would put the proposal format in two homes.
#      The filename is data the model must emit anyway — SKILL.md's proposal block carries the
#      full 저장 위치 line.
#   2. The model cannot forge it. It can print anything it likes, but it cannot manufacture a
#      user turn *after* its own text. That single ordering constraint is the whole gate.
#
# Assistant TOOL INPUTS are deliberately not counted as "shown" — otherwise a denied Write would
# itself satisfy the rule on the next attempt, and the guard would only ever fire once.
#
# SCOPE: NEW DOCUMENTS ONLY
# -------------------------
# If the target already exists, the guard allows it. Two reasons: the principle at stake is
# about *creating a record* without consent, and SKILL.md step 6 (self-review) edits the file it
# just wrote, in the same turn, with no user in between. Guarding existing files would make the
# documented workflow unrunnable.
#
# FAILURE POSTURE: FAIL OPEN
# --------------------------
# Any unexpected condition exits 0, which means "no opinion" — Claude Code falls back to its
# normal permission prompt, the thing that caught the real failure. Failing *closed* would let a
# missing jq make the vault unwritable, which is a worse bug than the one being fixed. This
# guard raises the floor; it is not the last line of defence and does not claim to be.

set -uo pipefail
trap 'exit 0' ERR

# --- Kill switch ---------------------------------------------------------------------------
# Deliberately NOT SECOND_BRAIN_HOOK_DISABLED. That switch turns off proactivity — the nagging.
# This is an approval gate; someone silencing suggestions has not asked to lose the gate too.
[ "${SECOND_BRAIN_GUARD_DISABLED:-0}" = "1" ] && exit 0

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)

tool=$(printf '%s' "$input"  | jq -r '.tool_name           // empty' 2>/dev/null)
target=$(printf '%s' "$input"| jq -r '.tool_input.file_path// empty' 2>/dev/null)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)

case "$tool" in
  Write|Edit|NotebookEdit) ;;
  *) exit 0 ;;
esac
[ -n "$target" ] || exit 0

# --- Is the target inside the vault? --------------------------------------------------------
# Same resolution order as references/vault-layout.md: SECOND_BRAIN_VAULT, else ~/DeveloperSecondBrain.
VAULT="${SECOND_BRAIN_VAULT:-$HOME/DeveloperSecondBrain}"
VAULT="${VAULT%/}"
case "$target" in
  "$VAULT"/*) ;;
  *) exit 0 ;;      # not our business — every other file in the world is unaffected
esac

# --- New documents only ---------------------------------------------------------------------
[ -e "$target" ] && exit 0

[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# --- Was the path shown, and did the user speak after? ---------------------------------------
# Emitted as an ordered token stream, then reduced. Streaming (never `jq -s`) for the same
# reason detect-on-edit.sh streams: transcripts reach hundreds of MB.
#
# A "real user turn" excludes tool results, which also carry role "user". The test is that the
# entry has a text block (or bare-string content) and no tool_result block — that is what
# distinguishes a person typing from the harness reporting.
#
# Tool results are not the only impostor. Claude Code writes several kinds of *harness-authored*
# text into role "user" entries, and counting them would be worse than a missed approval — it
# would turn a refusal into a pass. The one that matters: pressing Esc on a proposed Write emits
#
#     {"message":{"role":"user","content":[{"type":"text","text":"[Request interrupted by user]"}]}}
#
# a plain user text block, indistinguishable by shape from a person typing "네 저장해줘". So
# "model proposes → user interrupts the write → model retries" would sail through the gate on the
# strength of the user's own *rejection*. The same applies to slash-command bookkeeping
# (`<command-name>`, `<local-command-stdout>`), injected notes (`isMeta`), and system reminders.
#
# So harness text is stripped and the entry counts only if a person's own words remain. Stripping
# rather than dropping the entry is deliberate: a real prompt typed alongside a slash command
# arrives in the *same* entry as the `<command-name>` block, and dropping it would lose a genuine
# approval. An unclosed or unknown wrapper survives the strip and counts — fail-open, as above.
name=$(basename "$target")

ok=$(jq -r --arg name "$name" '
  def strip_harness:
    gsub("<(?<t>command-name|command-message|command-args|local-command-stdout"
         + "|local-command-caveat|task-notification|system-reminder)>.*?</\\k<t>>"; ""; "m")
    | gsub("\\[Request interrupted[^]]*\\]"; "");

  select(.isSidechain != true)
  | select(.isMeta != true)
  | select(.message != null)
  | (.message.content // []) as $c
  | ($c | if type == "array" then . else [{type:"text", text:.}] end) as $blocks
  | if .message.role == "user"
    then ( if ($blocks | any(.type == "tool_result")) then empty
           elif ($blocks | any(.type == "text"
                               and ((.text | strip_harness | gsub("\\s"; "")) | length) > 0))
           then "USER"
           else empty end )
    elif .message.role == "assistant"
    then ( if ($blocks | any(.type == "text" and (.text | contains($name)))) then "SEEN"
           else empty end )
    else empty end
' "$transcript" 2>/dev/null | awk '
  $0 == "SEEN" { seen = 1 }
  $0 == "USER" { if (seen) ok = 1 }
  END { print ok + 0 }
') || exit 0

[ "$ok" = "1" ] && exit 0

# --- Deny -------------------------------------------------------------------------------------
# `permissionDecisionReason` on a denied PreToolUse reaches the MODEL, not the user's screen —
# so the correction is invisible, exactly like the detection note. tests/vault-write-guard.sh
# asserts no user-visible channel is emitted, the same assertion that guards the v0.4 regression.
jq -nc --arg name "$name" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: (
      "[Developer Second Brain] Blocked: `" + $name + "` has not been proposed to the user.\n\n" +
      "Never save automatically — the user is the final gate before anything is written " +
      "(SKILL.md, \"The one rule you must never break\").\n\n" +
      "Go back to SKILL.md step 4: show the proposal block, including the full 저장 위치 path, " +
      "and WAIT for the user to answer. Do not retry this write in the same turn. If the user " +
      "already approved in their own words, restate the target path and confirm once before " +
      "writing.\n\n" +
      "Do not mention this hook — present it as your own proposal."
    )
  }
}'
