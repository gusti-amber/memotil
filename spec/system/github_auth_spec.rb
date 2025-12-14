# 🎓 OmniAuthの統合テスト方法 公式wiki: https://github.com/omniauth/omniauth/wiki/Integration-Testing

require "rails_helper"

RSpec.describe "GitHub OAuth", type: :system do
  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.test_mode = false
  end

  def mock_github_success(email: "user@example.com", name: "GitHub User", uid: "123456")
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
      provider: "github",
      uid: uid,
      info: { email: email, name: name, nickname: name },
      credentials: { token: "token" }
    )
  end

  describe "GitHub認証" do
    context "未ログインユーザーがログイン画面から認証を行う場合" do
      context "認証が成功した場合" do
        it "正常にログインできる" do
          mock_github_success

          visit new_user_session_path
          click_button "GitHubでログイン"

          expect(page).to have_current_path(tasks_path)
          expect(page).to have_content("ログアウト") # 成功後はサインイン済み（ヘッダーにログアウトが表示される想定）
        end
      end
    end

    context "認証が失敗した場合" do
      it "ログイン画面にリダイレクトされる" do
        OmniAuth.config.mock_auth[:github] = :invalid_credentials

        visit new_user_session_path
        click_button "GitHubでログイン"

        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("GitHubでログイン") # 失敗時はログイン画面へ戻る
      end
    end
  end

  describe "GitHub連携" do
    context "ログイン済みユーザーがDoneタスク詳細画面からGitHub連携を行う場合" do
      let(:user) { create(:user) }
      let(:done_task) { create(:done_task, user: user) }

      before do
        sign_in user
        visit task_path(done_task)
      end

      context "認証が成功した場合" do
        it "正常に連携し、サクセスメッセージが表示される" do
          mock_github_success

          click_button "GitHubと連携する"

          expect(page).to have_current_path(task_path(done_task))
          expect(page).to have_content("GitHubとの連携に成功しました")
        end
      end

      context "認証が失敗した場合" do
        skip "アラートメッセージが表示される" do
          OmniAuth.config.mock_auth[:github] = :invalid_credentials

          click_button "GitHubと連携する"

          expect(page).to have_current_path(task_path(done_task))
          expect(page).to have_content("GitHubとの連携に失敗しました")
        end
      end

      context "GitHubアカウントが既に他のユーザーと連携されている場合" do
        let!(:other_user) { create(:user, github_uid: "123456", github_token: "existing_token") }

        it "アラートメッセージが表示される" do
          mock_github_success(uid: "123456") # 同じuidを使用

          click_button "GitHubと連携する"

          expect(page).to have_current_path(task_path(done_task))
          expect(page).to have_content("GitHubアカウントは既に他のユーザーと連携されています")
        end
      end
    end
  end
end
