---
name: pr-description
description: Write narrative-driven PR descriptions that honor the repository's PR template and respect the boundary between PR Summary, commit messages, and design docs. Use when creating a PR (gh pr create), writing or rewriting PR body text, improving an existing PR description, or when the user says "PR説明文", "PRの説明を書いて", or "pull requestの説明".
---

The diff shows what changed. The description adds what the diff cannot: why this change exists and what decisions shaped it. Don't duplicate the diff.

## Before writing

<must_read_template>
Read the repository's PR template before drafting. Look at `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `docs/pull_request_template.md`, or any path the repository documents.

If the template exists, follow its sections and inline guidance literally. The template encodes review conventions specific to that team. When the template's guidance conflicts with the defaults in this skill, the template wins. Examples:

- Template says "keep summary to 1-2 lines, put details in commit messages" → write a 1-2 line Summary, do not impose the Context / Approach / Outcome structure from this skill.
- Template provides numbered headings like `## 背景` `## 変更内容` `## 動作確認` → fill those exact headings, do not invent new ones.
- Template asks for a checklist → include the checklist verbatim, then mark items.

If no template exists, fall back to the Summary structure below.
</must_read_template>

## Boundary between PR Summary, commit messages, and design docs

<information_placement>
Each surface carries different information at different granularities. Choosing the right surface keeps the PR Summary scannable.

- **PR Summary**: Why this matters now, what was chosen, what does not change. Read at PR list and code review time, often by people who will not open the diff.
- **Commit messages**: The detailed flow of what was done and the causal chain between commits. Read by anyone bisecting history or following the change later.
- **Design doc / Plan / linked issue**: Investigation logs, alternatives considered and rejected, internal mechanism walkthroughs (library / runtime / browser internals), verbatim quotes from issue trackers. Read only by those who follow the link.

When you are tempted to write a paragraph that walks through the internal mechanism of a library or runtime, ask first whether a link to a Plan or issue would serve the reviewer better. If the reviewer needs the Plan to understand the PR, link to it. If they need the PR Summary to understand the change, keep the Summary focused on decisions and outcomes, not the mechanism.
</information_placement>

## Summary

Use paragraph breaks to separate each layer of reasoning:

1. **Context**: Why this change is needed now. Lead with business or operational impact when it exists ("alerts were firing", "users reported the page hangs", "X% of sessions affected"). Then the technical context (prior PR, design decision, user report). Non-engineer reviewers (PM, QA, support) read this part first, so the opening sentence should make sense to them.
2. **Approach**: Why this approach was chosen. State judgment with first-person reasoning. Link to tools or libraries when introducing them.
3. **Outcome / scope**: What this accomplishes, what it does not change.

Not every PR needs all three. A small bugfix might need only context and approach. A pure refactoring might be two sentences. Match the depth to the complexity.

One topic per paragraph. If a paragraph covers two unrelated points, split it.

| Do | Don't |
|---|---|
| Write prose paragraphs for rationale | Duplicate information already in the diff |
| Summarize at the level the reader needs. One phrase often beats an enumeration | List individual symptoms or changes when a single summary captures the point |
| Describe motivation and judgment | Describe implementation (function names, file names, line counts) or process (how many iterations, what tools were used to develop the change) |
| Link to tools, libraries, or references when introducing them | Assume the reviewer knows every tool |

## Format

Default to prose paragraphs for the rationale. Reach for structure when it makes the Summary easier to scan, not as decoration:

- **Numbered lists** for sequential flows. A bug reproduction sequence, a multi-step failure trace, or an ordered list of fix steps reads faster as numbered items than as one long sentence.
- **Bullet lists** for genuinely parallel items. Related existing usages of a pattern, scope boundaries the PR is opting out of.
- **Subheadings** like `### 修正内容` `### 検証` only when the PR Summary is long enough that scrolling without anchors becomes a burden. A short Summary does not need them.

What still does not belong in the Summary: a bullet-by-bullet retelling of the diff (file paths, function names, line counts). The diff already shows this. If you find yourself listing "moved X to Y, added Z helper", that is the diff talking, not the rationale.

See `references/examples.md` for worked examples showing how structure helps a bug-fix Summary scan better, and how lists of diff changes hurt a refactoring Summary.

## Length guidance

<length_check>
If your PR Summary exceeds 5 paragraphs or roughly 1000 characters in Japanese / 600 words in English, pause and ask: have you moved Plan or design-doc content into the PR Summary that belongs in the Plan?

Common over-share patterns that inflate Summaries:

- Internal mechanism walkthroughs (library / browser / runtime source references, IPC, dispatch internals)
- Meta-discussion of "why this approach is robust under uncertainty"
- Historical iteration of considered alternatives that were rejected
- Verbatim quotes from issue trackers when a single link would suffice

If any of these apply, link to the Plan or issue and cut the inlined version. Reviewers who need that depth will follow the link.
</length_check>

## Style

- Give each idea its own sentence. Short, complete sentences are easier to scan than long chains.
- When writing in Japanese, use polite form (敬体 / ですます調).

## Test plan

Concrete steps. Checkboxes (`- [x]`). Commands run, endpoints hit, scenarios tested.

Omit this section when there is nothing to verify manually. Examples: documentation changes, config-only changes, pure refactoring with existing test coverage.

## References

- `references/examples.md` — worked examples for refactoring PRs, tool introduction PRs, and bug-fix PRs. Each shows the editing progression from a first draft to a tightened final version, with notes on what each revision fixed.
