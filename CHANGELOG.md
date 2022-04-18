# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.7.0] - 2022-04-26

### Features
- Trackable id filter added to activities resolver.

## [1.6.2] - 2022-04-12

### Fixes
- Verdict not getting updated.
- Replaced null value of verdict with empty object '{}'

### Tasks
```ruby
rake verdict:replace_null
```

## [1.6.1] - 2022-03-24

### Fixes
- User sign_out and sign_in routes added for prod && preprod.

## [1.6.0] - 2022-04-5

### Features
- Sorting filter for name, labels and confirmation states.

### Fixes
- Revert issue for confirmation fix.
- Clearing tac properties while reverting back to TA.

### Tasks
```ruby
rake gis:populate
```

## [1.5.0] - 2022-03-29

### Features
- New offer confirmation state introduced.
- Assigned kam field added in projects.
- Added confirmation status for the project in RFO state.
- Updated permissions.

### Fixes
- Pdf building type display fix.

## [1.4.0] - 2022-03-23

### Features
- Email trigger for building count error.
- File upload attribute added.
- Project site address for project.
- HFC new logic update for standard cost.

### Fixes
- PDF gis url mapping fix.
- Project structure update with new building flow.
- Remove move_in_end_date from building.

## [1.3.2] - 2022-03-21

## Fixes
- Pct range rake task added.

### Tasks
```ruby
rake seed:pct
```

## [1.3.2] - 2022-03-18

### Fixes
- Plz spacing error fix.
- Typo mistake fix

## [1.3.1] - 2022-03-16

### Fixes
- Admintoolkit Pct Calculation range fixes.
- Edit payback issue fix.

## [1.3.0] - 2022-02-28

### Features
- Project contract summary pdf generation endpoint.
- New gems used for pdf generation:
    - `wicked_pdf`
    - `wkhtmltopdf-binary`
    - `draper`

## [2.1.1] - 2022-03-09

### Features
- Access Technology logic implementation in TA state.
- Payback Period calculators.
- Permissions update with cost threshold.
- Cost Threshold permission application on project level.

### Fixes
- Project Label update fixes.
- Pct calculation, payback period, build cost and lease cost fixies.
- Revert project state issue fixes.
- Archiving issues fixes.

## [2.1.0] - 2022-03-09

### Feature
- Introduced third_party access technology.
- Introduced building type for project.
- Introduced new attributes in AdminToolkit::Competition

### Fixes
- Project Label update fixes.

## [2.0.3] - 2022-02-25

### Fixes
- If a project has more than 50 homes then such types of projects will be assigned to KAM. This assignment will be done based on the settings of “KAM Regions” in the Penetration tab from the Admin toolkit.
- If a project has a specific landlord, then such projects will be assigned to certain KAMs who are assigned to those landlords. This assignment will be done based on the settings in the “Assign KAM” tab from the Admin toolkit.
- If a project is newly uploaded/created into the New Build portal but if no above criteria are there for that project then it will be assigned to the NBO team (expert or standard) and any other person who clicks on that project will be automatically assigned.
- Project lot number fix
- Translation added fro address book deleter activity log.

## [2.0.2] - 2022-02-25

### Features
- Access Technology logic implementation in TA state.
- Payback Period calculators.
- Introduced third_party access technology.
- Permissions update with cost threshold.
- Introduced building type for project.
- Introduced new attributes in AdminToolkit::Competition
- Cost Threshold permission application on project level.

### Fixes
- Project Label update fixes.
- Pct calculation, payback period, build cost and lease cost fixies.
- Revert project state issue fixes.
- Archiving issues fixes.


## [2.0.1] - 2022-02-17

### Features
- PLZ file import error email trigger.
- Building file import email trigger.

## [1.2.1] - 2022-01-04

### Fixes
- Added missing building argument in TAC state
- PCT calculation logic update.

## [1.2.0] - 2021-12-31

### Features
- Introduced "Cost Threshold" in the AdminToolkit, where we can set the margin of the cost,
  So that in the TAC only certain users can move the project from one state to another.

## [1.1.0] - 2021-12-31

### Features
- Introduced "calculate pct as" column in competition table consisting of the following types of PCT calculations.
  - Swisscom DSL
  - SFN/Big4
  - Swisscom FTTH

## [1.0.0] - 2021-12-30

### Features
- Projects can now support multiple connections based on the connection types.
- Support for parallel testing.
- API for importing penetrations.

### Fixes
- Updated logic for calculation PCT cost for projects based on the connection types and sunrise access options.


## [0.4.0] - 2021-12-16

### Features
  - AdminToolkit for Ready for Offer Module:
      - Positions: It contains the additional cost i.e. discounts and additions which will be used in standard cost calculation in contract summary of the project.
      - Marketings: It has the type of marketing activities with relevant costs, which will be used in the later phase of the contract cost calculations in later stage of the project.
      - Prices: The cost per apartments with the range of apartments are stored in this section which will be used in the standard cost calculations.
      - Offer Content: It has the title and contents of the contract with different language support.

