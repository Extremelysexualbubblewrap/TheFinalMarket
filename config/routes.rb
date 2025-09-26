Rails.application.routes.draw do
  get "notifications/index"
  get "notifications/mark_as_read"
  get "notifications/mark_all_as_read"
  resources :bonds, only: [:new, :create]
  resources :disputes do
    resources :comments, controller: 'dispute_comments', only: [:create]
  end
  namespace :moderator do
    root 'disputes#index'
    resources :disputes do
      member do
        patch :resolve
        patch :dismiss
        patch :assign
      end
    end
  end

  resources :disputes, only: [:index, :show, :new, :create] do
    collection do
      get :my_disputes
    end
  end
  namespace :admin do
    root 'dashboard#index'
    resources :users do
      patch :toggle_role, on: :member
    end
    resources :products, only: [:index, :show, :destroy]
    resources :seller_applications, only: [:index, :show, :update]
  end
  resources :seller_applications, only: [:new, :create]
  resources :cart_items do
    collection do
      delete :clear
    end
  end
  root 'products#index'
  
  resources :items do
    resources :reviews, only: [:create, :update, :destroy] do
      member do
        post :helpful
        delete :helpful, action: :unhelpful
      end
    end
  end

  resources :users do
    resources :reviews, only: [:create, :update, :destroy] do
      member do
        post :helpful
        delete :helpful, action: :unhelpful
      end
    end
  end
  
  get    '/signup',  to: 'users#new'
  post   '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  
  resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
