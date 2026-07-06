# Project Principles

> The constitutional document for Developer Second Brain.
>
> This is not a usage guide (see the [README](README.md)) and not a how-to for contributors
> (see [CONTRIBUTING.md](CONTRIBUTING.md)). It defines the **timeless design philosophy and
> decision-making principles** that every future maintainer should uphold. When a decision is
> unclear, this document — not convenience, not the newest idea — is the tiebreaker.
>
> Principles here are meant to outlive any specific implementation. Code will be rewritten;
> these should not.

---

## 1. Vision

Developer Second Brain aims to become a developer's **external memory for engineering
experience** — a system that quietly turns the daily act of building software into a durable,
retrievable, compounding asset.

The end state is not "an assistant that answers questions." It is a **Second Brain**: a
trusted store where a developer's hard-won knowledge — the bugs they beat, the trade-offs they
weighed, the systems they designed — accumulates over years and pays back as portfolio
material, interview readiness, and faster future decisions.

If the project ever succeeds completely, a developer using it for five years should be able to
answer *"why did I choose this?"* and *"have I solved this before?"* instantly, from their own
recorded experience.

## 2. Core Philosophy

**Why this project exists.** Ordinary AI assistants operate as `question → answer → done`. The
experience evaporates. The insight that took three hours to earn is gone by next week, and
nothing accumulates. A developer can be productive every single day and still have nothing to
show for it a year later.

**What it solves.** It closes the loop: `question → build → solve → judge worth → document →
store → asset`. The knowledge that would have evaporated is captured, classified, and kept.

**Why knowledge preservation is the primary goal.** Everything else the project might do —
generate reports, prep interviews, build resumes — is *downstream* of one thing: having
preserved the knowledge in the first place. A well-preserved corpus enables unlimited future
features. A missing corpus makes them impossible. Therefore preservation is the root, and it
is protected above all convenience features.

The single question that governs every decision:

> **"Does this help the developer accumulate knowledge?"**

If the answer is no, the feature does not belong here — however clever or convenient it is.

## 3. Non-Negotiable Principles

These should almost never change. Changing one is a constitutional amendment, not a routine
edit — it requires an explicit, documented rationale.

1. **Quality over quantity.** A small vault of high-value records beats a large vault of noise.
   The system should record less, not more, when in doubt.
2. **Never auto-save without user confirmation.** The user is always the final gate before
   anything is written. Automation may *propose*; only the user *approves*. This is the
   project's hard line and its trust contract.
3. **English prompts, Korean output.** Internal reasoning, instructions, and structure are in
   English; everything the user reads and every saved document is in Korean. This separation
   keeps prompts precise and output natural.
4. **The Skill is an orchestrator, not a giant prompt.** The core skill decides *what to do*
   and delegates *how to judge* to modular references loaded on demand. It must stay thin.
5. **Features are composable and modular.** Every capability is a self-contained unit that can
   be added, removed, or reasoned about in isolation. No hidden coupling.
6. **The user's attention is sacred.** The system interrupts only when the engineering
   substance justifies it. A false "record this?" is worse than a missed low-value note.

## 4. Architectural Principles

The system is deliberately separated into distinct roles. Each separation exists to protect a
specific property — not for decoration.

- **Skills** — *behavior and judgment.* A skill is a role Claude assumes and a workflow it
  runs. Skills own the "what and when." They must remain thin orchestrators.
- **References** — *knowledge and rules.* The detailed criteria a skill consults (how to judge,
  how to score, how to classify). Kept separate so rules can grow richly without inflating the
  prompt, and so they are loaded only when needed.
- **Templates** — *output shape.* The form a produced artifact takes. Separated so the *format*
  of knowledge can evolve independently of the *logic* that produces it.
- **Commands** — *user-invoked entry points.* Explicit, on-demand triggers. Separated from
  skills so manual and automatic invocation share one workflow but stay independently
  addressable.
- **Hooks** — *automatic triggers.* Event-driven activation. Kept as a distinct layer so
  automation can be added or removed without touching the behavior it triggers — and so
  automation can never bypass the user-approval gate.
- **Storage** — *where knowledge lives.* Deliberately isolated behind a single boundary so the
  backend can change (local today, Notion tomorrow, something else later) without disturbing
  anything upstream.

The guiding idea: **each layer changes for one reason.** Behavior, rules, format, triggers, and
persistence evolve on independent schedules, so a change in one never forces a rewrite of
another.

## 5. Repository Conventions

