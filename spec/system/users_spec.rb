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

  describe 'パスワードリセット' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

    before do
      # メール送信をクリア
      ActionMailer::Base.deliveries.clear
    end

    context 'パスワードリセットリクエスト' do
      it 'ログイン画面から「パスワードをお忘れですか？」リンクでパスワードリセットリクエスト画面に遷移できる' do
        visit new_user_session_path

        click_link 'パスワードをお忘れですか？'

        expect(page).to have_current_path(new_user_password_path)
        expect(page).to have_content('パスワード再設定のお手続き')
      end

      it '登録済みメールアドレスを入力して送信すると、リセット用リンクを含むメールが送信される' do
        visit new_user_password_path

        fill_in 'メールアドレス', with: user.email
        click_button '設定メールを送信'

        # メールが送信されたことを確認
        expect(page).to have_current_path(new_user_session_path)
        
        # メール送信を確認
        expect(ActionMailer::Base.deliveries.size).to eq(1)
      end

      it 'メールアドレスが空の場合はエラーが表示される' do
        visit new_user_password_path

        fill_in 'メールアドレス', with: ''
        click_button '設定メールを送信'

        expect(page).to have_content('メールアドレス を入力してください')
      end

      it '登録されていないメールアドレスを入力した場合はエラーが表示される' do
        visit new_user_password_path

        fill_in 'メールアドレス', with: 'unregistered@example.com'
        click_button '設定メールを送信'

        # 存在しないメールアドレスの場合、エラーが表示される
        expect(page).to have_content('メールアドレス が見つかりませんでした')
      end
    end

    context 'パスワードリセット' do
      before do
        # パスワードリセットトークンを生成
        # set_reset_password_tokenを直接呼び出すことで、プレーンテキストのトークンを取得できる
        @reset_token = user.send(:set_reset_password_token)
      end

      it 'メール内のリンクからパスワードリセット画面に遷移できる' do
        visit edit_user_password_path(reset_password_token: @reset_token)

        expect(page.current_path).to match(%r{/users/password/edit})
        expect(page).to have_content('新しいパスワードの設定')
      end

      it '新しいパスワード（8文字以上）と確認パスワードを入力して送信すると、パスワードが更新され、自動的にログイン状態になる' do
        visit edit_user_password_path(reset_password_token: @reset_token)

        new_password = 'newpassword123'
        fill_in 'パスワード', with: new_password
        fill_in 'パスワード（確認）', with: new_password
        click_button 'パスワードを再設定'

        # 自動的にログイン状態になることを確認（パスワード更新成功時）
        expect(page).to have_content('ログアウト')
        expect(page).to have_current_path(tasks_path)

        # パスワードが更新されたことを確認（新しいパスワードでログインできる）
        user.reload
        expect(user.valid_password?(new_password)).to be true
      end

      # ✨ 今後、トークンの有効期限が切れている場合は、エラーメッセージの表示ではなく、画面表示が変更されるようにする
      it '有効期限が切れたパスワードリセットトークンの場合はエラーが表示される' do
        # 有効期限を切らせるため、reset_password_sent_atを6時間以上後に設定
        user.update_column(:reset_password_sent_at, 7.hours.ago)
        
        visit edit_user_password_path(reset_password_token: @reset_token)

        # フォームは表示されるが、送信時にエラーが発生する
        new_password = 'newpassword123'
        fill_in 'パスワード', with: new_password
        fill_in 'パスワード（確認）', with: new_password
        click_button 'パスワードを再設定'

        # 有効期限切れのエラーが表示される
        expect(page).to have_content('パスワードリセットトークン の有効期限が切れています')
      end

      it 'パスワードが7文字以下の場合はエラーが表示される' do
        visit edit_user_password_path(reset_password_token: @reset_token)

        fill_in 'パスワード', with: 'short'
        fill_in 'パスワード（確認）', with: 'short'
        click_button 'パスワードを再設定'

        expect(page).to have_content('パスワード は8文字以上で入力してください')
      end

      it 'パスワードとパスワード確認が一致しない場合はエラーが表示される' do
        visit edit_user_password_path(reset_password_token: @reset_token)

        fill_in 'パスワード', with: 'newpassword123'
        fill_in 'パスワード（確認）', with: 'different123'
        click_button 'パスワードを再設定'

        expect(page).to have_content('パスワード（確認） とパスワードの入力が一致しません')
      end
    end
  end
end
