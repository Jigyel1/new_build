# frozen_string_literal: true

namespace :db do
  desc 'This is an idempotent execution. Can be called any number of times.'
  task setup_prod: :environment do
    load Rails.root.join('db/prod_seeds.rb')
  end

  desc 'Seed user for login with some 1000 fake users'
  task setup_dev: :environment do
    sh 'rails db:setup_prod db:seed'
    sh 'USERS=1000 rails fakefy:load'
  end

  desc 'Drop, create, run migrations & seed db from scratch'
  task reset_dev: :environment do
    sh 'rails db:environment:set RAILS_ENV=development'
    sh 'rails db:drop db:create db:migrate db:test:prepare db:setup_dev'
  end
end
