--This query will select all groups and for each group, it will create an array with all its members
--This query also create a member array for CREATEDB, REPLICATION and SUPERUSER
SELECT groups.rolname AS group_name,
    ARRAY( SELECT membre.rolname
           FROM pg_auth_members membres
             JOIN pg_roles group_subquery ON group_subquery.oid = membres.roleid
             JOIN pg_roles membre ON membre.oid = membres.member
          WHERE group_subquery.oid = groups.oid) AS member_list
   FROM pg_roles groups
  WHERE (EXISTS ( SELECT 1
           FROM pg_auth_members m
          WHERE m.roleid = groups.oid))
UNION
SELECT 'SUPERUSER'::name AS nom_groupe,
    ARRAY( SELECT u.usename AS "User name"
           FROM pg_user u
          WHERE u.usesuper) AS liste_membres
UNION
SELECT 'CREATEDB'::name AS nom_groupe,
    ARRAY( SELECT u.usename AS "User name"
           FROM pg_user u
          WHERE u.usecreatedb) AS liste_membres
UNION
SELECT 'REPLICATION'::name AS nom_groupe,
    ARRAY( SELECT u.usename AS "User name"
           FROM pg_user u
          WHERE u.userepl) AS liste_membres
  ORDER BY 1;

 