# Documentation use Swagger - open API specs

For telco-uam  use rspec api documentation. 

# Generators 
 how are generators created in rails
- for eg. rails g devise:views
  https://guides.rubyonrails.org/generators.html


https://github.com/gjtorikian/graphql-docs

# .env

Make sure you update the following keys
SESSION_TIMEOUT = `30` # in minutes

# Seed

`rails db:seed` to populate current_user

`USERS=100000 rails fakefy:load` to generate fake data


# Tests

for specs, make sure you test for both data(success) or errors(failure).

Success Mocks
put the mocks for errors first for faster tracking during errors.

Failure Mocks
do the reverse for failure mocks.

# Logs

sidekiq - `journalctl -u sidekiq_new_build -f`

# Activity Log

Activity Stream 2.0