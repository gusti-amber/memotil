Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }
  
  # ゲストユーザー作成用ルート
  devise_scope :user do
    post '/users/guest', to: 'users/sessions#create_guest', as: :guest_session
  end

  root "static_pages#top"
end
