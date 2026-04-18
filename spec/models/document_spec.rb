require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'バリデーション' do
    let(:document) { build(:document) }

    describe 'url' do
      context '存在性' do
        it 'urlが存在する場合は有効' do
          document.url = 'https://example.com'
          expect(document).to be_valid, 'urlが存在する場合は有効である必要があります'
        end

        it 'urlが空の場合は無効' do
          document.url = ''
          expect(document).not_to be_valid, 'urlが空の場合は無効である必要があります'
          expect(document.errors[:url]).to include('を入力してください')
        end

        it 'urlがnilの場合は無効' do
          document.url = nil
          expect(document).not_to be_valid, 'urlがnilの場合は無効である必要があります'
          expect(document.errors[:url]).to include('を入力してください')
        end
      end

      context '一意性' do
        it '同じurlが既に存在する場合は無効' do
          existing_document = create(:document, url: 'https://example.com')
          document.url = 'https://example.com'
          expect(document).not_to be_valid, '同じurlが既に存在する場合は無効である必要があります'
        end

        it '異なるurlの場合は有効' do
          create(:document, url: 'https://example.com')
          document.url = 'https://different.com'
          expect(document).to be_valid, '異なるurlの場合は有効である必要があります'
        end
      end

      context 'URL形式' do
        it '有効なHTTP URLの場合は有効' do
          document.url = 'http://example.com'
          expect(document).to be_valid, '有効なHTTP URLの場合は有効である必要があります'
        end

        it '有効なHTTPS URLの場合は有効' do
          document.url = 'https://example.com'
          expect(document).to be_valid, '有効なHTTPS URLの場合は有効である必要があります'
        end

        it '無効なURL形式の場合は無効' do
          document.url = 'あかさたな'
          expect(document).not_to be_valid, '無効なURL形式の場合は無効である必要があります'
          expect(document.errors[:url]).to include('は無効な形式です')
        end

        it 'HTTP/HTTPS以外のプロトコルの場合は無効' do
          document.url = 'ftp://example.com'
          expect(document).not_to be_valid, 'HTTP/HTTPS以外のプロトコルの場合は無効である必要があります'
          expect(document.errors[:url]).to include('はhttpまたはhttpsで始まる必要があります')
        end
      end
    end
  end

  describe 'アソシエーション' do
    describe 'has_many :document_posts' do
      let(:document) { create(:document) }

      it 'document_postsにアクセスできる' do
        document_post = create(:document_post, document: document)
        expect(document.document_posts).to include(document_post)
      end

      it 'documentが削除されると、関連するdocument_postsも削除される' do
        create(:document_post, document: document)
        expect { document.destroy }.to change(DocumentPost, :count).by(-1), 'documentが削除されると、関連するdocument_postsも削除される必要があります'
      end
    end
  end

  describe 'DocumentのOGP情報の保存' do
    let(:url) { 'https://ogp.example.com/page' }

    context 'OGP取得成功時' do
      before do
        allow_any_instance_of(OgpScraperService).to receive(:fetch_attributes).and_return(
          title: 'OGPタイトル',
          description: 'OGP説明',
          image_url: 'https://ogp.example.com/og.png'
        )
      end

      it 'Documentは作成され、title / description / image_url に値が保存される' do
        document = described_class.create!(url: url)
        expect(document.title).to eq('OGPタイトル')
        expect(document.description).to eq('OGP説明')
        expect(document.image_url).to eq('https://ogp.example.com/og.png')
      end
    end

    context 'OGP取得失敗時' do
      before do
        allow_any_instance_of(OgpScraperService).to receive(:fetch_attributes).and_return(nil)
      end

      it 'Documentは作成され、title / description / image_url にnilが保存される' do
        document = described_class.create!(url: url)
        expect(document.title).to be_nil
        expect(document.description).to be_nil
        expect(document.image_url).to be_nil
      end
    end
  end
end
