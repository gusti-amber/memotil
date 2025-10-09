class DocumentPost < ApplicationRecord
  include Postable
  belongs_to :document

  validates :document_id, presence: true
end
