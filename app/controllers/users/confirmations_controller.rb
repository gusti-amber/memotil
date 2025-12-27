# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    # 🎓 Devise デフォルトの記述: https://github.com/heartcombo/devise/blob/main/app/controllers/devise/confirmations_controller.rb
    # 確認処理の前に、メールアドレス変更用の確認メールかどうかを判定(確認処理が完了すると、unconfirmed_emailがnilになるため)
    # unconfirmed_emailが存在する場合はメールアドレス変更用のメールと判定
    self.resource = resource_class.find_by_confirmation_token(params[:confirmation_token])
    @is_email_change = resource&.unconfirmed_email.present?

    super
  end

  # POST /resource/confirmation
  # def create
  #   super
  # end

  protected

  # 確認後のリダイレクト先を指定するメソッド
  # - メールアドレス変更用の確認メール → 元いた画面があればそこへ、なければタスク一覧画面へ
  # - メールアドレス登録用の確認メール（サインアップ時）→ ログイン画面へ
  def after_confirmation_path_for(resource_name, resource)
    if @is_email_change
      # メールアドレス変更用の確認メールの場合
      stored_location_for(resource) || tasks_path
    else
      # メールアドレス登録用の確認メール（サインアップ時）の場合
      new_user_session_path
    end
  end
end
