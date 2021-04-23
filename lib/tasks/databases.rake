# frozen_string_literal: true

namespace :db do
  task setup_prod: :environment do
    # sh 'rails db:prod_seeds'
    load Dir[Rails.root.join('db', 'prod_seeds.rb')].first
  end

  task setup_dev: :environment do
    sh 'rails db:seed'
    sh 'USERS=1000 rails fakefy:load'
  end

  task reset_dev: :environment do
    def update_file
      routes = Rails.root.join('config', 'routes.rb')
      lines = File.readlines(routes)
      index = lines.index { |line| line.include?('devise_for :users') }

      # comment out `devise_for` until the migration is complete as it causes migration issues.
      to_prepend = '# '
      lines[index].prepend(to_prepend)
      File.open(routes, 'w') { |f| f.write(lines.join) }

      yield if block_given?

      # uncomment `devise_for` after the migration.
      lines[index] = lines[index][to_prepend.size..]
      File.open(routes, '') { |f| f.write(lines.join) }
    end

    update_file do
      sh 'rails db:environment:set RAILS_ENV=development'
      sh 'rails db:drop db:create db:migrate db:test:prepare db:setup_dev'
    end
  end
end
