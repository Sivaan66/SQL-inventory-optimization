WITH current_vs_optimized AS (
    SELECT 
        sku_id,
        AVG(inventory_level) AS current_avg_inventory,
        AVG(reorder_point) AS current_static_rop,
        CEIL(
            (AVG(units_sold) * AVG(supplier_lead_time_days)) + 
            (1.65 * STDDEV_SAMP(units_sold) * SQRT(AVG(supplier_lead_time_days)))
        ) AS optimized_dynamic_rop
    FROM supply_chain_data
    GROUP BY sku_id
)
SELECT 
    sku_id,
    ROUND(current_avg_inventory, 0) AS current_avg_inventory,
    ROUND(current_static_rop, 0) AS current_static_rop,
    optimized_dynamic_rop,
    ROUND(current_static_rop - optimized_dynamic_rop, 0) AS rop_reduction_delta
FROM current_vs_optimized
ORDER BY rop_reduction_delta DESC;