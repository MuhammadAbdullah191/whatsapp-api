Rails.application.routes.draw do
  root 'pages#index'
  namespace :api do
    namespace :v1 do
      resources :users, except: [:show]
      resources :rooms, except: [:update] do
        resources :messages, only: [:index, :create]
      end

    end
    
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
