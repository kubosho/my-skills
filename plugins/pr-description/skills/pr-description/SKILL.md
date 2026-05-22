---
name: pr-description
description: Write narrative-driven PR descriptions that honor the repository's PR template and respect the boundary between PR Summary, commit messages, and design docs. Use when creating a PR (gh pr create), writing or rewriting PR body text, improving an existing PR description, or when the user says "PR説明文", "PRの説明を書いて", or "pull requestの説明".
---

The diff shows what changed. The description adds what the diff cannot: why this change exists and what decisions shaped it. Don't duplicate the diff.

## Before writing

<must_read_template>
Read the repository's PR template before drafting. Look at `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE.md`, `docs/pull_request_template.md`, or any path the repository documents.

If the template exists, follow its sections and inline guidance literally. The template encodes review conventions specific to that team. When the template's guidance conflicts with the defaults in this skill, the template wins. Examples:

- Template says "keep summary to 1-2 lines, put details in commit messages", write a 1-2 line Summary, do not impose the Context / Approach / Outcome structure from this skill.
- Template provides numbered headings like `## 背景` `## 変更内容` `## 動作確認`, fill those exact headings, do not invent new ones.
- Template asks for a checklist, include the checklist verbatim, then mark items.

If no template exists, fall back to the Summary structure below.
</must_read_template>

## Boundary between PR Summary, commit messages, and design docs

<information_placement>
Each surface carries different information at different granularities. Choosing the right surface keeps the PR Summary scannable.

- **PR Summary**: Why this matters now, what was chosen, what does not change. Read at PR list and code review time, often by people who will not open the diff.
- **Commit messages**: The detailed flow of what was done and the causal chain between commits. Read by anyone bisecting history or following the change later.
- **Design doc / Plan / linked issue**: Investigation logs, alternatives considered and rejected, internal mechanism walkthroughs, verbatim quotes from issue trackers. Read only by those who follow the link.

The following content categories belong in the Plan / linked issue, not in the PR Summary. When you find yourself reaching for them, write a one-line pointer to the Plan instead.

- **Library internals**: framework source references, internal function names, dispatch logic in a third-party library
- **Browser / runtime internals**: History API event sequencing, V8 / JSC behavior, Node.js event-loop quirks, browser-specific rendering paths
- **Race condition mechanics**: precise interleaving of events, lock states, scheduler interactions
- **Rejected alternatives with full reasoning**: "We also considered X, Y, Z because A, B, C": one line per option in the Summary at most, the full reasoning lives in the Plan
- **Verbatim issue-tracker excerpts**: link to the issue instead

If the reviewer needs the Plan to understand the PR, link to it. If they need the PR Summary to understand the change, keep the Summary focused on decisions and outcomes, not the mechanism.
</information_placement>

## Summary

Use paragraph breaks to separate each layer of reasoning:

1. **Context**: Why this change is needed now. Lead with business or operational impact when it exists ("alerts were firing", "users reported the page hangs", "X% of sessions affected"). Then the technical context (prior PR, design decision, user report). Non-engineer reviewers (PM, QA, support) read this part first, so the opening sentence should make sense to them.
2. **Approach**: Why this approach was chosen. State judgment with first-person reasoning. Link to tools or libraries when introducing them.
3. **Outcome / scope**: What this accomplishes, what it does not change.

Not every PR needs all three. A small bugfix might need only context and approach. A pure refactoring might be two sentences. Match the depth to the complexity.

One topic per paragraph. If a paragraph covers two unrelated points, split it.

<abstract_over_enumerate>
Push every piece of information up one abstraction level before it lands in the Summary. The Summary's job is the conclusion ("had no clear owner", "drifted into variations", "one place to update"), not the inventory ("validation, pagination, UUID parsing, and error response formatting").

If you write a sentence that lists three or more concrete pattern names, function-style nouns, or per-file changes, that is the inventory leaking through. Ask: what is the one thing all those items have in common, and can the sentence say that instead?

