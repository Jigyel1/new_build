SELECT telco_uam_users.id  AS id,
       profiles.firstname  AS firstname,
       profiles.lastname   AS lastname,
       profiles.salutation AS salutation,
       profiles.department AS department,
       profiles.phone      AS phone
FROM telco_uam_users
         JOIN profiles ON profiles.user_id = telco_uam_users.id