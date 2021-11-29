Rails.application.routes.draw do
  root 'posts#index'
  devise_for :users
  resources :posts, :profiles, :friend_requests
  post 'friend_requests/accept/:id', to: 'friend_requests#accept_request', as: 'accept_friend_request'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
