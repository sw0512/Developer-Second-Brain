# Writing rules — making a saved document reusable

The Detection Engine decides *whether* to record. These rules govern *how* the document is
written, and are applied at pipeline stage ⑥ (write) plus the self-review pass that follows.

The test for every rule here is the same one question:

> **Six months from now, on a different project, can the user act on this document alone —
> without the original conversation and without the original repo?**

A document that reads well but fails that test is noise. These rules exist because each one
has already failed it in a real saved doc.

---

## R1. Code snippets must be self-contained

A snippet is not an illustration, it is the reproducible core of the fix.

- **Every identifier that carries a value must show its value.** If the snippet uses
  `GRAVITY`, `RETRY_LIMIT`, `TIMEOUT`, or a config key, the document must state what it was
  set to — either inline or in a constants block right above the snippet.
- Prefer a short **constants block + logic block** over one long elided snippet. Elision
  (`// ...`) is fine for *repetitive* lines, never for the values that make it work.
- Strip framework noise, keep the load-bearing lines.

❌ `const dt = Math.min(elapsed, MAX_DT);` with `MAX_DT` never defined
✅ `const MAX_DT = 1 / 30; // 탭 복귀 시 dt 폭주 방지` then the logic

## R2. Every tuned number needs its rationale

Any number that could have been a different number needs three things:

1. **What it means** — the unit or the definition (`반발계수 = 충돌 직후 속도 ÷ 직전 속도`).
2. **How it was arrived at** — measured, calculated, or **tuned by eye**. "눈으로 맞춘 값"
   is a completely acceptable answer and must be said outright; never dress a guess up as a
   derivation, and never leave it unexplained.
3. **What breaks if it changes** — the range that still works, or the symptom outside it.

If the honest answer to (2) is "I don't remember", write that instead of inventing one.
An admitted unknown is recoverable; a fabricated derivation is not.

## R3. Record coupling between values

Constants tuned together are the single most common source of "I changed one number and it
broke". When one value is **derived from** or **only valid alongside** another, say so
explicitly at the point where the value is introduced.

> `e`가 바운스 간격을 정하고 → 3회째 접지 시각이 정해지고 → 거기서 `VX`를 역산한다.
> **`e`를 바꾸면 `VX`도 다시 계산해야 한다.**

This applies beyond physics: timeout vs. retry count, batch size vs. memory limit, cache TTL
vs. poll interval, pool size vs. connection limit.

## R4. Names and terminology stay consistent

- Fix a single spelling for every product, service, and component name on first use and hold
  it for the whole document — including the frontmatter `title`.
- Keep identifiers verbatim from the source (`settling`, not `settle`). The document may be
  grepped against the real repo later.

## R5. Never invent detail

Already stated in `SKILL.md`; restated here because R1–R3 create pressure to fill gaps.
When a value, a version, or a benchmark number is not actually known, write
`(미확인)` rather than a plausible-looking figure. Reaching into the real source to *look it
up* is encouraged; guessing at it is not.

---

## Self-review pass (run before confirming the save)

After writing the file, **re-read what was written** and check it against this list. Fix what
fails, then report the save location. Do not ask the user to run this pass.

| # | Check | Fails when |
|---|-------|-----------|
| 1 | Every constant in a snippet has a value | a name appears with no number anywhere |
| 2 | Every tuned number has meaning + origin + failure range | a bare magic number sits in prose or code |
| 3 | Derived / co-tuned values are marked as coupled | two numbers were fitted to each other silently |
| 4 | Product & identifier names spelled consistently | title and body disagree, or an identifier was paraphrased |
| 5 | Frontmatter parses and `title` matches the `#` heading | a stray quote, or the two drifted apart |
| 6 | Every claim traces to the conversation or the source | a detail was smoothed in to make prose flow |
| 7 | Interview points make no claim the body doesn't support | a talking point outruns the evidence |

**Values may be read from the source repo to satisfy checks 1–3.** If the code is reachable,
open it and fill in the real numbers — that is the intended way to pass this pass, not a
shortcut around it. If it is not reachable, mark `(미확인)` and say so when confirming the save.
