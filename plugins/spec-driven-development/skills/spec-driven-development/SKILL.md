---
name: spec-driven-development
description: How to run spec-driven development. Covers where the spec lives, the flow from spec-authoring through spec-implement to spec-implementation-check, and how task progress and commits are handled. Use when starting spec-driven work, or when checking how to proceed.
---

## Managing the spec

- `docs/specs/`, relative to the project root (`jj root`), is the default location. Ask the user where the spec lives before writing, and place it in a GitHub Issue when the user chooses that.

## Shared rules

- `spec-authoring` writes and settles the spec, `spec-implement` implements one task identified by AC-N, and `spec-implementation-check` verifies the implementation.
- Each `### AC-N：タスク名` section under `## タスク` is one task, one verification unit, and one jj commit context. Its `#### 受け入れ基準` bullets are individual acceptance criteria, not separate implementation units.
- Negative requirements are prohibitions. Do not implement anything listed there.
- Read the entire spec. Gather common requirements, the target task's requirements, full definitions and reasons at explicit reference destinations, and requirements in other tasks that protect behavior affected by the diff. Do not implement those other tasks.
- Keep a definition shared by some tasks, including its reasons, in the task that defines it. Consuming tasks explicitly reference the defining task, concrete heading, and relevant definition. A dependency establishes order and does not replace that reference.
- A task is ready only when every task listed in its `依存` field is complete. Resolve missing or conflicting status or dependency evidence through spec-authoring before dependent work begins.

## Progress and commits

- Track progress on each task's `状態：` line as `未着手`, `進行中`, or `完了`. Do not maintain a separate task list.
- Mark the task `状態：完了` only after all its acceptance-criterion checks succeed and spec-implementation-check allows the commit.
- Update the spec progress marker in the same commit as the implementation for that task.
- Once every task is implemented, set the spec status to `done`.

## Existing spec compatibility

Old-format specs keep their structure:

- Migrate an existing spec only when requested, preserving identifiers, requirements, reasons, progress, and references.
- `### AC-N` sections under `## 受け入れ基準` are still task units. Read the document-level `## ネガティブ要件` and `## 技術的制約` in full, including task-specific decisions placed there.
- Read and update progress in the old `## タスク一覧`: `- [ ] AC-N：タスク名` is not started, `- [ ] AC-N：（進行中）タスク名` is in progress, and `- [x] AC-N：タスク名` is complete. Do not add new task-local state lines alongside that list.
- Read and preserve `**Depends On**：...` entries.
