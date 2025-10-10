require 'nokogiri'
require 'open-uri'

class OgpScraperService
  def initialize(url)
    @url = url
  end

  def call
    {
      title: extract_title,
      description: extract_description,
      image_url: extract_ogp_image
    }
  rescue => e
    Rails.logger.error "OGP scraping failed for #{@url}: #{e.message}"
    fallback_data
  end

  private

  def extract_title
    # OGP title > meta title > h1 > URL
    doc.at('meta[property="og:title"]')&.[]('content') ||
    doc.at('title')&.text&.strip ||
    doc.at('h1')&.text&.strip ||
    @url
  end

  def extract_description
    # OGP description > meta description
    doc.at('meta[property="og:description"]')&.[]('content') ||
    doc.at('meta[name="description"]')&.[]('content') ||
    '説明がありません'
  end

  def extract_ogp_image
    # OGP image > 最初のimgタグ
    ogp_image = doc.at('meta[property="og:image"]')&.[]('content')
    return ogp_image if ogp_image.present?

    # 相対URLを絶対URLに変換
    first_image = doc.at('img')&.[]('src')
    return nil unless first_image.present?

    URI.join(@url, first_image).to_s
  rescue URI::InvalidURIError
    first_image
  end

  def doc
    @doc ||= begin
      # タイムアウト設定とUser-Agentを設定
      options = {
        'User-Agent' => 'Mozilla/5.0 (compatible; OGP-Scraper/1.0)',
        read_timeout: 10,
        open_timeout: 10
      }
      Nokogiri::HTML(URI.open(@url, options))
    end
  end

  def fallback_data
    {
      title: @url,
      description: 'OGP情報の取得に失敗しました',
      image_url: nil
    }
  end
end
