module ApplicationHelper
  def auth_page?
    devise_controller? && (
      (controller_name == "sessions" && action_name == "new") ||
      (controller_name == "registrations" && action_name == "new") ||
      (controller_name == "passwords" && %w[new edit].include?(action_name))
    )
  end
end
