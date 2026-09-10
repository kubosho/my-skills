---
name: spec-implement
description: Implement one task identified by AC-N from a spec's settled design. Use for spec-based implementation.
argument-hint: "<docs/specs/spec-file.md or GitHub Issue URL> [AC-N]"
---

Implement exactly one AC-N task from the given spec, including all its acceptance-criterion bullets. The task section, not an individual bullet, is the implementation and progress unit.

If no spec location is provided, ask for it. Follow the existing spec compatibility rules in `../spec-driven-development/SKILL.md` for old-format specs.

If no task is specified, pick the first task in spec order whose state is `未着手` or `進行中`, whose `依存` tasks are all `完了`, and whose additional `開始条件` are verified as satisfied. Apply the same readiness checks to an explicitly selected task. Read prerequisite procedures in technical constraints as well, including referenced sections. Task completion alone does not prove deployment or production verification. If no task is ready, report what is missing instead of starting dependent work. Unknown conditions require evidence or clarification, not an assumption of completion.

1. Read the entire spec, not just the target task. Gather common requirements, the task's negative requirements and technical constraints, and the full definitions and reasons at explicit reference destinations, following further references as needed. Retain requirements in other tasks that protect behavior affected by this diff without implementing those other tasks. Once readiness is established, update the target task's state line to `状態：進行中`. For an old-format spec, update its task-list marker instead, as specified in the compatibility rules.
2. Collect transcription context before writing anything: find existing code closest to what this AC touches (same layer, similar feature), and note its naming, error handling, and test style. New code follows these observed patterns.

   If an observed pattern appears inferior to a general best practice, present a discussion draft BEFORE starting implementation:
   - 観測パターン：file:line と要約
   - 一般論：代替案と、それが優れるとされる根拠
   - 具体的な不利益：このコードベースで実際に起きている、または起きうる問題。挙げられない場合は好みの差なので、提示せず観測パターンに従う
   - 影響範囲：一般論に切り替えた場合に揃え直しが必要な箇所の見積もり
   - 推奨：観測パターンに従う / このACから一般論を採用 / 別specとして移行を起こす

   Wait for the user's decision. If the user defers, follow the observed pattern for this AC.

3. Write failing tests transcribed directly from each acceptance criterion's input or operation and expected observable result. When a criterion has no runnable behavior, transcribe it into an existence check instead.
4. Implement in one pass. If a decision the spec does not determine arises mid-implementation, stop. Report it as a spec defect and return to spec-authoring. Do not resolve it inline and keep typing.
5. Run the narrowest relevant test until green, or confirm the existence check succeeds.
6. Run spec-implementation-check and follow its judgement.
