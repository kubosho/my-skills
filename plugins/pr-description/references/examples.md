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
| v1 → v2 | Bullet list of "what changed" instead of narrative of "why" | Added motivation (problem → solution) per change |
| v2 → v3 | Implementation details mixed into Summary | Separated Summary from Changes |
| v3 → v4 | Per-change paragraphs + redundant Changes section | Unified narrative with judgment in Summary, no Changes |

The lesson here is about diff-restating bullet lists, not about lists in general. Lists are fine when they enumerate genuinely parallel items or sequential steps. They hurt when they replace a narrative with a flat retelling of the diff.

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

---

# Bug-fix PR Example (multi-step reproduction)

Real editing history from a bug-fix PR that went through 3 revisions. Covers the case the refactoring and tool-introduction examples don't: a bug whose reproduction is a multi-step sequence and whose root cause involves runtime internals. Structure (numbered lists, subheadings) helps reviewers scan the flow. Internal mechanism details belong in a linked Plan, not the Summary.

## The PR

A checkout page intermittently submits the order twice when the user navigates back from the confirmation screen and then re-submits. Roughly 0.4% of checkout sessions are affected, triggering duplicate-charge alerts. The fix gates the submit handler on a per-navigation token and links to the Plan that documents the History API behavior involved.

## v1 — Prose-only, multi-step flow crammed into one paragraph

```markdown
## Summary

決済確定画面で二重決済の問い合わせが断続的に発生していました。再現する流れとしては、ユーザーが確認画面から「戻る」で入力画面に戻り、もう一度「確認」ボタンを押すと submit ハンドラが過去のナビゲーションに紐づいた状態を保持したまま再発火し、サーバー側は別リクエストとして処理されるため同一注文が 2 件作成される、という挙動になっていました。修正としては、ナビゲーションごとにトークンを発行し、submit ハンドラがトークン不一致を検出した場合は早期 return するようにしました。
```

**Problems:**

- 再現手順が 1 段落に詰め込まれており、レビュアーが流れを追うのに 2 回読み直す必要がある
- 「ビジネス影響」（二重決済アラート / 影響セッション率）が冒頭にない。非エンジニアのレビュアーが温度感を掴めない
- 「修正としては」が散文に埋もれており、変更の主軸がスキャンしづらい

## v2 — Plan の内部解析まで PR Summary に流し込んだ過剰版

```markdown
## Summary

決済確定画面で二重決済の問い合わせが断続的に発生していました。0.4% の checkout セッションが影響を受け、duplicate-charge アラートを継続的に発火させていました。

ブラウザの History API では popstate イベント発火時に history entry の state が以前のスナップショットを保持し続けます。Chromium ソースを確認したところ、`NavigationController::HandleRendererDebugURL` 周辺で state restore のタイミングが session history の traversal direction によって変わるため、`history.replaceState` 直後の `popstate` で古い state が混入する可能性があります。さらに React Router の `useNavigate` は内部的に history.push を呼び出す前に `useRef` で保持した previous state を参照しており、これと組み合わさると submit ハンドラに渡される navigation context が 1 ステップ古い状態になります。

このため、ナビゲーションごとにトークンを発行し、submit ハンドラがトークン不一致を検出した場合は早期 return するようにしました。トークン方式は厳密にはレースを完全に防ぐわけではありませんが、観測された不整合のうち 99% 以上はこのパスで吸収できます。RFC 7231 の冪等性ガイドラインも参照しましたが、今回のスコープでは冪等キーをサーバー側に追加するより前段で弾く方が低リスクと判断しました。

なお、Safari と Firefox では再現せず、Chromium 系のみで観測されています。ただし他ブラウザでも同等の race が潜在的に起こりうるため、ブラウザ判定で分岐する方針は取りませんでした。
```

**Problems:**

- Chromium 内部ソースの参照や React Router の `useRef` 挙動は Plan / 調査メモに残すべき内容で、PR Summary には冗長
- 「99% 以上のパスで吸収」「RFC 7231 を参照したが冪等キーは見送り」といった alternative 検討の歴史も Plan のスコープ
- 5 段落 / 約 1000 字に達しており、レビュアーが意思決定に必要な情報を取り出すコストが高い
- 再現手順は依然として散文で、流れを追いづらい

## v3 (final) — Business impact 冒頭 + 構造化された再現手順 + Plan へのリンク

```markdown
## Summary

決済確定画面で二重決済の問い合わせが断続的に発生し、duplicate-charge アラートが継続発火していました。直近 7 日間で checkout セッションの約 0.4% が影響を受けています。

再現する流れは以下です。

1. ユーザーが確認画面から「戻る」で入力画面に戻る
2. 入力画面で内容を変えずに「確認」ボタンを再度押す
3. submit ハンドラが過去のナビゲーションに紐づいた state を保持したまま再発火し、サーバー側で別リクエストとして処理される

根本原因はブラウザの History API と SPA のナビゲーション state 管理の組み合わせで発生する race です。詳細な解析は [Plan: 2026-05-15-duplicate-checkout-investigation](https://example.invalid/plans/2026-05-15-duplicate-checkout-investigation) にまとめています。

### 修正内容

1. ナビゲーションごとにトークンを発行し、submit ハンドラの引数として渡す
2. submit ハンドラはトークン不一致を検出した場合に早期 return する
3. token 発行の単体テストと、戻る→再 submit のシナリオを E2E に追加する

冪等キーをサーバー側に追加する案も検討しましたが、Plan に記載のとおり今回のスコープでは見送っています。
```

**Why this works:**

- 冒頭で「二重決済」「アラート発火」「影響セッション率」を提示し、非エンジニアのレビュアーも温度感を共有できる
- 再現手順を番号付きリストにしたことで、レビュアーは流れを 1 回スキャンするだけで把握できる
- 内部メカニズム（History API の挙動、React Router の挙動、Chromium 内部）はすべて Plan へのリンクに集約し、Summary は意思決定と結果に集中している
- `### 修正内容` 見出しで「現象」と「対策」が視覚的に分離され、長めの Summary でもスクロールしやすい
- 検討して見送った代替案は 1 行 + リンクで触れるだけで、Plan の議論を Summary に流し込んでいない

## Summary of the progression

| Version | Anti-pattern | Fix applied |
|---|---|---|
| v1 → v2 | 多段の再現手順を 1 段落に圧縮、ビジネス影響なし | ビジネス影響を冒頭に追加、根本原因に踏み込んだ |
| v2 → v3 | Plan / 調査メモの内部解析を Summary に流し込み、長大化 | 内部詳細は Plan リンクに外出し、再現手順を番号付きリストで構造化、検討済み代替案は 1 行に圧縮 |
