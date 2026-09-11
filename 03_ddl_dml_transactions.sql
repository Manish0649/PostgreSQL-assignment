
alter table supply_chain.shipments 
add column shipment_status varchar(30) not null default 'in_transit';

select shipment_id, shipment_status from supply_chain.shipments limit 10;

create table supply_chain.ddl_test (
    test_id serial primary key,
    test_name varchar(50)
);
select * from supply_chain.ddl_test;

insert into supply_chain.ddl_test (test_name) values ('test_record');
select * from supply_chain.ddl_test;

truncate table supply_chain.ddl_test;
select * from supply_chain.ddl_test;

drop table supply_chain.ddl_test;


DML

insert into supply_chain.suppliers (supplier_id) values ('SUP051');
select * from supply_chain.suppliers where supplier_id = 'SUP051';

insert into supply_chain.shipments
values ('SHP0701', 'SUP051', 1, 'India', 30000, 2000, 20, 100000, 25000, 0, 0, 'in_transit');
select * from supply_chain.shipments where shipment_id = 'SHP0701';

update supply_chain.shipments set shipment_status = 'delayed'
where shipment_id in (select shipment_id from supply_chain.shipment_risk where current_delay > 0);

select s.shipment_id, r.current_delay, s.shipment_status
from supply_chain.shipments s
join supply_chain.shipment_risk r
on s.shipment_id = r.shipment_id
where r.current_delay > 0;

update supply_chain.shipments
set freight_cost = freight_cost * 1.10 where freight_cost > 150000;

select shipment_id, freight_cost
from supply_chain.shipments where freight_cost > 150000 order by freight_cost desc;

update supply_chain.shipments s
set freight_cost = r.freight_cost from supply_chain.shipment_raw r where s.shipment_id = r.shipment_id;

delete from supply_chain.shipments
where shipment_id = 'SHP0701';

delete from supply_chain.suppliers
where supplier_id = 'SUP051';

insert into supply_chain.suppliers (supplier_id) values ('SUP051')
on conflict (supplier_id) do update set supplier_id = 'SUP052';

select *
from supply_chain.suppliers
where supplier_id = 'SUP052';

-----Transactions-------------

begin;
update supply_chain.shipments
set shipment_status = 'delayed' where shipment_id = 'SHP0001';

update supply_chain.shipment_risk
set current_delay = current_delay + 1 where shipment_id = 'SHP0001';

select s.shipment_id, s.shipment_status, r.current_delay
from supply_chain.shipments s
join supply_chain.shipment_risk r on s.shipment_id = r.shipment_id 
where s.shipment_id = 'SHP0001';

commit;


begin;

update supply_chain.shipments
set shipment_status = 'testing' where shipment_id = 'SHP0001';

select shipment_id, shipment_status
from supply_chain.shipments where shipment_id = 'SHP0001';

update supply_chain.shipments
set freight_cost = 'invalid' where shipment_id = 'SHP0001';

rollback;

select shipment_id, shipment_status
from supply_chain.shipments where shipment_id = 'SHP0001';