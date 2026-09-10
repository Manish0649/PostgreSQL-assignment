-- 1. inner join
select s.shipment_id, s.supplier_id, sp.supplier_id as supplier_reference
from supply_chain.shipments s
inner join supply_chain.suppliers sp
on s.supplier_id = sp.supplier_id;

-- 2. left join
select sp.supplier_id, s.shipment_id
from supply_chain.suppliers sp
left join supply_chain.shipments s
on sp.supplier_id = s.supplier_id;

-- 3. right join
select s.shipment_id, s.supplier_id, sp.supplier_id as supplier_reference
from supply_chain.shipments s
right join supply_chain.suppliers sp
on s.supplier_id = sp.supplier_id;

-- 4. full outer join
select sp.supplier_id, s.shipment_id
from supply_chain.suppliers sp
full outer join supply_chain.shipments s
on sp.supplier_id = s.supplier_id;

-- 5. cross join
select sp.supplier_id, p.product_type
from supply_chain.suppliers sp
cross join supply_chain.products p;
