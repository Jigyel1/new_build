# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  mount Telco::Uam::Engine, at: '/'

  root 'home#index'

  namespace :api do
    namespace :v1 do
      # comment this out(`devise_for ...`) in case you face issues like
      #    #=>`PG::UndefinedTable: ERROR:  relation "profiles" does not exist`
      #
      # in development/test servers when running migration from scratch.
      devise_for :users, controllers: { invitations: :invitations }

      post '/graphql', to: 'graphql#execute'
    end
  end

  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: 'api/v1/graphql' if Rails.env.development?
end
