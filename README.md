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
curl localhost:3000/api/v1/graphql -H "Accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI0ZDAwNWNkOC0yYTg1LTRiYjEtYmNhYS0yODllNjYyNWIwZGMiLCJzdWIiOiI3OWE4NmI4Yi02MjNhLTQ3ODMtOGMwNC04MzQyZjQ1YmQ1YjAiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE2MTk2MDQ4MjMsImV4cCI6MTYxOTYwODQyM30.ctUh8ag6NKLzDCgyJiEfnPN5STUthJDBtWOL5RaxbfY" -F operations='{ "query": "mutation (\$avatar: Upload!) { uploadAvatar(input: { avatar: \$avatar }) { user { profile {id avatarUrl} } } }", "variables": { "avatar": null} }' -F map='{ "0": ["variables.avatar"] }' -F 0=@spec/files/matrix.jpeg
```


# Activity Log

Activity Stream 2.0

# TODOS:

1. erd/class diagram
2. rollbar