require 'rails_helper'

RSpec.describe 'Posts', type: :request do
  let(:user) { create(:user) }
  let(:task) { create(:task, user: user) }

  before do
    sign_in user
  end

  describe 'POST /tasks/:task_id/posts' do
    context 'TextPost作成' do
      context '正常な入力の場合' do
        it 'PostとTextPostが正常に作成される' do
          post_params = {
            post: {
              postable_type: 'TextPost',
              postable_attributes: { body: 'test_text_post' }
            }
          }

          expect {
            post task_posts_path(task), params: post_params
          }.to change(Post, :count).by(1)
            .and change(TextPost, :count).by(1)

          expect(response).to have_http_status(:redirect)
          expect(Post.last.postable_type).to eq('TextPost')
          expect(Post.last.postable.body).to eq('test_text_post')
        end
      end
    end

    context 'DocumentPost作成' do
      context '正常な入力の場合' do
        it 'PostとDocumentPostとDocumentが正常に作成される' do
          post_params = {
            post: {
              postable_type: 'DocumentPost',
              postable_attributes: { url: 'https://docs.example.com' }
            }
          }

          expect {
            post task_posts_path(task), params: post_params
          }.to change(Post, :count).by(1)
            .and change(DocumentPost, :count).by(1)
            .and change(Document, :count).by(1)

          expect(response).to have_http_status(:redirect)

          # Documentレコードが作成されることを確認
          document = Document.find_by(url: 'https://docs.example.com')
          expect(document).to be_present

          # DocumentPostレコードが作成され、Documentと関連付けられることを確認
          document_post = DocumentPost.last
          expect(document_post).to be_present
          expect(document_post.document_id).to eq(document.id)

          # PostレコードがDocumentPostと関連付けられることを確認
          post = Post.last
          expect(post.postable_type).to eq('DocumentPost')
          expect(post.postable).to eq(document_post)
        end
      end
    end
  end
end
