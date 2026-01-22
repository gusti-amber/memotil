class TilForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :path, :string
  attribute :message, :string
  attribute :body, :string
  attribute :repo, :string

  validates :path, presence: true
  validates :repo, presence: true

  validate :validate_path_format

  private

  def validate_path_format
    return if path.blank?

    errors.add(:path, "は.mdで終わる必要があります") unless path.end_with?(".md")
  end
end
