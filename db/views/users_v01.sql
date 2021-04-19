-- SELECT
--     statuses.id AS searchable_id,
--     'Status' AS searchable_type,
--     comments.body AS term
-- FROM statuses
--          JOIN comments ON statuses.id = comments.status_id
--
-- UNION
--
-- SELECT
--     statuses.id AS searchable_id,
--     'Status' AS searchable_type,
--     statuses.body AS term
-- FROM statuses

SELECT
    telco_uam_users.id AS id,
    profiles.firstname AS profiles.firstname,
    profiles.lastname AS lastname,
    profiles.salutation AS salutation,
    profiles.department AS department,
    profiles.phone AS phone
FROM telco_uam_users
    JOIN profiles ON profiles.user_id = telco_uam_users.id