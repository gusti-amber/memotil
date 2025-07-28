class RenameMemosToTextPosts < ActiveRecord::Migration[7.2]
  def up
    # テーブル名を変更
    rename_table :memos, :text_posts

    # Postモデルのpostable_typeを更新
    execute "UPDATE posts SET postable_type = 'TextPost' WHERE postable_type = 'Memo'"
  end

  def down
    # 元に戻す
    execute "UPDATE posts SET postable_type = 'Memo' WHERE postable_type = 'TextPost'"
    rename_table :text_posts, :memos
  end
end
