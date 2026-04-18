namespace :documents do
  desc "既存DocumentのOGPカラム（title/description/image_url）をバックフィルする（title または description が nil のレコードが対象・冪等）"
  task backfill_ogp: :environment do
    scope = Document.where(title: nil).or(Document.where(description: nil))
    total = scope.count
    processed = 0

    scope.find_each do |document|
      processed += 1
      begin
        data = OgpScraperService.new(document.url).fetch_attributes
        if data
          document.update_columns(
            title: data[:title],
            description: data[:description],
            image_url: data[:image_url],
            updated_at: Time.current
          )
        end
      rescue => e
        Rails.logger.error(
          "[documents:backfill_ogp] [#{processed}/#{total}] id=#{document.id} url=#{document.url} error=#{e.class}: #{e.message}"
        )
      end

      puts "[documents:backfill_ogp] [#{processed}/#{total}] id=#{document.id}"
      sleep 0.5
    end
  end
end
