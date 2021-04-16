# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_210_416_052_020) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pgcrypto'
  enable_extension 'plpgsql'

  create_table 'addresses', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'street', default: ''
    t.string 'street_no', default: ''
    t.string 'city', default: ''
    t.string 'zip', default: ''
    t.string 'addressable_type'
    t.uuid 'addressable_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[addressable_type addressable_id], name: 'index_addresses_on_addressable'
  end

  create_table 'profiles', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.uuid 'user_id', null: false
    t.string 'salutation', null: false
    t.string 'firstname', default: '', null: false
    t.string 'lastname', default: '', null: false
    t.string 'phone', null: false
    t.string 'department'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index %w[firstname lastname], name: 'index_profiles_on_firstname_and_lastname'
    t.index ['user_id'], name: 'index_profiles_on_user_id'
  end

  create_table 'roles', force: :cascade do |t|
    t.string 'name', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['name'], name: 'index_roles_on_name'
  end

  create_table 'telco_uam_users', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.string 'invitation_token'
    t.datetime 'invitation_created_at'
    t.datetime 'invitation_sent_at'
    t.datetime 'invitation_accepted_at'
    t.integer 'invitation_limit'
    t.string 'invited_by_type'
    t.bigint 'invited_by_id'
    t.integer 'invitations_count', default: 0
    t.string 'jti', null: false
    t.boolean 'active', default: true
    t.bigint 'role_id', null: false
    t.datetime 'discarded_at'
    t.index ['discarded_at'], name: 'index_telco_uam_users_on_discarded_at'
    t.index ['email'], name: 'index_telco_uam_users_on_email', unique: true
    t.index ['invitation_token'], name: 'index_telco_uam_users_on_invitation_token', unique: true
    t.index ['invited_by_id'], name: 'index_telco_uam_users_on_invited_by_id'
    t.index %w[invited_by_type invited_by_id], name: 'index_telco_uam_users_on_invited_by'
    t.index ['jti'], name: 'index_telco_uam_users_on_jti', unique: true
    t.index ['reset_password_token'], name: 'index_telco_uam_users_on_reset_password_token', unique: true
    t.index ['role_id'], name: 'index_telco_uam_users_on_role_id'
  end

  add_foreign_key 'profiles', 'telco_uam_users', column: 'user_id'
  add_foreign_key 'telco_uam_users', 'roles'
end
