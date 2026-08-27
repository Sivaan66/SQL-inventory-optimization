# Phase 2: Exploratory Data Analysis (EDA) in SQL

## 1. Executive Overview

Phase 2 focuses on executing exploratory data analysis (EDA) using MySQL to uncover core demand patterns, inventory imbalances, supplier reliability, and promotional lift across TechElectro Inc.'s distribution network.

---

## 2. Advanced SQL Analysis Queries & Findings

### 2.1. Demand Pattern & Forecast Accuracy Analysis

Evaluates total demand variance by comparing actual `Units_Sold` against baseline `Demand_Forecast` across product lines.

```sql
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
```

Results:

| sku_id | total_units_sold | total_demand_forecast | forecast_variance | mape_percentage |
| ------ | ---------------- | --------------------- | ----------------- | --------------- |
| SKU_18 | 37234            | 37181.77              | 52.23             | 0.14            |
| SKU_1  | 37026            | 37009.30              | 16.70             | 0.05            |
| SKU_33 | 37012            | 37033.25              | -21.25            | 0.06            |
| SKU_13 | 36915            | 36953.86              | -38.86            | 0.11            |
| SKU_47 | 36912            | 36880.77              | 31.23             | 0.08            |
| SKU_9  | 36855            | 36758.61              | 96.39             | 0.26            |
| SKU_4  | 36811            | 36813.70              | -2.70             | 0.01            |
| SKU_12 | 36794            | 36785.71              | 8.29              | 0.02            |
| SKU_3  | 36785            | 37031.12              | -246.12           | 0.67            |
| SKU_31 | 36742            | 37030.60              | -288.60           | 0.79            |

---

### 2.2. Stock Status Profiling (Overstock vs. Understock)

Quantifies inventory health by comparing daily `Inventory_Level` against the defined `Reorder_Point`.

```sql
SELECT 
    warehouse_id,
    COUNT(CASE WHEN inventory_level > reorder_point THEN 1 END) AS overstock_days,
    COUNT(CASE WHEN inventory_level < reorder_point THEN 1 END) AS understock_days,
    COUNT(CASE WHEN inventory_level = reorder_point THEN 1 END) AS optimal_days,
    COUNT(*) AS total_recorded_days
FROM supply_chain_data
GROUP BY warehouse_id
ORDER BY warehouse_id;
```

**Results-**

| warehouse_id | Over_stock | under_stock | total_recorded_days |
| ------------ | ---------- | ----------- | ------------------- |
| WH_1         | 17252      | 956         | 18250               |
| WH_2         | 17246      | 954         | 18250               |
| WH_3         | 17238      | 964         | 18250               |
| WH_4         | 17242      | 946         | 18250               |
| WH_5         | 17231      | 967         | 18250               |

---

### 2.3. Supplier Lead Time & Performance Profiling

Measures lead time consistency and order distribution across all 10 component suppliers.

```sql
SELECT 
    supplier_id,
    ROUND(AVG(supplier_lead_time_days), 0) as supplier_Delivery_time,
    MAX(supplier_lead_time_days) AS max_delivery_time,
    MIN(supplier_lead_time_days) AS min_delivery_time,
    COUNT(DISTINCT sku_id) AS supported_sku,
    SUM(units_sold) AS total_volume_handeled
FROM
    supply_chain_data
GROUP BY supplier_id
ORDER BY total_volume_handeled asc;
```

**Results:**

