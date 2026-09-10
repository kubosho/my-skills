---
name: spec-driven-development
description: How to run spec-driven development. Covers where the spec lives, the flow from spec-authoring through spec-implement to spec-implementation-check, and how AC progress and commits are handled. Use when starting spec-driven work, or when checking how to proceed.
---

Follow this workflow for spec-driven development.

## Managing the spec

- `docs/specs/` is the default location for a spec. Ask the user where it lives before writing, and place it in a GitHub Issue when the user chooses that.
- `docs/specs/` is relative to the project root (`jj root`).

## Implementation and verification

- `spec-authoring` writes and settles the spec, `spec-implement` implements one task identified by AC-N, and `spec-implementation-check` verifies the implementation.
- Each `### AC-N：タスク名` section under `## タスク` is one task, one verification unit, and one jj commit context. Its `#### 受け入れ基準` bullets are individual acceptance criteria, not separate implementation units.
- Negative requirements are prohibitions. Do not implement anything listed there.
- Always run the tests or existence checks for all acceptance criteria of the task before marking work complete. If any does not succeed, the task is not complete.
- Read common requirements, the target task's requirements, and explicitly referenced definitions together. Read the entire spec to retain constraints that protect existing behavior in other tasks.

## Progress and commits

- Keep each task's name in its heading and progress directly within that task as `状態：未着手`, `状態：進行中`, or `状態：完了`. Do not maintain a separate task list.
- Mark the task `状態：完了` only after all its acceptance-criterion checks succeed and spec-implementation-check allows the commit. Keep it in progress while a return or required human judgement remains.
- `依存：AC-N` requires that task's completion. `開始条件：...` records additional prerequisites such as production deployment and verification. Completion does not prove these prerequisites have been met.
- Update the spec progress marker in the same commit as the implementation for that AC.
- Once every AC is implemented, set the spec status to `done`.

## Existing spec compatibility

All spec skills use these rules when reading or updating an existing spec:

- Do not bulk-rewrite existing specs or migrate one merely to implement or review it. Change its format only when requested, preserving identifiers, requirements, reasons, progress, references, and operational start conditions.
- In the old format, `### AC-N` sections under `## 受け入れ基準` are still task units. Read the document-level `## ネガティブ要件` and `## 技術的制約` in full, including task-specific decisions placed there.
- Read and update progress in the old `## タスク一覧`: `- [ ] AC-N：タスク名` is not started, `- [ ] AC-N：（進行中）タスク名` is in progress, and `- [x] AC-N：タスク名` is complete. Do not add new task-local state lines alongside that list.
- Read `**Depends On**：...` with its full meaning. An AC identifier alone requires completion, but wording such as `AC-1 から AC-8 の本番反映` also requires that operational condition. Preserve additional prerequisites from the spec's technical constraints, such as production verification and a separate PR.
- Missing or conflicting status, dependencies, or start-condition evidence is not proof that a task is ready. Resolve the ambiguity through spec-authoring before dependent work begins.
