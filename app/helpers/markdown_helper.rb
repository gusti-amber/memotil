module MarkdownHelper
  require "rouge"
  require "rouge/plugins/redcarpet"

  class CustomRenderer < Redcarpet::Render::HTML
    # 🎓 Rouge::Plugins::Redcarpet: https://github.com/rouge-ruby/rouge/blob/b30020bb8ac965ef2a29560e115ebf0fc3da32d1/lib/rouge/plugins/redcarpet.rb
    include Rouge::Plugins::Redcarpet

    def block_code(code, language)
      highlighted_code = super
      language_label = ERB::Util.html_escape(language.presence || "text")
      copy_source = ERB::Util.html_escape(code)

      <<~HTML
        <div class="markdown-code-block bg-surface-elevated rounded-box" data-controller="code-copy">
          <div class="flex items-center justify-between gap-2 px-3 py-2 text-xs text-muted">
            <span>#{language_label}</span>
            <button type="button" class="btn btn-ghost btn-xs border-none hover:bg-neutral/10" data-action="code-copy#copy" data-code-copy-target="button">コピー</button>
          </div>
          <div class="overflow-x-auto">
            #{highlighted_code}
          </div>
          <textarea class="sr-only" readonly data-code-copy-target="source">#{copy_source}</textarea>
        </div>
      HTML
    end
  end

  # Markdown形式の解析と表示
  def markdown(text)
    return "" if text.blank?

    # Markdown→HTML変換用のレンダラー
    renderer = CustomRenderer.new(
      hard_wrap: true, # Markdown形式が改行を含む時、<br>を挿入
      filter_html: true, # HTMLタグを削除
      safe_links_only: true, # 外部リンクを新しいタブで開く
      link_attributes: {
        target: "_blank",
        rel: "noopener noreferrer"
      }
    )

    # Markdownパーサー
    markdown = Redcarpet::Markdown.new(renderer, {
      fenced_code_blocks: true, # コードブロックの解析を許可
      tables: true, # テーブルの解析を許可
      autolink: true, # リンクを自動的に解析
      strikethrough: true, # 取り消し線の解析を許可
      disable_indented_code_blocks: true # インデントされたコードブロックを無効化
    })

    # コードブロックを発見すると、block_codeメソッドが呼び出される
    markdown.render(text).html_safe
  end
end
