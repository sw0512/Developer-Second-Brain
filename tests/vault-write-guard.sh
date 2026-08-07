#!/usr/bin/env bash
#
# Regression tests for hooks/guard-vault-write.sh
#
# The guard enforces one rule: a NEW vault document may be written only if its filename appeared
# in assistant TEXT before the most recent real user turn. Everything here tests that rule and
# the fail-open posture around it.
#
# Two asymmetries shape the case list, and both point the same way — most cases are denials:
#
#   * A wrong ALLOW writes a document the user never agreed to. That is the failure this hook
#     was built for (2026-08-04), so every way of faking an approval gets a case: assistant tool
#     inputs, tool results, and harness-authored user text.
#   * A wrong DENY only costs a turn — the model restates the path and asks. But a *crash* is
#     not a deny; it is an allow, because the guard fails open. So the malformed-input cases
#     assert allow, and they are asserting that nothing exploded on the way there.
#
# The last section replays the 2026-08-04 session that motivated the guard. Those transcripts are
# personal, so they are not committed and the document names here are placeholders — what is
# reproduced is the *shape* (which paths appeared in assistant text, and when), which is all the
# rule reads. The expectations are the measured results recorded in the ADR
# (adr/2026-08-07-vault-write-guard-strict-approval-rule.md), not guesses.
#
# Usage:  ./tests/vault-write-guard.sh          (exit 0 = all pass)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/hooks/guard-vault-write.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# A scratch vault, never the real one. The guard allows any file that already exists, so running
# against ~/DeveloperSecondBrain would mark every already-saved document "allow" and the suite
# would assert nothing.
VAULT="$TMP/vault"
mkdir -p "$VAULT/troubleshooting" "$VAULT/adr" "$VAULT/how-to"
export SECOND_BRAIN_VAULT="$VAULT"

pass=0
fail=0

ok()  { printf '  ✅ %-52s %s\n' "$1" "${2:-ok}"; pass=$((pass + 1)); }
bad() { printf '  ❌ %-52s %s\n' "$1" "${2:-}";   fail=$((fail + 1)); }

# transcript <file> <spec>...
#
# Each spec is <kind>:<payload>, in conversation order:
#   u:TEXT        a person typing
#   a:TEXT        assistant text (the only thing that can "show" a path)
#   tool:PATH     assistant tool_use with a file_path — deliberately NOT proof of showing
#   result:TEXT   a tool_result — role "user", but the harness talking
#   meta:TEXT     an injected note (isMeta), e.g. a skill preamble
#   side:TEXT     a subagent's user turn (isSidechain) — not this conversation's user
transcript() {
  local file="$1"; shift
  python3 - "$file" "$@" <<'PY'
import json, sys
path, specs = sys.argv[1], sys.argv[2:]
def entry(kind, payload):
    if kind == "u":
        return {"message": {"role": "user", "content": [{"type": "text", "text": payload}]}}
    if kind == "a":
        return {"message": {"role": "assistant", "content": [{"type": "text", "text": payload}]}}
    if kind == "tool":
        return {"message": {"role": "assistant", "content": [
            {"type": "tool_use", "name": "Write", "input": {"file_path": payload}}]}}
    if kind == "result":
        return {"message": {"role": "user", "content": [
            {"type": "tool_result", "content": payload}]}}
    if kind == "meta":
        return {"isMeta": True,
                "message": {"role": "user", "content": [{"type": "text", "text": payload}]}}
    if kind == "side":
        return {"isSidechain": True,
                "message": {"role": "user", "content": [{"type": "text", "text": payload}]}}
    raise SystemExit(f"unknown spec kind: {kind}")
with open(path, "w") as f:
    # Real transcripts interleave bookkeeping lines that carry no .message at all.
    f.write(json.dumps({"type": "summary", "summary": "session start"}) + "\n")
    for spec in specs:
        kind, _, payload = spec.partition(":")
        f.write(json.dumps(entry(kind, payload), ensure_ascii=False) + "\n")
PY
}

# payload <transcript> <file> [tool]
payload() {
  python3 -c 'import json,sys; print(json.dumps({"tool_name": sys.argv[1],
      "tool_input": {"file_path": sys.argv[2]}, "transcript_path": sys.argv[3]}))' \
    "${3:-Write}" "$2" "$1"
}

# check <expect: allow|deny> <label> <stdin-json>
# stderr counts as output: a guard that decides correctly but leaks to the terminal has still
# damaged the session.
check() {
  local expect="$1" label="$2" data="$3" out got
  out=$(printf '%s' "$data" | bash "$HOOK" 2>&1)
  got="allow"; [ -n "$out" ] && got="deny"
  if [ "$got" = "$expect" ]; then ok "$label" "$expect"
  else bad "$label" "expected $expect, got $got"; [ -n "$out" ] && printf '     %.150s\n' "$out"; fi
}

