module ApplicationHelper
  def auth_page?
    devise_controller? && (
      (controller_name == "sessions" && action_name == "new") ||
      (controller_name == "registrations" && %w[new create].include?(action_name)) ||
      (controller_name == "passwords" && %w[new edit create update].include?(action_name)) ||
      (controller_name == "confirmations" && %w[new show create].include?(action_name))
    )
  end
end
