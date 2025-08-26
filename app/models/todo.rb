class Todo < ApplicationRecord
  belongs_to :task

  validates :body, presence: true, length: { maximum: 255 }

  def done?
    done
  end
end
