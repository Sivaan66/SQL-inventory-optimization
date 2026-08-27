USE techelectro_inventory;

/*
M5.1 - Rolling Demand Baseline

Purpose:
    Compare short-term (30-day) demand with a longer-term (90-day) baseline
    for each SKU.

Important modeling choice:
    supply_chain_data is stored at SKU + warehouse + date grain. Because the
    existing ROP model is evaluated at SKU level, demand is first aggregated
    across warehouses for each SKU and calendar date. This prevents each
    warehouse row from being treated as an independent daily observation.

Assumption:
    The dataset provides a daily observation for each SKU/warehouse. After
    aggregation, each SKU should have one row per calendar date. The ROWS-based
    windows below therefore represent 30 and 90 daily observations.
*/

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

rolling_demand AS (
    SELECT
        sku_id,
        record_date,
        daily_units_sold,

        /* Short-term demand baseline */
        AVG(daily_units_sold) OVER (
            PARTITION BY sku_id
            ORDER BY record_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS avg_demand_30d,

        /* Long-term demand baseline */
        AVG(daily_units_sold) OVER (
            PARTITION BY sku_id
            ORDER BY record_date
            ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
        ) AS avg_demand_90d,

        /* Number of observations available in each window */
        COUNT(*) OVER (
            PARTITION BY sku_id
            ORDER BY record_date
            ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
        ) AS observations_30d,

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
    ROUND(avg_demand_30d, 2) AS avg_daily_demand_30d,
    ROUND(avg_demand_90d, 2) AS avg_daily_demand_90d,
    ROUND(
        CASE
            WHEN avg_demand_90d = 0 THEN NULL
            ELSE ((avg_demand_30d - avg_demand_90d) / avg_demand_90d) * 100
        END,
        2
    ) AS demand_change_pct_30d_vs_90d,
    CASE
        WHEN observations_90d < 90 THEN 'INSUFFICIENT_90D_HISTORY'
        WHEN avg_demand_30d > avg_demand_90d * 1.10 THEN 'INCREASING'
        WHEN avg_demand_30d < avg_demand_90d * 0.90 THEN 'DECREASING'
        ELSE 'STABLE'
    END AS demand_trend,
    observations_30d,
    observations_90d
FROM rolling_demand
WHERE record_date = (
    SELECT MAX(record_date)
    FROM supply_chain_data
)
ORDER BY demand_change_pct_30d_vs_90d DESC, sku_id;

/*
Optional validation query:
Confirm the number of SKU-date observations available after warehouse
aggregation. A fully populated one-year dataset should show 365 observations
per SKU.
*/

SELECT
    sku_id,
    COUNT(*) AS sku_calendar_days,
    MIN(record_date) AS first_date,
    MAX(record_date) AS last_date
FROM daily_sku_demand
GROUP BY sku_id
ORDER BY sku_calendar_days, sku_id;
