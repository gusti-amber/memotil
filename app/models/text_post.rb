class TextPost < ApplicationRecord
  include Postable

  validates :body, presence: true
end
