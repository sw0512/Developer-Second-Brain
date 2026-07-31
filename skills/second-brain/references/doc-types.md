# Documentation Types — How to choose

Pick the single best-fit type **from the table below**. Each maps to a template in
`templates/<type>.md` and a subfolder in the vault.

This table is a **closed set**. Never invent a type, and never adapt one by renaming it — a
type without a template has no output shape, and the vault's "folder name = type name"
invariant (`vault-layout.md`) turns the invented name into a permanent stray folder. If
nothing fits well, pick the closest row and record the strain in `alternates`; a genuinely
missing type is a change to this file, not a runtime decision.

| Type | Use when… | Template | Long-term value |
|------|-----------|----------|-----------------|
| `troubleshooting` | A specific bug/problem was diagnosed and solved | `troubleshooting.md` | High — great interview/portfolio material |
| `how-to` | A repeatable procedure was carried out — a setup, an integration, an implementation | `how-to.md` | Medium–High — saves the next run |
| `adr` | A technology/architecture decision was made between alternatives | `adr.md` | High — shows engineering judgment |
| `til` | A small, self-contained thing was learned | `til.md` | Low–Medium — quick note |
| `retrospective` | Reflecting on a task/sprint/project (what went well / poorly) | `retrospective.md` | Medium — growth tracking |
| `resume-material` | An experience worth turning into a resume / interview story | `resume-material.md` | Very high — STAR-ready |
| `study-note` | Structured notes on a technology (Spring, React, Redis, Docker, AI…) | `study-note.md` | Medium — reference knowledge |

## Tie-breakers

- **Bug + decision mixed** → if the story is "we hit X and chose Y", prefer `adr`;
  if it's "we hit X and here's the fix", prefer `troubleshooting`.
- **Strong interview value** → in addition to the primary type, mention that it could later
  be promoted to `resume-material` (STAR format). Do not create two docs unless asked.
- **Small learning** → `til`. Do not inflate a one-liner into a troubleshooting doc.
- **`how-to` vs `troubleshooting`** → did something *break*? If the story starts with a symptom
  and ends with a root cause, it is `troubleshooting`. If it starts with "I need X working" and
  ends with X working, it is `how-to` — even if steps went wrong along the way.
- **`how-to` vs `study-note`** → whose knowledge is it? `study-note` explains a technology in
  general ("what MSW is"); `how-to` records what *this* project actually did, with its real
  paths and values ("how we ran on MSW until the backend deployed").
- **`how-to` vs `adr`** → a setup usually contains a small choice. If the comparison of
  alternatives is the point, it is `adr`; if the choice is one line inside a procedure someone
  will re-run, it is `how-to` with the decision noted in "배운 점".

## STAR promotion (resume-material)

`resume-material` documents should be structured so they can expand into STAR:
**S**ituation · **T**ask · **A**ction · **R**esult. Capture measurable results where
possible (latency ↓, error rate ↓, throughput ↑, time saved).
