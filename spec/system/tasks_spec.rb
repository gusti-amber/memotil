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

  describe 'タスク新規作成' do
    before do
      login_as(user, scope: :user)
    end

    let(:max_tags) { 5 }

    context '正常な入力の場合' do
      it 'タスクが新規作成される' do
        tags = create_list(:tag, max_tags)
        visit new_task_path
        fill_in 'タイトル', with: 'test_task_with_tag'
        
        # 「選択」ボタンをクリックしてドロップダウンを開く
        find('span', text: '選択').click
        
        # 最初のタグを選択
        first('input[type="checkbox"]').check
        
        # ドロップダウンを閉じる
        # ⚠️ find('body').clickは正常に動作しない（セレクトボックスを閉じない）
        find('body').send_keys(:escape)
        
        click_button '作成'
        
        expect(page).to have_content('test_task_with_tag')
        expect(page).to have_content(tags.first.name)
      end

      it '戻るボタンをクリックすると一覧ページに戻る' do
        visit new_task_path
        click_link '戻る'
        expect(page).to have_content('タスク')
        expect(page).to have_link('作成')
      end
    end

    context 'バリデーションエラーが発生する場合' do
      it 'タイトルが空の場合、エラーメッセージが表示される' do
        visit new_task_path
        fill_in 'タイトル', with: ''
        click_button '作成'
        
        expect(current_path).to eq new_task_path
        expect(page).to have_content('タイトル を入力してください')
      end

      it 'タイトルが1文字の場合、エラーメッセージが表示される' do
        visit new_task_path
        fill_in 'タイトル', with: 'a'
        click_button '作成'
        
        expect(current_path).to eq new_task_path
        expect(page).to have_content('タイトル は2文字以上で入力してください')
      end

      it 'タイトルが256文字以上の場合、エラーメッセージが表示される' do
        visit new_task_path
        fill_in 'タイトル', with: 'a' * 256
        click_button '作成'
        
        expect(current_path).to eq new_task_path
        expect(page).to have_content('タイトル は255文字以下で入力してください')
      end

      it 'タグを最大数を超える数選択した場合、エラーメッセージが表示される' do
        tags = create_list(:tag, max_tags + 1)
        visit new_task_path
        fill_in 'タイトル', with: 'test_task_with_too_many_tags'
        
        # 「選択」ボタンをクリックしてドロップダウンを開く
        find('span', text: '選択').click
        
        # 最大数を超えるタグを選択
        (max_tags + 1).times do |i|
          all('input[type="checkbox"]')[i].check
        end
        
        # ドロップダウンを閉じる（ESCキーを押す）
        find('body').send_keys(:escape)
        
        click_button '作成'
        
        expect(current_path).to eq new_task_path
        expect(page).to have_content("タグ は最大#{max_tags}個まで選択できます")
      end
    end
  end
end
