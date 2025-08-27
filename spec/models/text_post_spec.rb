require 'rails_helper'

RSpec.describe TextPost, type: :model do
  describe 'バリデーション' do
    let(:text_post) { build(:text_post) }

    describe 'body' do
      context '存在性' do
        it 'bodyが存在する場合は有効' do
          text_post.body = 'text_post_body'
          expect(text_post).to be_valid, 'bodyが存在する場合は有効である必要があります'
        end

        it 'bodyが空の場合は無効' do
          text_post.body = ''
          expect(text_post).not_to be_valid, 'bodyが空の場合は無効である必要があります'
          expect(text_post.errors[:body]).to include('を入力してください')
        end

        it 'bodyがnilの場合は無効' do
          text_post.body = nil
          expect(text_post).not_to be_valid, 'bodyがnilの場合は無効である必要があります'
          expect(text_post.errors[:body]).to include('を入力してください')
        end
      end

      context '文字数制限' do
        it '500文字以内の場合は有効' do
          text_post.body = 'a' * 500
          expect(text_post).to be_valid, 'bodyが500文字以内の場合は有効である必要があります'
        end

        it '501文字以上の場合は無効' do
          text_post.body = 'a' * 501
          expect(text_post).not_to be_valid, 'bodyが501文字以上の場合は無効である必要があります'
          expect(text_post.errors[:body]).to include('は500文字以下で入力してください')
        end
      end
    end
  end

  describe 'アソシエーション' do
    describe 'has_one :post' do
      let(:text_post) { create(:text_post) }

      it 'postにアクセスできる' do
        post = create(:post, postable: text_post)
        expect(text_post.post).to eq post
      end

      it 'text_postが削除されると、関連するpostも削除される' do
        post = create(:post, postable: text_post)
        expect { text_post.destroy }.to change(Post, :count).by(-1), 'text_postが削除されると、関連するpostも削除される必要があります'
      end
    end

    describe 'has_one :task, through: :post' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:text_post) { create(:text_post) }
      let!(:post) { create(:post, user: user, task: task, postable: text_post) }

      it 'taskにアクセスできる' do
        expect(text_post.task).to eq task
      end
    end

    describe 'has_one :user, through: :post' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:text_post) { create(:text_post) }
      let!(:post) { create(:post, user: user, task: task, postable: text_post) }

      it 'userにアクセスできる' do
        expect(text_post.user).to eq user
      end
    end
  end
end
