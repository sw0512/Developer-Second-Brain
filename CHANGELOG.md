# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project uses
the roadmap versions in `docs/roadmap.md`.

## [Unreleased]

### Added — document quality rules (from dogfooding a saved troubleshooting doc)
- `references/writing-rules.md` — how a saved document is written, so it stays actionable
  without the originating conversation: self-contained snippets (R1), rationale for every
  tuned number including an honest "tuned by eye" (R2), explicit coupling between co-tuned
  values (R3), consistent naming (R4), no invented detail (R5).
- **Self-review pass** as workflow step 6 in `SKILL.md` — after writing, re-read the file
  against the writing-rules checklist and fix failures before confirming the save. Reading the
  source repo to fill in real constant values is the intended way to pass, not a shortcut.
- Template reminders inline where they bite: `troubleshooting.md` gains a constants block plus
  a "이 숫자들은 어떻게 정했나" section; `adr.md` gains "확정한 설정값"; `study-note.md` and
  `til.md` gain snippet-value hints.

### Added — v0.2 Documentation Detection Engine (per docs/design/v0.2-detection-engine.md)
- Evidence / Assessment separation with the purpose-independence invariant: Evidence holds
  observed, purpose-independent facts; the derived `documentation` Assessment holds the
  judgments (importance, confidence, classification, explanation).
- `references/interruption-policy.md` — 3-level confidence + propose/hold/silent decision table,
  vault de-duplication, and per-session cooldown.
- `tests/` — behavioral evaluation harness: README + 14 labeled fixtures (heavy on hard
  negatives), labeling Evidence and Assessment separately.

### Changed — v0.2
- `SKILL.md` workflow integrated with the 6-stage detection pipeline (gate → Evidence →
  Assessment → interruption decision → propose → write), staying a thin orchestrator.
- `references/detection-rules.md` rewritten into the eligibility gate + signal taxonomy +
  Evidence object (with guardrails) + "≥2 signals" and "resolution-required" rules.
- `references/importance-score.md` sharpened with calibration anchors, scoring from Evidence as
  part of the Assessment.
- Templates now carry `evidence:` and `assessment:` frontmatter; the loose `type`/`importance`
  fields were relocated into the Assessment (no duplication).

### Added
- `PROJECT_PRINCIPLES.md` — constitutional document defining the long-term architectural
  philosophy and non-negotiable principles.
- `RELEASE_NOTES.md` — v0.1.0 release notes.

### Changed (architecture audit against PROJECT_PRINCIPLES.md)
- Storage mechanics (paths, defaults, filename rules) now live **only** in
  `references/vault-layout.md`; `SKILL.md` delegates to it instead of restating them, so the
  orchestrator no longer knows the backend (§4/§5/§6/§7).
- Vault folders now always equal the type name — removed the `study-note` → `study-notes`
  special case and the type→folder lookup table (§5/§8).
- `/document` command delegates to the skill instead of re-listing the workflow (§5).
- Removed the duplicated plugin version from `marketplace.json`; `plugin.json` is the single
  source (§5).

## [0.1.0] — 2026-07-06

First MVP: the Documentation Skill.

### Added
- `second-brain` skill — the Documentation Engineer workflow: judge → select type →
  score → propose → (on approval) write.
- Six Korean document templates: troubleshooting, adr, til, retrospective,
  resume-material, study-note.
- On-demand references: detection rules, importance score, doc-type selection, vault layout.
- `/document` command for manual, on-demand recording.
- Local Markdown vault output (default `~/DeveloperSecondBrain/`, override via
  `$SECOND_BRAIN_VAULT`).
- Plugin packaging: `plugin.json` + `marketplace.json` for `/plugin install`.
- Dev symlink workflow: `scripts/install-dev.sh` / `scripts/uninstall-dev.sh`
  (links the skill and `/document` into `~/.claude`).
- Docs: architecture, philosophy, roadmap; a filled troubleshooting example; MIT license.

### Design guarantees
- Never auto-saves — every write requires explicit user approval.
- English prompts, Korean output.
- Skill is self-contained (references + templates inside the skill dir).
