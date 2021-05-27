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

  root 'homes#index'

  namespace :api do
    namespace :v1 do
      get :authorization_endpoint, to: 'omniauth#authorization_endpoint'

      # comment this out(`devise_for ...`) in case you face issues like
      #    #=>`PG::UndefinedTable: ERROR:  relation "profiles" does not exist`
      # in development/test servers when running migration from scratch.
      #
      # Note: This is already taken care of when you run `rails db:reset_dev`
      # devise_for :users, controllers: { invitations: :invitations }

      post '/graphql', to: 'graphql#execute'
    end
  end

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: 'api/v1/graphql' if Rails.env.development?
end
