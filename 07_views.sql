-- view 1: create supplier performance view

create or replace view supply_chain.vw_supplier_performance as
select
    s.supplier_id as supplier,
    s.country,
    count(s.shipment_id) as shipment_count,
    sum(s.shipment_volume) as total_shipment_volume,
    round(avg(r.current_delay),2) as average_delay,
    round(avg(r.supplier_reliability),2) as average_reliability,
    sum(s.freight_cost) as total_freight_cost,
    sum(s.revenue_impact) as total_revenue_impact
from supply_chain.shipments s
join supply_chain.shipment_risk r
on s.shipment_id = r.shipment_id
group by s.supplier_id, s.country;

-- display supplier performance
select *
from supply_chain.vw_supplier_performance;


-- -- view 2: create shipment risk view

create or replace view supply_chain.vw_shipment_risk as
select
    s.shipment_id,
    s.supplier_id as supplier,
    s.country,
    p.product_type as product,
    r.route_risk_score as route_risk,
    r.political_risk,
    r.port_congestion,
    r.delay_probability,
    r.current_delay,
    i.inventory_days
from supply_chain.shipments s
join supply_chain.products p
on s.product_id = p.product_id
join supply_chain.shipment_risk r
on s.shipment_id = r.shipment_id
join supply_chain.inventory i
on s.shipment_id = i.shipment_id;

-- display shipment risk

select *
from supply_chain.vw_shipment_risk;

-- view 3: create critical shipments view

create or replace view supply_chain.vw_critical_shipments as
select *
from supply_chain.vw_shipment_risk
where route_risk >= 7
and delay_probability >= 0.7
and current_delay >= 10
and inventory_days < 15;

-- display critical shipments

select *
from supply_chain.vw_critical_shipments;


-- 1. Which suppliers have the highest total shipment volume?

select supplier,country total_shipment_volume
from supply_chain.vw_supplier_performance
order by total_shipment_volume desc
limit 5;


-- 2. Which suppliers have below-average reliability?

select supplier, average_reliability,country
from supply_chain.vw_supplier_performance
where average_reliability < (
    select avg(average_reliability)
    from supply_chain.vw_supplier_performance
)
order by average_reliability;


-- 3. Which shipments have high route risk and high delay probability?

select shipment_id, supplier, country, product, route_risk, delay_probability
from supply_chain.vw_shipment_risk
where route_risk >= 7
and delay_probability >= 0.7
order by route_risk desc, delay_probability desc;


-- 4. Which shipments have low inventory coverage and significant current delay?

select shipment_id, supplier, country, product, current_delay, inventory_days
from supply_chain.vw_shipment_risk
where current_delay >= 10
and inventory_days < 15
order by current_delay desc, inventory_days;


-- 5. Which shipments are classified as critical?

select shipment_id, supplier, country, product,
       route_risk, delay_probability, current_delay, inventory_days
from supply_chain.vw_critical_shipments
order by route_risk desc, delay_probability desc;


-- 6. Which country has the highest average route risk? (without using views)

select s.country, round(avg(r.route_risk_score),2) as average_route_risk
from supply_chain.shipments s
join supply_chain.shipment_risk r
on s.shipment_id = r.shipment_id
group by s.country
order by average_route_risk desc
limit 1;
