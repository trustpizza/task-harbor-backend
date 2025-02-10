Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  # # config/routes.rb
  resources :project_templates do
    resources :projects, only: [:create] do
      resources :tasks, only: [:create, :show, :update, :destroy] do
        post 'dependencies', on: :member, to: 'tasks#add_dependency'
        delete 'dependencies/:depends_on_task_id', on: :member, to: 'tasks#remove_dependency'
      end
    end
  end
  resources :projects, only: [:index, :show]

end
