# PR Description Examples

Real editing history from a refactoring PR that went through 4 revisions. Each version fixes a specific problem, showing how to arrive at a good PR description.

## The PR

Consolidate duplicated patterns (user lookup, pagination helpers, error messages) across 13 API handlers into shared middleware and utilities. Pure refactoring, no behavioral changes.

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
- File names and function names in every bullet - this is implementation detail, not motivation
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
- Each change gets its own paragraph with its own problem→solution arc - three mini-narratives instead of one
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
- Changes has 7 items. Items 4-7 are mechanical consequences of items 1-3:
  - "Add `getUser(c)` context accessor" follows naturally from adding `userMiddleware`
  - "Replace the 5-line block in all 13 handlers" is the whole point of the middleware
  - "Split route groups" is a routing adjustment implied by the middleware
  - "Update `integration_test.go`" is a test update implied by the middleware
- A reviewer seeing 7 items thinks "large PR", but only 3 things actually happened

## v4 (final) — Summary tells the whole story

```markdown
## Summary

PR #10 built the API layer incrementally, and identical patterns emerged
across all 13 handlers.

Now that the API shape has stabilized, this PR extracts those patterns
into shared middleware and helpers. Pagination helpers had no clear owner
because they lived in a handler file despite being used by three handlers.
Error response helpers had diverged between handlers, producing inconsistent
messages for clients. The user lookup block was copy-pasted everywhere
instead of following the existing middleware pattern.

No behavioral changes.
```

**Why this works:**
- Summary uses paragraph breaks. First paragraph: context (prior PR created duplication). Second paragraph: approach and judgment for each consolidation. Third paragraph: scope
- No Changes section. The diff shows what moved where. Summary adds *why* each consolidation was needed ("had no clear owner", "had diverged", "instead of following the existing pattern")
- No lists appended with dashes or colons. Each judgment is its own sentence

## Summary of the progression

| Version | Anti-pattern | Fix applied |
|---|---|---|
| v1 → v2 | Bullet list of diff changes | Added motivation (problem → solution) per change |
| v2 → v3 | Implementation details mixed into Summary | Separated Summary from Changes |
| v3 → v4 | Per-change paragraphs + redundant Changes section | Unified narrative with judgment in Summary, no Changes |

---

# Tool Introduction PR Example

Real editing history from a linter introduction PR that went through 3 revisions. Covers a pattern not shown in the refactoring example above: introducing a new tool where the key information is *why this tool* and *what judgment calls were made in configuration*.

## The PR

Introduce textlint to a documentation-heavy repository to catch common writing issues (redundant expressions, incorrect terminology) automatically via pre-commit hook and CI.

## v1 — Implementation dump

```markdown
## Summary

textlint を導入した。30ファイルを対象に、preset-ja-technical-writing と
textlint-rule-preset-jtf-style を設定し、pre-commit hook で自動実行されるようにした。
また CI でも textlint を実行するワークフローを追加した。

## Changes

- `.textlintrc.json` を追加（preset-ja-technical-writing; preset-jtf-style; 一部ルール無効化）
- `package.json` に textlint 関連の devDependencies を追加
- `.husky/pre-commit` に textlint コマンドを追加
- `.github/workflows/lint.yml` に textlint ジョブを追加
- `docs/` 配下の 30 ファイルで検出された指摘を修正

## Test plan

- [x] `npx textlint docs/` を実行してエラーが 0 件であることを確認
- [x] pre-commit hook が動作することを確認
- [x] CI が通ることを確認
```

**Problems:**
- Summary にファイル数(30)、プリセット名、pre-commit hook など実装詳細が漏れ出ている
- なぜ textlint なのか、なぜこのプリセットなのかの判断根拠がない
- 括弧とセミコロンで1行に詰め込んでおり読みにくい
- ツールへのリンクがない
- Test plan はドキュメント変更が主なので不要

## v2 — Judgment added but structure still flat

```markdown
## Summary

ドキュメントのレビューで表記ゆれや冗長表現の指摘が繰り返されていた。人手で毎回拾うのはコストが高いため、自動検出できる仕組みが必要だと考えた。

textlint は日本語の技術文書向けプリセットが充実しており、既存の ESLint/Prettier と同じ Node.js ツールチェインに乗るため導入コストが低いと判断した。

## Changes

- textlint の設定を追加（preset-ja-technical-writing をベースに、句読点スタイルは既存ドキュメントに合わせて無効化）
- pre-commit hook と CI ワークフローで自動実行されるように設定
- 既存ドキュメントの指摘箇所を修正
```

**Better, but:**
- Changes の1項目目で括弧内に設定判断の説明を詰め込んでいる。サブリストで分けるべき
- textlint へのリンクがない
- Test plan がまだ残っている（ドキュメント修正とツール設定だけなので不要）

## v3 (final) — Judgment in Summary, no Changes

```markdown
## Summary

ドキュメントのレビューで表記ゆれや冗長表現の指摘が繰り返されていました。人手で毎回拾うのはコストが高いため、自動検出できる仕組みが必要だと考えました。

[textlint](https://textlint.github.io/) は日本語の技術文書向けプリセットが充実しており、既存の ESLint/Prettier と同じ Node.js ツールチェインに乗るため導入コストが低いと判断しました。RedPen も検討しましたが、日本語向けプリセットのエコシステムの厚さで textlint を選びました。

設定は preset-ja-technical-writing と preset-jtf-style をベースにしています。sentence-length ルールは既存ドキュメントがデフォルト上限を超える箇所が多く、全修正はこの PR のスコープ外のため無効化しました。
```

**Why this works:**
- 1段落目で「なぜ必要か」、2段落目で「なぜ textlint か」の判断根拠、3段落目で設定の判断理由を説明している
- textlint へのリンクがあり、レビュアーがツールを知らなくても参照できる
- Changes セクションはない。diff で分かる「何をしたか」を繰り返す代わりに、「なぜそうしたか」を Summary の段落として書いている
- ファイル数やファイル名は diff で分かるので書いていない
- Test plan はドキュメント修正とツール設定のみの PR なので省略している

## Summary of the progression

| Version | Anti-pattern | Fix applied |
|---|---|---|
| v1 → v2 | Implementation details in Summary, no judgment | Added motivation and tool selection reasoning |
| v2 → v3 | Separate Changes section that restates the diff, unnecessary Test plan | Judgment folded into Summary paragraphs, no Changes, no Test plan |
