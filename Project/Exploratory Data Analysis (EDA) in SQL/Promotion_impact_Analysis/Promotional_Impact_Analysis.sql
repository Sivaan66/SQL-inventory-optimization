SELECT 
    promotion_flag,
    COUNT(*) AS total_days,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(units_sold), 0) AS average_units_sold,
    ROUND(AVG(inventory_level), 0) AS avg_units_availability
FROM
    supply_chain_data
GROUP BY promotion_flag;

