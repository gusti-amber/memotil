module MarkdownHelper
  class CustomRenderer < Redcarpet::Render::HTML
    def block_code(code, language)
      # Markdown形式で言語指定されている場合、シンタックスハイライトを行う
      if language.present?
        # 指定された言語からRougeの字句解析器を取得
        lexer = Rouge::Lexer.find(language.downcase)
        # 指定された言語が見つからない場合は、テキストの解析器を使用
        lexer = Rouge::Lexer.find('text') unless lexer

        # 🎓 Rouge::Formatters::HTMLInlineにより、style属性でコードをハイライトする
        # Githubのテーマオブジェクトを渡して使用
        formatter = Rouge::Formatters::HTMLInline.new(Rouge::Themes::Github)
        formatter.format(lexer.lex(code))
      else
        # ♻️ 言語が指定されていない場合の例外処理（一時的）
        raise NotImplementedError, "Language not specified - implementation pending"
      end
    end
  end

  # Markdown形式の解析を行うヘルパーメソッド
  def markdown(text)
    return "" if text.blank?
    
    renderer = CustomRenderer.new
    markdown = Redcarpet::Markdown.new(renderer, {
      fenced_code_blocks: true # コードブロックの解析を許可
    })

    # コードブロックを発見すると、block_codeメソッドが呼び出される
    markdown.render(text).html_safe
  end
end
