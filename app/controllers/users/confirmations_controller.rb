# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  # def show
  #   super
  # end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  protected

  # 確認後のリダイレクト先を指定するメソッド
  # 元いた画面（stored_location_for）があればそこへ、なければタスク一覧画面へリダイレクト
  def after_confirmation_path_for(resource_name, resource)
    stored_location_for(resource) || tasks_path
  end
end

