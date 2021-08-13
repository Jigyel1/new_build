# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.1] - 

### Feature
- Projects

### Fixes

### Tasks
- Redo admin toolkit project cost create migration
```ruby
rails db:migrate:redo VERSION=20210702172133
```

## [0.1.1] - 2021-07-30

### Feature 
- Admin Toolkit - [Stories](https://docs.google.com/document/d/1vdkGmwaZxw4uApvr-fqXgd0JG4YNEp2OxjtEfENXvus/edit)

### Tasks
- Seed competitions, footprints, labels & PCTs.
```ruby
rails db:setup_prod
rails import:penetrations
```

## [0.1.0] - 2021-05-03

---
### Feature
- User invitation, profile management, role management, user address
- Role based permissions

### Tasks

- `rails db:setup_prod`
    - populates roles & their respective permissions