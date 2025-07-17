class Task < ApplicationRecord
  belongs_to :user

  has_many :tasktags
  has_many :tags, through: :tasktags
  has_many :todos, dependent: :destroy

  enum status: { todo: 0, doing: 1, done: 2 }

  validates :title, presence: true, length: { minimum: 2, maximum: 255 }
  validates :status, presence: true
end
