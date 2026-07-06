# Vault Layout — Where documents are stored

The vault is the user's local "Second Brain". It lives **outside** any single project so
knowledge accumulates in one place across all repos. (In v0.3 this local vault will sync to
Notion as the long-term store.)

## Resolving the vault root

1. If the environment variable `SECOND_BRAIN_VAULT` is set, use it.
2. Otherwise default to `~/DeveloperSecondBrain/`.

Expand `~` to the user's home directory. Create the root and the type subfolder if they do
not exist (`mkdir -p`).

## Directory structure

```
~/DeveloperSecondBrain/
├── troubleshooting/
├── adr/
├── til/
├── retrospective/
├── resume-material/
└── study-note/
```

## Filenames

`YYYY-MM-DD-kebab-case-title.md`

- Date = today's date.
- Title = a short, descriptive, ASCII kebab-case slug derived from the doc title
  (transliterate Korean to a readable slug; keep it under ~60 chars).
- If a file with the same name exists, append `-2`, `-3`, … .

Examples:
```
troubleshooting/2026-07-06-jwt-refresh-401-loop.md
adr/2026-07-06-redis-for-refresh-token-store.md
til/2026-07-06-git-restore-staged.md
```

## Type → folder rule

The folder name is **always identical to the type name** — no exceptions, no lookup table.
A document of type `<type>` is stored in `<vault-root>/<type>/`. New types added later follow
the same rule automatically.
