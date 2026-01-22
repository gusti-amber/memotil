class TilForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :path, :string
  attribute :message, :string
  attribute :body, :string
  attribute :repo, :string

  validates :path, presence: true
  validates :repo, presence: true
end
