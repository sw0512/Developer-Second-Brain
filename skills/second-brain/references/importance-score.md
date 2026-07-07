# Importance Score — the value judgment of the documentation Assessment

This reference drives the **importance** field of the `documentation` Assessment (pipeline
stage ③). It reads the **Evidence object** (`detection-rules.md`) — the contributing signals and
resolution — and does **not** re-inspect the raw conversation. Importance is a judgment; it
lives in the Assessment, never in Evidence.

## Scoring method

Rubric-anchored holistic judgment: score holistically, but constrained by explicit dimensions
and calibration anchors so ⭐ levels mean the same thing every time. **No numeric per-signal
weighting** — that would be false precision. Weigh the Evidence qualitatively.

| Score | Meaning | Recommendation strength |
|-------|---------|-------------------------|
| ⭐ | Not worth recording | — (stay silent) |
| ⭐⭐ | Minor — a short TIL at most | Offer briefly, don't push |
| ⭐⭐⭐ | Worth saving | Recommend |
| ⭐⭐⭐⭐ | Strongly worth saving | Actively recommend |
| ⭐⭐⭐⭐⭐ | Must save — high interview/portfolio value | Strongly recommend |

## Dimensions (weigh from the Evidence signals)

1. **Difficulty** — how hard was the problem/decision? (signal B)
2. **Reusability** — will it recur or teach a transferable lesson? (signals B/D)
3. **Interview value** — does it answer "왜 X를 선택했나요?" style questions? (signals C/E)
4. **Portfolio value** — measurable impact or notable skill? (signals E, esp. performance)
5. **Decision content** — a real trade-off navigated vs. a mechanical fix? (signal C)

## Calibration anchors (map Evidence → score)

- **⭐** — no substantive signals; gate-adjacent. *e.g.* renamed a variable.
- **⭐⭐** — a single `novelty` signal, small and self-contained. *e.g.* learned a new `git`
  flag. `resolution: confirmed` but low reuse.
- **⭐⭐⭐** — one solid signal with real substance, or two weak ones. *e.g.* `difficulty` +
  `resolution: confirmed` on a flaky test caused by a timezone assumption.
- **⭐⭐⭐⭐** — a strong signal mix, typically `decision` or `difficulty` **plus** `domain`.
  *e.g.* chose Redis over in-memory for refresh tokens with clear reasons (`decision` +
  `domain`), or a measured performance win (`domain=performance` + `resolution`).
- **⭐⭐⭐⭐⭐** — multiple strong corroborating signals in a high-value domain with confirmed
  resolution and clear interview/portfolio value. *e.g.* designed JWT + refresh rotation and
  solved a release-blocking 401 loop (`difficulty` + `decision` + `domain=auth` + `resolution:
  confirmed`).

## Output

Set the Assessment's `importance` (⭐1–5). The user-facing one-line reason is the Assessment's
`explanation`, **rendered from the Evidence signals** (see `interruption-policy.md` and the
skill workflow) — do not compose a separate rationale here.
