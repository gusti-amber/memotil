class Post < ApplicationRecord
  belongs_to :task
  belongs_to :user
  delegated_type :postable, types: %w[Memo], dependent: :destroy
end
