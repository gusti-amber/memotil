class Task < ApplicationRecord
  belongs_to :user

  has_many :tasktags, dependent: :destroy
  has_many :tags, through: :tasktags
  has_many :todos, -> { order(created_at: :asc, id: :asc) }, dependent: :destroy
  has_many :posts, dependent: :destroy

  # 🎓 reject_if: :all_blank について、:all_blankが渡されると、_destroyの値を除くすべての属性が空白レコードを受け付けなくなるprocが1つ生成されます。
  #   つまり、_destroyの値を除くすべての属性に値がないと、レコードが作成されないようになる。
  accepts_nested_attributes_for :todos, allow_destroy: true, reject_if: :all_blank

  enum status: { doing: 1, done: 2 }

  validates :title, presence: true, length: { minimum: 2, maximum: 255 }
  validates :status, presence: true
  validate :tags_must_be_five_or_less
  validate :todos_must_be_five_or_less

  def self.ransackable_attributes(auth_object = nil)
    %w[title status]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[tags]
  end

  private

  def tags_must_be_five_or_less
    if tag_ids.present? && tag_ids.length > 5
      errors.add(:tag_ids, :too_many)
    end
  end

  def todos_must_be_five_or_less
    if todos.count > 5
      errors.add(:todos, :too_many)
    end
  end
end
