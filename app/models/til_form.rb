class TilForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :path, :string
  attribute :message, :string
  attribute :body, :string
  attribute :repo, :string
end
