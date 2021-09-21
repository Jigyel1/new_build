# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_09_11_120552) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.uuid "owner_id"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["owner_id"], name: "index_active_storage_attachments_on_owner_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "owner_id", null: false
    t.string "trackable_type"
    t.uuid "trackable_id"
    t.uuid "recipient_id"
    t.string "action", null: false
    t.jsonb "log_data", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_activities_on_created_at", order: :desc
    t.index ["log_data"], name: "index_activities_on_log_data"
    t.index ["owner_id"], name: "index_activities_on_owner_id"
    t.index ["recipient_id"], name: "index_activities_on_recipient_id"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["trackable_type", "trackable_id"], name: "index_activities_on_trackable"
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "street", default: ""
    t.string "street_no", default: ""
    t.string "city", default: ""
    t.string "zip", default: ""
    t.string "addressable_type"
    t.uuid "addressable_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "log_data"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "admin_toolkit_competitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.float "factor", null: false
    t.decimal "lease_rate", null: false
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "admin_toolkit_footprint_buildings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "min", null: false
    t.integer "max", null: false
    t.integer "index", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index"], name: "index_admin_toolkit_footprint_buildings_on_index"
  end

  create_table "admin_toolkit_footprint_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider", null: false
    t.integer "index", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index"], name: "index_admin_toolkit_footprint_types_on_index"
  end

  create_table "admin_toolkit_footprint_values", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "project_type", null: false
    t.uuid "footprint_building_id", null: false
    t.uuid "footprint_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["footprint_building_id"], name: "index_admin_toolkit_footprint_values_on_footprint_building_id"
    t.index ["footprint_type_id"], name: "index_admin_toolkit_footprint_values_on_footprint_type_id"
  end

  create_table "admin_toolkit_kam_investors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "kam_id", null: false
    t.string "investor_id", null: false
    t.text "investor_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["investor_id"], name: "index_admin_toolkit_kam_investors_on_investor_id"
    t.index ["kam_id"], name: "index_admin_toolkit_kam_investors_on_kam_id"
  end

  create_table "admin_toolkit_kam_regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "kam_id"
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["kam_id"], name: "index_admin_toolkit_kam_regions_on_kam_id"
    t.index ["name"], name: "index_admin_toolkit_kam_regions_on_name"
  end

  create_table "admin_toolkit_label_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "label_list", default: [], null: false, array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_admin_toolkit_label_groups_on_code"
    t.index ["label_list"], name: "index_admin_toolkit_label_groups_on_label_list"
  end

  create_table "admin_toolkit_pct_costs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "index", null: false
    t.integer "min", null: false
    t.integer "max", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index"], name: "index_admin_toolkit_pct_costs_on_index"
  end

  create_table "admin_toolkit_pct_months", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "index", null: false
    t.integer "min", null: false
    t.integer "max", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["index"], name: "index_admin_toolkit_pct_months_on_index"
  end

  create_table "admin_toolkit_pct_values", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "status", null: false
    t.uuid "pct_month_id", null: false
    t.uuid "pct_cost_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["pct_cost_id"], name: "index_admin_toolkit_pct_values_on_pct_cost_id"
    t.index ["pct_month_id"], name: "index_admin_toolkit_pct_values_on_pct_month_id"
  end

  create_table "admin_toolkit_penetration_competitions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "penetration_id", null: false
    t.uuid "competition_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["competition_id"], name: "index_admin_toolkit_penetration_competitions_on_competition_id"
    t.index ["penetration_id", "competition_id"], name: "by_penetration_competition", unique: true
    t.index ["penetration_id"], name: "index_admin_toolkit_penetration_competitions_on_penetration_id"
  end

  create_table "admin_toolkit_penetrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "zip", null: false
    t.string "city", null: false
    t.float "rate", null: false
    t.uuid "kam_region_id", null: false
    t.boolean "hfc_footprint", null: false
    t.string "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["kam_region_id"], name: "index_admin_toolkit_penetrations_on_kam_region_id"
    t.index ["zip"], name: "index_admin_toolkit_penetrations_on_zip"
  end

  create_table "admin_toolkit_project_costs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "standard", precision: 15, scale: 2
    t.decimal "arpu", precision: 15, scale: 2
    t.decimal "socket_installation_rate", precision: 15, scale: 2
    t.integer "index", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "resource", null: false
    t.jsonb "actions", default: {}, null: false
    t.string "accessor_type"
    t.uuid "accessor_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["accessor_type", "accessor_id"], name: "index_permissions_on_accessor"
    t.index ["actions"], name: "index_permissions_on_actions"
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "salutation", null: false
    t.string "firstname", default: "", null: false
    t.string "lastname", default: "", null: false
    t.string "phone", null: false
    t.string "department"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "log_data"
    t.string "avatar_url"
    t.index ["firstname", "lastname"], name: "index_profiles_on_firstname_and_lastname"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "external_id"
    t.string "internal_id"
    t.serial "project_nr"
    t.string "priority"
    t.string "category"
    t.string "status", default: "Open", null: false
    t.string "assignee_type", default: "KAM Project", null: false
    t.string "entry_type", default: "Manual", null: false
    t.uuid "assignee_id"
    t.uuid "kam_region_id"
    t.string "construction_type"
    t.date "construction_starts_on"
    t.date "move_in_starts_on"
    t.date "move_in_ends_on"
    t.string "lot_number"
    t.integer "buildings_count", default: 0, null: false
    t.integer "apartments_count"
    t.text "description"
    t.text "additional_info"
    t.float "coordinate_east"
    t.float "coordinate_north"
    t.string "label_list", default: [], null: false, array: true
    t.jsonb "additional_details", default: {}
    t.boolean "archived", default: false, null: false
    t.integer "address_books_count", default: 0, null: false
    t.integer "files_count", default: 0, null: false
    t.integer "tasks_count", default: 0, null: false
    t.integer "completed_tasks_count", default: 0, null: false
    t.boolean "standard_cost_applicable"
    t.string "access_technology"
    t.boolean "in_house_installation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "competition_id"
    t.text "analysis"
    t.boolean "customer_request"
    t.jsonb "verdicts", default: {}, null: false
    t.index ["additional_details"], name: "index_projects_on_additional_details"
    t.index ["assignee_id"], name: "index_projects_on_assignee_id"
    t.index ["competition_id"], name: "index_projects_on_competition_id"
    t.index ["external_id"], name: "index_projects_on_external_id"
    t.index ["kam_region_id"], name: "index_projects_on_kam_region_id"
    t.index ["status"], name: "index_projects_on_status", where: "((status)::text <> 'Archived'::text)"
  end

  create_table "projects_access_tech_costs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "hfc_on_premise_cost", precision: 15, scale: 2
    t.decimal "hfc_off_premise_cost", precision: 15, scale: 2
    t.decimal "lwl_on_premise_cost", precision: 15, scale: 2
    t.decimal "lwl_off_premise_cost", precision: 15, scale: 2
    t.text "comment"
    t.text "explanation"
    t.uuid "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_projects_access_tech_costs_on_project_id"
  end

  create_table "projects_address_books", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_id"
    t.string "type", null: false
    t.string "display_name", null: false
    t.string "entry_type", null: false
    t.boolean "main_contact", default: false, null: false
    t.string "name", null: false
    t.string "additional_name"
    t.string "company"
    t.string "po_box"
    t.string "language"
    t.string "phone"
    t.string "mobile"
    t.string "email"
    t.string "website"
    t.string "province"
    t.string "contact"
    t.uuid "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_id"], name: "index_projects_address_books_on_external_id"
    t.index ["project_id"], name: "index_projects_address_books_on_project_id"
  end

  create_table "projects_buildings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "external_id"
    t.uuid "assignee_id"
    t.uuid "project_id", null: false
    t.integer "apartments_count", default: 0, null: false
    t.date "move_in_starts_on"
    t.date "move_in_ends_on"
    t.jsonb "additional_details", default: {}
    t.integer "files_count", default: 0, null: false
    t.integer "tasks_count", default: 0, null: false
    t.integer "completed_tasks_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["additional_details"], name: "index_projects_buildings_on_additional_details"
    t.index ["assignee_id"], name: "index_projects_buildings_on_assignee_id"
    t.index ["external_id"], name: "index_projects_buildings_on_external_id"
    t.index ["project_id"], name: "index_projects_buildings_on_project_id"
  end

  create_table "projects_installation_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "project_id", null: false
    t.integer "sockets"
    t.string "builder"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_projects_installation_details_on_project_id"
  end

  create_table "projects_label_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "label_list", default: [], null: false, array: true
    t.uuid "project_id", null: false
    t.uuid "label_group_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["label_group_id"], name: "index_projects_label_groups_on_label_group_id"
    t.index ["label_list"], name: "index_projects_label_groups_on_label_list"
    t.index ["project_id"], name: "index_projects_label_groups_on_project_id"
  end

  create_table "projects_pct_costs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "project_cost", precision: 15, scale: 2
    t.decimal "socket_installation_cost", precision: 15, scale: 2, default: "0.0"
    t.decimal "arpu", precision: 15, scale: 2
    t.decimal "lease_cost", precision: 15, scale: 2
    t.float "penetration_rate"
    t.integer "payback_period", default: 0, null: false
    t.uuid "project_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["project_id"], name: "index_projects_pct_costs_on_project_id"
  end

  create_table "projects_tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "taskable_type", null: false
    t.uuid "taskable_id", null: false
    t.string "title", null: false
    t.string "status", default: "To-Do", null: false
    t.string "previous_status"
    t.text "description", null: false
    t.date "due_date", null: false
    t.uuid "assignee_id", null: false
    t.uuid "owner_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["assignee_id"], name: "index_projects_tasks_on_assignee_id"
    t.index ["owner_id"], name: "index_projects_tasks_on_owner_id"
    t.index ["taskable_type", "taskable_id"], name: "index_projects_tasks_on_taskable"
    t.index ["updated_at"], name: "index_projects_tasks_on_updated_at", order: :desc
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "users_count", default: 0, null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "telco_uam_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discarded_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.uuid "invited_by_id"
    t.integer "invitations_count", default: 0
    t.uuid "role_id", null: false
    t.boolean "active", default: true, null: false
    t.jsonb "log_data"
    t.string "provider"
    t.string "uid"
    t.string "jti", null: false
    t.index ["discarded_at"], name: "index_telco_uam_users_on_discarded_at"
    t.index ["email"], name: "index_telco_uam_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_telco_uam_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_telco_uam_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_telco_uam_users_on_invited_by"
    t.index ["jti"], name: "index_telco_uam_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_telco_uam_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_telco_uam_users_on_role_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_attachments", "telco_uam_users", column: "owner_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "telco_uam_users", column: "owner_id"
  add_foreign_key "activities", "telco_uam_users", column: "recipient_id"
  add_foreign_key "admin_toolkit_footprint_values", "admin_toolkit_footprint_buildings", column: "footprint_building_id"
  add_foreign_key "admin_toolkit_footprint_values", "admin_toolkit_footprint_types", column: "footprint_type_id"
  add_foreign_key "admin_toolkit_kam_investors", "telco_uam_users", column: "kam_id"
  add_foreign_key "admin_toolkit_kam_regions", "telco_uam_users", column: "kam_id"
  add_foreign_key "admin_toolkit_pct_values", "admin_toolkit_pct_costs", column: "pct_cost_id"
  add_foreign_key "admin_toolkit_pct_values", "admin_toolkit_pct_months", column: "pct_month_id"
  add_foreign_key "admin_toolkit_penetration_competitions", "admin_toolkit_competitions", column: "competition_id"
  add_foreign_key "admin_toolkit_penetration_competitions", "admin_toolkit_penetrations", column: "penetration_id"
  add_foreign_key "admin_toolkit_penetrations", "admin_toolkit_kam_regions", column: "kam_region_id"
  add_foreign_key "profiles", "telco_uam_users", column: "user_id"
  add_foreign_key "projects", "admin_toolkit_competitions", column: "competition_id"
  add_foreign_key "projects", "admin_toolkit_kam_regions", column: "kam_region_id"
  add_foreign_key "projects", "telco_uam_users", column: "assignee_id"
  add_foreign_key "projects_access_tech_costs", "projects"
  add_foreign_key "projects_address_books", "projects"
  add_foreign_key "projects_buildings", "projects"
  add_foreign_key "projects_buildings", "telco_uam_users", column: "assignee_id"
  add_foreign_key "projects_installation_details", "projects"
  add_foreign_key "projects_label_groups", "admin_toolkit_label_groups", column: "label_group_id"
  add_foreign_key "projects_label_groups", "projects"
  add_foreign_key "projects_pct_costs", "projects"
  add_foreign_key "projects_tasks", "telco_uam_users", column: "assignee_id"
  add_foreign_key "projects_tasks", "telco_uam_users", column: "owner_id"

  create_view "users_lists", sql_definition: <<-SQL
      SELECT telco_uam_users.id,
      telco_uam_users.active,
      telco_uam_users.email,
      concat(profiles.firstname, ' ', profiles.lastname) AS name,
      profiles.phone,
      profiles.department,
      roles.id AS role_id,
      roles.name AS role,
      profiles.avatar_url
     FROM ((telco_uam_users
       JOIN profiles ON ((profiles.user_id = telco_uam_users.id)))
       JOIN roles ON ((roles.id = telco_uam_users.role_id)))
    WHERE (telco_uam_users.discarded_at IS NULL)
    ORDER BY (concat(profiles.firstname, ' ', profiles.lastname));
  SQL
  create_view "projects_lists", sql_definition: <<-SQL
      SELECT projects.id,
      projects.external_id,
      projects.project_nr,
      projects.category,
      projects.name,
      projects.priority,
      projects.construction_type,
      projects.apartments_count,
      projects.move_in_starts_on,
      projects.move_in_ends_on,
      projects.buildings_count,
      projects.lot_number,
      cardinality(projects.label_list) AS labels,
      concat(addresses.street, ' ', addresses.street_no, ', ', addresses.zip, ', ', addresses.city) AS address,
      concat(profiles.firstname, ' ', profiles.lastname) AS assignee,
      projects.assignee_id,
      projects_address_books.display_name AS investor,
      admin_toolkit_kam_regions.name AS kam_region
     FROM (((((projects
       LEFT JOIN telco_uam_users ON ((telco_uam_users.id = projects.assignee_id)))
       LEFT JOIN profiles ON ((profiles.user_id = telco_uam_users.id)))
       LEFT JOIN addresses ON (((addresses.addressable_id = projects.id) AND ((addresses.addressable_type)::text = 'Project'::text))))
       LEFT JOIN projects_address_books ON (((projects_address_books.project_id = projects.id) AND ((projects_address_books.type)::text = 'Investor'::text))))
       LEFT JOIN admin_toolkit_kam_regions ON ((admin_toolkit_kam_regions.id = projects.kam_region_id)))
    ORDER BY projects.move_in_starts_on;
  SQL
  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute(<<-SQL)
