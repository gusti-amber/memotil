class Document < ApplicationRecord
  has_many :document_posts, dependent: :destroy

  validates :url, presence: true, uniqueness: true
  validate :url_format_validation

  # OGP情報を取得するメソッド
  def ogp_info
    @ogp_info ||= OgpScraperService.new(url).call
  end

  # カード表示用のヘルパーメソッド
  def card_title
    ogp_info[:title]
  end

  def card_description
    ogp_info[:description]
  end

  def card_image_url
    ogp_info[:image_url]
  end

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
