class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [ :github ]
  # 🎓 UserモデルにOmniAuthを導入する方法（プロバイダがfacebookの場合）: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview#facebook-example

  has_many :tasks, dependent: :destroy
  has_many :posts, dependent: :destroy
  # カスタムバリデーション
  validates :name, presence: true, length: { minimum: 2, maximum: 20 }

  def self.from_github(auth)
    # 👍 今後、メールアドレスなどでログインしている状態でタスク詳細画面からGitHub認証を行う場合、GitHubアカウントの情報を既存のUserレコードに追加する処理を実装予定。
    user = find_or_create_by(github_uid: auth.uid) do |u|
      u.email = auth.info.email
      u.password = Devise.friendly_token[0, 20]
      u.name = auth.info.name || auth.info.nickname
      u.github_token = auth.credentials.token
    end

    # 既存ユーザーの場合もトークンを更新する（スコープ変更に対応するため）
    if user.persisted? && user.github_token != auth.credentials.token
      user.update(github_token: auth.credentials.token)
    end

    user
  end

  def guest_user?
    return false unless email

    email.start_with?("guest_") && email.end_with?("@example.com")
  end
end
