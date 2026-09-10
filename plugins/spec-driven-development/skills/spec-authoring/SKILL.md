---
name: spec-authoring
description: Draft or refine a spec from a user goal or rough plan. Use when creating a new spec, turning a plan into acceptance criteria, or updating an existing spec.
argument-hint: "<goal, rough plan, docs/specs/spec-file.md, or GitHub Issue URL>"
---

Ask the user where the spec lives before writing: `docs/specs/`, relative to the project root (`jj root`), or a GitHub Issue. `docs/specs/` is the default.

For new specs, follow the `_template.md` in the same directory as this SKILL.md. If it does not exist, use the structure described below. For existing specs, follow the compatibility rules in `../spec-driven-development/SKILL.md`. Do not migrate their structure unless requested.

The user owns and approves the purpose, acceptance criteria, negative requirements, scope limit, and final spec.

Draft, refine, and point out ambiguity. Ask for missing decisions one at a time, but inspect the codebase instead when it can answer the question.

The spec is the final requirement for implementation and review agents. Keep each section to its defined content, without work notes, supplementary remarks, or investigation findings. Record design decisions and reasons in the appropriate section, ask in your response when the user must decide, and discard the rest.

## Structure and decision placement

Use `## 目的`, `## 共通要件`, `## スコープ上限`, and `## タスク`, in that order. Under `## タスク`, each `### AC-N：タスク名` is a task, the unit of implementation, verification, and progress. Its `#### 受け入れ基準` bullets are the individual acceptance criteria, not separate tasks.

Keep the task name only in its heading. Directly below it, write `状態：未着手` and `依存：なし` or the required AC identifiers. Progress uses `状態：未着手`, `状態：進行中`, and `状態：完了`. Do not append a task list.

Begin each task's explanation with the state it will achieve. Continue the paragraph with what changes from the current state and how that change serves the spec's purpose. Do not merely rephrase the heading or enumerate acceptance criteria. The paragraph explains the outcome and its meaning, while the criteria make that outcome concretely verifiable. Keep both even when they discuss the same subject.

Place task-specific design decisions in that task's `#### ネガティブ要件` or `#### 技術的制約`. Only decisions that apply to every task belong in `## 共通要件`, separated under `### ネガティブ要件` and `### 技術的制約`. Write each decision's reason as a nested list item directly beneath it.

For a definition shared by some tasks, keep its full text and reasons in the task that defines it. In each consuming task's requirements, explicitly name the defining task and the concrete heading, with the relevant definition identified. Add a named subheading under the defining section when needed. A dependency entry establishes order, not which constraints are shared, and cannot replace this reference.

Distinguish task completion dependencies from operational start conditions. When production deployment or verification is required before starting a task, add a `開始条件：...` line below its dependency line and put the required procedure and reason in its technical constraints. For example, AC-9 can depend on completion of AC-1 through AC-8 while separately requiring their production deployment and successful production verification before creating its separate PR. Do not reduce such a condition to task completion.

## Settlement checks

The heading and progress-location checks below apply to the new format. When an existing spec keeps the old format, apply the compatibility rules instead and check the same requirement meaning, reasons, and prerequisites without demanding relocation.

Before declaring the spec settled, verify:

- The purpose section states the current problem, the solution applied, and what to build, in that order, in a form that can be skimmed. Design decisions do not accumulate in the purpose section.
- Every design decision is placed according to its applicability, in negative requirements or technical constraints, with its reason directly beneath it. Decisions without reasons have caused fabricated reasons in later rewrites. Common requirements contain only decisions applicable to all tasks and distinguish prohibitions from technical prescriptions.
- Every task's opening paragraph states the achieved state, the change, and its connection to the purpose. Its acceptance criteria cover that state without requirements left only in the explanation or contradictions between the explanation and criteria.
- Each acceptance-criterion bullet is written as an observable outcome (input or operation, then expected result), with no design decisions left to the implementer.
- A failing test can be written directly from each acceptance-criterion bullet, before any implementation code. When a criterion has no runnable behavior, an existence check takes the place of the test.
- Shared definitions retain their full content and reasons at their defining task. Consumers identify an existing, concrete heading and the definition they use, not just an AC dependency. Renaming or splitting tasks leaves no broken references.
- Task identifiers are unique, dependencies exist and are not circular, and operational start conditions are preserved separately from completion. Task names and progress have no duplicate task list in the new format.
- When revising an existing spec, no requirements, reasons, preserved behaviors, or deployment and verification conditions have been lost or weakened by relocation. Follow the compatibility rules if it remains in the old format.
- No unresolved items (TBD, 要検討, 〜かもしれない) remain in the spec body.
- No work notes, supplementary remarks, or investigation findings remain in the spec.
- The scope limit has concrete numbers.

While any check fails, the spec is not settled and implementation does not start.

Keep tasks inside the spec itself, whether it is a file or a GitHub Issue.
