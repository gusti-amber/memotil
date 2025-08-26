class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :tasks, dependent: :destroy
  has_many :posts, dependent: :destroy
  # カスタムバリデーション
  validates :name, presence: true, length: { minimum: 2, maximum: 20 }
  validates :password, presence: true, length: { minimum: 6 }
end
