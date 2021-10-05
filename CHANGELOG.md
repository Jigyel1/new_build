# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.2] - 2021-08-15

### Feature
- Projects - [Stories](https://docs.google.com/document/d/1Y2CNgTsEwuf48CmSIUKxr1wTXq5Lynwn1PPdhxHzgrE/edit#)

### Fixes
- project_type in AdminToolkit::FootprintValue renamed as category.
- Create KamRegions individually with validations instead of a bulk insert.
- Seed AdminToolkit::LabelGroups with respect to the available project statuses.
- Set min PCT month to 0 and max to max unsigned int.

### Tasks

```ruby
rails db:migrate:redo VERSION=20210702172133
rails db:migrate
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