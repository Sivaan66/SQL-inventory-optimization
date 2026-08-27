SELECT 
    sku_id,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(demand_forecast), 2) AS total_demand_forecast,
    ROUND(SUM(units_sold) - SUM(demand_forecast), 2) AS forecast_variance,
    ROUND(
        ABS(SUM(units_sold) - SUM(demand_forecast)) / NULLIF(SUM(units_sold), 0) * 100, 
        2
    ) AS mape_percentage
FROM supply_chain_data
GROUP BY sku_id
ORDER BY total_units_sold DESC
LIMIT 10;