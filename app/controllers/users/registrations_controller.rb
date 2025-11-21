# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [ :update ]
  before_action :store_previous_path, only: [ :edit ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    super
    current_or_guest_user # 主にはゲストユーザーからログイン中のユーザーへのデータの引き継ぎ
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # 元いたページのURLをセッションに保存
  def store_previous_path
    session[:previous_path] = request.referer.presence
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  # 🎓 プロフィール更新後、sessionに保存された、前のページにリダイレクトする。sessionに値がない場合はタスク一覧画面にフォールバック
  # 参考wiki: https://github.com/heartcombo/devise/wiki/How-To:-Customize-the-redirect-after-a-user-edits-their-profile
  def after_update_path_for(_resource)
    previous_path = session[:previous_path]
    session.delete(:previous_path)
    previous_path.presence || tasks_path
  end

  # 🎓 Deviseのupdate_resourceメソッドをオーバーライド。current password 不要で更新できるように変更
  # 参考wiki: https://github.com/heartcombo/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password
  # ⚠️ 今後、メールアドレスやパスワードの更新を実装する際には、current password を要求するように条件分岐する必要がある
  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end