| supplier_id | supplier_Delivery_time | max_delivery_time | min_delivery_time | supported_sku | total_volume_handeled |
| ----------- | ---------------------- | ----------------- | ----------------- | ------------- | --------------------- |
| SUP_9       | 8                      | 14                | 2                 | 16            | 117259                |
| SUP_6       | 8                      | 14                | 2                 | 16            | 146684                |
| SUP_3       | 8                      | 14                | 2                 | 20            | 168017                |
| SUP_5       | 7                      | 13                | 2                 | 21            | 168145                |
| SUP_4       | 9                      | 14                | 3                 | 22            | 183147                |
| SUP_2       | 8                      | 14                | 2                 | 21            | 190999                |
| SUP_10      | 7                      | 14                | 2                 | 21            | 197242                |
| SUP_1       | 8                      | 14                | 3                 | 23            | 204249                |
| SUP_8       | 9                      | 14                | 2                 | 22            | 205407                |
| SUP_7       | 8                      | 14                | 2                 | 29            | 248830                |

---

### 2.4. Promotional Impact & Sales Velocity Analysis

Measures sales performance on promotional vs. non-promotional days to calculate promotional lift.

```sql
SELECT 
    promotion_flag,
    COUNT(*) AS total_days,
    SUM(units_sold) AS total_units_sold,
    ROUND(AVG(units_sold), 0) AS average_units_sold,
    ROUND(AVG(inventory_level), 0) AS avg_units_availability
FROM
    supply_chain_data
GROUP BY promotion_flag;
```

**Results:**

| promotion_flag | total_days | total_units_sold | average_units_sold | avg_units_availability |
| -------------- | ---------- | ---------------- | ------------------ | ---------------------- |
| 0              | 81980      | 1599018          | 20                 | 472                    |
| 1              | 9270       | 230961           | 25                 | 466                    |

**Analysis :**

- `Promotions are associated with ~28% higher unit demand, while average inventory availability is ~1.3% lower, suggesting that promotional periods may increase inventory pressure.`
- `Even though promotional observations represent only about 10.2% of all observations, they account for about  12.6% of total units sold .`

---

### 2.5. Regional Financial Exposure Analysis

Calculates tied-up working capital and revenue potential across regional distribution hubs.

```sql
SELECT 
    region,
    COUNT(DISTINCT warehouse_id) AS actively_working_warehouses,
    SUM(inventory_level * unit_cost) AS total_tiedUp_capital,
    SUM(units_sold*unit_price) AS revenue_generated
FROM
    supply_chain_data
GROUP BY region
ORDER BY total_tiedUp_capital desc;
```

**Results:** 

| region | actively_working_warehouses | total_tiedUp_capital | revenue_generated |
| ------ | --------------------------- | -------------------- | ----------------- |
| North  | 5                           | 132148966.31         | 8411171.01        |
| East   | 5                           | 132122398.00         | 8398382.40        |
| South  | 5                           | 130569498.93         | 8320450.82        |
| West   | 5                           | 130403127.88         | 8296332.99        |

**Revenue-to-Capital Ratio = Revenue Generated / Tied-Up Capital :**

| Region | Revenue / Capital |
| ------ | ----------------: |
| North  |  **6.365%** |
| East   |  **6.357%** |
| South  |  **6.372%** |
| West   |  **6.362%** |

**Analysis:**

* North has  **$1.75M more capital tied up than West** , yet generates only  **$114.8K more revenue** .
* Regional inventory-capital efficiency is **highly consistent across all four regions**, with **South** marginally **leading** and **East** marginally **trailing.**


## 3. Key Insight Summary Matrix

| Metric Dimension               | Key Finding                                        | Strategic Impact                                                                  |
| :----------------------------- | :------------------------------------------------- | :-------------------------------------------------------------------------------- |
| **Inventory Health**     | 86,209 overstock days vs. 4,787 understock days    | Significant capital tied up in slow-moving inventory across distribution hubs.    |
| **Forecast Variance**    | High forecast precision at aggregate SKU levels    | Micro-level warehouse allocation shifts are required to balance dynamic demand.   |
| **Supplier Reliability** | Lead times range from 7 to 9 days across suppliers | Lead times are highly predictable, enabling tight dynamic reorder point modeling. |
| **Promotional Lift**     | Promotional periods drive higher volume demand     | Dynamic safety stock adjustments are required prior to scheduled promotion runs.  |
