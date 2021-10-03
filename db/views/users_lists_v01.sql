SELECT telco_uam_users.id                                   AS id,
       telco_uam_users.active                               AS active,
       telco_uam_users.email                                AS email,
       CONCAT(profiles.firstname, ' ', profiles.lastname)   AS name,
       profiles.phone                                       AS phone,
       roles.name                                           AS role

FROM telco_uam_users
    JOIN profiles ON profiles.user_id = telco_uam_users.id
    JOIN roles ON roles.id = telco_uam_users.role_id

WHERE telco_uam_users.discarded_at IS NULL

ORDER BY name ASC