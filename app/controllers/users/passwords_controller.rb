# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # 🎓 passwords#createをカスタマイズ
  # 公式実装: https://github.com/heartcombo/devise/blob/main/app/controllers/devise/passwords_controller.rb
  def create
    email = user_params[:email]
    user = User.find_by(email: email)

    # 未確認ユーザーの場合、エラーを追加
    if !user&.confirmed?
      self.resource = resource_class.new(user_params)
      resource.errors.add(:email, :unconfirmed)
      respond_with(resource)
    else
      super
    end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  protected

  def user_params
    params.require(:user).permit(:email)
  end

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
