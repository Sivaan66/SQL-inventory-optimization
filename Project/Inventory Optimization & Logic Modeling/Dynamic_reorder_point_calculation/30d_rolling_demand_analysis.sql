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

rolling_30d AS (
    SELECT
        sku_id,
        record_date,
        daily_units_sold,

        AVG(daily_units_sold) OVER (
            PARTITION BY sku_id
            ORDER BY record_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS avg_demand_30d,

        COUNT(*) OVER (
            PARTITION BY sku_id
            ORDER BY record_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS observations_30d

    FROM daily_sku_demand
)

SELECT
    sku_id,
    record_date,
    daily_units_sold,
    ROUND(avg_demand_30d, 2) AS avg_daily_demand_30d,
    observations_30d
FROM rolling_30d
ORDER BY
    sku_id,
    record_date;