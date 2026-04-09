---
name: pr-description
description: Write narrative-driven PR descriptions as a Summary that explains why and what judgment shaped the change. Use when creating a PR (gh pr create), writing or rewriting PR body text, improving an existing PR description, or when the user says "PR説明文", "PRの説明を書いて", or "pull requestの説明".
---

The diff shows what changed. The description adds what the diff cannot: why this change exists and what decisions shaped it. Don't duplicate the diff.

## Summary

Use paragraph breaks to separate each layer of reasoning:

1. **Context**: Why this change is needed now (prior PR, user report, design decision)
2. **Approach**: Why this approach was chosen. State judgment with first-person reasoning. Link to tools or libraries when introducing them
3. **Outcome / scope**: What this accomplishes, what it does not change

Not every PR needs all three. A small bugfix might need only context and approach. A pure refactoring might be two sentences. Match the depth to the complexity.

One topic per paragraph. If a paragraph covers two unrelated points, split it.

| Do | Don't |
|---|---|
| Write prose paragraphs | Use bullet lists |
| Summarize at the level the reader needs. One phrase often beats an enumeration | List individual symptoms or changes when a single summary captures the point |
| Describe motivation and judgment | Describe implementation (function names, file names, line counts) or process (how many iterations, what tools were used to develop the change) |
| Link to tools, libraries, or references when introducing them | Assume the reviewer knows every tool |

## Style

- Write short, complete sentences. Don't chain clauses or items with dashes, colons, or comma-separated lists. If the information matters, give it its own sentence. If it belongs in the diff, cut it.
- When writing in Japanese, use polite form (敬体/ですます調).

## Test plan

Concrete steps. Checkboxes (`- [x]`). Commands run, endpoints hit, scenarios tested.

Omit this section when there is nothing to verify manually. Examples: documentation changes, config-only changes, pure refactoring with existing test coverage.
