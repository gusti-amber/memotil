class Memo < ApplicationRecord
  include Postable
  
  validates :body, presence: true
end
