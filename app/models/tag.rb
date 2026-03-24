class Tag < ApplicationRecord
  belongs_to :user, optional: true, inverse_of: :tags

  has_many :tasktags, dependent: :destroy
  has_many :tasks, through: :tasktags

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }, if: -> { user_id.nil? }
  validates :name, uniqueness: { case_sensitive: false, scope: :user_id }, if: -> { user_id.present? }

  scope :system_tags, -> { where(user_id: nil) }

  def self.for_user(user)
    system_tags.or(where(user_id: user.id))
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end
end
