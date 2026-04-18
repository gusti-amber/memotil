class Document < ApplicationRecord
  has_many :document_posts, dependent: :destroy

  validates :url, presence: true, uniqueness: true
  validate :url_format_validation

  before_validation :fetch_ogp, on: :create

  # カード表示用のヘルパーメソッド
  def card_title
    title.presence || "タイトルを取得できませんでした"
  end

  def card_description
    description.presence || "説明文を取得できませんでした"
  end

  def card_image_url
    image_url.presence
  end

  def card_has_image?
    card_image_url.present?
  end

  private

  def fetch_ogp
    data = OgpScraperService.new(url).fetch_attributes
    return if data.nil?

    self.title = data[:title]
    self.description = data[:description]
    self.image_url = data[:image_url]
  end

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
