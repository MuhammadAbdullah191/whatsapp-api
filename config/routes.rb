Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, except: %i(show)
      resources :rooms, except: %i(index update) do
        resources :messages, only: %i(index create)
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
