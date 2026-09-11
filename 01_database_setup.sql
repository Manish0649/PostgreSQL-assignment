create schema supply_chain;

CREATE TABLE supply_chain.shipment_raw (
    shipment_id VARCHAR(50),
    supplier_id VARCHAR(50),
    country VARCHAR(100),
    product_type VARCHAR(100),
    monthly_demand NUMERIC,
    shipment_volume NUMERIC,
    route_risk_score NUMERIC,
    historical_delay NUMERIC,
    fuel_price NUMERIC,
    political_risk NUMERIC,
    port_congestion NUMERIC,
    inventory_days NUMERIC,
    supplier_reliability NUMERIC,
    alternative_supplier_count INTEGER,
    transit_time NUMERIC,
    delay_probability NUMERIC,
    current_delay NUMERIC,
    freight_cost NUMERIC,
    revenue_impact NUMERIC,
    disruption_event VARCHAR(255)
);

COPY supply_chain.shipment_raw
FROM 'C:/Users/MANISH BANSAL/Downloads/supply_chain_hormuz_crisis_700.csv'
WITH (
    FORMAT CSV,
    HEADER TRUE
);

select * from supply_chain.shipment_raw limit 10;

select count(*) as total_records from supply_chain.shipment_raw;

SELECT COUNT(*) AS total_columns FROM information_schema.columns WHERE table_schema = 'supply_chain'  AND table_name = 'shipment_raw';

SELECT
    COUNT(*) FILTER (WHERE shipment_id IS NULL) AS shipment_id_nulls,
    COUNT(*) FILTER (WHERE supplier_id IS NULL) AS supplier_id_nulls,
    COUNT(*) FILTER (WHERE country IS NULL) AS country_nulls,
    COUNT(*) FILTER (WHERE product_type IS NULL) AS product_type_nulls,
    COUNT(*) FILTER (WHERE monthly_demand IS NULL) AS monthly_demand_nulls,
    COUNT(*) FILTER (WHERE shipment_volume IS NULL) AS shipment_volume_nulls,
    COUNT(*) FILTER (WHERE route_risk_score IS NULL) AS route_risk_nulls,
    COUNT(*) FILTER (WHERE historical_delay IS NULL) AS historical_delay_nulls,
    COUNT(*) FILTER (WHERE fuel_price IS NULL) AS fuel_price_nulls,
    COUNT(*) FILTER (WHERE political_risk IS NULL) AS political_risk_nulls,
    COUNT(*) FILTER (WHERE port_congestion IS NULL) AS port_congestion_nulls,
    COUNT(*) FILTER (WHERE inventory_days IS NULL) AS inventory_days_nulls,
    COUNT(*) FILTER (WHERE supplier_reliability IS NULL) AS supplier_reliability_nulls,
    COUNT(*) FILTER (WHERE alternative_supplier_count IS NULL) AS alternative_supplier_count_nulls,
    COUNT(*) FILTER (WHERE transit_time IS NULL) AS transit_time_nulls,
    COUNT(*) FILTER (WHERE delay_probability IS NULL) AS delay_probability_nulls,
    COUNT(*) FILTER (WHERE current_delay IS NULL) AS current_delay_nulls,
    COUNT(*) FILTER (WHERE freight_cost IS NULL) AS freight_cost_nulls,
    COUNT(*) FILTER (WHERE revenue_impact IS NULL) AS revenue_impact_nulls,
    COUNT(*) FILTER (WHERE disruption_event IS NULL) AS disruption_event_nulls
FROM supply_chain.shipment_raw;

SELECT shipment_id, COUNT(*) AS occurrence_count FROM supply_chain.shipment_raw
GROUP BY shipment_id HAVING COUNT(*) > 1;

SELECT supplier_id, COUNT(*) AS sp_occurrence_count FROM supply_chain.shipment_raw
GROUP BY supplier_id HAVING COUNT(*) > 1;

select count(*) filter (where delay_probability < 0 or delay_probability > 1) as invalid_delay_probability,
count(*) filter (where supplier_reliability < 0 or supplier_reliability > 1) as invalid_supplier_reliability
from supply_chain.shipment_raw;

select
    count(*) filter (where monthly_demand < 0) as negative_monthly_demand,
    count(*) filter (where shipment_volume < 0) as negative_shipment_volume,
    count(*) filter (where inventory_days < 0) as negative_inventory_days,
    count(*) filter (where transit_time < 0) as negative_transit_time,
    count(*) filter (where freight_cost < 0) as negative_freight_cost,
    count(*) filter (where revenue_impact < 0) as negative_revenue_impact,
    count(*) filter (where current_delay < 0) as negative_current_delay
from supply_chain.shipment_raw;