require 'rails_helper'

RSpec.describe DocumentPost, type: :model do
  describe 'バリデーション' do
    let(:document_post) { build(:document_post) }

    describe 'document_id' do
      context '存在性' do
        it 'document_idが存在する場合は有効' do
          document = create(:document)
          document_post.document_id = document.id
          expect(document_post).to be_valid, 'document_idが存在する場合は有効である必要があります'
        end

        it 'document_idが空の場合は無効' do
          document_post.document_id = nil
          expect(document_post).not_to be_valid, 'document_idが空の場合は無効である必要があります'
          expect(document_post.errors[:document_id]).to include('を入力してください')
        end
      end
    end
  end

  describe 'アソシエーション' do
    describe 'belongs_to :document' do
      let(:document) { create(:document) }
      let(:document_post) { create(:document_post, document: document) }

      it 'documentにアクセスできる' do
        expect(document_post.document).to eq document
      end

      it 'documentが削除されると、document_postも削除される' do
        document_post
        expect { document.destroy }.to change(DocumentPost, :count).by(-1), 'documentが削除されると、document_postも削除される必要があります'
      end
    end

    describe 'has_one :post' do
      let(:document_post) { create(:document_post) }

      it 'postにアクセスできる' do
        post = create(:post, postable: document_post)
        expect(document_post.post).to eq post
      end

      it 'document_postが削除されると、関連するpostも削除される' do
        post = create(:post, postable: document_post)
        expect { document_post.destroy }.to change(Post, :count).by(-1), 'document_postが削除されると、関連するpostも削除される必要があります'
      end
    end

    describe 'has_one :task, through: :post' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:document_post) { create(:document_post) }
      let!(:post) { create(:post, user: user, task: task, postable: document_post) }

      it 'taskにアクセスできる' do
        expect(document_post.task).to eq task
      end
    end

    describe 'has_one :user, through: :post' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:document_post) { create(:document_post) }
      let!(:post) { create(:post, user: user, task: task, postable: document_post) }

      it 'userにアクセスできる' do
        expect(document_post.user).to eq user
      end
    end
  end
end
