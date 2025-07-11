class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :tasks, dependent: :destroy
  # カスタムバリデーション
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
end
