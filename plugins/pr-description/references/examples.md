# PR Description Examples

PR Summary の「悪い例」と「良い例」を対比で見せる例集です。SKILL.md の原則だけだと抽象的になりがちな部分を、具体的な書き直しの差分で補います。

## 目次

| シナリオ | 学べること | 形式 |
|---|---|---|
| [Refactoring (英)](#refactoring-pr-example-英語進化メカニズム) | 段階的に書き直すと何が直るか | v1 → v4 の 4 段階 |
| [Refactoring (日)](#refactoring-pr-example-日本語結論レベルへの抽象化) | 結論レベルまで抽象化する | Before / After |
| [Tool Introduction (日)](#tool-introduction-pr-example-判断根拠の重要性) | 「なぜこの選定か」を語る | Before / After |
| [Large Migration (日)](#large-migration-pr-example-長い-pr-の構造化) | 長い PR を見出しで構造化する | Before / After |
| [Bug-fix (日)](#bug-fix-pr-example-多段現象の構造化) | 多段の再現手順を番号付きリストで | Before / After |

「進化メカニズム」を最初に英語例で 1 度だけ見せ、それ以降は各シナリオで Before / After の対比だけを示します。中間段階の修正過程は最初の例から類推してください。

---

# Refactoring PR Example (英語、進化メカニズム)

## The PR

Consolidate duplicated patterns (user lookup, pagination helpers, error messages) across 13 API handlers into shared middleware and utilities. Pure refactoring, no behavioral changes.

## v1: Diff summary as bullet list

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
- File names and function names in every bullet, this is implementation detail, not motivation
- No project context: what happened before this PR that created the duplication?
- A reviewer reading only this Summary still doesn't know *why now*

## v2: Per-change paragraphs

```markdown
## Summary

Several shared helpers (`PaginatedResponse`, `parsePaginationParams`,
`encodeCursor`) lived in `topic_handler.go` despite being used by three
different handlers. This made it unclear where to find pagination logic and
risked accidental breakage when editing topic-specific code. They are now in
a dedicated `pagination.go`.

The ownership-check error message was inconsistent. `topic_handler.go`
returned `"access denied"` while every other handler returned `"forbidden"`
for the same 403 scenario. Unified to `"forbidden"` so clients can rely on
a single error string.

Every protected handler repeated the same 5-line `getFirebaseUID` →
`GetUserByFirebaseUID` → 404 pattern (13 occurrences). This duplication
meant any change to user-lookup behavior required editing every handler file.
A new `userMiddleware` performs the lookup once and stores the result in the
Echo context, matching the existing `firebaseAuthMiddleware` pattern. Handlers
now call `getUser(c)` instead.

No logic changes, only code movement, message alignment, and deduplication.
```

**Better, but:**
- Each change gets its own paragraph with its own problem→solution arc, three mini-narratives instead of one
- Summary still contains implementation details (`pagination.go`, `getUser(c)`, `Echo context`)
- Reads like three separate PRs stitched together, not one cohesive change

## v3: Separated Summary/Changes, but Changes is bloated

```markdown
## Summary

Several shared helpers (`PaginatedResponse`, `parsePaginationParams`,
`encodeCursor`) lived in `topic_handler.go` despite being used by three
different handlers. This made it unclear where to find pagination logic and
risked accidental breakage when editing topic-specific code.

The ownership-check error message was inconsistent. `topic_handler.go`
returned `"access denied"` while every other handler returned `"forbidden"`
for the same 403 scenario. Clients couldn't rely on a single error string
for ownership failures.

Every protected handler repeated the same 5-line `getFirebaseUID` →
`GetUserByFirebaseUID` → 404 pattern (13 occurrences). Any change to
user-lookup behavior required editing every handler file.

No logic changes, only code movement, message alignment, and deduplication.

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
- Changes has 7 items. Items 4-7 are mechanical consequences of items 1-3
- A reviewer seeing 7 items thinks "large PR", but only 3 things actually happened

## v4 (final): Summary tells the whole story

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
- Three paragraphs: context, approach with judgment, scope
- No Changes section. The diff shows what moved where. Summary adds *why* each consolidation was needed
- Each judgment is its own sentence

## Progression at a glance

| Step | Anti-pattern | Fix applied |
|---|---|---|
| v1 → v2 | Bullet list of "what changed" instead of narrative of "why" | Added motivation per change |
| v2 → v3 | Implementation details mixed into Summary | Separated Summary from Changes |
| v3 → v4 | Per-change paragraphs + redundant Changes section | Unified narrative with judgment in Summary, no Changes |

この英語例だけ 4 段階に展開しているのは、Summary を書き直すと何がどう直るかを順を追って示すためです。以降の例では同じメカニズムを Before / After の対比だけで示します。

---

# Refactoring PR Example (日本語、結論レベルへの抽象化)

複数の画面コンポーネントに同じ fetch / loading / error の状態管理パターンが散らばっていたものを、共通カスタムフックに集約する PR。挙動の変更なし。

## Before (実装名を Summary に列挙してしまった版)

```markdown
## Summary

直近の機能追加で新しい画面が増え、どの画面でも fetch、loading 表示、error ハンドリングのコードがほぼ同じ形で繰り返されるようになりました。コピーペーストが進むほど、ロード中スピナーの仕様変更やエラー文言の統一が漏れやすくなります。

そこで `useResource` というカスタムフックを新設し、`UserProfile`、`OrderList`、`SettingsPanel` をこのフックに置き換えました。fetch、loading state、error state の管理が 1 か所にまとまるため、今後の挙動変更も 1 か所で済みます。

挙動の変更はありません。
```

## After (結論レベルまで抽象化した版)

```markdown
## Summary

直近の機能追加で画面が増え、どの画面でも fetch と loading / error 表示のコードが似た形でコピーされるようになりました。仕様変更やエラー文言の統一が、画面ごとに同じ修正を繰り返す作業に化けていたため、ここで共通化します。

主要な画面の状態管理ロジックをカスタムフックに集約しました。これによって今後、ロード中表示やエラー時の挙動を変える際に、フックを 1 か所触れば全画面に反映できます。

挙動の変更はありません。既存のテストは引き続き通ります。
```

## Lesson

Before では「`UserProfile`、`OrderList`、`SettingsPanel`」「fetch、loading state、error state」と画面名や項目を列挙していました。これらは diff を見れば分かる情報です。After では「主要な画面」「状態管理ロジック」と一段階上の抽象に持ち上げ、Summary では「変えれば全画面に効く」という判断軸だけが残るようにしています。実装の列挙を Summary に書きたくなったら、その上位概念で言い換えられないか試してください。

---

# Tool Introduction PR Example (判断根拠の重要性)

ドキュメント中心リポジトリに textlint を導入し、表記ゆれや冗長表現を pre-commit / CI で自動検出する PR。

## Before (実装ダンプ、判断根拠なし)

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

## After (判断根拠を Summary に、Changes / Test plan は省略)

```markdown
## Summary

ドキュメントのレビューで表記ゆれや冗長表現の指摘が繰り返されていました。人手で毎回拾うのはコストが高いため、自動検出できる仕組みが必要だと考えました。

[textlint](https://textlint.github.io/) は日本語の技術文書向けプリセットが充実しており、既存の ESLint/Prettier と同じ Node.js ツールチェインに乗るため導入コストが低いと判断しました。RedPen も検討しましたが、日本語向けプリセットのエコシステムの厚さで textlint を選びました。

設定は preset-ja-technical-writing と preset-jtf-style をベースにしています。sentence-length ルールは既存ドキュメントがデフォルト上限を超える箇所が多く、全修正はこの PR のスコープ外のため無効化しました。
```

## Lesson

ツール導入 PR で本当にレビューしてほしいのは「やったこと」ではなく「なぜそのツールを選んだか / なぜその設定にしたか」の判断です。Before はファイル名やプリセット名で埋まっていますが、判断根拠は読み取れません。After では 1 段落目で動機、2 段落目でツール選定の判断（代替案との比較含む）、3 段落目で設定判断、と段落ごとに 1 つの判断を語っています。ツール名にリンクを置くと、知らないレビュアーがすぐ確認できます。ドキュメント / 設定変更だけの PR なら Test plan も省略してかまいません。

---

# Large Migration PR Example (長い PR の構造化)

本番 RDB を PostgreSQL 12 から 16 にメジャーバージョンアップする PR。互換性検証で見つかったクエリ修正、監視閾値の更新、ロールアウト計画までを 1 PR にまとめる。メンテナンス枠は深夜 30 分以内。

## Before (動機なく Changes を並べただけ)

```markdown
## Summary

PostgreSQL を 12 から 16 にアップグレードします。pg_upgrade を使用します。検証環境ではすでに動作確認済みです。

## Changes
- PostgreSQL バージョンを 12 から 16 に変更
- 古いクエリを 2 つ修正
- 監視閾値を変更
- Runbook を追加

## Test plan
- [x] 検証環境でアップグレードを実施
- [x] 全 API のスモークテスト
```

## After (見出しで構造化、判断は Plan / Runbook にリンク)

```markdown
## Summary

### 背景

PostgreSQL 12 のコミュニティサポートが 2026/11 で終了します。EOL 後にセキュリティパッチが当たらないリスクを避けるため、サポート期間中に PG16 まで一気に上げます。

### アプローチ

メンテナンス枠が深夜 30 分以内という制約に収めるため、`pg_upgrade --link` モードを採用しました。dump/restore はデータ量 (約 800GB) で 4〜6 時間かかるため不可、論理レプリケーションと Blue-Green デプロイは運用負荷とディスク容量の観点で本 PR のスコープでは見送っています。手段比較の詳細は [Plan: 2026-04-30-postgres-upgrade-strategy](https://example.invalid/plans/2026-04-30-postgres-upgrade-strategy) を参照してください。

### 影響と対応

互換性検証で挙動が変わるクエリが 3 件見つかったため、本 PR で修正しています。

1. PG13 で `string_agg` の NULL 引数の扱いが変わった影響を受けるクエリ (2 件)
2. PG14 で `regexp_match` の戻り型が変わった影響を受けるクエリ (1 件)

具体的な変更点は diff を参照してください。両方とも [PostgreSQL リリースノート](https://example.invalid/postgres-release-notes) に記載のある仕様変更で、内部挙動の詳細は Plan に整理しています。

監視ダッシュボードは PG16 で再設計されたバッファマネージャ統計に合わせ、buffer_hit_ratio とコネクション数の閾値を再キャリブレーションしました。古い閾値のままだと PG16 で誤検知が増えるため、同 PR に含めています。

### ロールアウト

dev → staging → prod の順で進めます。staging では 5/15 から 1 週間流し、エラー率と p95 レイテンシに有意な変化がないことを確認済みです。本番投入は 5/30 深夜 2:00 - 2:30 のメンテナンス枠を予約しています。

### スコープ外

論理レプリケーションの導入は本 PR には含みません。別 PR (#412) で対応します。今回は in-place アップグレードに専念し、レプリケーション構成の変更は分離しています。

## 関連リンク

- [Plan: 2026-04-30-postgres-upgrade-strategy](https://example.invalid/plans/2026-04-30-postgres-upgrade-strategy)
- [Runbook: PostgreSQL アップグレード手順](https://example.invalid/runbooks/postgres-upgrade)
- 別 PR #412 (論理レプリケーション導入)

## Test plan
- [x] dev 環境で `pg_upgrade --link` を実施し、全 API のスモークテストが通ることを確認
- [x] staging 環境で 1 週間運用 (5/15 〜 5/22)、エラー率と p95 レイテンシに有意な変化がないことを確認
- [ ] 本番投入 (5/30 深夜 2:00 - 2:30)
- [ ] 本番投入後 24 時間のメトリクスモニタリング
```

## Lesson

Summary が長くなる PR でも、見出しで切ると読みやすさは落ちません。逆に、長くなる必然性のない情報（4 手段の比較詳細、PG 内部仕様の解説など）を Summary に詰め込むと、長さに比例して読みにくくなります。「### 背景 / ### アプローチ / ### 影響と対応 / ### ロールアウト / ### スコープ外」と機能ごとに見出しを切り、内部詳細は Plan や Runbook へのリンクに逃がす、という構造が長い PR では効きます。冒頭の「### 背景」は非エンジニアレビュアー（PM / SRE / セキュリティ）が真っ先に読むパートとして使えます。

---

# Bug-fix PR Example (多段現象の構造化)

決済確定画面で二重決済が発生する PR。再現は多段の手順で、根本原因がブラウザ内部の race にあるため、Plan へのリンクで詳細を逃がす必要がある。

## Before (多段の再現手順を 1 段落に圧縮)

```markdown
## Summary

決済確定画面で二重決済の問い合わせが断続的に発生していました。再現する流れとしては、ユーザーが確認画面から「戻る」で入力画面に戻り、もう一度「確認」ボタンを押すと submit ハンドラが過去のナビゲーションに紐づいた状態を保持したまま再発火し、サーバー側は別リクエストとして処理されるため同一注文が 2 件作成される、という挙動になっていました。修正としては、ナビゲーションごとにトークンを発行し、submit ハンドラがトークン不一致を検出した場合は早期 return するようにしました。
```

## After (ビジネス影響 + 番号付きリスト + Plan リンク)

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

## Lesson

Before の問題は 2 つあります。まず冒頭にビジネス影響（アラート発火、影響セッション率）がないため、非エンジニアのレビュアーが温度感をつかめません。次に、3 段階の再現手順を散文 1 段落で書いており、レビュアーが流れを把握するのに読み直しが必要です。After では冒頭で影響を提示し、再現手順を番号付きリスト化することで、1 回スキャンするだけで把握できる構造にしています。ブラウザ内部や React Router の内部挙動などの根本原因詳細は Plan へのリンクに集約し、Summary には「ブラウザ History API と SPA navigation state の race」という結論レベルの 1 文だけ残します。検討して見送った代替案も 1 行 + Plan リンクで足ります。
