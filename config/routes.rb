Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/docs"
  mount Rswag::Api::Engine => "/docs"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  post "sleep_records/clock_in", to: "sleep_records#clock_in"
  post "sleep_records/clock_out", to: "sleep_records#clock_out"
  post "login", to: "auth#login"
  delete "logout", to: "auth#logout"

  resources :followings, only: [:create]
end
