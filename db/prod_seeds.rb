# frozen_string_literal: true

# To run the seed file for PROD run
#   :=> `rails db:setup_prod`

require_relative '../permissions/bulk_updater'

warning = <<~WARNING
  If you need to set default permissions with respect to the roles, send `RESET_PERMISSIONS=true`
  when calling `rails db:setup_prod`, `rails db:setup_dev` or `rails db:reset_dev`.

  Don't send that flag as true in a production setup if the permissions are already set! as
  it will reset the already created permissions. \n
WARNING

$stdout.write(warning)

Role.names.each_key do |name|
  role = Role.find_or_create_by!(name: name)
  next unless ENV.fetch('RESET_PERMISSIONS', '').to_b

  Permissions::BulkUpdater.new(role: role).call
rescue NoMethodError
  puts "No policy configuration for #{role.name}"
end

def create_record(attributes)
  record = yield if block_given?
  return if record.persisted?

  record.assign_attributes(attributes)
  record.save!
end

{
  super_user: 'The Superuser can perform all possible features of the tool.',
  management: 'The Management can view projects and get an overview of the projects in the pipeline. Additionally' \
              ' users with that role will make decisions if they are required.',
  administrator: 'The Administrator can edit roles, make changes to users and invite new users to the tool.' \
                 ' He also can change parameters in the admin toolkit. The Admin cannot handle any project.',
  manager_commercialization: 'Users with that role will take up certain Marketing-activities that cannot be performed' \
                             ' by the NBO / KAM users.',
  kam: 'Users with that role handle projects that are marked as Key Accounts.',
  manager_nbo_kam: 'Users with that role get an overview on the tasks of NBO & KAM users.' \
                   ' They will also make certain decisions if required.',
  manager_presales: 'Users with that role will get an overview of the tasks of all Presales engineers.',
  presales: 'Users with that role will analyze Complex projects.',
  team_expert: 'Users with this role can analyze Standard projects, issue contracts and handle all administrative' \
               ' tasks of Newbuild Projects. (analysis – Offer – Verification – Commercialisation)',
  team_standard: 'Users with this role can issue contracts after the projects are analyzed und can handle the' \
                 ' administrative tasks of Newbuild Projects. (Offer – Verification – Commercialization)'
}.each_pair do |role, description|
  role = Role.find_by!(name: role)
  role.update(description: description)
end

# Default cost threshold, i.e, to be used moving in project state from TAC
AdminToolkit::CostThreshold.destroy_all && AdminToolkit::CostThreshold.create!(exceeding: 5000)

%w[pcts footprints label_groups competitions kam_regions offer_prices project_costs].each do |file|
  puts "Loading #{file.camelize}"
  load(Rails.root.join("db/seeds/#{file}.rb"))
end
