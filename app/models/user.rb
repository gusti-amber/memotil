class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable,
          :omniauthable, omniauth_providers: [:github]
          # 🎓 UserモデルにOmniAuthを導入する方法（プロバイダがfacebookの場合）: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview#facebook-example

  has_many :tasks, dependent: :destroy
  has_many :posts, dependent: :destroy
  # カスタムバリデーション
  validates :name, presence: true, length: { minimum: 2, maximum: 20 }
end
