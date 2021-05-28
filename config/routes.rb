# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount Telco::Uam::Engine, at: '/'

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(username),
      ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])
    ) & ActiveSupport::SecurityUtils.secure_compare(
      ::Digest::SHA256.hexdigest(password),
      ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'])
    )
  end
  mount Sidekiq::Web, at: '/sidekiq'

  get 'homes/index', to: 'homes#index'
  root 'homes#index'

  namespace :api do
    namespace :v1 do
      get :authorization_endpoint, to: 'omniauth#authorization_endpoint'
      post '/graphql', to: 'graphql#execute'
    end
  end

  scope 'api/v1', defaults: { format: :json } do
    devise_for :users,
               class_name: 'Telco::Uam::User',
               module: :devise,
               controllers: {
                 omniauth_callbacks: 'telco/uam/api/v1/omniauth_callbacks'
               }
  end

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: 'api/v1/graphql' if Rails.env.development?
end
