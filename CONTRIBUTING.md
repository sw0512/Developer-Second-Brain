# Contributing to Developer Second Brain

Thanks for your interest. This project has one guiding question — keep it in mind for every
change:

> **"Does this help the developer accumulate knowledge?"**

If a change doesn't build the user's long-term engineering asset, it probably doesn't belong.

For the deeper "why" behind every rule below, read [PROJECT_PRINCIPLES.md](PROJECT_PRINCIPLES.md)
— the project's constitutional document. This guide is the *practical how*; that one is the
*timeless why*, and it wins any tiebreak.

## Project shape

This repo is a **Claude Code plugin**. The important pieces:

```
skills/second-brain/   # the skill (behavior) + its own references/ and templates/
commands/document.md   # the /document slash command
.claude-plugin/        # plugin.json (manifest) + marketplace.json (distribution)
scripts/               # dev symlink install/uninstall
docs/                  # architecture, philosophy, roadmap
```

The skill is **self-contained**: `references/` and `templates/` live *inside*
`skills/second-brain/` so a single symlink makes the whole thing work. Never make a skill
file reach outside its own directory (no `../`), or the symlink dev flow breaks.

## Dev workflow (fast loop)

Use symlinks while developing — edits take effect on the next Claude Code run, no reinstall:

```bash
./scripts/install-dev.sh     # links the skill + /document into ~/.claude
# ...edit files, restart Claude Code, test...
./scripts/uninstall-dev.sh   # removes the symlinks (never touches real files)
```

To test the real distribution path instead:

```bash
/plugin marketplace add ~/Git/Developer-Second-Brain
/plugin install developer-second-brain
```

## Conventions

- **English for prompts, Korean for output.** Everything Claude reasons with (SKILL.md,
  references, commands) is in English. Everything the user reads and every saved document is
  in Korean.
- **Never auto-save.** Any code path that writes to the vault must go through explicit user
  approval. This is the project's hard rule.
- **Keep SKILL.md thin.** SKILL.md is the orchestrator. Detailed rules live in
  `references/*.md` and are loaded on demand. Don't grow SKILL.md into one giant prompt.

## How to add a new documentation type

Adding a type (e.g. `postmortem`) touches four places — keep them in sync:

1. `skills/second-brain/templates/<type>.md` — the Korean template (with frontmatter).
2. `skills/second-brain/references/doc-types.md` — add a row + when-to-use guidance.
3. `skills/second-brain/references/vault-layout.md` — add the type → folder mapping.
4. `skills/second-brain/SKILL.md` — add the type to the list in step 2 of the workflow.

Optionally add a filled example under `examples/`.

## How to add a new capability (skill or command)

- A new *behavior* Claude performs → a new skill under `skills/<name>/` (self-contained).
- A new *user-invoked action* → a new command under `commands/<name>.md`.
- Keep capabilities separate rather than overloading `second-brain`. For example, future
  "weekly report" generation should be its own skill/command that *reads* the vault, not a
  branch inside the capture skill.

## Commit / PR guidelines

- Keep changes focused; match the surrounding style.
- Update `CHANGELOG.md` under `Unreleased` for user-facing changes.
- If you change structure, update `docs/architecture.md` and the README structure block.
