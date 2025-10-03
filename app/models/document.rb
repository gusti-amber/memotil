class Document < ApplicationRecord
  has_many :document_posts, dependent: :destroy

  validates :url, presence: true, uniqueness: true
end
