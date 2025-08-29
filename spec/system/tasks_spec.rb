require 'rails_helper'

RSpec.describe 'Tasks', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:task) { create(:task, user: user) }
  let(:other_user_task) { create(:task, user: other_user) }

  describe '認証フィルター' do
    context '未ログインユーザーの場合' do
      it 'タスク一覧ページにアクセスするとログインページにリダイレクトされる' do
        visit tasks_path
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('ログインしてください')
      end

      it 'タスク作成ページにアクセスするとログインページにリダイレクトされる' do
        visit new_task_path
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('ログインしてください')
      end

      it 'タスク詳細ページにアクセスするとログインページにリダイレクトされる' do
        visit task_path(task)
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('ログインしてください')
      end

      it 'タスク編集ページにアクセスするとログインページにリダイレクトされる' do
        visit edit_task_path(task)
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content('ログインしてください')
      end
    end
  end
end
