# frozen_string_literal: true

class Users::Mailer < Devise::Mailer
  # 🎓 カスタムメーラーを使用することで、app/views/users/mailer/ からテンプレートを探すようになる

  # インライン添付ファイルとしてロゴを追加
  # 🎓 インライン添付ファイルを作成する: https://railsguides.jp/v7.2/action_mailer_basics.html#%E3%82%A4%E3%83%B3%E3%83%A9%E3%82%A4%E3%83%B3%E6%B7%BB%E4%BB%98%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%82%92%E4%BD%9C%E6%88%90%E3%81%99%E3%82%8B
  before_action :attach_logo

  private

  def attach_logo
    attachments.inline["logo.svg"] = File.read(Rails.root.join("app", "assets", "images", "logo.svg"))
  end
end
