## Documentation
For REST specific docs, check out [project-url/api-docs](https://new-build.selise.dev/api-docs/index.html). The documentation is password protected. 

---

## Test Server 

Navigating to the server - 
```ruby
ssh ssh telco@192.168.20.2 -p 5657 # jump box
ssh telco # actual test server
```

### Server 1 #Thor
url: `new-build-thor.selise.dev`
project_root: `/home/telco/new-build/thor/be/new-build`
type `new-build-thor` to go to project root

---

from the jump server - `su mvm`, then `ssh nginx`

nginx_config: `//etc/nginx/conf.d/telco/new-build-thor.conf`

---

sidekiq-ui: `new-build-thor.selise.dev/sidekiq`

api-docs: `new-build-thor.selise.dev/api-docs`

Credentials available in the `.env` file.

puma_config: `/lib/systemd/system/puma_new_build_thor.service`

sidekiq_config: `/lib/systemd/system/sidekiq_new_build.service`

sidekiq logs: `journalctl -u sidekiq_new_build_thor -f`

action mailer settings with SMTP - check out `config/environments/production.rb` at `/home/telco/new-build/thor/be/new-build`

---

### Server 2 #Loki

Use the same configuration as server 1 but instead of thor, replace all text with loki.

---

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

### Graphical Workflow

![graphical-workflow](class_diagrams/graphical-workflow.png)

---

# Performance

1. Resolvers are expected to execute any implementation within `10 ms` - Max 50 only at extreme cases. To ensure that, we use `rspec-benchmark`.
For example check out - `spec/graphql/resolvers/users_resolver_spec.rb`. 

---

# Modules

### Admin Toolkit

- [Stories](https://docs.google.com/document/d/1vdkGmwaZxw4uApvr-fqXgd0JG4YNEp2OxjtEfENXvus/edit)
- [Designs](https://www.figma.com/file/1wn1cKsrkRryY3lv6ATGZm/UPC-New-Build?node-id=2661%3A5365)

---

# Avatar upload

```ruby
curl -X POST localhost:3000/api/v1/graphql -H "Accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJhODM1NzU2Ny1mODhiLTQ0MDctOTUyOS1kNzcyODM2NGJlY2MiLCJzdWIiOiIyYTJiZjJkZS1kMjMxLTRiMTEtYTBmMi0yMzM4ZTQ5NTljYjYiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE2MjI3MTYzOTUsImV4cCI6IjE2NTkwMDQzOTUifQ.PnleIkS9hskyU8vGz2C83crVAI5nSfwUiqjcfElHp7M"  -F operations='{ "query": "mutation ($avatar: Upload!) { uploadAvatar(input: { avatar: \$avatar }) { user { profile {avatarUrl} } } }", "variables": { "avatar": null} }' -F map='{ "0": ["variables.avatar"] }'  -F 0=@spec/files/matrix.jpeg
```

```ruby
# test server - thor 
curl -X POST https://new-build-thor.selise.dev/api/v1/graphql -H "Accept: application/json" -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJqdGkiOiJhODM1NzU2Ny1mODhiLTQ0MDctOTUyOS1kNzcyODM2NGJlY2MiLCJzdWIiOiIyYTJiZjJkZS1kMjMxLTRiMTEtYTBmMi0yMzM4ZTQ5NTljYjYiLCJzY3AiOiJ1c2VyIiwiYXVkIjpudWxsLCJpYXQiOjE2MjI3MTYzOTUsImV4cCI6IjE2NTkwMDQzOTUifQ.PnleIkS9hskyU8vGz2C83crVAI5nSfwUiqjcfElHp7M"  -F operations='{ "query": "mutation ($avatar: Upload!) { uploadAvatar(input: { avatar: \$avatar }) { user { profile {avatarUrl} } } }", "variables": { "avatar": null} }' -F map='{ "0": ["variables.avatar"] }'  -F 0=@spec/files/matrix.jpeg

```

---

## Activity Log

TODO: Activity Stream 2.0

--- 
## Migration guidelines

`rollback` on mat views don't seem to work with the default configuration. comment out the `update_view ....`, `rollback` and `uncomment & migrate`

---

## .env

TEST_SERVER
> When `TEST_SERVER` is true, cors will be enabled. Also, if this is enabled, jwt token will be sent to FE for development/testing purposes.
  Use this only in the test servers!

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



```ruby
# A project will be assigned to NBO/KAM in the following different ways:
# 1) If a project has more than 50 homes then such types of projects will be assigned to KAM.
# This assignment will be done based on the settings of "KAM Regions" in the Penetration tab from the Admin toolkit.
#
# 2) If a project has a specific landlord, then such projects will be assigned to certain KAMs who are assigned
# those landlords. This assignment will be done based on the settings in the "Assign KAM" tab from the Admin toolkit.
#
# 3) If a project is newly uploaded/created into the New Build portal but if no above criteria
# are there for that project then it will be assigned to the NBO(any user with that role) and has
# clicked on that project will be automatically assigned.
#
# If a project is assigned to a KAM (scenarios 1 and 2), then the system generated label "KAM Project" will be added
# to the project. If it is assigned to the NBO team (scenario 3), then the system generated label "NBO Project" will
# be added to the project.


# Project Type
# What are Customer Requests, Proactive and Reactive Projects?
# Customer request - Those type of projects where a Customer applied themselves to Sunrise UPC to get a service from them
# Reactive - If a project is not a good deal, the NBO team/KAM team will send it to the Sales team.
# Such projects will be considered a “Reactive project” until the customer gets back to Sunrise UPC for further inquiry.
#
# Proactive - If a project is a very good deal then Sunrise UPC will give that customer’s project high
# priority and become a “proactive project”.
```