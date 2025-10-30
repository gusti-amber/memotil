# 🎓 参考資料: https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :github

  def github
    @user = User.from_github(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in(@user)
      set_flash_message(:notice, :success, kind: "GitHub") if is_navigational_format?
      redirect_to tasks_path
    else
      redirect_to new_user_session_url
    end
  end

  def failure
    redirect_to new_user_session_path
  end
end


