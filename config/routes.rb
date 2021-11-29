Rails.application.routes.draw do
  root 'posts#index'
  devise_for :users
  resources :posts

  resources :users, only: %i[index show] do
    resources :friendships, only: %i[create] do
      collection do
        get 'accept_friend_request'
        get 'decline_friend_request'
      end
    end
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
