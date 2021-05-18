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
    def update_file # rubocop:disable Metrics/AbcSize, Rake/MethodDefinitionInTask
      routes = Rails.root.join('config/routes.rb')
      lines = File.readlines(routes)
      index = lines.index { |line| line.include?('devise_for :users') }

      # comment out `devise_for` until the migration is complete as it causes migration issues.
      to_prepend = '# '
      lines[index].prepend(to_prepend)
      File.open(routes, 'w') { |f| f.write(lines.join) }

      yield if block_given?
    rescue StandardError => e
      puts e
    ensure
      # uncomment `devise_for` after the migration.
      lines[index] = lines[index][to_prepend.size..]
      File.open(routes, 'w') { |f| f.write(lines.join) }
    end

    update_file do
      sh 'rails db:environment:set RAILS_ENV=development'
      sh 'rails db:drop db:create db:migrate db:test:prepare db:setup_dev'
    end
  end
end
