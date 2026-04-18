require "nokogiri"
require "open-uri"

class OgpScraperService
  def initialize(url)
    @url = url
  end

  def call
    fetch_attributes
  end

  # DBにOGP情報（title, description, image_url）を保存するためのメソッド
  def fetch_attributes
    {
      title: extract_title,
      description: extract_description,
      image_url: extract_ogp_image
    }
  rescue => e
    Rails.logger.error "以下のURLのOGP情報の取得に失敗しました: #{@url}\n
                        エラーメッセージ: #{e.message}"
    nil
  end

  private

  def extract_title
    # OGP title > meta title > h1 > URL
    # 🎓 doc.at: 最初にマッチした要素のみ取得
    # 🎓 .text: タグ要素のテキストを取得
    # 🎓 .strip: テキストの前後の空白を削除
    doc.at('meta[property="og:title"]')&.[]("content") ||
    doc.at("title")&.text&.strip ||
    doc.at("h1")&.text&.strip ||
    nil
  end

  def extract_description
    # OGP description > meta description
    doc.at('meta[property="og:description"]')&.[]("content") ||
    doc.at('meta[name="description"]')&.[]("content") ||
    nil
  end

  def extract_ogp_image
    # 1. OGP画像を優先取得
    ogp_image = doc.at('meta[property="og:image"]')&.[]("content")
    return ogp_image if ogp_image.present?

    # 2. ページ内の最初の画像を取得
    first_image = doc.at("img")&.[]("src")
    return nil unless first_image.present?

    # 3. 最初の画像の相対URLを絶対URLに変換
    URI.join(@url, first_image).to_s
  rescue URI::InvalidURIError
    first_image
  end

  def doc
    # docが取得できない場合、beginブロック内の処理を実行
    @doc ||= begin
      # オプション(User-Agent, タイムアウト)の設定
      # 🎓 User-Agentを偽装することで、アクセス先のサイトのbot検出を回避
      # library open-uri: https://docs.ruby-lang.org/ja/latest/library/open=2duri.html
      options = {
        "User-Agent" => "Mozilla/5.0 (compatible; OGP-Scraper/1.0)",
        read_timeout: 10,
        open_timeout: 10
      }
      Nokogiri::HTML(URI.open(@url, options))
    end
  end
end
