Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount Telco::Uam::Engine, at: "/"

  root 'home#index'
end
