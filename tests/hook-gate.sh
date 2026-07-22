#!/usr/bin/env bash
#
# Regression tests for hooks/detect-on-stop.sh
#
# The fixtures in tests/fixtures/ evaluate the *engine's judgment* (is this worth recording?).
# This file tests the layer underneath: the Stop hook's cheap gate — does it fire only when a
# session plausibly contained development work, and does it stay silent on everything else?
#
# The rule under test is asymmetric, and so are the cases: firing wrongly costs the user an
# interruption, but *failing silently in the wrong way* (a crash, a stderr leak, an infinite
# stop loop) breaks their session. Most cases below are therefore negative.
#
# Usage:  ./tests/hook-gate.sh          (exit 0 = all pass)

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$REPO_ROOT/hooks/detect-on-stop.sh"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export SECOND_BRAIN_STATE_DIR="$TMP/state"

pass=0
fail=0

# jsonl <file> <count> <tool-name-or-"text"> [override-index] [override-tool]
# Synthesizes a transcript of <count> lines, each carrying one tool_use (or plain text).
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

# check <expect: fire|silent> <label> <stdin-json>
# Captures stdout AND stderr: a hook that "works" but leaks an error message to the terminal
# is a user-visible defect, so stderr noise fails the test too.
check() {
  local expect="$1" label="$2" payload="$3"
  local out
  out=$(printf '%s' "$payload" | bash "$HOOK" 2>&1)
  local got="silent"; [ -n "$out" ] && got="fire"
  if [ "$got" = "$expect" ]; then
    printf '  ✅ %-42s %s\n' "$label" "$expect"
    pass=$((pass + 1))
  else
    printf '  ❌ %-42s expected %s, got %s\n' "$label" "$expect" "$got"
    [ -n "$out" ] && printf '     output: %.160s\n' "$out"
    fail=$((fail + 1))
  fi
}

payload() { printf '{"session_id":"%s","transcript_path":"%s","stop_hook_active":%s}' "$1" "$2" "${3:-false}"; }

echo "hook gate — fires only on real development work"

jsonl "$TMP/work.jsonl"     40 Read 5 Edit    # substantial session, one real edit
jsonl "$TMP/shell.jsonl"    40 Bash           # pure-debugging session, heavy shell
jsonl "$TMP/qa.jsonl"       40 text           # conversation only, no tools
jsonl "$TMP/readonly.jsonl" 40 Read           # exploration only, nothing changed
jsonl "$TMP/short.jsonl"     4 Read 1 Edit    # real edit but a trivially short session

echo
echo "  positive — work happened"
check fire   "edit in a substantial session"      "$(payload s-edit  "$TMP/work.jsonl")"
check fire   "heavy shell use (debugging)"        "$(payload s-shell "$TMP/shell.jsonl")"

echo
echo "  negative — no work, or not enough of it"
check silent "conversation only, zero tools"      "$(payload s-qa   "$TMP/qa.jsonl")"
check silent "read-only exploration"              "$(payload s-ro   "$TMP/readonly.jsonl")"
check silent "edit but session too short"         "$(payload s-sh   "$TMP/short.jsonl")"

echo
echo "  safety — must never break the session"
check silent "loop guard (stop_hook_active)"      "$(payload s-loop "$TMP/work.jsonl" true)"
check silent "missing transcript file"            "$(payload s-gone "$TMP/nonexistent.jsonl")"
check silent "missing session_id"                 '{"transcript_path":"/tmp/x.jsonl"}'
check silent "empty object"                       '{}'
check silent "malformed json (no stderr leak)"    'not json at all'
check silent "empty stdin"                        ''

echo
echo "  per-session cap — fires at most once"
check fire   "first stop of a new session"        "$(payload s-cap "$TMP/work.jsonl")"
check silent "second stop, same session"          "$(payload s-cap "$TMP/work.jsonl")"
check fire   "different session, unaffected"      "$(payload s-cap2 "$TMP/work.jsonl")"

echo
echo "  kill switch"
SECOND_BRAIN_HOOK_DISABLED=1 \
  check silent "SECOND_BRAIN_HOOK_DISABLED=1"     "$(payload s-off "$TMP/work.jsonl")"

echo
echo "  emitted payload is valid Stop-hook JSON"
out=$(printf '%s' "$(payload s-json "$TMP/work.jsonl")" | bash "$HOOK" 2>/dev/null)
if printf '%s' "$out" | jq -e '.decision == "block" and (.reason | length > 0)' >/dev/null 2>&1; then
  printf '  ✅ %-42s %s\n' "decision=block with non-empty reason" "ok"
  pass=$((pass + 1))
else
  printf '  ❌ %-42s got: %.120s\n' "decision=block with non-empty reason" "$out"
  fail=$((fail + 1))
fi

echo
echo "── $pass passed, $fail failed"
[ "$fail" -eq 0 ]