- **Source and data are separate.** The repository holds the system; the user's knowledge lives
  in a vault outside it. Never entangle the two.
- **A capability owns its assets.** A skill is self-contained — its supporting rules and formats
  live within it, never reaching outside its own boundary. Self-containment is what keeps
  capabilities portable and independently testable.
- **Documentation mirrors architecture.** When structure changes, the documents that describe
  it change in the same step. Drift between docs and reality is treated as a defect.
- **One concept, one home.** Each rule, format, or mapping has a single authoritative location.
  Duplication is debt.
- **Explain the "why," not just the "what."** Design documents record the reasoning behind a
  decision so future maintainers inherit judgment, not just outcomes.

## 6. Prompt Engineering Principles

Prompts are the project's real source code and deserve the same discipline as code.

- **Orchestrate, then delegate.** A prompt should describe a clear sequence and defer detailed
  judgment to focused, separately-maintained references. Resist the urge to inline everything.
- **Small, composable, loaded on demand.** Prefer several sharp documents over one sprawling
  one. Load detail only when the moment needs it.
- **Instructions are unambiguous and testable.** Prefer concrete rules and calibrated examples
  over vague guidance. If two maintainers could read a prompt two ways, it is not done.
- **Evolve by refining references, not by swelling the orchestrator.** When behavior needs to
  improve, sharpen the relevant reference. The orchestrator should stay roughly the same size
  forever.
- **Separate the language of thought from the language of output.** Reasoning stays in the
  precise internal language; user-facing text stays natural. Do not blur them.
- **Encode the hard rules explicitly.** Non-negotiables (especially the approval gate) must be
  stated in the prompt itself, not left implicit.

## 7. Storage Philosophy

Storage must remain **abstract and replaceable.** The knowledge — its structure, its metadata,
its meaning — is the asset. *Where* it is stored is an implementation detail that will change
over the project's life.

- The rest of the system must never assume a particular backend. It knows *that* knowledge is
  stored, not *how*.
- Portability is a feature. A record should carry enough self-describing metadata that it
  remains meaningful independent of any storage engine, and can migrate without loss.
- Changing the backend (local files → Notion → future systems) must be a change in one place,
  never a ripple through the whole system.
- The user owns their data. Storage choices must keep the knowledge exportable and outlive any
  single tool — including this one.

## 8. Extensibility Rules

The project must grow in **capability** without growing in **complexity**. The central danger is
drift toward a single monolithic prompt that tries to do everything. Guard against it:

- **New behavior is a new unit, not a new branch.** A genuinely new capability becomes its own
  self-contained skill or command — never another conditional bolted onto an existing one.
- **The capture skill never grows.** The part that records knowledge stays focused on recording.
  Features that *consume* accumulated knowledge (reports, interview prep, resume generation) are
  separate read-side capabilities that read the vault; they do not expand the writer.
- **Separate the write side from the read side.** Capturing knowledge and generating things
  *from* captured knowledge are different concerns with different lifecycles. Keep them apart.
- **Metadata is the contract between capabilities.** New features integrate by reading the
  structured metadata records already carry — not by coupling directly to each other.
- **Adding a feature should not require understanding all others.** If a new capability forces a
  maintainer to reason about unrelated parts of the system, the boundaries have failed and
  should be fixed before the feature lands.
- **Prefer composition over configuration.** Many small parts that combine cleanly beat one
  large part with many switches.

If a proposed change makes the system harder to reason about, it is wrong even if it "works."

## 9. Long-Term Direction

The project evolves through three stages. Each is a superset of the last; none discards what
came before.

1. **Documentation Assistant** — *capture.* It reliably recognizes what is worth recording and
   preserves it well, with the user's approval. This is the foundation: without trustworthy
   capture, nothing above it can exist.

2. **Developer Knowledge Manager** — *organize and connect.* Beyond individual records, it
   understands relationships between them — linking decisions, problems, and technologies into a
   navigable body of knowledge, and surfacing what the developer already knows when it is
   relevant.

3. **Developer Second Brain** — *compound and serve.* The accumulated corpus actively pays back:
   readiness for interviews, portfolio material, growth reports, and instant recall of past
   reasoning. The developer's own experience becomes a queryable, compounding asset.

The direction is one-way and cumulative: **capture** enables **organization**, which enables a
true **Second Brain**. Every decision should move the project along this arc — and never
sacrifice a lower stage to chase a higher one. A brilliant report generator built on unreliable
capture is a house built on sand.

---

*When these principles and a convenient shortcut conflict, the principles win. That is the
entire point of writing them down.*
