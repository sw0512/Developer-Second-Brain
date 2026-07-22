#!/usr/bin/env bash
#
# Regression tests for hooks/detect-on-edit.sh
#
# The fixtures in tests/fixtures/ evaluate the *engine's judgment* (is this worth recording?).
# This file tests the layer underneath: the hook's cheap gate — does it arm only when a session
# plausibly contained development work, and does it stay silent on everything else?
#
# The rule under test is asymmetric, and so are the cases: arming wrongly costs the user a
# little model attention, but *failing in the wrong way* (a crash, a stderr leak, a user-visible
# message) breaks or pollutes their session. Most cases below are therefore negative.
#
# The v0.4 Stop-hook design died on exactly one of these: it was correct and still unusable,
# because its output channel was rendered to the user. "Never emits a user-visible channel" is
# now an assertion, not a design intention.
#
# Usage:  ./tests/hook-gate.sh          (exit 0 = all pass)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/hooks/detect-on-edit.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export SECOND_BRAIN_STATE_DIR="$TMP/state"

pass=0
fail=0

ok()   { printf '  ✅ %-46s %s\n' "$1" "${2:-ok}";   pass=$((pass + 1)); }
bad()  { printf '  ❌ %-46s %s\n' "$1" "${2:-}";     fail=$((fail + 1)); }

# jsonl <file> <count> <tool-or-"text"> [override-index] [override-tool]
jsonl() {
  python3 - "$@" <<'PY'
import json, sys
path, count, tool = sys.argv[1], int(sys.argv[2]), sys.argv[3]
oi = int(sys.argv[4]) if len(sys.argv) > 4 else -1
ot = sys.argv[5] if len(sys.argv) > 5 else None
with open(path, "w") as f:
    for i in range(count):
        name = ot if i == oi else tool
        block = ({"type": "text", "text": f"message {i}"} if name == "text"
                 else {"type": "tool_use", "name": name})
        f.write(json.dumps({"message": {"content": [block]}}) + "\n")
PY
}

# Real transcripts interleave non-message bookkeeping (snapshots, hook records, attachments)
# with messages, and a message's content may be a bare string. Both shapes broke earlier
# versions of the gate, so both are fixtures.
mixed_transcript() {
  python3 - "$1" <<'PY'
import json, sys
with open(sys.argv[1], "w") as f:
    for i in range(40):                      # bookkeeping — carries no .message
        f.write(json.dumps({"type": "snapshot", "uuid": f"u{i}"}) + "\n")
    for i in range(5):                       # only 5 real messages, 3 of them edits
        block = ({"type": "tool_use", "name": "Edit"} if i < 3
                 else {"type": "text", "text": "hi"})
        f.write(json.dumps({"message": {"content": [block]}}) + "\n")
PY
}

string_content_transcript() {
  python3 - "$1" <<'PY'
import json, sys
with open(sys.argv[1], "w") as f:
    for _ in range(30):
        f.write(json.dumps({"message": {"content": "plain string content"}}) + "\n")
    for _ in range(3):
        f.write(json.dumps({"message": {"content": [{"type": "tool_use", "name": "Edit"}]}}) + "\n")
PY
}

payload() { printf '{"transcript_path":"%s","cwd":"%s"}' "$1" "${2:-/proj/default}"; }

# check <expect: arm|silent> <label> <stdin-json>
# Captures stdout AND stderr: a hook that works but leaks to the terminal is a user-visible
# defect, so stderr noise fails too.
check() {
  local expect="$1" label="$2" data="$3" out got
  out=$(printf '%s' "$data" | bash "$HOOK" 2>&1)
  got="silent"; [ -n "$out" ] && got="arm"
  if [ "$got" = "$expect" ]; then ok "$label" "$expect"
  else bad "$label" "expected $expect, got $got"; [ -n "$out" ] && printf '     %.150s\n' "$out"; fi
}

echo "hook gate — arms only on real development work"

