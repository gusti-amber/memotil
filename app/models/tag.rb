class Tag < ApplicationRecord
  has_many :tasktags
  has_many :tasks, through: :tasktags

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end
end
