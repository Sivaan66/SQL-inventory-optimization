SELECT 
    COUNT(DISTINCT sku_id) AS total_skus,
    COUNT(DISTINCT warehouse_id) AS total_warehouses,
    COUNT(DISTINCT supplier_id) AS total_suppliers,
    COUNT(DISTINCT region) AS total_regions
FROM supply_chain_data;