What gets measured gets managed.

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
`rails db:setup`


# Tests

for specs, make sure you test for both data(success) or errors(failure).

Success Mocks
put the mocks for errors first for faster tracking during errors.

Failure Mocks
do the reverse for failure mocks.

# Logs

sidekiq - `journalctl -u sidekiq_new_build -f`

# Avatar upload

```ruby
curl localhost:3000/api/v1/graphql -H "Accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI3OTA2ZmM0ZS04YTA5LTQ2YmEtOTE3YS05M2M4ZDY5ZjZiYmEiLCJzdWIiOiI1YTVmYmI0NS0zYmE2LTQzMDgtODlkYy01NTYzNjc1Nzc5ZWEiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE2MTk2Mjk2MjksImV4cCI6MTYxOTYzMzIyOX0.k-OYoMA31JsMf-8L2FflBzXFv2poCYxV_N5J_Hkf6W0``" -F operations='{ "query": "mutation (\$avatar: Upload!) { uploadAvatar(input: { avatar: \$avatar }) { user { profile {avatarUrl} } } }", "variables": { "avatar": null} }' -F map='{ "0": ["variables.avatar"] }' -F 0=@spec/files/matrix.jpeg
```


# Activity Log

Activity Stream 2.0

# DB migrate

`rollback` on mat views don't seem to work with the default configuration. comment out the `update_view ....`, `rollback` and `uncomment & migrate`

# TODOS:

1. erd/class diagram
2. rollbar