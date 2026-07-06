# Documentation Types — How to choose

Pick the single best-fit type. Each maps to a template in `templates/<type>.md` and a
subfolder in the vault.

| Type | Use when… | Template | Long-term value |
|------|-----------|----------|-----------------|
| `troubleshooting` | A specific bug/problem was diagnosed and solved | `troubleshooting.md` | High — great interview/portfolio material |
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

## STAR promotion (resume-material)

`resume-material` documents should be structured so they can expand into STAR:
**S**ituation · **T**ask · **A**ction · **R**esult. Capture measurable results where
possible (latency ↓, error rate ↓, throughput ↑, time saved).
