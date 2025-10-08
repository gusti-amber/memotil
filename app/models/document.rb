class Document < ApplicationRecord
  has_many :document_posts, dependent: :destroy

  validates :url, presence: true, uniqueness: true
  validate :url_format_validation

  private

  def url_format_validation
    return if url.blank?

    begin
      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        errors.add(:url, :invalid_protocol)
      end
    rescue URI::InvalidURIError
      errors.add(:url, :invalid_url_format)
    end
  end
end
