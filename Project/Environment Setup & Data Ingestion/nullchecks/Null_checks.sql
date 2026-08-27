SELECT 
    SUM(CASE WHEN record_date IS NULL THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN sku_id IS NULL THEN 1 ELSE 0 END) AS null_skus,
    SUM(CASE WHEN warehouse_id IS NULL THEN 1 ELSE 0 END) AS null_warehouses,
    SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS null_suppliers,
    SUM(CASE WHEN unit_cost IS NULL OR unit_cost <= 0 THEN 1 ELSE 0 END) AS invalid_costs
FROM techelectro_inventory.supply_chain_data;