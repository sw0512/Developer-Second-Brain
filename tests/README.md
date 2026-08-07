# Behavioral evaluation

The Detection Engine is prompt-driven and non-deterministic, so it is evaluated against
**labeled fixtures**, not unit tests. This directory is a first-class part of the project
(v0.2), not an afterthought.

## Two layers, two kinds of test

| | What it tests | How |
|---|---|---|
| `fixtures/` | The engine's **judgment** — is this worth recording? | labeled fixtures, scored by hand |
| `hook-gate.sh` | The hook's **gate** — is it worth asking the engine at all? — and its **output contract** | `./tests/hook-gate.sh`, automated |
| `vault-write-guard.sh` | The approval gate — may this document be written at all? | `./tests/vault-write-guard.sh`, automated |

Both hooks are deterministic shell, so they get real assertions. Run `hook-gate.sh` after
touching `hooks/detect-on-edit.sh` — it covers the safety guards (malformed input, per-project
cooldown, marker pruning) that, if broken, would spam or slow a user's session.

Run `vault-write-guard.sh` after touching `hooks/guard-vault-write.sh`. It tests one rule — a new
vault document needs its filename shown in assistant text *before* the last real user turn — and
its case list is mostly denials, because the two error directions are not symmetric: a wrong
allow writes a document nobody agreed to, while a wrong deny costs one turn. Every way of faking
an approval is a case: assistant tool inputs, tool results, subagent turns, and harness-authored
user text such as `[Request interrupted by user]` (pressing Esc on the write — a *rejection* that
is shaped exactly like consent).

The guard fails open, so a crash reads as an allow, not a deny. That is why the malformed-input
cases assert allow: they are checking that nothing exploded on the way to that answer.

Its last section replays the 2026-08-04 session that motivated the guard. Real transcripts are
personal and are not committed, so those fixtures are rebuilt by hand — but their expectations
are the measured results recorded in the ADR, not guesses.

One assertion appears in both files for a specific reason: **a hook must emit no user-visible channel**
(`decision` / `reason` / `systemMessage`). The v0.4 Stop-hook design was correct and still
unusable, because Claude Code renders a blocked Stop's `reason` to the user — the instruction
telling the model to stay quiet was printed on screen every time. That is now a test, not an
intention.

## What a fixture is

Each file in `fixtures/` is a short, realistic conversation plus a **gold label**, split — per
the Evidence / Assessment separation — into:

- **Gold — Evidence** (facts): which signals should fire, `resolution`, `explicit_request`,
  `negatives`. These are objective and should have high inter-rater agreement.
- **Gold — Assessment** (judgment): `should_document`, `type` (+ alternates), an `importance`
  band (±1 ⭐), `confidence`, and the `expected_action` (propose / hold / silent).

Labeling the two separately is deliberate: it localizes failures. A wrong action caused by a
*missed fact* (Evidence) is a different fix than one caused by *mis-weighted judgment*
(Assessment).

## How to run and score (by hand)

For each fixture:

1. Feed the **Transcript** to the engine (the `second-brain` skill workflow), through the
   `documentation` Assessment and the interruption decision.
2. Compare the engine's output to the gold label:
   - **Evidence match** — did the right signals fire? Is `resolution` correct?
   - **Assessment match** — correct `should_document`, `type`, `importance` band, `confidence`,
     and `expected_action`?
3. Record pass/fail per fixture and note the failure mode.

## Metrics, in priority order

1. **Precision** on `should_document` — the headline. A false "record this?" is a defect.
2. **Recall** on clearly-valuable events — secondary; some misses are acceptable.
3. **Classification accuracy** — correct `type`.
4. **Score agreement** — within ±1 ⭐ of the gold band.

## Growing the set

Every real-world false positive becomes a new regression fixture here. Keep the set heavy on
**hard negatives** — the cases the engine most needs to get right.
