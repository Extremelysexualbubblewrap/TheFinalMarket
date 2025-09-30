Rails.application.routes.draw do
  resources :conversations, only: [:index, :create] do
    resources :messages, only: [:index, :create]
  end

  # Seller Area
  namespace :seller do
    resources :orders, only: [:index, :show] do
      member do
        patch :ship
      end
    end
  end

  # Seller Dashboard
  namespace :dashboard do
    get 'overview'
    get 'payment_history'
    get 'escrow'
    get 'bond'
  end

  # Search routes
  get 'search', to: 'search#index'
  get 'search/suggestions', to: 'search#suggestions'

  # Admin routes
  namespace :admin do
    get 'financials', to: 'financials#index'

    resources :users, only: [:index, :show] do
      member do
        patch :suspend
        post :warn
        patch :verify_seller
      end
    end

    resources :disputes, only: [:index, :show] do
      member do
        patch :assign_moderator
        post :post_comment
        patch :resolve
      end
    end

    resources :bonds, only: [:index, :show] do
      member do
        patch :approve
        patch :forfeit
      end
    end

    get 'analytics', to: 'analytics#index'
    get 'analytics/real_time', to: 'analytics#real_time'
    get 'analytics/cohorts', to: 'analytics#cohorts'
    get 'analytics/export', to: 'analytics#export'
    get 'analytics/dashboard', to: 'analytics#dashboard'

    resources :ab_tests do
      member do
        get :report
        patch :update
      end
      collection do
        get :dashboard
      end
    end

    namespace :predictive_analytics do
      root to: 'predictive_analytics#index'
      get 'sales_forecast'
      get 'inventory_predictions'
      get 'customer_behavior'
      get 'churn_risk'
      post 'retrain_models'
    end
  end

  # Square webhooks
  namespace :webhooks do
    post 'square', to: 'square#receive'
  end

  # Mount Split Dashboard
  mount Split::Dashboard, at: 'split', constraints: -> (request) { 
    request.env['warden'].user&.admin? 
  }

  resources :tags, except: [:new, :edit] do
    get :autocomplete, on: :collection
  end

  resources :products do
    resources :variants, except: [:index, :show]
    resources :option_types, except: [:index, :show] do
      resources :option_values, only: [:create, :update, :destroy]
    end
    resources :product_images, only: [:create, :destroy] do
      member do
        patch :make_primary
        patch :update_position
      end
    end
  end

  resource :wishlist, only: [:show] do
    post 'add/:product_id', to: 'wishlists#add_item', as: :add_item
    delete 'remove/:product_id', to: 'wishlists#remove_item', as: :remove_item
  end

  resources :saved_items, only: [:index, :create, :destroy] do
    member do
      post :move_to_cart
    end
  end

  resources :recommendations, only: [:index] do
    get :recently_viewed, on: :collection
    get :similar_products, on: :collection
  end

  resource :comparisons, only: [:show] do
    post 'add/:product_id', to: 'comparisons#add_item', as: :add_item
    delete 'remove/:product_id', to: 'comparisons#remove_item', as: :remove_item
    delete 'clear', to: 'comparisons#clear', as: :clear
  end
  
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
