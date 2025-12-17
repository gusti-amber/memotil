# 🎓 参考資料: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :github

  def github
    auth = request.env["omniauth.auth"]

    # ログイン済みユーザーがDoneタスク詳細画面やアカウント設定画面からGitHub連携を行う場合
    if user_signed_in?
      @user = current_user

      begin
        # 既存のログインユーザーにGitHub情報を追加
        if @user.update(github_uid: auth.uid, github_token: auth.credentials.token)
          set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
        else
          # バリデーションエラーが発生した場合（通常は発生しない）
          set_flash_message(:alert, :failure, kind: "GitHub") if is_navigational_format?
        end
      rescue ActiveRecord::RecordNotUnique
        # 既存の別ユーザーが同じGitHubアカウントを連携している場合
        set_flash_message(:alert, :already_linked, kind: "GitHub") if is_navigational_format?
      end

      # 🎓 origin_params: https://github.com/omniauth/omniauth?tab=readme-ov-file#origin-param
      # OmniAuthのドキュメントでは、`origin` パラメータが空のときに `omniauth.origin` に HTTP_REFERER がセットされる、と説明されている。
      # つまり明示的な `origin` が無い場合は参照元URLを「戻り先候補」として使う
      # params: {origin: URL} を指定すると、OmniAuthが"omniauth.origin"にコールバック時のURLを設定する
      origin = request.env["omniauth.origin"].presence
      redirect_to(origin || tasks_path)

    # 未ログインユーザーがログイン画面からGitHub認証を行う場合
    else
      @user = User.from_github(auth)

      if @user.persisted?
        sign_in(@user)
        
        # 🎓 set_flash_message: Devise専用のフラッシュメッセージを設定するメソッド
        set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?

        # ログイン後にDeviseのafter_sign_in_path_forメソッド(正確にはオーバーライドしたもの)で指定されたパスにリダイレクト
        redirect_to after_sign_in_path_for(@user)
      else
        redirect_to new_user_session_url
      end
    end
  end

  def failure
    redirect_to new_user_session_path
  end
end
