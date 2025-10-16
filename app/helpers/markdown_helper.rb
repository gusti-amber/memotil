module MarkdownHelper
  require "rouge"
  require "rouge/plugins/redcarpet"

  class CustomRenderer < Redcarpet::Render::HTML
    # 🎓 Rouge::Plugins::Redcarpet: https://github.com/rouge-ruby/rouge/blob/b30020bb8ac965ef2a29560e115ebf0fc3da32d1/lib/rouge/plugins/redcarpet.rb
    include Rouge::Plugins::Redcarpet
  end


  # Markdown形式の解析を行うヘルパーメソッド
  def markdown(text)
    return "" if text.blank?

    renderer = CustomRenderer.new(
      hard_wrap: true # Markdown形式が改行を含む時、<br>を挿入
    )
    markdown = Redcarpet::Markdown.new(renderer, {
      fenced_code_blocks: true # コードブロックの解析を許可
    })

    # コードブロックを発見すると、block_codeメソッドが呼び出される
    markdown.render(text).html_safe
  end
end
