Rails.application.routes.draw do
  root 'posts#index'
  devise_for :users
  resources :users, only: %i[index show] do
    resources :friendships, only: %i[create]
  end
  resources :posts
  post 'friend_requests/accept/:id', to: 'friend_requests#accept_request', as: 'accept_friend_request'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
