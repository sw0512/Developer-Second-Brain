# Developer Second Brain — v0.1.0

First public release. This is an early MVP: it does one thing — help you capture engineering
knowledge into a local vault, with your approval. Everything else on the roadmap is not built
yet.

## Vision

Developer Second Brain is a Personal Knowledge Management framework for Claude Code. It is not
a Notion automation tool — it is a system for turning your development experience into a lasting
asset. As you build, it recognizes moments worth recording (a hard bug, a technology choice, an
architecture change), and — only with your confirmation — writes them up as engineering docs
that accumulate into portfolio and interview material over time.

Every decision in the project answers one question: *"Does this help the developer accumulate
knowledge?"*

## What v0.1 provides

- **The `second-brain` skill** — a "Documentation Engineer" workflow: judge whether work is
  worth recording → pick a document type → score its importance (⭐1–5) → propose it in Korean →
  write it **only after you approve**.
- **Six document types**, each with a Korean template: Troubleshooting, ADR, TIL,
  Retrospective, Resume Material, Study Note.
- **`/document` command** — trigger the same workflow manually, including for earlier work.
- **Local Markdown vault** — documents are written to `~/DeveloperSecondBrain/` (override with
  `SECOND_BRAIN_VAULT`), one global vault across all your projects.
- **Two install paths** — a distributable Claude Code plugin (`/plugin install`) and a symlink
  dev workflow (`scripts/install-dev.sh`) for contributors.
- **Documentation** — README, architecture, philosophy, roadmap, a constitutional
  `PROJECT_PRINCIPLES.md`, and `CONTRIBUTING.md`.

## Key architectural decisions

- **Never auto-save.** Automation may propose; only the user approves a write. This is a hard,
  non-negotiable rule.
- **English prompts, Korean output.** Internal instructions are English; everything you read and
  every saved document is Korean.
- **The skill is a thin orchestrator.** SKILL.md decides *what to do*; detailed judgment lives in
  `references/*.md` loaded on demand, so the prompt doesn't grow into a monolith.
- **Storage is isolated behind one boundary.** All "where/how documents are stored" rules live in
  `references/vault-layout.md` alone, so the backend can change (local now, Notion later) without
  touching the skill.
- **Capture vs. generation are separate concerns.** Future features that *read* the vault
  (reports, interview prep) will be their own capabilities, not additions to the capture skill.
- **Source and data are separate.** The repo holds the system; your knowledge lives in an
  external vault.

## Repository structure

```
Developer-Second-Brain/
├── .claude-plugin/        # plugin manifest + marketplace metadata
├── skills/second-brain/   # the skill (self-contained)
│   ├── references/        #   detection rules · importance score · doc types · vault layout
│   └── templates/         #   six Korean document templates
├── commands/document.md   # /document command
├── scripts/               # install-dev.sh / uninstall-dev.sh (symlink dev workflow)
├── docs/                  # architecture · philosophy · roadmap
├── examples/              # a filled sample output
├── hooks/                 # (v0.4) placeholder for automatic triggers
├── PROJECT_PRINCIPLES.md  # constitutional design document
├── CONTRIBUTING.md · CHANGELOG.md · README.md · LICENSE
```

## Known limitations

- **Korean output only.** The system is designed around Korean documents; other languages are
  not supported yet.
- **No Notion integration.** The long-term store is a local vault for now. Notion sync is planned
  (v0.3), not present.
- **No automatic triggering.** The skill activates from its description or via `/document`; there
  are no hooks yet (v0.4), so capture is not fully hands-off.
- **Behavior is prompt-driven and not deterministic.** Type selection and importance scoring are
  judgment calls made by the model; results will vary.
- **`/document` availability differs by install path.** Present with the plugin install and with
  the dev symlink; a bare manual skill copy would not include it.
- **Unverified at scale.** This is an MVP validated on small, hand-run cases — not on a large body
  of real usage.

## Technical debt (deferred by design)

- **Storage is a documented contract, not a code adapter.** Appropriate while behavior is
  prompt-driven; a formal adapter arrives with Notion (v0.3).
- **`hooks/` is a placeholder** (README only) that communicates the v0.4 seam; it has no runtime
  effect yet.
- **No automated/eval tests.** Meaningful tests here are behavioral evals, deferred beyond v0.1.

See `CHANGELOG.md` for the detailed change list and `PROJECT_PRINCIPLES.md` for the reasoning
behind these choices.

## Roadmap for v0.2

v0.2 focuses on sharpening the core capture quality before adding new surfaces:

- More precise **Importance Score** calibration and clearer rationale in proposals.
- Better **document-type selection** accuracy, especially the troubleshooting/ADR boundary.
- Expanded detection-rule examples to reduce false "record this?" prompts.

Later versions: Notion integration (v0.3), hooks for automatic capture (v0.4), resume/STAR
generation (v0.5), and the full Second Brain — knowledge graph and reports (v1.0). See
`docs/roadmap.md`.

## Install

```bash
/plugin marketplace add sw0512/Developer-Second-Brain
/plugin install developer-second-brain
```

## License

MIT.
