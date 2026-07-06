---
description: Manually run the Developer Second Brain workflow to record the current (or a specified) piece of work into your knowledge vault.
---

The user wants to document something into their Developer Second Brain vault.

Invoke the **second-brain** skill and run its full workflow. The skill is the single source of
truth for the workflow, scoring, and storage rules — do not restate or reimplement them here.

Command-specific behavior only:

- **Scope:** if the user named a topic in `$ARGUMENTS`, document that; otherwise use the most
  recent substantive work in this conversation.
- **Lower bar:** because the user invoked this explicitly, you may proceed even for
  lower-importance work. Still show the Importance Score, and still require explicit approval
  before writing — the never-auto-save rule always holds.
