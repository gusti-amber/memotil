# frozen_string_literal: true

# 🎓 UsersテーブルにConfirmable関連のカラムを追加する方法: https://github.com/heartcombo/devise/wiki/How-To:-Add-:confirmable-to-Users

class AddConfirmableToUsers < ActiveRecord::Migration[7.2]
  def up
    # Confirmable関連のカラムを追加
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string # Only if using reconfirmable

    # インデックスを追加
    add_index :users, :confirmation_token, unique: true

    # 既存ユーザーを確認済みとして扱う（confirmed_atを現在時刻で設定）
    User.update_all confirmed_at: DateTime.now
  end

  def down
    # インデックスを削除
    remove_index :users, :confirmation_token

    # カラムを削除
    remove_column :users, :unconfirmed_email
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_token
  end
end
