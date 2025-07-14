class Tasktag < ApplicationRecord
  belongs_to :task
  belongs_to :tag
end
