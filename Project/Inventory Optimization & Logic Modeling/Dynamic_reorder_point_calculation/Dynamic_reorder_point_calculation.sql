with dynamic_reorder_point as (
select
  sku_id,
  avg(units_sold) as avg_daily_demand,
  avg(supplier_lead_time_days) as avg_lead_time,
  round(1.65*stddev_samp(units_sold)*sqrt(avg(supplier_lead_time_days)), 2) as safety_stock
from supply_chain_data
group by sku_id)
select
sku_id,
  round(avg_daily_demand , 2) as avg_daily_demand,
  round(avg_lead_time, 2) as avg_lead_time,
  round(safety_stock, 2) as safety_stock,
  round((avg_daily_demand*avg_lead_time)+safety_stock) as reorder_point
from dynamic_reorder_point
order by reorder_point desc
limit 5;
