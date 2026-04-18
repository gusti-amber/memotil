# rakeタスク運用メモ

## documents:backfill_ogp

### 目的

`documents` テーブルに OGP 用カラム（`title` / `description` / `image_url`）を追加したマイグレーション適用後、**既存レコード**のこれらのカラムを外部サイトから取得して埋める。新規作成時はアプリ側で自動取得されるため、本タスクは**過去データの一度きりの移行**に相当する。

### 実行タイミング

- 該当マイグレーションを本番に適用した**直後**に、手動で 1 回実行する。
- 開発環境では、マイグレーション後に必要に応じて実行する。

### 開発環境での実行

```zsh
docker compose exec web bundle exec rails documents:backfill_ogp
```

### 本番環境（Render）での実行

1. 実行前に **DB のバックアップ取得**を推奨する。
2. Render ダッシュボード → 対象の Web Service → **Shell** タブを開く。
3. 次を実行する。

   ```zsh
   bundle exec rails documents:backfill_ogp
   ```

4. 完了後、Rails コンソール等で成功状況を確認できる。

   ```ruby
   Document.where(title: nil).count
   ```

   `title` が取得できなかったレコードは `nil` のまま残る。表示は `card_title` の URL フォールバックで破綻しない。

### 挙動

- 対象は **`title` が `nil` の `Document` のみ**（何度実行しても同じ結果になりやすい冪等な範囲）。
- 外部サイトへの負荷を避けるため、レコード間に短い待機を挟む。
- 1 件で失敗してもタスク全体は継続し、ログに記録する。
