select
    v.shipment_id as "Shipment ID",
    v.supplier as "Supplier",
    v.country as "Country",
    v.product as "Product",
    s.shipment_volume as "Shipment Volume",
    v.route_risk as "Route Risk",
    v.political_risk as "Political Risk",
    v.port_congestion as "Port Congestion",
    r.supplier_reliability as "Supplier Reliability",
    v.inventory_days as "Inventory Days",
    s.transit_time as "Transit Time",
    v.delay_probability as "Delay Probability",
    v.current_delay as "Current Delay",
    s.freight_cost as "Freight Cost",
    s.revenue_impact as "Revenue Impact",
    s.risk_classification as "Risk Classification",
    round(
        (
            (v.route_risk::numeric / 10) * 20
            + v.political_risk * 15
            + v.port_congestion * 15
            + v.delay_probability * 20
            + least(v.current_delay::numeric / 30, 1) * 10
            + greatest(1 - r.supplier_reliability / 100, 0) * 10
            + greatest(1 - v.inventory_days::numeric / 30, 0) * 5
            + least(
                supply_chain.calculate_freight_risk(
                    s.shipment_volume,
                    r.fuel_price,
                    v.route_risk
                ) / 100,
                1
            ) * 5
        ),
        2
    ) as "Supply Chain Risk Score",
    case
        when v.route_risk >= 9 and v.delay_probability >= 0.8 then 'critical'
        when v.route_risk >= 8 and v.delay_probability >= 0.75 then 'high'
        when v.route_risk >= 7 then 'medium'
        else 'low'
    end as "Final Risk Level"
from supply_chain.vw_shipment_risk v
join supply_chain.shipments s
on v.shipment_id = s.shipment_id
join supply_chain.shipment_risk r
on v.shipment_id = r.shipment_id
where v.shipment_id in (
    select shipment_id
    from supply_chain.vw_critical_shipments
)
order by "Supply Chain Risk Score" desc
limit 20;