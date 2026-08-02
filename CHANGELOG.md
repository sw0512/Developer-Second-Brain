# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project uses
the roadmap versions in `docs/roadmap.md`.

## [Unreleased]

### Added — `how-to`, the seventh type, and a closed type set
A real run classified four documents as `reference` — a type that has never existed. The
documents were procedures (extracting an API contract from backend source, running on MSW until
the backend deployed, wiring an OAuth data layer), and none of the six types fit: nothing broke,
so not `troubleshooting`; the comparison of alternatives was not the point, so not `adr`; and
they record what *this* project did rather than explaining a technology, so not `study-note`.

Two defects, fixed separately. The gap is real, so `how-to` is now a type. But inventing one at
write time is its own failure — `vault-layout.md` creates the folder on demand, so an invented
name becomes a permanent folder with no template and no reader.

- `templates/how-to.md`: 상황 → 절차 → 확인 → 되돌리기/제거 → 주의점 → 배운 점. "되돌리기" is
  there because a procedure that stands up temporary scaffolding (a mock, a dev proxy) is not
  finished until the note says when to take it down.
- `references/doc-types.md` states the table is a closed set, and adds tie-breakers against
  `troubleshooting` (did something break?), `study-note` (whose knowledge is it?), and `adr`
  (is the choice the point, or one line inside a procedure?).
- `references/vault-layout.md` records *why* the set must be closed — the folder-on-demand rule
  is what makes an invented type permanent.

### Added — the project axis, as metadata
Documents now carry a `project` field in their frontmatter. The vault keeps exactly one
directory level (type); a project never becomes a folder. Landing this before the v0.3 Notion
sync is deliberate — a project maps to a Notion property, so a folder would have to be
flattened at sync time. Rationale in `docs/backlog.md` §1.

- `project` added to all six templates, between `date` and the type-specific fields.
- `references/vault-layout.md` is the single home for the rule: why it is a field and not a
  folder, and how the name is derived (`git remote` origin repo name → repo/working directory
  basename → `unknown`, name kept verbatim, never invented).
- `SKILL.md` step 5 fills the field from that rule; `docs/architecture.md` metadata contract
  and `examples/` sample updated to match.

### Changed — v0.4.1: the trigger goes silent
v0.4 shipped and was reverted within a minute of real use. The Stop hook reached a correct
proposal — detection was never the failure. The failure was the channel: Claude Code renders a
blocked Stop's `reason` to the user, so the instruction telling the model to stay quiet was
itself printed on screen at every fire. There was no silent path to have.

Structural, not tunable: `Stop` is not a member of Claude Code's `hookSpecificOutput` union, so
a Stop hook cannot use `additionalContext` — the channel that reaches the model without
reaching the user. `PostToolUse` is a member.

- `hooks/detect-on-stop.sh` → `hooks/detect-on-edit.sh`: `PostToolUse` on
  `Edit|Write|NotebookEdit`, emitting `hookSpecificOutput.additionalContext`. Nothing is
  rendered to the user; acting on the note is the model's choice and silence leaves no trace.
- Cooldown is keyed on the **project path**, not `session_id`. The second v0.4 defect: one
  stretch of work spans several sessions (a background job and the interactive session have
  different ids), so a per-session cap still fired repeatedly — two markers, one piece of work.
  Sessions sharing a working directory now share one 6-hour cooldown.
- `MIN_EDITS` 1 → 3, since `PostToolUse` fires per edit and one stray edit should not arm it.
  `MIN_BASH` dropped: the matcher already scopes this to editing work.
- Cooldown is checked before the transcript scan, so an armed project costs one `stat` (0.05s)
  instead of a full scan (0.08s on 2MB) at every subsequent edit.
- `hook-wiring.py` sweeps both `PostToolUse` and `Stop`, so upgrading removes the v0.4
  registration instead of leaving it firing alongside the new one.
- `tests/hook-gate.sh` — 20 assertions. New: **the output must contain no user-visible channel**
  (`decision` / `reason` / `systemMessage`). The v0.4 failure is now an assertion, not a
  design intention.

### Added — v0.4 Hooks: the missing trigger
The detection engine was complete but effectively unreachable. A skill is model-invoked, and
this one's trigger condition ("after you finish solving a problem") maps to no user request —
so nothing ever prompted the judgment and only `/document` reached it. v0.4 supplies the
trigger. Pulled ahead of v0.3 (Notion): syncing a vault is pointless while the vault stays
empty.

- `hooks/detect-on-stop.sh` — `Stop` hook. Cheap gate (edits ≥1 **or** Bash ≥8, **and**
  ≥12 messages) → `decision: block` handing the model an instruction to run the engine.
  Fires at most once per session.
- Gate reads the transcript against its **real** shape, verified on live sessions: counts
  entries carrying `.message` rather than raw lines (a sample session had 564 lines vs 309
  messages — line counting silently loosened the gate), tolerates string-typed `content`, and
  streams instead of slurping (149MB transcript: 516MB → 3.3MB RSS; 2MB transcript: 0.05s).
- **Separation of concerns held**: the hook answers only "did work happen?", never "is it
  valuable?" — value stays solely in `references/`. Its instruction says so explicitly, so a
  firing hook is never read as evidence for `should_document: true`.
- **Safety**: loop guard via `stop_hook_active`, marker written before firing, stderr
  suppressed, silent `exit 0` on every unexpected condition. A missed proposal is recoverable
  via `/document`; a broken Stop hook is not.
- `hooks/hooks.json` for plugin installs; `scripts/hook-wiring.py` registers it in
  `~/.claude/settings.json` for symlink dev installs (idempotent, backs up, preserves
  unrelated hooks, refuses malformed JSON). Wired by `install-dev.sh`, removed by
  `uninstall-dev.sh`.
- `tests/hook-gate.sh` — 19 automated assertions over the gate and its safety guards. First
  automated tests in the project; `fixtures/` still cover engine judgment by hand.
- Session markers are pruned after 30 days on each fire — one file per session accumulated
  indefinitely otherwise.
- Hook is invoked as `bash <path>` (matching the first-party plugins) so a dropped executable
  bit cannot silently break it.
- Off switches: `SECOND_BRAIN_HOOK_DISABLED=1`, `install-dev.sh --no-hook`.
- `SKILL.md` gains a Triggers section covering both the hook and `/document`.

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
