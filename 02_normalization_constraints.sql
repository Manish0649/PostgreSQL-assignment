drop table if exists supply_chain.inventory;
drop table if exists supply_chain.shipment_risk;
drop table if exists supply_chain.shipments;
drop table if exists supply_chain.products;
drop table if exists supply_chain.suppliers;

create table supply_chain.suppliers (
    supplier_id varchar(50) primary key
);

create table supply_chain.products (
    product_id serial primary key,
    product_type varchar(100) not null unique
);

create table supply_chain.shipments (
    shipment_id varchar(50) primary key,
    supplier_id varchar(50) not null references supply_chain.suppliers(supplier_id),
    product_id integer not null references supply_chain.products(product_id),
    country varchar(100) not null,
    monthly_demand numeric not null check (monthly_demand >= 0),
    shipment_volume numeric not null check (shipment_volume > 0),
    transit_time numeric not null check (transit_time >= 0),
    freight_cost numeric not null check (freight_cost >= 0),
    revenue_impact numeric not null,
    revenue_impact_invalid integer not null check (revenue_impact_invalid in (0, 1)),
    disruption_event integer not null check (disruption_event in (0, 1))
);

create table supply_chain.shipment_risk (
    shipment_id varchar(50) primary key references supply_chain.shipments(shipment_id),
    route_risk_score numeric not null,
    historical_delay numeric not null check (historical_delay >= 0),
    fuel_price numeric not null check (fuel_price >= 0),
    political_risk numeric not null check (political_risk >= 0),
    port_congestion numeric not null check (port_congestion >= 0),
    supplier_reliability numeric not null check (supplier_reliability between 0 and 1),
    alternative_supplier_count integer not null check (alternative_supplier_count >= 0),
    delay_probability numeric not null check (delay_probability between 0 and 1),
    current_delay numeric not null check (current_delay >= 0)
);

create table supply_chain.inventory (
    shipment_id varchar(50) primary key references supply_chain.shipments(shipment_id),
    inventory_days numeric not null check (inventory_days >= 0)
);

comment on table supply_chain.shipment_raw is
'The raw table violates normalization principles because supplier, product, shipment, risk,
and inventory information are stored together in a single table, causing redundancy and update anomalies.
The normalized design separates these concepts into related tables using primary and foreign keys.';

insert into supply_chain.suppliers (supplier_id)
select distinct supplier_id
from supply_chain.shipment_raw;

insert into supply_chain.products (product_type)
select distinct product_type
from supply_chain.shipment_raw;

insert into supply_chain.shipments (shipment_id, supplier_id, product_id, country, monthly_demand, shipment_volume, transit_time, freight_cost, revenue_impact, revenue_impact_invalid, disruption_event)
select r.shipment_id, r.supplier_id, p.product_id, r.country, r.monthly_demand, r.shipment_volume, r.transit_time, r.freight_cost, r.revenue_impact, case when r.revenue_impact < 0 then 1 else 0 end, r.disruption_event::integer
from supply_chain.shipment_raw r
join supply_chain.products p on r.product_type = p.product_type;

insert into supply_chain.shipment_risk (shipment_id, route_risk_score, historical_delay, fuel_price, political_risk, port_congestion, supplier_reliability, alternative_supplier_count, delay_probability, current_delay)
select shipment_id, route_risk_score, historical_delay, fuel_price, political_risk, port_congestion, supplier_reliability, alternative_supplier_count, delay_probability, current_delay
from supply_chain.shipment_raw;

insert into supply_chain.inventory (shipment_id, inventory_days)
select shipment_id, inventory_days
from supply_chain.shipment_raw;

select count(*) as supplier_count from supply_chain.suppliers;
select count(*) as product_count from supply_chain.products;
select count(*) as shipment_count from supply_chain.shipments;
select count(*) as shipment_risk_count from supply_chain.shipment_risk;
select count(*) as inventory_count from supply_chain.inventory;

select shipment_id, revenue_impact, revenue_impact_invalid
from supply_chain.shipments
where revenue_impact_invalid = 1;