## [0.3.2] - 2021-12-15

### Features
- New gems in dev/test environment
    - `bundler-leak` - find out leaky gem dependencies.
    - `pghero` - a performance dashboard for postgres

### Fixes
- Removing `sidekiq-statistic` until the memory leakage issue is resolved. 
    - https://github.com/davydovanton/sidekiq-statistic/issues/117
- Using static gis url for manually created projects.
    - Add `ENV[GIS_URL_STATIC]` with value of `https://webgis.upc.ch/web_office/synserver?project=AccessPlanningSales&language=DE` 


## [0.3.1] - 2021-11-29

### Features
- Single building details download
- Email trigger for assigning or un-assigning the assignee and the technical incharge of the project
- Email trigger for person assigned to project task

### Fixes
- Activity log text improvements
- Project with earliest date to be listed at top in project listing
- Manager Commercialization role permission update

## [0.3.0] - 2021-11-30

### Features
- API for fetching addresses
- `customer_request` filter on projects
- Soft delete for projects, buildings and address books

### Fixes
- Either `name` or `company` should be mandatory for address books.
- Fix street parsing in project populator.
- Archived projects to be updated with the row data and status updated to `technical_analysis` on import.

## [0.2.1] - 2021-11-15

### Features
- Support for address book deletion
- Auto assign `current_user` as the project incharge if not specified.

### Fixes
- Fix loading of `IdableRows` and `OrderedRows` in `app/services/projects/organizer.rb`
- Use `technical_analysis_completed` permission when transitioning a project from `technical_analysis` to `ready_for_offer` insetad of `ready_for_offer` permission.
- Project status revert to use `from_state` permission instead of `to_state` permission. This means if a user can move the project from `technical_analysis` to `ready_for_offer` then he can also move the project from `ready_for_offer` back to `technical_analysis`.
- Use attributes sent from FE for project transition validation with `TacValidator` and not the with the ones assigned to the project.
- Permission changes for roles in `permissions.yml`.
- ETL jobs to selectively pick rows to be passed further to the ETL pipeline.
- `OnDueDateJob` to be run every day instead of every minute


## [0.2.0] - 2021-11-08

### Features
- Email notification for tasks with respect to due dates.
    - One to be sent a day before the due date at 9:00 AM.
    - Other to be sent on the day of the due date at 5:00 PM.


## [0.1.6] - 2021-11-05

### Features
- `Commercialization` as the final project state with state transitions.

### Fixes
- Admin Toolkit read access for all admins and users with project read permission.
- Allow 0 as min of apartment in `AdminToolkit::Apartment`. 
- Auto-archive irrelevant projects.
- Display `assignee_type` in projects list if assignee is not set.
- Extract out header and footer template for emails.
- Display investor's name in projects list and not investor type.
- Building import - use column 0 for external id and column 5 for internal id.

## [0.1.5] - 2021-10-29

### Fixes
- Query upto only 2 decimal places for the rate in penetrations.
- Save`rate` as decimal(without converting to percent)
    - use the `rate` as is for calculations
    - but show it as a percentage in the admin toolkit
- Don't allow project move in date changes on project update.
- Project move in dates to be changed as per buildings move in dates.
- Move in date validation for projects and buildings.
- Remove authorization when querying for Admintoolkit `labels` and `pct_cost`.
- Extract out concerns for `Project` and `User`.
- Validate user has no `kam_regions` and `kam_investors` before a soft delete.
- Module renaming from `Taskable` to `Trackable`.
- Auto update kam region for projects on `create/update/import`.


## [0.1.4] - 2021-10-25

### Features
- Filter projects with `internal_ids`.
- `draft_version` attribute available to `ProjectsList` table.

### Fixes
- Admin toolkit to use apartments count for project categorization instead of buildings count. `AdminToolkit::Building` renamed as `AdminToolkit::Apartment`
- Re-assign user projects, buildings and tasks to another user before deleting the user.
- For KAMs, KAM Regions & KAM Investors need to be reassigned as well if they have any.
- Mutation changes => `UpdateIncharge` to `AssignIncharge` as this made more sense after introducing `UnassignIncharge` mutation.
- Set `gis_url` and `info_manager_url` for projects on creation.
- Technical Analysis Completed to be performed only by project incharge. And if it's a complex project, they should additionally have permission for complex project transitions.
- Move cost based authorization to `ready_for_offer` stage from `technical_analysis_completed` stage.


## [0.1.3] - 2021-10-19

### Feature
- Activity logs for projects - [Reference](https://docs.google.com/spreadsheets/d/1NG7nZcK1Sb3UIZaOJ6X2mSmPN2zRky7Hi_lrHmmyUYo/edit?ts=60fe4c13#gid=563629172)

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