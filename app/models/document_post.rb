class DocumentPost < ApplicationRecord
  belongs_to :document
  
  validates :document_id, presence: true
end