jsonl "$TMP/work.jsonl"     40 Read 5 Edit    # 40 messages, 1 edit
jsonl "$TMP/edits.jsonl"    40 Edit           # plenty of edits
jsonl "$TMP/qa.jsonl"       40 text           # conversation only
jsonl "$TMP/readonly.jsonl" 40 Read           # exploration only
jsonl "$TMP/short.jsonl"     6 Edit           # edits but too short a session

echo
echo "  positive — sustained editing work"
check arm    "many edits in a substantial session"  "$(payload "$TMP/edits.jsonl" /p/a)"

echo
echo "  negative — no work, or not enough of it"
check silent "one stray edit (below MIN_EDITS)"     "$(payload "$TMP/work.jsonl" /p/b)"
check silent "conversation only, zero tools"        "$(payload "$TMP/qa.jsonl" /p/c)"
check silent "read-only exploration"                "$(payload "$TMP/readonly.jsonl" /p/d)"
check silent "edits but session too short"          "$(payload "$TMP/short.jsonl" /p/e)"

echo
echo "  real-transcript shapes"
mixed_transcript "$TMP/mixed.jsonl"
string_content_transcript "$TMP/strcontent.jsonl"
# 45 raw lines but only 5 messages: counting lines instead of messages would wrongly arm here.
check silent "bookkeeping lines aren't messages"    "$(payload "$TMP/mixed.jsonl" /p/f)"
check arm    "string-typed message content"         "$(payload "$TMP/strcontent.jsonl" /p/g)"

echo
echo "  safety — must never break the session"
check silent "missing transcript file"              "$(payload "$TMP/nope.jsonl" /p/h)"
check silent "missing cwd"                          '{"transcript_path":"/tmp/x.jsonl"}'
check silent "empty object"                         '{}'
check silent "malformed json (no stderr leak)"      'not json at all'
check silent "empty stdin"                          ''

echo
echo "  cooldown is per PROJECT, not per session"
# v0.4's session-keyed cap failed here: a background job and the interactive session have
# different session ids, so one stretch of work fired more than once.
check arm    "first edit burst in a project"        "$(payload "$TMP/edits.jsonl" /p/shared)"
check silent "same project again (throttled)"       "$(payload "$TMP/edits.jsonl" /p/shared)"
check silent "same project, different session"      "$(payload "$TMP/edits.jsonl" /p/shared)"
check arm    "a different project is unaffected"    "$(payload "$TMP/edits.jsonl" /p/other)"

echo
echo "  kill switch"
SECOND_BRAIN_HOOK_DISABLED=1 \
  check silent "SECOND_BRAIN_HOOK_DISABLED=1"       "$(payload "$TMP/edits.jsonl" /p/off)"

echo
echo "  output contract — silent channel only"
out=$(printf '%s' "$(payload "$TMP/edits.jsonl" /p/json)" | bash "$HOOK" 2>/dev/null)
if printf '%s' "$out" | jq -e '.hookSpecificOutput.hookEventName == "PostToolUse"
                               and (.hookSpecificOutput.additionalContext | length > 0)' >/dev/null 2>&1
then ok "additionalContext on PostToolUse"
else bad "additionalContext on PostToolUse" "got: $(printf '%.120s' "$out")"; fi

# The v0.4 failure, encoded as an assertion: `decision`/`reason` is the channel Claude Code
# renders to the user. If either ever reappears, the silent design has regressed.
if printf '%s' "$out" | jq -e 'has("decision") or has("reason") or has("systemMessage")' >/dev/null 2>&1
then bad "no user-visible channel emitted" "decision/reason/systemMessage present"
else ok "no user-visible channel emitted"; fi

echo
echo "  state markers stay bounded"
touch -t 202001010000 "$SECOND_BRAIN_STATE_DIR/ancient.fired"
printf '%s' "$(payload "$TMP/edits.jsonl" /p/prune)" | bash "$HOOK" >/dev/null 2>&1
if [ ! -e "$SECOND_BRAIN_STATE_DIR/ancient.fired" ]
then ok "old markers pruned"
else bad "old markers pruned"; fi

echo
echo "── $pass passed, $fail failed"
[ "$fail" -eq 0 ]
