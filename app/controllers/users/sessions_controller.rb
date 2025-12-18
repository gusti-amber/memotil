# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    super
    current_or_guest_user # 主にはゲストユーザーからログイン中のユーザーへのデータの引き継ぎ
  end

  # ゲストユーザー作成アクション
  def create_guest
    guest_user
    set_flash_message(:notice, :signed_in_as_guest) if is_navigational_format?
    redirect_to after_sign_in_path_for(current_user)
  end

  # DELETE /resource/sign_out
  def destroy
    # ゲストユーザーの場合は適切に削除処理を行う
    if current_user&.email&.start_with?("guest_")
      # キャッシュの問題を回避: current_userはWarden戦略によりキャッシュされたオブジェクトの可能性
      # 解決策: IDを保存 → セッションクリア → データベースから直接削除
      guest_user_id = current_user.id
      session[:guest_user_id] = nil

      # データベースから直接取得して削除（キャッシュを無視）
      User.find_by(id: guest_user_id)&.destroy
    end
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
