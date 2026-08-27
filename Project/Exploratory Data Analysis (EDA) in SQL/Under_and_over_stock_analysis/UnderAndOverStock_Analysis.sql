select
warehouse_id,
count(case when inventory_level > reorder_point then 1 end) as Over_stock,
count(case when inventory_level < reorder_point then 1 end) as under_stock,
count(*) as total_recorded_days

from supply_chain_data
group by warehouse_id
order by warehouse_id;