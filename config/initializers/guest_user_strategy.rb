# wardenストラテジーについてはこちらを参照
# https://github.com/wardencommunity/warden/wiki/Strategies
Warden::Strategies.add(:guest_user) do
  # このストラテジーが実行されるべきかを判定
  # ゲストユーザーIDがセッションに存在する場合のみ、このストラテジーが有効になる
  def valid?
    session[:guest_user_id].present?
  end

  # 実際の認証処理を実行
  # ゲストユーザーIDをもとに、ユーザーを取得し、認証を行う
  def authenticate!
    u = User.where(id: session[:guest_user_id]).first
    success!(u) if u.present?
  end
end
