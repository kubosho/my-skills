---
name: spec-authoring
description: Draft or refine a spec from a user goal or rough plan. Use when creating a new spec, turning a plan into acceptance criteria, or updating an existing spec.
argument-hint: "<goal, rough plan, docs/specs/spec-file.md, or GitHub Issue URL>"
---

Ask the user where the spec lives before writing.

Follow [spec-driven-development](../spec-driven-development/SKILL.md).

For new specs, use `_template.md` in the same directory as this SKILL.md as the definition of the document structure. If it is unavailable, report that instead of inventing one.

The user owns and approves the spec.

Draft, refine, and point out ambiguity. Ask for missing decisions one at a time, but inspect the codebase instead when it can answer the question.

The spec is the final requirement for implementation and review agents. Each section holds only its defined content: record design decisions and reasons in the appropriate section, ask in your response when the user must decide, and leave out work notes, supplementary remarks, and investigation findings.

## Settlement checks

Before declaring the spec settled, verify that the applicable template instructions and shared rules are satisfied, then check:

- No design decisions are left to the implementer.
- References resolve to the intended definitions, including after renaming or splitting tasks.
- Task identifiers are unique, and dependencies exist and are not circular.
- When revising an existing spec, no requirements, reasons, or preserved behaviors have been lost or weakened by relocation.
- No unresolved items (TBD, 要検討, 〜かもしれない) remain in the spec body.

While any check fails, the spec is not settled and implementation does not start.
