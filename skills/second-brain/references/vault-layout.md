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

## Project is metadata, not a folder

The vault has **one** directory level: type. A document's project belongs in the frontmatter
field `project`, never in the path. There is no `<project>/<type>/` or `<type>/<project>/`.

Why the field and not a folder:

- **It would undo the reason the vault exists.** The vault lives outside any single project so
  every repo's knowledge lands in one place. Splitting by project restores the walls, and a
  lesson learned in project A stops being visible while working on project B.
- **There are two axes and a path can only pick one.** Whichever order you choose, the reverse
  query gets awkward, and the "folder name = type name" invariant above breaks.
- **Notion (v0.3) has no such folder.** A project there is a property, not a nested database.
  A folder would have to be flattened at sync time — a storage-shaped decision leaking into the
  capture side.
- **Renames stay cheap.** A repo rename or a monorepo split is a one-line frontmatter edit;
  as a path it is a bulk move.

If a project's records must be *physically* separate (work vs. personal, say), point
`SECOND_BRAIN_VAULT` at a different root — see "Resolving the vault root" above. That is the
whole mechanism; there is nothing else to configure.

### Deriving the project name

In order, first match wins:

1. The repo name from `git remote get-url origin` — the last path segment, minus `.git`
   (`git@github.com:sw0512/Developer-Second-Brain.git` → `Developer-Second-Brain`).
2. No remote (or not a git repo): the basename of the repo root, else of the working directory.
3. Neither is meaningful — no directory context, a temp path, `$HOME`: `unknown`.

Keep the name verbatim as the source gives it (do not kebab-case or lowercase it) so the same
project always writes the same string. Never invent or prettify a name; `unknown` is a valid
answer and is easier to fix later than a wrong guess.