DOC="$VAULT/troubleshooting/2026-08-07-jwt-refresh-401-loop.md"
NAME="2026-08-07-jwt-refresh-401-loop.md"
PROPOSAL="기록할 만한 내용이 있습니다.

저장 위치: ~/DeveloperSecondBrain/troubleshooting/$NAME"

echo "vault write guard — a new document needs an approval turn"

echo
echo "  the rule"
transcript "$TMP/approved.jsonl" \
  "u:리프레시 토큰 401 무한루프 원인 찾았어" "a:원인은 만료 판정 순서였습니다" \
  "a:$PROPOSAL" "u:응 저장해줘"
check allow "proposal, then the user answers"           "$(payload "$TMP/approved.jsonl" "$DOC")"

transcript "$TMP/silent.jsonl" \
  "u:리프레시 토큰 401 무한루프 원인 찾았어" "a:원인은 만료 판정 순서였습니다" \
  "a:기록해두겠습니다"
check deny  "path never shown to the user"              "$(payload "$TMP/silent.jsonl" "$DOC")"

# The 2026-08-04 failure verbatim: the proposal and the write land in one turn, so the user never
# got a chance to answer between them.
transcript "$TMP/sameturn.jsonl" \
  "u:이거 해결됐네" "a:$PROPOSAL"
check deny  "declared and written in the same turn"      "$(payload "$TMP/sameturn.jsonl" "$DOC")"

transcript "$TMP/stale.jsonl" \
  "a:$PROPOSAL" "u:응 저장해줘" "u:아니 잠깐, 다른 얘기부터 하자"
check allow "approval still counts after later chatter"  "$(payload "$TMP/stale.jsonl" "$DOC")"

echo
echo "  what does not count as showing the path"
# Without this, a denied Write becomes the evidence that unlocks the retry, and the guard fires
# exactly once per session — ever.
transcript "$TMP/toolinput.jsonl" \
  "u:정리해줘" "tool:$DOC" "u:다시 해봐"
check deny  "assistant tool input is not 'shown'"        "$(payload "$TMP/toolinput.jsonl" "$DOC")"

transcript "$TMP/toolresult.jsonl" \
  "a:$PROPOSAL" "result:File created at $DOC"
check deny  "tool_result is not a user turn"             "$(payload "$TMP/toolresult.jsonl" "$DOC")"

transcript "$TMP/sidechain.jsonl" \
  "a:$PROPOSAL" "side:네 저장하세요"
check deny  "a subagent's user turn is not the user"     "$(payload "$TMP/sidechain.jsonl" "$DOC")"

echo
echo "  harness-authored user text is not approval"
# The sharpest case in the suite: Esc on the proposed write emits a plain user text block. Read
# naively it is a *rejection* being counted as consent.
transcript "$TMP/interrupt.jsonl" \
  "a:$PROPOSAL" "tool:$DOC" "u:[Request interrupted by user for tool use]"
check deny  "[Request interrupted] after the proposal"   "$(payload "$TMP/interrupt.jsonl" "$DOC")"

transcript "$TMP/interrupt2.jsonl" "a:$PROPOSAL" "u:[Request interrupted by user]"
check deny  "[Request interrupted by user]"              "$(payload "$TMP/interrupt2.jsonl" "$DOC")"

transcript "$TMP/slashonly.jsonl" \
  "a:$PROPOSAL" "u:<command-name>/model</command-name><local-command-stdout>Set model</local-command-stdout>"
check deny  "slash-command bookkeeping alone"            "$(payload "$TMP/slashonly.jsonl" "$DOC")"

transcript "$TMP/metanote.jsonl" "a:$PROPOSAL" "meta:Base directory for this skill: /x/y"
check deny  "injected note (isMeta)"                     "$(payload "$TMP/metanote.jsonl" "$DOC")"

transcript "$TMP/reminder.jsonl" \
  "a:$PROPOSAL" "u:<system-reminder>background context</system-reminder>"
check deny  "system-reminder only"                       "$(payload "$TMP/reminder.jsonl" "$DOC")"

# The other half of the same rule. A person's words ride in the SAME entry as the command
# bookkeeping, so dropping such entries wholesale would throw away real approvals.
transcript "$TMP/slashplus.jsonl" \
  "a:$PROPOSAL" "u:<command-name>/document</command-name>이거 저장해줘"
check allow "real words alongside a slash command"       "$(payload "$TMP/slashplus.jsonl" "$DOC")"

