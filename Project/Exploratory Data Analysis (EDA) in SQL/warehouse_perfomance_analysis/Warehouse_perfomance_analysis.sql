SELECT 
    region,
    COUNT(DISTINCT warehouse_id) AS actively_working_warehouses,
    SUM(inventory_level * unit_cost) AS total_tiedUp_capital,
    SUM(units_sold*unit_price) AS revenue_generated
FROM
    supply_chain_data
GROUP BY region
ORDER BY total_tiedUp_capital desc;
