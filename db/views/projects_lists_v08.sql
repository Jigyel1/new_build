SELECT projects.id                                              AS id,
       projects.external_id                                     AS external_id,
       projects.project_nr                                      AS project_nr,
       projects.status                                          AS status,
       projects.category                                        AS category,
       projects.name                                            AS name,
       coalesce(projects.priority_tac, projects.priority)         AS priority,
       projects.construction_type                               AS construction_type,
       projects.apartments_count                                AS apartments_count,
       projects.move_in_starts_on                               AS move_in_starts_on,
       projects.move_in_ends_on                                 AS move_in_ends_on,
       projects.buildings_count                                 AS buildings_count,
       projects.lot_number                                      AS lot_number,
       projects.internal_id                                     AS internal_id,
       projects.draft_version                                   AS draft_version,
       projects.assignee_type                                   AS assignee_type,
       projects.customer_request                                AS customer_request,
       addresses.city                                           AS city,
       addresses.zip                                            AS zip,
       projects.label_list                                      AS label_list,
       projects.confirmation_status                             AS confirmation_status,

       CONCAT(
         addresses.street, ' ',
         addresses.street_no, ', ',
         addresses.zip, ', ',
         addresses.city
       )                                                        AS address,

       coalesce(
         NULLIF(CONCAT(profiles.firstname, ' ', profiles.lastname), ' '),
         projects.assignee_type
       )                                                        AS assignee,

       CONCAT(kam_profile.firstname, ' ', kam_profile.lastname) AS kam_assignee,

       projects.assignee_id                                     AS assignee_id,
       projects.kam_assignee_id                                 AS kam_assignee_id,
       projects_address_books.name                              AS investor,
       admin_toolkit_kam_regions.name                           AS kam_region

FROM projects
    LEFT JOIN telco_uam_users ON telco_uam_users.id = projects.assignee_id
    LEFT JOIN profiles ON profiles.user_id = telco_uam_users.id
    LEFT JOIN profiles as kam_profile ON kam_profile.user_id = projects.kam_assignee_id
    LEFT JOIN addresses ON addresses.addressable_id = projects.id AND addresses.addressable_type = 'Project'
    LEFT JOIN projects_address_books ON projects_address_books.project_id = projects.id AND projects_address_books.type = 'Investor'
    LEFT JOIN admin_toolkit_kam_regions ON admin_toolkit_kam_regions.id = projects.kam_region_id

WHERE projects.discarded_at IS NULL

ORDER BY projects.move_in_starts_on ASC NULLS LAST
