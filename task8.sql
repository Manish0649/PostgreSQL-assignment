
-- A. add risk classification column

alter table supply_chain.shipments
add column if not exists risk_classification varchar(20);


-- A. create risk classification function

create or replace function supply_chain.classify_risk(
    p_route_risk numeric,
    p_delay_probability numeric,
    p_current_delay numeric,
    p_inventory_days numeric
)
returns varchar(20)
language plpgsql
as $$
begin
    if p_route_risk >= 7
       and p_delay_probability >= 0.7
       and p_current_delay >= 10
       and p_inventory_days < 15 then
        return 'CRITICAL';

    elsif p_route_risk >= 7
          and p_delay_probability >= 0.7 then
        return 'HIGH';

    elsif p_route_risk >= 5
          or p_delay_probability >= 0.5
          or p_current_delay >= 5
          or p_inventory_days < 30 then
        return 'MEDIUM';

    else
        return 'LOW';
    end if;
end;
$$;


-- use the risk classification function

select
    shipment_id,
    supply_chain.classify_risk(
        route_risk,
        delay_probability,
        current_delay,
        inventory_days
    ) as risk_classification
from supply_chain.vw_shipment_risk;


-- B. create freight risk score function

create or replace function supply_chain.calculate_freight_risk(
    p_shipment_volume numeric,
    p_fuel_price numeric,
    p_route_risk numeric
)
returns numeric
language plpgsql
as $$
begin
    return round(
        (p_shipment_volume * p_fuel_price * p_route_risk) / 100000,
        2
    );
end;
$$;


-- use the freight risk score function

select
    s.shipment_id,
    supply_chain.calculate_freight_risk(
        s.shipment_volume,
        r.fuel_price,
        r.route_risk_score
    ) as freight_risk_score
from supply_chain.shipments s
join supply_chain.shipment_risk r
on s.shipment_id = r.shipment_id;


-- C. create stored procedure to update risk classification

create or replace procedure supply_chain.update_risk_classification(
    p_shipment_id varchar(50)
)
language plpgsql
as $$
declare
    v_route_risk numeric;
    v_delay_probability numeric;
    v_current_delay numeric;
    v_inventory_days numeric;
    v_classification varchar(20);
begin
    select
        r.route_risk_score,
        r.delay_probability,
        r.current_delay,
        i.inventory_days
    into
        v_route_risk,
        v_delay_probability,
        v_current_delay,
        v_inventory_days
    from supply_chain.shipment_risk r
    join supply_chain.inventory i
    on r.shipment_id = i.shipment_id
    where r.shipment_id = p_shipment_id;

    if not found then
        raise exception 'Shipment % not found', p_shipment_id;
    end if;

    v_classification := supply_chain.classify_risk(
        v_route_risk,
        v_delay_probability,
        v_current_delay,
        v_inventory_days
    );

    update supply_chain.shipments
    set risk_classification = v_classification
    where shipment_id = p_shipment_id;
end;
$$;


-- call the stored procedure

call supply_chain.update_risk_classification('SHP0001');


-- check the updated risk classification

select shipment_id, risk_classification
from supply_chain.shipments
where shipment_id = 'SHP0001';


-- D. create shipment audit table

create table if not exists supply_chain.shipment_audit (
    audit_id serial primary key,
    shipment_id varchar(50),
    old_value numeric,
    new_value numeric,
    operation varchar(20),
    changed_at timestamp default current_timestamp
);


-- create audit trigger function

create or replace function supply_chain.audit_freight_cost()
returns trigger
language plpgsql
as $$
begin
    insert into supply_chain.shipment_audit (
        shipment_id,
        old_value,
        new_value,
        operation,
        changed_at
    )
    values (
        old.shipment_id,
        old.freight_cost,
        new.freight_cost,
        tg_op,
        current_timestamp
    );

    return new;
end;
$$;


-- create freight cost audit trigger

drop trigger if exists trg_audit_freight_cost
on supply_chain.shipments;

create trigger trg_audit_freight_cost
after update of freight_cost
on supply_chain.shipments
for each row
when (old.freight_cost is distinct from new.freight_cost)
execute function supply_chain.audit_freight_cost();


-- test the audit trigger

update supply_chain.shipments
set freight_cost = freight_cost + 100
where shipment_id = 'SHP0001';


-- display shipment audit records

select *
from supply_chain.shipment_audit
order by changed_at desc;


-- E. create shipment validation function

create or replace function supply_chain.validate_shipment()
returns trigger
language plpgsql
as $$
begin
    if new.shipment_volume < 0 then
        raise exception 'Shipment volume cannot be negative';
    end if;

    if new.freight_cost < 0 then
        raise exception 'Freight cost cannot be negative';
    end if;

    return new;
end;
$$;


-- create shipment validation trigger

drop trigger if exists trg_validate_shipment
on supply_chain.shipments;

create trigger trg_validate_shipment
before insert or update
on supply_chain.shipments
for each row
execute function supply_chain.validate_shipment();


-- create risk validation function

create or replace function supply_chain.validate_risk()
returns trigger
language plpgsql
as $$
begin
    if new.delay_probability < 0
       or new.delay_probability > 1 then
        raise exception 'Delay probability must be between 0 and 1';
    end if;

    return new;
end;
$$;


-- create risk validation trigger

drop trigger if exists trg_validate_risk
on supply_chain.shipment_risk;

create trigger trg_validate_risk
before insert or update
on supply_chain.shipment_risk
for each row
execute function supply_chain.validate_risk();


-- test invalid shipment volume

begin;

update supply_chain.shipments
set shipment_volume = -100
where shipment_id = 'SHP0001';

rollback;


-- test invalid delay probability

begin;

update supply_chain.shipment_risk
set delay_probability = 1.5
where shipment_id = 'SHP0001';

rollback;

--revert back the changes
update supply_chain.shipments s
set freight_cost = r.freight_cost
from supply_chain.shipment_raw r
where s.shipment_id = r.shipment_id;