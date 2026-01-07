class TextPost < ApplicationRecord
  include Postable

  validates :body, presence: true, length: { maximum: 1000 }
end
