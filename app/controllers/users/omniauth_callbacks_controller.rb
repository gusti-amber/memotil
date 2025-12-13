# 🎓 参考資料: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :github

  def github
    auth = request.env["omniauth.auth"]

    if user_signed_in?
      # 既存のログインユーザーにGitHub情報を追加
      @user = current_user
      @user.update(github_uid: auth.uid, github_token: auth.credentials.token)
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?

      # 🎓 origin_params: https://github.com/omniauth/omniauth?tab=readme-ov-file#origin-param
      # OmniAuthのドキュメントでは、`origin` パラメータが空のときに `omniauth.origin` に HTTP_REFERER がセットされる、と説明されている。
      # つまり明示的な `origin` が無い場合は参照元URLを「戻り先候補」として使う
      # params: {origin: URL} を指定すると、OmniAuthが"omniauth.origin"にコールバック時のURLを設定する
      origin = request.env["omniauth.origin"].presence
      redirect_to(origin || tasks_path)
    else
      # ログインしていない場合は既存のロジックを使用
      @user = User.from_github(auth)

      if @user.persisted?
        sign_in(@user)
        set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?

        origin = request.env["omniauth.origin"].presence
        redirect_to(origin || after_sign_in_path_for(@user))
      else
        redirect_to new_user_session_url
      end
    end
  end

  def failure
    redirect_to new_user_session_path
  end
end
