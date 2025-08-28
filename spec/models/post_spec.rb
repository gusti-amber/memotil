require 'rails_helper'

RSpec.describe Post, type: :model do
  describe 'アソシエーション' do
    describe 'belongs_to :user' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:text_post) { create(:text_post) }
      let(:post) { build(:post, user: user, task: task, postable: text_post) }

      it 'userにアクセスできる' do
        expect(post.user).to eq user
      end

      it 'userが存在しない場合は無効' do
        post = build(:post, user: nil, task: task, postable: text_post)
        expect(post).not_to be_valid, 'userが存在しない場合は無効である必要があります'
      end

      it 'userが存在する場合は有効' do
        expect(post).to be_valid, 'userが存在する場合は有効である必要があります'
      end
    end

    describe 'belongs_to :task' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:text_post) { create(:text_post) }
      let(:post) { build(:post, user: user, task: task, postable: text_post) }

      it 'taskにアクセスできる' do
        expect(post.task).to eq task
      end

      it 'taskが存在しない場合は無効' do
        post = build(:post, user: user, task: nil, postable: text_post)
        expect(post).not_to be_valid, 'taskが存在しない場合は無効である必要があります'
      end

      it 'taskが存在する場合は有効' do
        expect(post).to be_valid, 'taskが存在する場合は有効である必要があります'
      end
    end

    describe 'delegated_type :postable' do
      let(:user) { create(:user) }
      let(:task) { create(:task, user: user) }
      let(:text_post) { create(:text_post) }
      let(:post) { create(:post, user: user, task: task, postable: text_post) }

      it 'postableにアクセスできる' do
        expect(post.postable).to eq text_post
      end

      it 'postable_typeが正しく設定される' do
        expect(post.postable_type).to eq 'TextPost'
      end

      it 'postable_idが正しく設定される' do
        expect(post.postable_id).to eq text_post.id
      end
    end
  end
end
