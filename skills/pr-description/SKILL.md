---
name: pr-description
description: Write narrative-driven PR descriptions with Summary→Changes→Test plan structure. Use when creating a PR (gh pr create), writing or rewriting PR body text, or improving an existing PR description.
---

The diff shows what changed. The description adds what the diff cannot: why this change exists and what decisions shaped it.

## Structure

```
## Summary
[1-2 paragraphs: why this PR exists, what it accomplishes]

## Changes
- [Primary change (context if non-obvious)]

## Test plan
- [x] [Concrete verification step]
```

## Summary

Answer **why now** and **what this accomplishes** as a unified narrative.

| Do | Don't |
|---|---|
| Open with project context (prior PR, design decision, user report) | Start with what changed |
| Write prose paragraphs | Use bullet lists |
| Describe motivation and outcome | Describe implementation |

Keep out of Summary: function names, file names, pattern names, line counts. Those belong in Changes or are visible in the diff.

## Changes

2-5 items. Primary changes only.

| Do | Don't |
|---|---|
| Name what changed with parenthetical context | List every modified file |
| Omit mechanical consequences (import fixes, test updates, go.sum) | Give each commit its own item |

If an item is an obvious consequence of another item, remove it.

## Test plan

Concrete steps. Checkboxes (`- [x]`). Commands run, endpoints hit, scenarios tested.
