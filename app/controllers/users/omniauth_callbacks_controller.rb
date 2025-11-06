# 🎓 参考資料: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :github

  def github
    @user = User.from_github(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in(@user)
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?

      # 🎓 origin_params: https://github.com/omniauth/omniauth?tab=readme-ov-file#origin-param
      # params: {origin: URL} を指定すると、OmniAuthが"omniauth.origin"にコールバック時のURLを設定する
      origin = request.env["omniauth.origin"].presence
      redirect_to(origin || stored_location_for(:user) || root_path)
    else
      redirect_to new_user_session_url
    end
  end

  def failure
    redirect_to new_user_session_path
  end
end
