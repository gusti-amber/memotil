require 'rails_helper'

RSpec.describe 'TILs', type: :request do
  describe 'POST /tasks/:task_id/til/preview' do
    let(:user) { create(:user) }
    let(:task) { create(:task, user: user) }

    context 'ログイン済みユーザーの場合' do
      before do
        sign_in user
      end

      it 'MarkdownプレビューHTMLを返す' do
        post preview_task_til_path(task), params: { body: '# Title' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('markdown-body')
        expect(response.body).to include('Title')
      end
    end

    context '未ログインユーザーの場合' do
      it 'ログイン画面へリダイレクトされる' do
        post preview_task_til_path(task), params: { body: '# Title' }

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
