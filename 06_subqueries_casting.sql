
-- 1. Find shipments whose freight cost is above the overall average.
select shipment_id, freight_cost
from supply_chain.shipments
where freight_cost > (select avg(freight_cost) from supply_chain.shipments);

-- 2. Find shipments whose current delay is above the overall average.
select shipment_id, current_delay
from supply_chain.shipment_risk
where current_delay > (select avg(current_delay) from supply_chain.shipment_risk);

-- 3. Find suppliers whose reliability is below the overall average.
select s.supplier_id, avg(r.supplier_reliability) as average_reliability
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
group by s.supplier_id
having avg(r.supplier_reliability) < (select avg(supplier_reliability) from supply_chain.shipment_risk);

-- 4. Find countries whose average route risk is above the global average.
select s.country, avg(r.route_risk_score) as average_route_risk
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
group by s.country
having avg(r.route_risk_score) > (select avg(route_risk_score) from supply_chain.shipment_risk);

-- 5. Find shipments with the maximum revenue impact.
select shipment_id, revenue_impact
from supply_chain.shipments
where revenue_impact = (select max(revenue_impact) from supply_chain.shipments);

-- 6. Find the second-highest freight cost.
select max(freight_cost) as second_highest_freight_cost
from supply_chain.shipments
where freight_cost < (select max(freight_cost) from supply_chain.shipments);

-- 7. Find shipments whose revenue impact is higher than their country's average.
select shipment_id, country, revenue_impact
from supply_chain.shipments s
where revenue_impact > (
    select avg(s2.revenue_impact)
    from supply_chain.shipments s2
    where s2.country = s.country
);

-- 8. Find shipments whose freight cost is higher than their product's average.
select s.shipment_id, s.product_id, s.freight_cost
from supply_chain.shipments s
where s.freight_cost > (
    select avg(s2.freight_cost)
    from supply_chain.shipments s2
    where s2.product_id = s.product_id
);

-- 9. Find the highest-risk shipment for each country.
select s.shipment_id, s.country, r.route_risk_score
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
where r.route_risk_score = (
    select max(r2.route_risk_score)
    from supply_chain.shipments s2
    join supply_chain.shipment_risk r2 on s2.shipment_id = r2.shipment_id
    where s2.country = s.country
);

-- 10. Find suppliers whose average delay is greater than the overall average delay.
select s.supplier_id, avg(r.current_delay) as average_delay
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
group by s.supplier_id
having avg(r.current_delay) > (select avg(current_delay) from supply_chain.shipment_risk);

-- 11. Demonstrate CAST(value AS datatype).
select shipment_id, cast(freight_cost as numeric(12,2)) as freight_cost_decimal
from supply_chain.shipments;

-- 12. Demonstrate value::datatype.
select shipment_id, freight_cost::numeric(12,2) as freight_cost_decimal
from supply_chain.shipments;

-- 13. Calculate disruption percentage using casting.
select round(
    (count(*) filter (where disruption_event = 1)::numeric / count(*)::numeric) * 100,
    2
) as disruption_percentage
from supply_chain.shipments;

-- 14. Convert calculated average delay into an integer.
select avg(current_delay)::integer as average_delay_integer
from supply_chain.shipment_risk;

-- 15. Format risk-related calculations using decimal precision.
select shipment_id, route_risk_score, delay_probability, 
(route_risk_score * delay_probability)::numeric(10,2) as risk_score
from supply_chain.shipment_risk;