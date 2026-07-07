# Interruption Policy — confidence and the propose / hold / silent decision

This reference drives pipeline stages ④ (confidence) and ⑤ (interruption decision). Confidence
and the decision are judgments of the `documentation` Assessment, **derived from the Evidence
object** (`detection-rules.md`). Keeping this out of SKILL.md preserves the thin orchestrator.

## Confidence (Assessment field) — three levels

Confidence is separate from importance. Importance asks "is this valuable?"; confidence asks
"are we sure, and is it finished?" Derive it from the Evidence:

- **Boundary completeness** — read `evidence.resolution`:
  - `confirmed` → supports high confidence.
  - `partial` / `none` → caps confidence at **low** (the work isn't finished).
- **Judgment reliability** — how corroborated are the signals?
  - One thin signal, or conflicting signals → **low**.
  - Two independent signals with concrete support → **medium**.
  - Several independent signals, concrete support, clear type → **high**.

Take the lower of the two readings. A ⭐⭐⭐⭐ event caught mid-debug (`resolution: none`) is
**low** confidence and must not interrupt.

## Interruption decision (stage ⑤) — the table

Timing = "are we at a natural boundary?" (problem resolved, task done, user changed topic).

| Situation | Action |
|-----------|--------|
| `explicit_request: true` / `/document` | **Propose** (bypass gates; approval still required to write) |
| importance ≥⭐⭐⭐ · confidence high · at a boundary | **Propose** once, in Korean |
| importance ≥⭐⭐⭐ · confidence low (mid-task / ambiguous) | **Hold** — re-evaluate at the next boundary |
| importance ⭐⭐ | **Stay silent** proactively (surfaces only if the user asks) |
| importance ⭐ | **Stay silent** |
| Topic already in the vault, or declined this session | **Stay silent** |
| Per-session proposal cap reached | **Stay silent** until the user opts back in |

Fewer than **2 independent signals** (and no explicit request) → never an unprompted proposal,
regardless of the table.

## De-duplication

Before proposing, check whether the topic is already recorded in the vault (see
`vault-layout.md` for where documents live). If it is, stay silent — or note it once
("이미 기록돼 있어요"), never re-propose.

## Per-session cooldown

- After the user **declines** a proposal, do not re-raise that topic in the same session.
- Cap unprompted proposals per session; once reached, stay silent unless the user asks.
- An explicit request (`/document`) always overrides the cooldown and cap — the user is in
  control.

## Rendered explanation

When the action is **propose**, the one-line Korean reason shown to the user is **rendered from
`evidence.contributing_signals`** — e.g. signals `difficulty` + `domain(auth)` →
"여러 번의 시도 끝에 원인 규명 + 인증 도메인". Do not write an explanation that isn't grounded in
the Evidence.
