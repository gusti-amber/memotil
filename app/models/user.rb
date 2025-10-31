class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
          :omniauthable, omniauth_providers: [ :github ]
  # 🎓 UserモデルにOmniAuthを導入する方法（プロバイダがfacebookの場合）: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview#facebook-example

  has_many :tasks, dependent: :destroy
  has_many :posts, dependent: :destroy
  # カスタムバリデーション
  validates :name, presence: true, length: { minimum: 2, maximum: 20 }

  def self.from_github(auth)
    find_or_create_by(github_uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name || auth.info.nickname
      user.github_token = auth.credentials.token
    end
  end
end
