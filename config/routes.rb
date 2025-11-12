Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # ゲストユーザー作成用ルート
  devise_scope :user do
    post "/users/guest", to: "users/sessions#create_guest", as: :guest_session
  end

  resources :tasks do
    patch :toggle_status, on: :member # toggle_statusというカスタムアクションの追加
    collection do
      get :autocomplete
    end
    resources :posts, only: [ :create, :destroy ]
    resources :todos, only: [ :update ]
    resource :til, only: [ :new, :create ]
  end

  root "static_pages#top"
end
