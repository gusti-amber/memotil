class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: [ :github ]
  # 🎓 UserモデルにOmniAuthを導入する方法（プロバイダがfacebookの場合）: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview#facebook-example

  has_many :tasks, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :tags, dependent: :destroy, inverse_of: :user
  # カスタムバリデーション
  validates :name, presence: true, length: { minimum: 2, maximum: 20 }

  after_create :create_dummy_data, unless: -> { guest_user? || Rails.env.test? }

  def self.from_github(auth)
    # 👍 今後、メールアドレスなどでログインしている状態でタスク詳細画面からGitHub認証を行う場合、GitHubアカウントの情報を既存のUserレコードに追加する処理を実装予定。
    # find_or_create_byのブロック内で新規ユーザーが作成された場合、after_createコールバックが自動的に呼ばれ、ダミーデータが生成される
    user = find_or_create_by(github_uid: auth.uid) do |u|
      u.email = auth.info.email
      u.password = Devise.friendly_token[0, 20]
      u.name = auth.info.name || auth.info.nickname
      u.github_token = auth.credentials.token
      u.skip_confirmation! # GitHub認証を行うユーザーはメールアドレスの確認処理をスキップ
    end

    # 既存ユーザーの場合もトークンを更新する（スコープ変更に対応するため）
    if user.persisted? && user.github_token != auth.credentials.token
      user.update(github_token: auth.credentials.token)
    end

    # 既存ユーザーが未確認の場合、確認処理をスキップ
    if user.persisted? && user.confirmed_at.nil?
      user.skip_confirmation!
      user.save
    end

    user
  end

  def guest_user?
    return false unless email

    email.start_with?("guest_") && email.end_with?("@example.com")
  end

  def github_user?
    github_uid.present?
  end

  # 確認メール必須かどうかを判定するメソッド
  # ゲストユーザーとGitHub認証ユーザーの場合はfalse(確認不要)、通常ユーザーの場合はtrue(確認メール必須)
  # 参考wiki: https://www.rubydoc.info/github/plataformatec/devise/Devise/Models/Confirmable#confirmation_required%3F-instance_method
  def confirmation_required?
    !guest_user? && !github_user?
  end

  private

  # ✨ 将来的に、ダミーデータの生成はサービスではなく、Userモデルに移行する
  # そのためには、ゲストユーザーの生成ロジックもUserモデルに移行する必要がある
  def create_dummy_data
    DummyDataCreatorService.new(self).call
  end
end
