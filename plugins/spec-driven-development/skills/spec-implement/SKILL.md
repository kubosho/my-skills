---
name: spec-implement
description: Implement one task identified by AC-N from a spec's settled design. Use for spec-based implementation.
argument-hint: "<docs/specs/spec-file.md or GitHub Issue URL> [AC-N]"
---

Implement exactly one task from the given spec.

Follow [spec-driven-development](../spec-driven-development/SKILL.md).

If no spec location is provided, ask for it.

If no task is specified, pick the first ready task in spec order. Check readiness for an explicitly selected task too. If none is ready, report what is missing.

1. Gather the applicable requirements, then mark the target task in progress.
2. Collect transcription context before writing anything: find existing code closest to what this task touches (same layer, similar feature), and note its naming, error handling, and test style. New code follows these observed patterns.

   If an observed pattern appears inferior to a general best practice, present a discussion draft BEFORE starting implementation:
   - 観測パターン：file:line と要約
   - 一般論：代替案と、それが優れるとされる根拠
   - 具体的な不利益：このコードベースで実際に起きている、または起きうる問題。挙げられない場合は好みの差なので、提示せず観測パターンに従う
   - 影響範囲：一般論に切り替えた場合に揃え直しが必要な箇所の見積もり
   - 推奨：観測パターンに従う / このタスクから一般論を採用 / 別specとして移行を起こす

   Wait for the user's decision. If the user defers, follow the observed pattern for this task.

3. Write failing tests transcribed directly from each acceptance criterion's input or operation and expected observable result. When a criterion has no runnable behavior, transcribe it into an existence check instead.
4. Implement the behavior or artifact specified by the tests or existence checks from step 3. If a decision the spec does not determine arises mid-implementation, stop. Report it as a spec defect and return to spec-authoring.
5. Run the narrowest relevant test until green, or confirm the existence check succeeds.
6. Run spec-implementation-check and follow its judgement.
