# PR Description Examples

Real editing history from a refactoring PR that went through 4 revisions. Each version fixes a specific problem, showing how to arrive at a good PR description.

## The PR

Consolidate duplicated patterns (user lookup, pagination helpers, error messages) across 13 API handlers into shared middleware and utilities. Pure refactoring — no behavioral changes.

## v1 — Diff summary as bullet list

```markdown
## Summary

- `pagination.go`: `PaginatedResponse`, `parsePaginationParams`,
  `encodeCursor` を `topic_handler.go` から専用ファイルに移動。
  3ハンドラーから使われる共通コードの置き場所を明確化
- エラーメッセージ統一: 所有者チェック失敗時の `"access denied"` を
  他ハンドラーと同じ `"forbidden"` に統一
- `userMiddleware`: 13ハンドラーで繰り返されていた `getFirebaseUID` →
  `GetUserByFirebaseUID` パターンをミドルウェアに抽出。
  各ハンドラーは `getUser(c)` 1行でユーザーを取得
- ロジックの変更なし。既存パターン（`firebaseAuthMiddleware`）に沿った共通化のみ。
```

**Problems:**
- Summary is a bullet list of what changed, not why this PR exists
- File names and function names in every bullet — this is implementation detail, not motivation
- No project context: what happened before this PR that created the duplication?
- A reviewer reading only this Summary still doesn't know *why now*

## v2 — Per-change paragraphs

```markdown
## Summary

Several shared helpers (`PaginatedResponse`, `parsePaginationParams`,
`encodeCursor`) lived in `topic_handler.go` despite being used by three
different handlers. This made it unclear where to find pagination logic and
risked accidental breakage when editing topic-specific code. They are now in
a dedicated `pagination.go`.

The ownership-check error message was inconsistent — `topic_handler.go`
returned `"access denied"` while every other handler returned `"forbidden"`
for the same 403 scenario. Unified to `"forbidden"` so clients can rely on
a single error string.

Every protected handler repeated the same 5-line `getFirebaseUID` →
`GetUserByFirebaseUID` → 404 pattern (13 occurrences). This duplication
meant any change to user-lookup behavior required editing every handler file.
A new `userMiddleware` performs the lookup once and stores the result in the
Echo context, matching the existing `firebaseAuthMiddleware` pattern. Handlers
now call `getUser(c)` instead.

No logic changes — only code movement, message alignment, and deduplication.
```

**Better, but:**
- Each change gets its own paragraph with its own problem→solution arc — three mini-narratives instead of one
- Summary still contains implementation details (`pagination.go`, `getUser(c)`, `Echo context`)
- Reads like three separate PRs stitched together, not one cohesive change

## v3 — Separated Summary/Changes, but Changes is bloated

```markdown
## Summary

Several shared helpers (`PaginatedResponse`, `parsePaginationParams`,
`encodeCursor`) lived in `topic_handler.go` despite being used by three
different handlers. This made it unclear where to find pagination logic and
risked accidental breakage when editing topic-specific code.

The ownership-check error message was inconsistent — `topic_handler.go`
returned `"access denied"` while every other handler returned `"forbidden"`
for the same 403 scenario. Clients couldn't rely on a single error string
for ownership failures.

Every protected handler repeated the same 5-line `getFirebaseUID` →
`GetUserByFirebaseUID` → 404 pattern (13 occurrences). Any change to
user-lookup behavior required editing every handler file.

No logic changes — only code movement, message alignment, and deduplication.

## Changes

- Move `PaginatedResponse`, `parsePaginationParams`, `encodeCursor`, and
  related sentinel errors from `topic_handler.go` to a new `pagination.go`
- Replace `"access denied"` with `"forbidden"` in `topic_handler.go`
  ownership checks
- Add `userMiddleware(queries)` that performs the DB user lookup and stores
  the result in Echo context, following the existing `firebaseAuthMiddleware`
  pattern
- Add `getUser(c)` context accessor in `context_keys.go`
- Replace the 5-line user-lookup block in all 13 handlers with
  `user := getUser(c)`
- Split route groups in `main.go`: login/callback use auth-only middleware,
  all other routes also get `userMiddleware`
- Update `integration_test.go` to include `userMiddleware` in the test setup
```

**Progress:**
- Summary/Changes separation is correct
- But Summary is still three per-change paragraphs, not a unified narrative
- Changes has 7 items — items 4-7 are mechanical consequences of items 1-3:
  - "Add `getUser(c)` context accessor" follows naturally from adding `userMiddleware`
  - "Replace the 5-line block in all 13 handlers" is the whole point of the middleware
  - "Split route groups" is a routing adjustment implied by the middleware
  - "Update `integration_test.go`" is a test update implied by the middleware
- A reviewer seeing 7 items thinks "large PR" — but only 3 things actually happened

## v4 (final) — Unified narrative + primary changes only

```markdown
## Summary

PR #10 built the API layer incrementally, and identical patterns emerged
across all 13 handlers — user lookup, pagination helpers, and error messages.
Now that the API shape has stabilized, this PR consolidates those patterns to
reduce the surface area for future changes.

No behavioral changes. All three commits are pure code movement and
deduplication.

## Changes

- Extract `PaginatedResponse`, `parsePaginationParams`, `encodeCursor` into
  `pagination.go` (used by topic, session, and message handlers but lived in
  `topic_handler.go`)
- Unify ownership-check error message to `"forbidden"` (`topic_handler.go`
  used `"access denied"`, all others used `"forbidden"`)
- Add `userMiddleware` to perform the `getFirebaseUID` →
  `GetUserByFirebaseUID` lookup once per request, replacing the same 5-line
  block repeated in every handler
```

**Why this works:**
- Summary opens with the prior PR (#10) that created the duplication — the reviewer immediately understands why *now*
- "Now that the API shape has stabilized" explains the timing
- Two sentences cover the full motivation; no per-change paragraphs
- "No behavioral changes" sets the reviewer's expectation in one line
- Changes has exactly 3 items — one per primary change
- Parenthetical context explains *why* each change was needed, not just *what*
- Mechanical consequences (test updates, route splitting, context accessor) are gone — they follow from the primary changes and the diff shows them

## Summary of the progression

| Version | Anti-pattern | Fix applied |
|---|---|---|
| v1 → v2 | Bullet list of diff changes | Added motivation (problem → solution) per change |
| v2 → v3 | Implementation details mixed into Summary | Separated Summary from Changes |
| v3 → v4 | Per-change paragraphs + bloated Changes (7 items) | Unified narrative + removed mechanical consequences (3 items) |
