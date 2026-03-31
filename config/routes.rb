Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords",
    confirmations: "users/confirmations",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  # ゲストユーザー作成用ルート
  devise_scope :user do
    post "/users/guest", to: "users/sessions#create_guest", as: :guest_session
  end

  resources :tags, only: [] do
    collection do
      get :autocomplete
    end
  end

  resources :tasks do
    # 🎓 member, collectionルーティングについて: https://railsguides.jp/v7.2/routing.html#restful%E3%81%AA%E3%82%A2%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3%E3%82%92%E3%81%95%E3%82%89%E3%81%AB%E8%BF%BD%E5%8A%A0%E3%81%99%E3%82%8B
    member do
      patch :toggle_status # PATCHリクエストとそれに伴う/tasks/:id/toggle_statusを認識
    end
    collection do
      get :autocomplete # GETリクエストとそれに伴う/tasks/autocomplete（idを伴わないパス）を認識
    end
    resources :posts, only: [ :create, :destroy ]
    resources :todos, only: [ :update ]
    resource :til, only: [ :new, :create ]
    resource :repo, only: [ :new, :create ]
  end

  root "pages#home"
end
