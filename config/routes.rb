Rails.application.routes.draw do
  root 'pages#index'
  namespace :api do
    namespace :v1 do
      resources :users do
        collection do
          get 'verify_user'
        end
      end
      resources :rooms do
        resources :messages
        collection do
          get 'find_by_user_ids'
        end
        
      end

    end
    
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
