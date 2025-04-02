Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      get "users/me", to: "users#me"

      resources :projects, only: [:index, :show, :create, :update, :destroy] do
        resources :tasks, only: [:index, :show, :create, :update, :destroy]
  
        resources :fields, only: [:index, :show, :create, :update, :destroy]
        resources :field_values, only: [:index, :show, :create, :update, :destroy]
      end
  
      resources :field_definitions, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
