module ApplicationHelper
  def auth_page?
    devise_controller? && %w[sessions registrations].include?(controller_name) && action_name == 'new'
  end
end
