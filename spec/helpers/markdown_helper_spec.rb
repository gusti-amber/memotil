# frozen_string_literal: true

require "rails_helper"

RSpec.describe MarkdownHelper, type: :helper do
  describe "#markdown" do
    it "空のときは空文字を返す" do
      expect(helper.markdown(nil)).to eq("")
      expect(helper.markdown("")).to eq("")
    end

    it "見出しが出力される" do
      html = helper.markdown("# Title\n\n## Sub")
      doc = Nokogiri::HTML::DocumentFragment.parse(html) # HTMLの解析
      expect(doc.at_css("h1").text).to eq("Title")
      expect(doc.at_css("h2").text).to eq("Sub")
    end

    it "リストが出力される" do
      html = helper.markdown("- one\n- two")
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      expect(doc.css("ul li").map { |li| li.text.strip }).to eq(%w[one two])
    end

    it "引用が出力される" do
      html = helper.markdown("before\n\n> quoted\n")
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      expect(doc.at_css("blockquote p").text).to eq("quoted")
    end

    it "テーブルが出力される" do
      body = "| a | b |\n|---|---|\n| 1 | 2 |\n"
      html = helper.markdown(body)
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      expect(doc.css("thead th").map { |th| th.text.strip }).to eq(%w[a b])
      expect(doc.css("tbody td").map { |td| td.text.strip }).to eq(%w[1 2])
    end

    it "自動リンクが出力され、targetとrelが付く" do
      html = helper.markdown("https://example.com/path")
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      link = doc.at_css("a")
      expect(link["href"]).to eq("https://example.com/path")
      expect(link["target"]).to eq("_blank")
      expect(link["rel"]).to eq("noopener noreferrer")
    end

    it "単一改行がbrになる" do
      html = helper.markdown("line one\nline two")
      expect(html).to include("<br>")
    end

    it "取り消し線が出力される" do
      html = helper.markdown("~~old~~")
      expect(html).to include("<del>")
    end

    it "フェンスコードブロックにラッパー・言語ラベル・コピーUI・本文 textarea がある" do
      html = helper.markdown("```ruby\nputs 1\n```")
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      block = doc.at_css(".markdown-code-block")
      expect(block.at_css("span").text).to eq("ruby")
      expect(block.at_css('textarea').text).to eq("puts 1\n")
      expect(block.at_css(".highlight")).to be_present
    end

    it "言語未指定のフェンスはラベルが text になる" do
      html = helper.markdown("```\nplain\n```")
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      block = doc.at_css(".markdown-code-block")
      expect(block.at_css("span").text).to eq("text")
    end

    it "生のscriptタグは実行用のマークアップとして出ない" do
      html = helper.markdown('<script>alert(1)</script>')
      expect(html).not_to include("<script>")
      expect(html).to include("alert(1)")
    end

    it "javascript: スキームのリンクは出力されない" do
      html = helper.markdown('[x](javascript:alert(1))')
      doc = Nokogiri::HTML::DocumentFragment.parse(html)
      expect(doc.css('a[href^="javascript:"]')).to be_empty
    end

    it "コードブロックの言語ラベルがHTMLエスケープされる" do
      html = helper.markdown("```<em>x\ny\n```")
      expect(html).to include("&lt;em&gt;x</span>")
      expect(html).not_to include("<em>x</span>")
    end
  end
end