CREATE OR REPLACE FUNCTION public.logidze_logger()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
  -- version: 1
  DECLARE
    changes jsonb;
    version jsonb;
    snapshot jsonb;
    new_v integer;
    size integer;
    history_limit integer;
    debounce_time integer;
    current_version integer;
    merged jsonb;
    iterator integer;
    item record;
    columns text[];
    include_columns boolean;
    ts timestamp with time zone;
    ts_column text;
  BEGIN
    ts_column := NULLIF(TG_ARGV[1], 'null');
    columns := NULLIF(TG_ARGV[2], 'null');
    include_columns := NULLIF(TG_ARGV[3], 'null');

    IF TG_OP = 'INSERT' THEN
      -- always exclude log_data column
      changes := to_jsonb(NEW.*) - 'log_data';

      IF columns IS NOT NULL THEN
        snapshot = logidze_snapshot(changes, ts_column, columns, include_columns);
      ELSE
        snapshot = logidze_snapshot(changes, ts_column);
      END IF;

      IF snapshot#>>'{h, -1, c}' != '{}' THEN
        NEW.log_data := snapshot;
      END IF;

    ELSIF TG_OP = 'UPDATE' THEN

      IF OLD.log_data is NULL OR OLD.log_data = '{}'::jsonb THEN
        -- always exclude log_data column
        changes := to_jsonb(NEW.*) - 'log_data';

        IF columns IS NOT NULL THEN
          snapshot = logidze_snapshot(changes, ts_column, columns, include_columns);
        ELSE
          snapshot = logidze_snapshot(changes, ts_column);
        END IF;

        IF snapshot#>>'{h, -1, c}' != '{}' THEN
          NEW.log_data := snapshot;
        END IF;
        RETURN NEW;
      END IF;

      history_limit := NULLIF(TG_ARGV[0], 'null');
      debounce_time := NULLIF(TG_ARGV[4], 'null');

      current_version := (NEW.log_data->>'v')::int;

      IF ts_column IS NULL THEN
        ts := statement_timestamp();
      ELSE
        ts := (to_jsonb(NEW.*)->>ts_column)::timestamp with time zone;
        IF ts IS NULL OR ts = (to_jsonb(OLD.*)->>ts_column)::timestamp with time zone THEN
          ts := statement_timestamp();
        END IF;
      END IF;

      IF NEW = OLD THEN
        RETURN NEW;
      END IF;

      IF current_version < (NEW.log_data#>>'{h,-1,v}')::int THEN
        iterator := 0;
        FOR item in SELECT * FROM jsonb_array_elements(NEW.log_data->'h')
        LOOP
          IF (item.value->>'v')::int > current_version THEN
            NEW.log_data := jsonb_set(
              NEW.log_data,
              '{h}',
              (NEW.log_data->'h') - iterator
            );
          END IF;
          iterator := iterator + 1;
        END LOOP;
      END IF;

      changes := '{}';

      IF (coalesce(current_setting('logidze.full_snapshot', true), '') = 'on') THEN
        changes = hstore_to_jsonb_loose(hstore(NEW.*));
      ELSE
        changes = hstore_to_jsonb_loose(
          hstore(NEW.*) - hstore(OLD.*)
        );
      END IF;

      changes = changes - 'log_data';

      IF columns IS NOT NULL THEN
        changes = logidze_filter_keys(changes, columns, include_columns);
      END IF;

      IF changes = '{}' THEN
        RETURN NEW;
      END IF;

      new_v := (NEW.log_data#>>'{h,-1,v}')::int + 1;

      size := jsonb_array_length(NEW.log_data->'h');
      version := logidze_version(new_v, changes, ts);

      IF (
        debounce_time IS NOT NULL AND
        (version->>'ts')::bigint - (NEW.log_data#>'{h,-1,ts}')::text::bigint <= debounce_time
      ) THEN
        -- merge new version with the previous one
        new_v := (NEW.log_data#>>'{h,-1,v}')::int;
        version := logidze_version(new_v, (NEW.log_data#>'{h,-1,c}')::jsonb || changes, ts);
        -- remove the previous version from log
        NEW.log_data := jsonb_set(
          NEW.log_data,
          '{h}',
          (NEW.log_data->'h') - (size - 1)
        );
      END IF;

      NEW.log_data := jsonb_set(
        NEW.log_data,
        ARRAY['h', size::text],
        version,
        true
      );

      NEW.log_data := jsonb_set(
        NEW.log_data,
        '{v}',
        to_jsonb(new_v)
      );

      IF history_limit IS NOT NULL AND history_limit <= size THEN
        NEW.log_data := logidze_compact_history(NEW.log_data, size - history_limit + 1);
      END IF;
    END IF;

    return NEW;
  END;
$function$
  SQL

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute("CREATE TRIGGER logidze_on_addresses BEFORE INSERT OR UPDATE ON \"addresses\" FOR EACH ROW WHEN (COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text) EXECUTE FUNCTION logidze_logger('null', 'updated_at')")

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute("CREATE TRIGGER logidze_on_profiles BEFORE INSERT OR UPDATE ON \"profiles\" FOR EACH ROW WHEN (COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text) EXECUTE FUNCTION logidze_logger('null', 'updated_at', '{salutation,firstname,lastname,phone,department}', 'true')")

  # no candidate create_trigger statement could be found, creating an adapter-specific one
  execute("CREATE TRIGGER logidze_on_telco_uam_users BEFORE INSERT OR UPDATE ON \"telco_uam_users\" FOR EACH ROW WHEN (COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text) EXECUTE FUNCTION logidze_logger('null', 'updated_at', '{active,email,invitation_created_at,invited_by_id,discarded_at,role_id}', 'true')")

end
