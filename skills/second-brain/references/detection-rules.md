# Detection Rules — When to record, when to stay silent

Documentation has a cost: the user's attention. Spend it only when the engineering
substance justifies it.

## Record (propose documentation)

- A hard or non-obvious bug was solved (root cause was not immediately clear).
- A new library, framework, or tool was adopted.
- A technology choice was made between real alternatives.
- A performance improvement was achieved or measured.
- Authentication / authorization was implemented (JWT, OAuth, sessions, RBAC…).
- A database schema / data model was designed or significantly changed.
- An API was designed (contracts, versioning, pagination, error model…).
- An architecture change was made (new layer, service split, caching strategy…).
- A project milestone was reached.
- The user explicitly says "이거 기록해줘 / 정리해줘 / 문서로 남겨줘".

## Do NOT record (stay silent — do not nag)

- Typo fixes.
- Cosmetic CSS / styling tweaks.
- Simple syntax questions ("이 함수 문법이 뭐였지?").
- Trivial one-line changes with no decision behind them.
- Restating something already documented in this vault without new insight.

## Judgment heuristics

Ask yourself:
1. **Would the user want to re-read this in 6 months?**
2. **Could this become an interview answer or a portfolio bullet?**
3. **Did we make a decision, or overcome a real difficulty?**

If none are "yes", stay silent. When in doubt, lean toward *not* interrupting —
a false "record this?" is more annoying than a missed low-value note.