echo
echo "  scope — what the guard leaves alone"
EXISTING="$VAULT/adr/2026-08-07-already-here.md"
: > "$EXISTING"
transcript "$TMP/none.jsonl" "u:고쳐줘"
# SKILL.md step 6 edits the file it just wrote, in the same turn. Guarding existing files would
# make the documented workflow unrunnable.
check allow "existing file (self-review edit)"           "$(payload "$TMP/none.jsonl" "$EXISTING")"
check allow "path outside the vault"                     "$(payload "$TMP/none.jsonl" "$TMP/elsewhere/notes.md")"
check allow "a vault-shaped path outside it"             "$(payload "$TMP/none.jsonl" "${VAULT}-backup/x.md")"
check allow "non-write tool"                             "$(payload "$TMP/none.jsonl" "$DOC" Bash)"

echo
echo "  kill switches"
SECOND_BRAIN_GUARD_DISABLED=1 \
  check allow "SECOND_BRAIN_GUARD_DISABLED=1"            "$(payload "$TMP/silent.jsonl" "$DOC")"
# Silencing the suggestions must not silence the gate — one asks, the other enforces.
SECOND_BRAIN_HOOK_DISABLED=1 \
  check deny  "SECOND_BRAIN_HOOK_DISABLED does not apply" "$(payload "$TMP/silent.jsonl" "$DOC")"

echo
echo "  fail open — never make the vault unwritable"
check allow "missing transcript file"                    "$(payload "$TMP/gone.jsonl" "$DOC")"
check allow "empty object"                               '{}'
check allow "malformed json (no stderr leak)"            'not json at all'
check allow "empty stdin"                                ''
check allow "no file_path"                               '{"tool_name":"Write","transcript_path":"/nope"}'
printf 'not { json\n' > "$TMP/corrupt.jsonl"
check allow "corrupt transcript lines"                   "$(payload "$TMP/corrupt.jsonl" "$DOC")"

echo
echo "  output contract — the model is told, the user is not"
out=$(printf '%s' "$(payload "$TMP/silent.jsonl" "$DOC")" | bash "$HOOK" 2>/dev/null)
if printf '%s' "$out" | jq -e '.hookSpecificOutput.hookEventName == "PreToolUse"
                               and .hookSpecificOutput.permissionDecision == "deny"
                               and (.hookSpecificOutput.permissionDecisionReason | length > 0)' >/dev/null 2>&1
then ok "deny on PreToolUse with a reason"
else bad "deny on PreToolUse with a reason" "got: $(printf '%.120s' "$out")"; fi

# Same assertion as hook-gate.sh, same reason: `decision`/`reason`/`systemMessage` is the channel
# Claude Code renders on screen. The v0.4 design was correct and unusable because of it.
if printf '%s' "$out" | jq -e 'has("decision") or has("reason") or has("systemMessage")' >/dev/null 2>&1
then bad "no user-visible channel emitted" "decision/reason/systemMessage present"
else ok "no user-visible channel emitted"; fi

# The reason has to name the file and point at the step to go back to, or the model cannot act on
# it — a deny it does not understand becomes a retry loop.
if printf '%s' "$out" | jq -e --arg n "$NAME" \
     '.hookSpecificOutput.permissionDecisionReason | contains($n) and contains("step 4")' >/dev/null 2>&1
then ok "reason names the file and the next step"
else bad "reason names the file and the next step"; fi

echo
echo "  replay — the 2026-08-04 session, rebuilt (expectations from the ADR)"
# Two documents from one approval. The proposal named only the how-to path; the troubleshooting
# filename first appeared in assistant text *after* it had been written. The user approved
# without ever seeing where the second document was going — the guard denying it is the rule
# working, not a false positive. See the ADR's 후보 A vs B.
FIRST="$VAULT/how-to/2026-08-04-first-doc.md"
SECOND="$VAULT/troubleshooting/2026-08-04-second-doc.md"
transcript "$TMP/replay.jsonl" \
  "u:이거 다 끝났다" \
  "a:저장 위치: ~/DeveloperSecondBrain/how-to/2026-08-04-first-doc.md" \
  "u:분리하면 총 3개인 건가?" "a:2개입니다" "u:아 그러면 2개로 해줘"
check allow "1551 — how-to, path was in the proposal"    "$(payload "$TMP/replay.jsonl" "$FIRST")"
check deny  "1564 — second doc, path never shown"        "$(payload "$TMP/replay.jsonl" "$SECOND")"

# The case the guard exists for: an approval with no path in sight anywhere.
THIRD="$VAULT/how-to/2026-08-04-third-doc.md"
transcript "$TMP/replay2.jsonl" \
  "u:아까 그 얘기도 있었지" "a:세 건이 후보입니다" "u:세 번째 건 바로 저장해줘"
check deny  "1970 — approved, but no path was restated"  "$(payload "$TMP/replay2.jsonl" "$THIRD")"

echo
echo "── $pass passed, $fail failed"
[ "$fail" -eq 0 ]
