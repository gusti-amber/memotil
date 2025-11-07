class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_or_guest_user

  # --------------以下ゲストユーザー関連のコード--------------
  protect_from_forgery

  # deviseの:authenticate_user!は動的に生成されるメソッド
  # 以下を参照
  # https://github.com/heartcombo/devise/blob/cf93de390a29654620fdf7ac07b4794eb95171d0/lib/devise/controllers/helpers.rb#L100

  def current_or_guest_user
    if current_user
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        logging_in # データ引き継ぎの機能は今後実装しないかの性が高い
        # reload guest_user to prevent caching problems before destruction
        #
        # キャッシュの問題を回避: @cached_guest_userが古いオブジェクトを参照する可能性
        # 解決策: with_retry=falseでキャッシュ無視 → reloadで最新状態取得 → 安全に削除
        guest_user(with_retry = false).try(:reload).try(:destroy)
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  # find guest_user object associated with the current session,
  # creating one as needed
  def guest_user(with_retry = true)
    # Cache the value the first time it's gotten.
    #
    # キャッシュ: @cached_guest_userで初回のみDBクエリ、以降はキャッシュを返す
    # 注意: 削除処理時はwith_retry=falseでキャッシュを無視する必要がある
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
    # セッションのIDが無効な場合: セッションクリア → with_retry=trueの場合のみ再帰呼び出し
    session[:guest_user_id] = nil
    guest_user if with_retry
  end

  # --------------ここまでゲストユーザー関連のコード--------------

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # ログイン後のリダイレクト先を指定するメソッド（Deviseのデフォルトメソッドをオーバーライド）
  def after_sign_in_path_for(resource)
    # 🎓 before_action :authenticate_user! で保護されたページに未認証でアクセスした場合は、そのURLがstored_location_for(resource)に記録される。
    # 保護されていないページ（例えば、ログイン画面や新規登録画面など）にアクセスした場合は、stored_location_for(resource)はnilになるため、tasks_pathにリダイレクトされる。
    stored_location_for(resource) || tasks_path
  end

  private

  # called (once) when the user logs in, insert any code your application needs
  # to hand off from guest_user to current_user.
  def logging_in
    # For example:
    # guest_comments = guest_user.comments.all
    # guest_comments.each do |comment|
    # comment.user_id = current_user.id
    # comment.save!
    # end
  end

  def create_guest_user
    u = User.new(name: "guest", email: "guest_#{Time.now.to_i}#{rand(100)}@example.com")
    u.save!(validate: false)
    session[:guest_user_id] = u.id
    u
  end
end
