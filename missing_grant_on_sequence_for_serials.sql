-- This query lists all the users that have the INSERT grant on a table but don't have grant on the sequence that's 
-- the default of a serial value in this table.

select grantee
,rtg.table_schema
,rtg.table_name
,(
 select distinct ug.object_schema||'.'||ug.object_name 
 from	information_schema.role_usage_grants ug
 where 'nextval('''||ug.object_schema||'.'||ug.object_name||'''::regclass)' = c.column_default
) as "sequence"

from information_schema.role_table_grants rtg
inner join information_schema.columns c on rtg.table_schema=c.table_schema and rtg.table_name=c.table_name
where privilege_type='INSERT'
and column_default like 'nextval%'

and grantee not in (
 select grantee
 from	information_schema.role_usage_grants ug
 where 'nextval('''||ug.object_schema||'.'||ug.object_name||'''::regclass)' = c.column_default
)
and grantee not in (SELECT u.usename FROM pg_user u WHERE u.usesuper)
limit 100