class Task < ApplicationRecord
  belongs_to :user

  enum status: { todo: 0, doing: 1, done: 2 }

  validates :title, presence: true, length: { minimum: 2, maximum: 255 }
  validates :status, presence: true
end
