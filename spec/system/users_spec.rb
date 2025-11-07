require 'rails_helper'

RSpec.describe 'Users', type: :system do
  describe 'ユーザー登録' do
    before do
      visit new_user_registration_path
    end

    context '有効な情報で登録する場合' do
      it 'ユーザーが正常に登録される' do
        fill_in '名前', with: 'test_user'
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認）', with: 'password'

        click_button '新規登録'

        # 登録後はログアウトボタンが表示される（自動ログイン）
        expect(page).to have_content('ログアウト')
        expect(page).to have_current_path(tasks_path)
      end
    end

    context '無効な情報で登録する場合' do
      it '名前が空の場合はエラーが表示される' do
        fill_in '名前', with: ''
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認）', with: 'password'

        click_button '新規登録'

        # 💡 GitHub ActionsのCI環境上でこのテストを実行した際に、エラーメッセージの表示が確認できなかった。
        # そのため、エラーメッセージの要素が表示されるまで5秒待つことで解決した。
        # Usersシステムスペックでは、実行順序が最初のエラーメッセージの表示テストなので、処理が遅れている可能性がある。
        expect(page).to have_css('.alert', wait: 5)
        expect(page).to have_content('名前 を入力してください')
      end

      it '名前が1文字の場合はエラーが表示される' do
        fill_in '名前', with: 'a'
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認）', with: 'password'

        click_button '新規登録'

        expect(page).to have_content('名前 は2文字以上で入力してください')
      end

      it '名前が21文字以上の場合はエラーが表示される' do
        fill_in '名前', with: 'a' * 21
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認）', with: 'password'

        click_button '新規登録'

        expect(page).to have_content('名前 は20文字以下で入力してください')
      end

      it 'メールアドレスが空の場合はエラーが表示される' do
        fill_in '名前', with: 'test_user'
        fill_in 'メールアドレス', with: ''
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認）', with: 'password'

        click_button '新規登録'

        expect(page).to have_content('メールアドレス を入力してください')
      end

      it 'メールアドレスが登録済みの場合はエラーが表示される' do
        # 既存のユーザーを作成
        existing_user = create(:user, email: 'test@example.com')

        fill_in '名前', with: 'test_user'
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認）', with: 'password'

        click_button '新規登録'

        expect(page).to have_content('メールアドレス はすでに登録済みです')
      end

      it 'パスワードが7文字以下の場合はエラーが表示される' do
        fill_in '名前', with: 'test_user'
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'a' * 7
        fill_in 'パスワード（確認）', with: 'a' * 7

        click_button '新規登録'

        expect(page).to have_content('パスワード は8文字以上で入力してください')
      end

      it 'パスワードとパスワード確認が一致しない場合はエラーが表示される' do
        fill_in '名前', with: 'test_user'
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認）', with: 'different_password'

        click_button '新規登録'

        expect(page).to have_content('パスワード（確認） とパスワードの入力が一致しません')
      end
    end
  end

  describe 'ユーザーログイン' do
    let(:user) { create(:user) }

    before do
      visit new_user_session_path
    end

    context '有効な情報でログインする場合' do
      it 'ユーザーが正常にログインされる' do
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: user.password

        click_button 'ログイン'

        expect(page).to have_content('ログアウト')
        expect(page).to have_current_path(tasks_path)
      end
    end

    context '無効な情報でログインする場合' do
      it '無効な認証情報の場合はエラーが表示される' do
        fill_in 'メールアドレス', with: 'wrong@example.com'
        fill_in 'パスワード', with: 'wrong_password'

        click_button 'ログイン'

        expect(page).to have_content('メールアドレスまたはパスワードが違います')
      end
    end
  end

  describe 'ユーザーログアウト' do
    let(:user) { create(:user) }

    before do
      sign_in user
      visit root_path
    end

    it 'ユーザーが正常にログアウトされる' do
      # ログアウトボタンをクリック
      click_button 'ログアウト'

      # ログアウト後はログイン・サインアップボタンが表示される
      expect(page).to have_content('ログイン')
      expect(page).to have_content('サインアップ')
      expect(page).to have_current_path(root_path)
    end
  end

  describe '認証フィルター' do
    context 'ログイン状態でログインページにアクセスしようとした場合' do
      let(:user) { create(:user) }

      before do
        sign_in user
      end

      it 'ルートページにリダイレクトされる' do
        visit new_user_session_path

        # 既にログインしている場合はルートページにリダイレクト
        expect(page).to have_current_path(tasks_path)
      end
    end
  end
end