Examples of the right abstraction level for a refactoring PR:

- "Validation logic had no clear owner because it lived inside individual handler files." (Conclusion, no inventory.)
- "Error response helpers had drifted across handlers, so clients saw different error strings for the same condition." (Conclusion plus reviewer-facing consequence.)

Examples of the inventory leaking through (avoid):

- "Request body validation, pagination checks, UUID parsing, and error response formatting were all copy-pasted." (Lists the items; the diff already shows them.)
- "We moved X helper, Y helper, and Z helper into a shared package." (Moves are visible in the diff.)
</abstract_over_enumerate>

| Do | Don't |
|---|---|
| Write prose paragraphs for rationale | Duplicate information already in the diff |
| Summarize at the level the reader needs. One phrase often beats an enumeration | List individual symptoms or changes when a single summary captures the point |
| Describe motivation and judgment | Describe implementation (function names, file names, line counts) or process (how many iterations, what tools were used to develop the change) |
| Link to tools, libraries, or references when introducing them | Assume the reviewer knows every tool |

## Format

Default to prose paragraphs for the rationale. Reach for structure only when it makes the Summary easier to scan, not as decoration and not to fit more information in:

- **Numbered lists** for sequential flows that the reviewer has to follow in order. A bug reproduction sequence, a multi-step failure trace, an ordered list of fix steps. If the items are not order-dependent, prefer prose.
- **Bullet lists** for genuinely parallel items where each item carries reviewer-relevant judgment. Scope boundaries the PR is opting out of, related existing usages a reviewer should compare against. Not for enumerating the implementation surface.
- **Subheadings** like `### 修正内容` `### 検証` only when the PR Summary is long enough that scrolling without anchors becomes a burden. A short Summary does not need them, and adding them to a short Summary makes it look bigger than the change deserves.

What still does not belong in the Summary:

- A bullet-by-bullet retelling of the diff (file paths, function names, line counts).
- A list of every pattern or sub-pattern that was consolidated, when one sentence at the conclusion level would do.
- Structure added because "the skill allows it", when prose was already working.

Before publishing, re-read each bullet or numbered item and ask: does removing this item lose something the reviewer needs, or does the surrounding prose already cover it? If the prose covers it, cut the list.

See `references/examples.md` for worked examples showing how structure helps a bug-fix Summary scan better, and how lists of diff changes hurt a refactoring Summary.

## Length guidance

<length_check>
If your PR Summary exceeds 5 paragraphs or roughly 1000 characters in Japanese / 600 words in English, pause and ask: have you moved Plan or design-doc content into the PR Summary that belongs in the Plan?

Common over-share patterns that inflate Summaries:

- Internal mechanism walkthroughs (library internals, browser History API internals, runtime event-loop internals, IPC dispatch)
- Meta-discussion of "why this approach is robust under uncertainty"
- Historical iteration of considered alternatives that were rejected
- Verbatim quotes from issue trackers when a single link would suffice
- Inventory of the items being consolidated, when the conclusion is the same for all of them

If any of these apply, link to the Plan or issue and cut the inlined version. Reviewers who need that depth will follow the link.
</length_check>

## Style

- Give each idea its own sentence. Short, complete sentences are easier to scan than long chains.
- When writing in Japanese, use polite form (敬体 / ですます調).
- Do not use em dashes or semicolons. Use commas, periods, or separate sentences.

## Test plan

Concrete steps. Checkboxes (`- [x]`). Commands run, endpoints hit, scenarios tested.

Omit this section when there is nothing to verify manually. Examples: documentation changes, config-only changes, pure refactoring with existing test coverage.

## References

- `references/examples.md`: worked examples for refactoring PRs, tool introduction PRs, and bug-fix PRs. Each shows the editing progression from a first draft to a tightened final version, with notes on what each revision fixed.
