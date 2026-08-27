use techelectro_inventory;

with sku_statistics as (
select
sku_id,
avg(units_sold) as avg_sold_per_day,
stddev_samp(units_sold) as daily_stddev_demand,
avg(supplier_lead_time_days) as avg_supplier_delay_days
from supply_chain_data
group by sku_id)

select
sku_id,
round(avg_sold_per_day, 2) as avg_daily_units_sold,
round(daily_stddev_demand, 2) as daily_demand_stddev,
round(avg_supplier_delay_days, 2) as avg_supplier_delivery_delays_in_days,
round(1.65*daily_stddev_demand*sqrt(avg_supplier_delay_days), 2) as Dynamic_safety_stock
from sku_statistics
order by Dynamic_safety_stock Desc;

