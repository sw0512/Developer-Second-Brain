# Behavioral evaluation

The Detection Engine is prompt-driven and non-deterministic, so it is evaluated against
**labeled fixtures**, not unit tests. This directory is a first-class part of the project
(v0.2), not an afterthought.

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
