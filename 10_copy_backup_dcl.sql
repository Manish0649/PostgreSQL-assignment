-- 1. Export all critical shipments
copy (select * from supply_chain.vw_critical_shipments) to 'C:\Users\Public\critical_shipments.csv' with (format csv, header true);

-- 2. Export supplier-level summary
copy (select * from supply_chain.vw_supplier_performance) to 'C:\Users\Public\supplier_summary.csv' with (format csv, header true);


-- task 10: B. import using COPY (run in pgAdmin Query Tool)

-- 3. Create staging table for critical shipments
drop table if exists supply_chain.critical_shipments_staging;
create table supply_chain.critical_shipments_staging as select * from supply_chain.vw_critical_shipments with no data;

-- 4. Import critical shipments CSV
copy supply_chain.critical_shipments_staging from 'C:\Users\Public\critical_shipments.csv' with (format csv, header true);

-- 5. Verify row count
select count(*) as staging_row_count from supply_chain.critical_shipments_staging;
select count(*) as original_row_count from supply_chain.vw_critical_shipments;

-- 6. Verify column count
select count(*) as column_count from information_schema.columns where table_schema = 'supply_chain' and table_name = 'critical_shipments_staging';

-- 7. Verify data consistency
select * from supply_chain.critical_shipments_staging except select * from supply_chain.vw_critical_shipments;
select * from supply_chain.vw_critical_shipments except select * from supply_chain.critical_shipments_staging;


-- task 10: C. database backup (run in Windows PowerShell or Command Prompt)

-- 8. Check pg_dump installation
pg_dump --version

-- 9. Create full database backup
pg_dump -U postgres -d SupplyChainRiskDB -F c -f "C:\Users\Public\SupplyChainRiskDB_full.backup"

-- 10. Create schema-only backup
pg_dump -U postgres -d SupplyChainRiskDB --schema-only -f "C:\Users\Public\SupplyChainRiskDB_schema.sql"

-- 11. Create data-only backup
pg_dump -U postgres -d SupplyChainRiskDB --data-only -f "C:\Users\Public\SupplyChainRiskDB_data.sql"


-- task 10: D. restore backup (run in Windows PowerShell or Command Prompt)

-- 12. Create restore database
psql -U postgres -c "create database ""SupplyChainRiskDB_Restore"";"

-- 13. Restore full database backup
pg_restore -U postgres -d SupplyChainRiskDB_Restore "C:\Users\Public\SupplyChainRiskDB_full.backup"


-- task 10: D. verify restored database (run in pgAdmin Query Tool connected to SupplyChainRiskDB_Restore)

-- 14. Verify restored tables
select table_schema, table_name from information_schema.tables where table_schema = 'supply_chain' and table_type = 'BASE TABLE' order by table_name;

-- 15. Verify restored shipment data
select count(*) as shipment_count from supply_chain.shipments;

-- 16. Verify restored constraints
select table_name, constraint_name, constraint_type from information_schema.table_constraints where table_schema = 'supply_chain' order by table_name, constraint_name;

-- 17. Verify restored views
select table_name from information_schema.views where table_schema = 'supply_chain' order by table_name;

-- 18. Verify restored functions and procedures
select routine_name, routine_type from information_schema.routines where routine_schema = 'supply_chain' order by routine_name;

-- 19. Verify restored indexes
select indexname, indexdef from pg_indexes where schemaname = 'supply_chain' order by indexname;

-- 20. Verify restored triggers
select trigger_name, event_object_table, event_manipulation from information_schema.triggers where trigger_schema = 'supply_chain' order by event_object_table, trigger_name;


-- task 10: E. DCL & role management (run in pgAdmin Query Tool as PostgreSQL administrator)

-- 21. Create database roles
create role supply_chain_admin;
create role supply_chain_analyst;
create role supply_chain_viewer;

-- 22. Grant full schema access to admin
grant all privileges on schema supply_chain to supply_chain_admin;

-- 23. Grant full table access to admin
grant all privileges on all tables in schema supply_chain to supply_chain_admin;

-- 24. Grant sequence access to admin
grant all privileges on all sequences in schema supply_chain to supply_chain_admin;

-- 25. Grant function execution to admin
grant execute on all functions in schema supply_chain to supply_chain_admin;

-- 26. Grant procedure execution to admin
grant execute on all procedures in schema supply_chain to supply_chain_admin;

-- 27. Grant analyst select, insert and update privileges
grant select, insert, update on all tables in schema supply_chain to supply_chain_analyst;

-- 28. Grant sequence access to analyst
grant usage, select on all sequences in schema supply_chain to supply_chain_analyst;

-- 29. Grant viewer select privileges
grant select on all tables in schema supply_chain to supply_chain_viewer;

-- 30. Revoke update privilege from analyst
revoke update on all tables in schema supply_chain from supply_chain_analyst;

-- 31. Grant update privilege back to analyst
grant update on all tables in schema supply_chain to supply_chain_analyst;

-- 32. Verify role permissions
select grantee, table_schema, table_name, privilege_type from information_schema.role_table_grants where table_schema = 'supply_chain' and grantee in ('supply_chain_admin','supply_chain_analyst','supply_chain_viewer') order by grantee, table_name, privilege_type;