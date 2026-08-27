use techelectro_inventory;

with eoq_metrics as (
select
sku_id,
avg(unit_cost) as unit_cost,
avg(units_sold)*365 as annual_demand,
50 as purchase_price,
0.2*(avg(unit_cost)) as annual_holding_cost
from supply_chain_data
group by sku_id
)
select
sku_id,
round(unit_cost, 2) as unit_cost,
round(annual_demand, 2) as annual_demand,
round(annual_holding_cost, 2) as annual_holding_cost_per_unit,
CEIL(SQRT((2 * annual_demand * purchase_price) / annual_holding_cost)) AS optimal_eoq
from eoq_metrics
order by optimal_eoq desc
limit 10;