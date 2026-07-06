# Importance Score — Rating a record's value

Assign a ⭐1–5 score. This drives how strongly you recommend recording, and later
(future versions) feeds the Resume Score.

| Score | Meaning | Your action |
|-------|---------|-------------|
| ⭐ | Not worth recording | Stay silent |
| ⭐⭐ | Minor — a short TIL at most | Offer briefly, don't push |
| ⭐⭐⭐ | Worth saving | Recommend recording |
| ⭐⭐⭐⭐ | Strongly worth saving | Actively recommend |
| ⭐⭐⭐⭐⭐ | Must save — high interview/portfolio value | Strongly recommend |

## Scoring dimensions

Weigh these to land on a score:

1. **Difficulty** — how hard was the problem / decision? (obvious → non-obvious → deep)
2. **Reusability** — will this recur, or teach a transferable lesson?
3. **Interview value** — does it answer "왜 X를 선택했나요?" style questions?
4. **Portfolio value** — does it demonstrate measurable impact or notable skill?
5. **Decision content** — was a real trade-off navigated (vs. a mechanical fix)?

## Calibration examples

- Fixing a typo in a variable name → ⭐
- Learning a new `git` flag → ⭐⭐ (TIL)
- Debugging a flaky test caused by a timezone assumption → ⭐⭐⭐
- Choosing Redis over in-memory cache for refresh-token storage, with reasoning → ⭐⭐⭐⭐
- Designing the auth architecture (JWT + refresh rotation) and solving a 401 loop that
  blocked release → ⭐⭐⭐⭐⭐

Always state the score with a **one-line Korean rationale** in the proposal, e.g.
`중요도: ⭐⭐⭐⭐ (기술 선택의 근거가 명확해 면접 소재로 강함)`.
