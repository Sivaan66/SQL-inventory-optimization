SELECT 
    MAX(record_date) AS max_date,
    MIN(record_date) AS min_date,
    DATEDIFF(MAX(record_date), MIN(record_date)) + 1 AS Date_range
FROM
    techelectro_inventory.supply_chain_data;