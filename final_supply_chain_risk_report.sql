-- final supply chain risk report: top 20 critical shipments
-- run in pgAdmin Query Tool

with shipment_data as (
    select
        v.shipment_id,
        v.supplier,
        v.country,
        v.product,
        s.shipment_volume,
        v.route_risk,
        v.political_risk,
        v.port_congestion,
        r.supplier_reliability,
        v.inventory_days,
        s.transit_time,
        v.delay_probability,
        v.current_delay,
        s.freight_cost,
        s.revenue_impact,
        supply_chain.classify_risk(
            v.route_risk,
            v.delay_probability,
            v.current_delay,
            v.inventory_days
        ) as risk_classification,
        (
            v.route_risk * 0.25
            + v.political_risk * 0.15
            + v.port_congestion * 0.15
            + (v.delay_probability * 10) * 0.15
            + least(v.current_delay, 10) * 0.10
            + greatest(0, 10 - v.inventory_days) * 0.10
            + greatest(0, 1 - r.supplier_reliability / 100.0) * 0.05
            + least(
                supply_chain.calculate_freight_risk(
                    s.shipment_volume,
                    r.fuel_price,
                    v.route_risk
                ) / 100.0,
                1
            ) * 0.05
        ) as risk_score
    from supply_chain.vw_shipment_risk v
    join supply_chain.shipments s
        on v.shipment_id = s.shipment_id
    join supply_chain.shipment_risk r
        on v.shipment_id = r.shipment_id
),
country_stats as (
    select
        country,
        avg(freight_cost) as avg_country_freight_cost
    from supply_chain.shipments
    group by country
)
select
    d.shipment_id as "Shipment ID",
    d.supplier as "Supplier",
    d.country as "Country",
    d.product as "Product",
    d.shipment_volume as "Shipment Volume",
    d.route_risk as "Route Risk",
    d.political_risk as "Political Risk",
    d.port_congestion as "Port Congestion",
    d.supplier_reliability as "Supplier Reliability",
    d.inventory_days as "Inventory Days",
    d.transit_time as "Transit Time",
    d.delay_probability as "Delay Probability",
    d.current_delay as "Current Delay",
    d.freight_cost as "Freight Cost",
    d.revenue_impact as "Revenue Impact",
    d.risk_classification as "Risk Classification",
    round(d.risk_score::numeric, 2) as "Supply Chain Risk Score",
    case
        when d.risk_score >= 7.5 then 'critical'
        when d.risk_score >= 6 then 'high'
        when d.risk_score >= 4 then 'medium'
        else 'low'
    end as "Final Risk Level",
    round(
        (
            d.freight_cost / nullif(cs.avg_country_freight_cost, 0)
        )::numeric,
        2
    ) as "Freight Cost vs Country Average"
from shipment_data d
join country_stats cs
    on d.country = cs.country
order by d.risk_score desc
limit 20;