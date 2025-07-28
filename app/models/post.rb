class Post < ApplicationRecord
  belongs_to :task
  belongs_to :user
  delegated_type :postable, types: %w[TextPost], dependent: :destroy
  accepts_nested_attributes_for :postable
end
