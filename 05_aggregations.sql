
-- 1. Which supplier has the highest shipment volume?
select supplier_id, sum(shipment_volume) as total_shipment_volume
from supply_chain.shipments
group by supplier_id
order by total_shipment_volume desc
limit 1;

-- 2. Which supplier has the highest revenue impact?
select supplier_id, sum(revenue_impact) as total_revenue_impact
from supply_chain.shipments
group by supplier_id
order by total_revenue_impact desc
limit 1;

-- 3. Which supplier has the highest average delay?
select s.supplier_id, avg(r.current_delay) as average_delay
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
group by s.supplier_id
order by average_delay desc
limit 1;

-- 4. Which suppliers have below-average reliability?
select s.supplier_id, avg(r.supplier_reliability) as average_reliability
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
group by s.supplier_id
having avg(r.supplier_reliability) < (select avg(supplier_reliability) from supply_chain.shipment_risk)
order by average_reliability;

-- 5. Which suppliers have more than 5 shipments?
select supplier_id, count(*) as shipment_count
from supply_chain.shipments
group by supplier_id
having count(*) > 5
order by shipment_count desc;

-- 6. Which country has the highest average route risk?
select s.country, avg(r.route_risk_score) as average_route_risk
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
group by s.country
order by average_route_risk desc
limit 1;

-- 7. Which country has the highest political risk?
select s.country, avg(r.political_risk) as average_political_risk
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
group by s.country
order by average_political_risk desc
limit 1;

-- 8. Which country has the highest total revenue impact?
select country, sum(revenue_impact) as total_revenue_impact
from supply_chain.shipments
group by country
order by total_revenue_impact desc
limit 1;

-- 9. What is the average delay by country?
select s.country, avg(r.current_delay) as average_delay
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id
group by s.country
order by average_delay desc;

-- 10. Which product has the highest demand?
select p.product_type as product, sum(s.monthly_demand) as total_demand
from supply_chain.products p
join supply_chain.shipments s on p.product_id = s.product_id
group by p.product_id, p.product_type
order by total_demand desc
limit 1;

-- 11. Which product has the highest freight cost?
select p.product_type as product, sum(s.freight_cost) as total_freight_cost
from supply_chain.products p
join supply_chain.shipments s on p.product_id = s.product_id
group by p.product_id, p.product_type
order by total_freight_cost desc
limit 1;

-- 12. Which product has experienced the highest number of disruptions?
select p.product_type as product, sum(s.disruption_event) as disruption_count
from supply_chain.products p
join supply_chain.shipments s on p.product_id = s.product_id
group by p.product_id, p.product_type
order by disruption_count desc
limit 1;

-- 13. What percentage of shipments experienced disruption?
select round(100.0 * count(*) filter (where disruption_event = 1) / count(*), 2) as disruption_percentage
from supply_chain.shipments;

-- 14. What is the total revenue impact?
select sum(revenue_impact) as total_revenue_impact
from supply_chain.shipments;

-- 15. What is the average shipment delay?
select avg(current_delay) as average_shipment_delay
from supply_chain.shipment_risk;

-- 16. Demonstrate min and max
select min(current_delay) as minimum_delay, max(current_delay) as maximum_delay
from supply_chain.shipment_risk;

-- 17. Demonstrate case
select shipment_id, current_delay,
case
    when current_delay = 0 then 'on_time'
    when current_delay <= 5 then 'minor_delay'
    when current_delay <= 10 then 'moderate_delay'
    else 'major_delay'
end as delay_category
from supply_chain.shipment_risk;