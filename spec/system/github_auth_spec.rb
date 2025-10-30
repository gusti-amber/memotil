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

  it "成功: GitHubでログインできる" do
    mock_github_success

    visit new_user_session_path
    click_button "GitHubでログイン"

    expect(page).to have_current_path(tasks_path)
    expect(page).to have_content("ログアウト") # 成功後はサインイン済み（ヘッダーにログアウトが表示される想定）
  end

  it "失敗: 認証エラー時はログイン画面へ戻る" do
    OmniAuth.config.mock_auth[:github] = :invalid_credentials

    visit new_user_session_path
    click_button "GitHubでログイン"

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("GitHubでログイン") # 失敗時はログイン画面へ戻る
  end
end
