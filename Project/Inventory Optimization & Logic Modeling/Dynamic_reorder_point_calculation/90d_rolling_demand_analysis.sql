WITH daily_sku_demand AS (
    SELECT
        sku_id,
        record_date,
        SUM(units_sold) AS daily_units_sold
    FROM supply_chain_data
    GROUP BY
        sku_id,
        record_date
),

rolling_90d AS (
    SELECT
        sku_id,
        record_date,
        daily_units_sold,

        AVG(daily_units_sold) OVER (
            PARTITION BY sku_id
            ORDER BY record_date
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS avg_demand_90d,

        COUNT(*) OVER (
            PARTITION BY sku_id
            ORDER BY record_date
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS observations_90d

    FROM daily_sku_demand
)

SELECT
    sku_id,
    record_date,
    daily_units_sold,
    ROUND(avg_demand_90d, 2) AS avg_daily_demand_30d,
    observations_90d
FROM rolling_90d
ORDER BY
    sku_id,
    record_date;