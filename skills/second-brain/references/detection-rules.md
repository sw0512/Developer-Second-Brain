# Detection Rules — Eligibility gate, observable signals, and Evidence construction

This reference drives pipeline stages ① (gate) and ② (Evidence extraction). Its sole output is
the **Evidence object**: observed, purpose-independent facts. It contains **no evaluation** and
makes **no proposal decision**. Importance, confidence, classification, and the explanation are
judgments owned by the Assessment (`importance-score.md`, `interruption-policy.md`,
`doc-types.md`); the propose / hold / silent decision is owned by `interruption-policy.md`.

**Purpose-independence invariant:** record only what is true of the conversation regardless of
why we are looking. Never phrase a rule here in terms of a downstream purpose (documentation,
resume, interview, portfolio) or of value. "Would this be observed the same whether documenting,
building a resume, or prepping an interview?" — if not, it does not belong in this file.

## Stage ① — Eligibility gate (hard exclusions, checked first)

If the work is clearly one of these, **stop silently** — do not extract Evidence:

- Typo fixes.
- Cosmetic CSS / styling tweaks.
- Simple syntax questions ("이 함수 문법이 뭐였지?").
- Trivial one-line changes with no decision behind them.

The gate is cheap and high-precision: reject obvious non-events before any further work.

## Stage ② — Observable signals

Signals are *categories of observation*, recognized semantically (not by keyword matching). Each
signal that fires is recorded with a **one-line factual `support`** — what was observed, quoted
or paraphrased from the conversation. This is the single, authoritative signal vocabulary; no
other list exists. Each description names only what is observable, never why it might matter
downstream.

- **A. Explicit intent** — the user asks to record ("기록해줘 / 정리해줘 / 문서로 남겨줘") or runs
  `/document`. Recorded as `explicit_request: true`.
- **B. Difficulty** — multiple failed attempts before resolution; long back-and-forth on one
  problem; a non-obvious cause; relief markers ("드디어 / 이게 문제였네").
- **C. Decision** — alternatives compared ("X vs Y"), trade-offs stated, an explicit choice with
  reasons.
- **D. Novelty** — a new library/framework/tool introduced or adopted; a first-time integration;
  a self-contained thing newly learned.
- **E. Domain** — work touching authentication, DB schema, API design, performance, architecture,
  caching, or security.
- **F. Resolution** — observations that the event is complete: tests passing after failing, a fix
  confirmed working, "됐다 / 해결", a milestone reached. Recorded as the `resolution` state.
- **G. Negative** — observations pushing toward silence: cosmetic/typo/syntax markers,
  mid-exploration with no resolution, the user still actively debugging, or a topic already
  present in the vault. Recorded in `negatives`.

## Evidence construction (stage ② output)

Emit exactly this structure — facts only:

```yaml
evidence:
  contributing_signals:
    - group: difficulty      # one of: difficulty | decision | novelty | domain
      support: "3 failed attempts before the 401 loop was traced to the filter chain"
    - group: decision
      support: "chose Redis over in-memory for refresh-token storage"
    - group: domain
      support: "authentication / session security"
  resolution: confirmed      # confirmed | partial | none   (from signal F)
  explicit_request: false    # true if signal A fired
  negatives: []              # any signal-G observations
```

Signals A, F, and G are recorded in the dedicated fields (`explicit_request`, `resolution`,
`negatives`); only B / C / D / E appear under `contributing_signals`.

### Construction guardrails (non-negotiable)

1. **Qualitative, not numeric.** Each signal carries natural-language `support` only — never a
   numeric weight or score. Corroboration is expressed by how many independent signals fired,
   not by a number.
2. **One vocabulary.** Use only the groups above. New signal types are added *here*, never as a
   parallel list elsewhere.
3. **Lean.** Record only signals that actually fired. Evidence is a compact record, not an essay.
4. **Facts only.** No importance, confidence, type, explanation, or downstream-purpose language
   in Evidence — those are the Assessment.

## Recognizing a signal (inclusion / exclusion)

Fire a signal only on a concrete, observable basis — not on any guess about downstream value:

- Was there an observable difficulty (failed attempts, a non-obvious cause)? → B
- Were alternatives or trade-offs explicitly discussed and a choice made? → C
- Was something new introduced, adopted, or learned? → D
- Did the work touch one of the listed domains? → E
- Is there an observation that the work is finished? → F (`resolution`)
- Is there an observation pushing toward silence? → G (`negatives`)

When in doubt, lean toward *not* firing a signal — a false signal is costlier than a missed one.

Whether a proposal is ultimately made from this Evidence (signal count, resolution state, etc.)
is decided elsewhere, by `interruption-policy.md`. This file does not make that decision.
