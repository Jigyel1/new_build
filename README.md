## Documentation
For REST specific docs, check out [project-url/api-docs](https://new-build.selise.dev/api-docs/index.html). The documentation is password protected. 

---

## Test Server 

url: `new-build.selise.dev`
project_root: `/home/dragondevel/Documents/new-build/be/new-build`

nginx_config: `/etc/nginx/conf.d/new-build.conf`

sidekiq-ui: `new-build.selise.dev/sidekiq`

api-docs: `new-build.selise.dev/api-docs`

Credentials available in the `.env` file.

puma_config: `/usr/lib/systemd/system/puma_new_build.service`

sidekiq_config: `/usr/lib/systemd/system/sidekiq_new_build.service`

sidekiq logs: `journalctl -u sidekiq_new_build -f`


### After update

run `bundle; rails db:migrate; sudo service puma_new_build restart, sudo service sidekiq_new_build restart`

---

## Project setup locally(or in test servers)

`rails db:setup_dev` to seed fake data.

`rails db:reset_dev` custom version of `rails db:reset` with fake data seeded.

---

## Test guidelines

Graphql will always return a 200 status irrespective of whether the execution succeeded or failed. So make sure you test both the `response/data` and `errors`.

<u>Success Mocks</u>
 
Mock `errors` first then the `data/response`. Speeds up the debugging process.

<u>Failure Mocks</u>

Do the opposite of success mocks(i.e. Test `data/response` first)

---

# Portal conventions

### Mutations

1. For mutations that accept single argument, use a single keyword argument in the resolve method. eg. `upload_avatar`, `delete_user`

2. And those that accept multiple arguments, nest it under the attributes params. eg. `update_user`, `update_user_status` etc.

---


# Avatar upload

```ruby
curl localhost:3000/api/v1/graphql -H "Accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiI3OTA2ZmM0ZS04YTA5LTQ2YmEtOTE3YS05M2M4ZDY5ZjZiYmEiLCJzdWIiOiI1YTVmYmI0NS0zYmE2LTQzMDgtODlkYy01NTYzNjc1Nzc5ZWEiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE2MTk2Mjk2MjksImV4cCI6MTYxOTYzMzIyOX0.k-OYoMA31JsMf-8L2FflBzXFv2poCYxV_N5J_Hkf6W0``" -F operations='{ "query": "mutation (\$avatar: Upload!) { uploadAvatar(input: { avatar: \$avatar }) { user { profile {avatarUrl} } } }", "variables": { "avatar": null} }' -F map='{ "0": ["variables.avatar"] }' -F 0=@spec/files/matrix.jpeg
```

---

## Activity Log

TODO: Activity Stream 2.0

--- 
## Migration guidelines

`rollback` on mat views don't seem to work with the default configuration. comment out the `update_view ....`, `rollback` and `uncomment & migrate`

---

## .env

PRODUCTION_SERVER
> When `PRODUCTION_SERVER` is false, cors will be enabled.
  Set this to true in the actual production server!

ALLOWED_DOMAINS
> Only users with the given domain can be invited & use the portal. For specs to work in bitbucket pipelines, make sure you atleast add selise.ch in ALLOWED_DOMAINS

MAIL_SENDER
> Application email sender - from

SWAGGER_USER, SWAGGER_PASS
> For API docs access protection. /api-docs

MAX_PAGE_SIZE
> Number of items returned per page. Defaults to 100. Defaults to 100

SESSION_TIMEOUT
> Devise session timeout. Defaults to 30 minutes of inactivity.

REDIS_HOST, REDIS_SECRET
> Redis credentials

SIDEKIQ_USERNAME, SIDEKIQ_PASSWORD
> For sidekiq UI - /sidekiq

USERS_PER_ROLE
> Users you want to show for each role. Only in the listing page. Details will call a different endpoint.
