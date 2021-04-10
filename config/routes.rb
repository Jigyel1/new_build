# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount Telco::Uam::Engine, at: '/'

  root 'home#index'

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: { invitations: :invitations }
    end
  end
end
