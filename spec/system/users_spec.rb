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

      it 'サインアップ成功時にフラッシュメッセージが表示される' do
        fill_in '名前', with: 'test_user'
        fill_in 'メールアドレス', with: 'test@example.com'
        fill_in 'パスワード', with: 'password'
        fill_in 'パスワード（確認）', with: 'password'

        click_button '新規登録'

        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('ユーザー登録が完了しました')
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

      it 'ログイン成功時にフラッシュメッセージが表示される' do
        fill_in 'メールアドレス', with: user.email
        fill_in 'パスワード', with: user.password

        click_button 'ログイン'

        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('ログインしました')
      end
    end

    context 'ゲストユーザーでログインする場合' do
      it 'ゲストユーザーで正常にログインされる' do
        click_button 'ゲストとしてログイン'

        # タスク一覧画面へリダイレクト
        expect(page).to have_current_path(tasks_path)
        expect(page).to have_content('ログアウト')

        # サクセスメッセージの表示
        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('ゲストユーザーでログインしました')
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
      visit tasks_path
    end

    it 'ユーザーが正常にログアウトされる' do
      # ユーザーメニューを開き、「ログアウト」ボタンをクリック
      find('[aria-label="open-user-menu"]').click
      click_link 'ログアウト'

      # ログアウト後はログイン・サインアップボタンが表示される
      expect(page).to have_content('ログイン')
      expect(page).to have_content('サインアップ')
      expect(page).to have_current_path(root_path)
    end

    it 'ログアウト時にフラッシュメッセージが表示される' do
      # ユーザーメニューを開き、「ログアウト」ボタンをクリック
      find('[aria-label="open-user-menu"]').click
      click_link 'ログアウト'

      expect(page).to have_css('.alert.alert-success')
      expect(page).to have_content('ログアウトしました')
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

        # サクセスメッセージの表示
        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('パスワード再設定のメールを送信しました')

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

        # サクセスメッセージの表示
        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('パスワードが変更されました')

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

  describe 'プロフィール編集' do
    let(:user) { create(:user, name: 'original_name', email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }

    before do
      sign_in user
      visit tasks_path
    end

    context 'ユーザーメニューからアカウント設定画面へ遷移する場合' do
      it 'ユーザーメニューから「アカウント設定」ボタンをクリックすると、アカウント設定画面へ遷移する' do
        find('[aria-label="open-user-menu"]').click
        click_link 'アカウント設定'

        expect(page).to have_current_path(edit_user_registration_path)
        expect(page).to have_content('アカウント設定')
      end
    end

    context '有効な情報でプロフィールを更新する場合' do
      it 'ユーザー名を更新すると、元いた画面へリダイレクトされ、プロフィールが正しく更新される' do
        find('[aria-label="open-user-menu"]').click
        click_link 'アカウント設定'

        fill_in '名前', with: 'updated_name'
        click_button '変更'

        expect(page).to have_current_path(tasks_path)

        # サクセスメッセージの表示
        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('ユーザー名が変更されました')

        # ユーザーメニューを開いてプロフィールが更新されているか確認
        find('[aria-label="open-user-menu"]').click
        expect(page).to have_content('updated_name')
      end
    end

    context '無効な情報でプロフィールを更新する場合' do
      it '名前が空の場合はエラーが表示される' do
        find('[aria-label="open-user-menu"]').click
        click_link 'アカウント設定'

        fill_in '名前', with: ''
        click_button '変更'

        expect(page).to have_content('名前 を入力してください')
      end

      it '名前が1文字の場合はエラーが表示される' do
        find('[aria-label="open-user-menu"]').click
        click_link 'アカウント設定'

        fill_in '名前', with: 'a'
        click_button '変更'

        expect(page).to have_content('名前 は2文字以上で入力してください')
      end

      it '名前が21文字以上の場合はエラーが表示される' do
        find('[aria-label="open-user-menu"]').click
        click_link 'アカウント設定'

        fill_in '名前', with: 'a' * 21
        click_button '変更'

        expect(page).to have_content('名前 は20文字以下で入力してください')
      end
    end
  end
  
  describe 'メールアドレス変更' do
    let(:user) { create(:user, email: 'test@example.com', password: 'password123', password_confirmation: 'password123') }
    
    before do
      sign_in user
      # メール送信をクリア
      ActionMailer::Base.deliveries.clear
    end
    
    context 'メールアドレス変更リクエスト' do
      before do
        visit tasks_path
        find('[aria-label="open-user-menu"]').click
        click_link 'アカウント設定'
      end
      
      it 'アカウント設定画面で現在のメールアドレスが表示される' do
        expect(page).to have_content('アカウント設定')
        expect(page).to have_content('test@example.com')
        expect(page).to have_content('現在のメールアドレス')
      end
      
      it '新しいメールアドレスを入力して送信すると、確認メールが送信される' do
        new_email = 'newemail@example.com'
        fill_in '新しいメールアドレス', with: new_email
        click_button '確認メールを送信'
        
        # タスク一覧画面へ遷移するまで待機
        expect(page).to have_current_path(tasks_path)
        
        # サクセスメッセージの表示
        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('新しいメールアドレスへ確認メールを送信しました')
        
        # メールが送信されたことを確認
        expect(ActionMailer::Base.deliveries.size).to eq(1)
        
        # メールアドレスはまだ変更されていない（unconfirmed_emailに保存されている）
        user.reload
        expect(user.email).to eq('test@example.com')
        expect(user.unconfirmed_email).to eq(new_email)
      end
      
      it 'メールアドレスが空の場合はエラーが表示される' do
        fill_in '新しいメールアドレス', with: ''
        click_button '確認メールを送信'
        
        expect(page).to have_content('メールアドレス を入力してください')
      end
      
      it '既に登録済みのメールアドレスの場合はエラーが表示される' do
        # 別のユーザーを作成
        create(:user, email: 'existing@example.com')
        
        fill_in '新しいメールアドレス', with: 'existing@example.com'
        click_button '確認メールを送信'
        
        expect(page).to have_content('メールアドレス はすでに登録済みです')
      end
    end
    
    context 'メールアドレス変更確認' do
      before do
        # 確認トークンを生成
        # unconfirmed_emailを設定してから、send_confirmation_instructionsを呼び出すことで、confirmation_tokenが生成される
        user.update(unconfirmed_email: 'newemail@example.com')
        user.send_confirmation_instructions
        user.reload
        @confirmation_token = user.confirmation_token
        user.update(confirmation_sent_at: Time.current)
      end
      
      it '確認メール内のリンクからメールアドレスが変更され、ログイン状態になり、タスク一覧画面へ遷移する' do
        visit user_confirmation_path(confirmation_token: @confirmation_token)
        
        # メールアドレスが変更されたことを確認
        user.reload
        expect(user.email).to eq('newemail@example.com')
        expect(user.unconfirmed_email).to be_nil
        expect(user.confirmed_at).to be_present
        
        # 自動的にログイン状態になることを確認
        expect(page).to have_content('ログアウト')
        expect(page).to have_current_path(tasks_path)
        
        # サクセスメッセージの表示
        expect(page).to have_css('.alert.alert-success')
        expect(page).to have_content('メールアドレスが変更されました')
      end
      
      # ✨ 以下のテストは確認メール再送画面`app/views/users/confirmations/new.html.erb`を実装する際に書く
      it '有効期限が切れた確認トークンの場合はエラーが表示される'
      it '無効な確認トークンの場合はエラーが表示される'
    end
  end

  describe 'ゲストユーザーの機能制限' do
    before do
      visit new_user_session_path
      click_button 'ゲストとしてログイン'
      expect(page).to have_current_path(tasks_path)
    end
  
    context 'ヘッダーの表示' do
      it 'ヘッダーにユーザーメニューは表示されず、ログアウトボタンのみ表示される' do
        expect(page).not_to have_css('[data-test-id="user-menu"]')
        expect(page).to have_link('ログアウト')
      end
    end

    context 'アカウント設定画面へのアクセス制限' do
      it 'URLで直接アカウント設定画面にアクセスしようとすると、直前のページにリダイレクトされ、アラートメッセージが表示される' do
        # タスク一覧画面からアカウント設定画面にアクセスしようとする
        visit edit_user_registration_path
  
        # タスク一覧画面にリダイレクトされる
        expect(page).to have_current_path(tasks_path)
  
        # アラートメッセージの表示
        expect(page).to have_css('.alert.alert-error')
        expect(page).to have_content('ゲストユーザーはアカウント設定画面にアクセスできません')
      end
    end
  end
end
