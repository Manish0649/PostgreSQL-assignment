
-- 1. Find shipments for a specific supplier before indexing

explain
select *
from supply_chain.shipments
where supplier_id = 'SUP001';


-- 1. Analyze shipments for a specific supplier before indexing

explain analyze
select *
from supply_chain.shipments
where supplier_id = 'SUP001';


-- 2. Find shipments from a specific country before indexing

explain
select *
from supply_chain.shipments
where country = 'India';


-- 2. Analyze shipments from a specific country before indexing

explain analyze
select *
from supply_chain.shipments
where country = 'India';


-- 3. Find shipments with high delay probability before indexing

explain
select *
from supply_chain.shipment_risk
where delay_probability >= 0.7;


-- 3. Analyze shipments with high delay probability before indexing

explain analyze
select *
from supply_chain.shipment_risk
where delay_probability >= 0.7;


-- 4. Find shipments with significant current delay before indexing

explain
select *
from supply_chain.shipment_risk
where current_delay >= 10;


-- 4. Analyze shipments with significant current delay before indexing

explain analyze
select *
from supply_chain.shipment_risk
where current_delay >= 10;


-- 5. Find highest-risk shipments before indexing

explain
select shipment_id, route_risk_score
from supply_chain.shipment_risk
order by route_risk_score desc
limit 10;


-- 5. Analyze highest-risk shipments before indexing

explain analyze
select shipment_id, route_risk_score
from supply_chain.shipment_risk
order by route_risk_score desc
limit 10;


-- create index on supplier_id

create index if not exists idx_shipments_supplier_id
on supply_chain.shipments(supplier_id);


-- create index on country

create index if not exists idx_shipments_country
on supply_chain.shipments(country);


-- create index on delay_probability

create index if not exists idx_shipment_risk_delay_probability
on supply_chain.shipment_risk(delay_probability);


-- create index on current_delay

create index if not exists idx_shipment_risk_current_delay
on supply_chain.shipment_risk(current_delay);


-- create index on route_risk_score

create index if not exists idx_shipment_risk_route_risk
on supply_chain.shipment_risk(route_risk_score);


-- 1. Check supplier query plan after indexing

explain
select *
from supply_chain.shipments
where supplier_id = 'SUP001';


-- 1. Analyze supplier query after indexing

explain analyze
select *
from supply_chain.shipments
where supplier_id = 'SUP001';


-- 2. Check country query plan after indexing

explain
select *
from supply_chain.shipments
where country = 'India';


-- 2. Analyze country query after indexing

explain analyze
select *
from supply_chain.shipments
where country = 'India';


-- 3. Check delay probability query plan after indexing

explain
select *
from supply_chain.shipment_risk
where delay_probability >= 0.7;


-- 3. Analyze delay probability query after indexing

explain analyze
select *
from supply_chain.shipment_risk
where delay_probability >= 0.7;


-- 4. Check current delay query plan after indexing

explain
select *
from supply_chain.shipment_risk
where current_delay >= 10;


-- 4. Analyze current delay query after indexing

explain analyze
select *
from supply_chain.shipment_risk
where current_delay >= 10;


-- 5. Check route risk sorting plan after indexing

explain
select shipment_id, route_risk_score
from supply_chain.shipment_risk
order by route_risk_score desc
limit 10;


-- 5. Analyze route risk sorting after indexing

explain analyze
select shipment_id, route_risk_score
from supply_chain.shipment_risk
order by route_risk_score desc
limit 10;

--The indexes help PostgreSQL find the required data faster instead of checking every row in
-- the table. However, since our dataset has only 700 rows, the difference in performance
-- is very small. In some cases, PostgreSQL may still use a sequential scan because scanning
-- a small table can be faster than using an index.
