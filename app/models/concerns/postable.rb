module Postable
  extend ActiveSupport::Concern

  included do
    has_one :post, as: :postable, dependent: :destroy
    has_one :task, through: :post
    has_one :user, through: :post
  end
end 