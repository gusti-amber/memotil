class Tag < ApplicationRecord
  has_many :tasktags
  has_many :tasks, through: :tasktags
end
