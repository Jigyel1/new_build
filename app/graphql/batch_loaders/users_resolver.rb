# frozen_string_literal: true

module BatchLoaders
  class UsersResolver < GraphQL::Function
    def call(role, _args, _ctx)
      # `.for` makes sure we return the same loader instance
      # so all leaves, so we can group data
      loader = UsersLoader.for
      # adds a post to the list of posts to be loaded
      loader.load(role)
      # returns the loader, not the actual topics
      # this gets transformed into topics afterward
      loader
    end

    # Loaders represent promises and mechanism to
    # postpone loading until we have all posts in the list
    class UsersLoader < GraphQL::Batch::Loader
      # perform called with all the posts
      def perform(roles)
        # this is the built-in active record mechanism to
        # preload associations into a group of records
        # association are loaded with the minimum amount of queries
        # if a couple of posts have same topics they would be loaded once
        ::ActiveRecord::Associations::Preloader.new.preload(roles, :users)

        roles.each do |role|
          # returns topics for every post in the list
          fulfill role, role.users
        end
      end
    end
  end
end
