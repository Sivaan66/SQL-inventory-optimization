# Phase 3: Inventory Optimization & Logic Modeling Documentation

## 1. Executive Overview

Phase 3 establishes the mathematical inventory optimization algorithms executed directly in MySQL. This phase moves TechElectro Inc. from static inventory thresholds to dynamic reorder mechanics by calculating **Safety Stock (SS)**, **Reorder Points (ROP)**, and **Economic Order Quantity (EOQ)** using advanced SQL window functions, statistical aggregates, and mathematical subqueries[cite: 1].

---

## 2. Mathematical Formulations & SQL Implementation

### 2.1. Dynamic Safety Stock (SS) Calculation

Safety Stock buffers against demand volatility and lead time variability. Using a **95% Service Level** ($Z = 1.65$):

**Safety Stock** = $Z \times \sigma(\text{demand}) \times \sqrt{\text{Lead Time}}$

where,

* **z**: The desired service level (number of standard deviations from the mean).

- **Demand**: The average demand during the lead time.
- **Lead Time**: The time it takes to replenish stock.

By applying these variables, we can effectively calculate the safety stock needed to meet customer demand during unforeseen delays.

```sql
use techelectro_inventory;

with sku_statistics as (
select
sku_id,
avg(units_sold) as avg_sold_per_day,
stddev_samp(units_sold) as daily_stddev_demand,
avg(supplier_lead_time_days) as avg_supplier_delay_days
from supply_chain_data
group by sku_id)

select
sku_id,
round(avg_sold_per_day, 2) as avg_daily_units_sold,
round(daily_stddev_demand, 2) as daily_demand_stddev,
round(avg_supplier_delay_days, 2) as avg_supplier_delivery_delays_in_days,
round(1.65*daily_stddev_demand*sqrt(avg_supplier_delay_days), 2) as Dynamic_safety_stock
from sku_statistics
order by Dynamic_safety_stock Desc;
```

**Results:**

| sku_id | avg_daily_units_sold | daily_demand_stddev | avg_supplier_delivery_delays_in_days | Dynamic_safety_stock |
| ------ | -------------------- | ------------------- | ------------------------------------ | -------------------- |
| SKU_36 | 20.05                | 9.16                | 11.40                                | 51.02                |
| SKU_38 | 20.13                | 9.21                | 11.20                                | 50.84                |
| SKU_41 | 20.02                | 9.08                | 11.20                                | 50.16                |
| SKU_3  | 20.16                | 9.2                 | 10.60                                | 49.44                |
| SKU_13 | 20.23                | 9.22                | 10.20                                | 48.61                |
| SKU_9  | 20.19                | 9.02                | 10.60                                | 48.47                |
| SKU_4  | 20.17                | 9.15                | 10.20                                | 48.2                 |
| SKU_43 | 20.02                | 9.03                | 10.40                                | 48.03                |
| SKU_2  | 19.99                | 9.11                | 10.20                                | 47.99                |
| SKU_10 | 20.04                | 9.07                | 10.20                                | 47.77                |
| SKU_29 | 20.13                | 9.4                 | 9.40                                 | 47.56                |
| SKU_15 | 19.94                | 9.05                | 9.40                                 | 45.77                |
| SKU_21 | 19.95                | 9.23                | 8.80                                 | 45.16                |
| SKU_14 | 20.05                | 9.16                | 8.80                                 | 44.82                |
| SKU_48 | 20.05                | 9.12                | 8.80                                 | 44.66                |
| SKU_50 | 20.06                | 8.98                | 9.00                                 | 44.44                |
| SKU_6  | 19.84                | 8.78                | 9.40                                 | 44.4                 |
| SKU_46 | 19.87                | 9.2                 | 8.40                                 | 44.01                |
| SKU_42 | 20.08                | 9.09                | 8.40                                 | 43.46                |
| SKU_18 | 20.40                | 9.31                | 8.00                                 | 43.43                |
| SKU_47 | 20.23                | 8.92                | 8.60                                 | 43.18                |
| SKU_49 | 19.99                | 8.99                | 8.40                                 | 42.98                |
| SKU_8  | 20.11                | 9.27                | 7.80                                 | 42.71                |
| SKU_26 | 19.94                | 9.23                | 7.80                                 | 42.53                |
| SKU_23 | 20.11                | 8.87                | 8.40                                 | 42.43                |
| SKU_1  | 20.29                | 8.95                | 8.20                                 | 42.27                |
| SKU_5  | 19.98                | 8.95                | 8.20                                 | 42.27                |
| SKU_17 | 19.97                | 9.03                | 7.80                                 | 41.6                 |
| SKU_44 | 20.10                | 9.14                | 7.60                                 | 41.58                |
| SKU_33 | 20.28                | 8.98                | 7.80                                 | 41.36                |
| SKU_28 | 19.99                | 9.2                 | 7.40                                 | 41.29                |
| SKU_16 | 20.00                | 9.14                | 7.40                                 | 41.02                |
| SKU_37 | 20.13                | 9.17                | 7.20                                 | 40.61                |
| SKU_40 | 19.97                | 9.06                | 7.20                                 | 40.11                |
| SKU_12 | 20.16                | 9.17                | 7.00                                 | 40.03                |
| SKU_24 | 19.93                | 8.89                | 7.40                                 | 39.88                |
| SKU_39 | 20.05                | 8.86                | 7.40                                 | 39.77                |
| SKU_35 | 19.97                | 8.93                | 6.80                                 | 38.44                |
| SKU_22 | 20.08                | 9.2                 | 6.00                                 | 37.19                |
| SKU_19 | 19.87                | 8.9                 | 6.20                                 | 36.56                |
| SKU_25 | 20.05                | 8.89                | 6.20                                 | 36.53                |
| SKU_45 | 19.92                | 8.85                | 6.00                                 | 35.75                |
| SKU_34 | 20.02                | 9.04                | 5.60                                 | 35.31                |
| SKU_31 | 20.13                | 8.85                | 5.80                                 | 35.16                |
| SKU_30 | 20.03                | 8.88                | 5.60                                 | 34.68                |
| SKU_27 | 19.96                | 9.17                | 5.00                                 | 33.84                |
| SKU_11 | 19.92                | 8.96                | 5.20                                 | 33.7                 |
| SKU_20 | 20.13                | 9.13                | 5.00                                 | 33.68                |
| SKU_32 | 20.08                | 9.05                | 5.00                                 | 33.38                |
| SKU_7  | 19.98                | 9.26                | 4.60                                 | 32.78                |

---

### 2.2. Dynamic Reorder Point (ROP) Modeling

The Reorder Point establishes the threshold stock level that triggers replenishment orders:

**Dynamic Reorder Point (ROP)** modeling calculates the exact inventory threshold that triggers a new purchase order before a warehouse runs out of stock.

Unlike static ROPs—which use fixed arbitrary thresholds—dynamic ROP automatically adjusts per product based on actual sales velocity, supplier delivery lead times, and demand volatility^^.

### Core Formula & Breakdown

The mathematical model splits inventory replenishment into two distinct protection layers:

$$
\text{ROP} = \underbrace{(\text{Average Daily Demand} \times \text{Average Lead Time})}_\text{Expected Sales During Delivery} + \underbrace{\text{Safety Stock}}_\text{Buffer for Surges/Delays}
$$

#### Component Breakdown:

* **Lead Time Demand (**$\text{Demand} \times \text{Lead Time}$**):** The number of units expected to be sold while waiting for supplier delivery.
* **Safety Stock (**$Z \times \sigma_{\text{demand}} \times \sqrt{L}$**):** The safety buffer that protects against sudden demand surges or unexpected supplier delays.

```sql
with dynamic_reorder_point as (
select
sku_id,
avg(units_sold) as avg_daily_demand,
avg(supplier_lead_time_days) as avg_lead_time,
round(1.65*stddev_samp(units_sold)*sqrt(avg(supplier_lead_time_days)), 2) as safety_stock
from supply_chain_data
group by sku_id)

select
sku_id,
round(avg_daily_demand , 2) as avg_daily_demand,
round(avg_lead_time, 2) as avg_lead_time,
round(safety_stock, 2) as safety_stock,
round((avg_daily_demand*avg_lead_time)+safety_stock) as reorder_point
from dynamic_reorder_point
order by reorder_point desc
limit 5;
```

**Results:**

| sku_id | avg_daily_demand | avg_lead_time | safety_stock | reorder_point |
| ------ | ---------------- | ------------- | ------------ | ------------- |
| SKU_36 | 20.05            | 11.40         | 51.02        | 280           |
| SKU_38 | 20.13            | 11.20         | 50.84        | 276           |
| SKU_41 | 20.02            | 11.20         | 50.16        | 274           |
| SKU_9  | 20.19            | 10.60         | 48.47        | 263           |
| SKU_3  | 20.16            | 10.60         | 49.44        | 263           |

So product wwith sku_id: `SKU_36`  has a reorder point of `280`. Means when the product inventory level reaches 280 it should be refilled according to it's `Total demand`.

---

### 2.3. Economic Order Quantity (EOQ) Optimization

EOQ calculates the optimal batch order size to minimize combined holding and ordering costs.

It answers one fundamental operational question: *"When we reach our Reorder Point (ROP), how many units should we order in a single batch?"*

### The Inventory Cost Trade-Off

EOQ balances two opposing operational costs:

```
            Total Inventory Cost = Ordering Costs + Holding Costs
```

1. **Ordering Costs (**$S$**):** The fixed cost to place and process a purchase order (e.g., administrative paperwork, shipping fees, unloading labor, inspection).
   * *If you order in tiny batches:* You place orders frequently **$\rightarrow$**  **Ordering costs skyrocket** .
2. **Holding Costs (**$H$**):** The cost of storing unsold stock in the warehouse (e.g., storage space, insurance, refrigeration, electricity, risk of damage or obsolescence).
   * *If you order in massive batches:* Inventory sits in the warehouse for months **$\rightarrow$**  **Holding costs skyrocket** .

**EOQ finds the exact mathematical "sweet spot" where ordering costs and holding costs balance out at their lowest total point.**

### The Mathematical Formula

$$
\text{EOQ} = \sqrt{\frac{2 \times D \times S}{H}}
$$

* **$D$ (Annual Demand):** **$\text{Average Daily Sales} \times 365$**
* **$S$ (Order Cost):** Fixed at **$\$50.00$** per purchase order
* **$H$ (Annual Holding Cost):** **$20\%$** of `Unit_Cost` (**$0.20 \times \text{Unit Cost}$**)

```sql
use techelectro_inventory;

with eoq_metrics as (
select
  sku_id,
  avg(unit_cost) as unit_cost,
  avg(units_sold)*365 as annual_demand,
  50 as purchase_price,
  0.2*(avg(unit_cost)) as annual_holding_cost
from supply_chain_data
group by sku_id
)
select
  sku_id,
  round(unit_cost, 2) as unit_cost,
  round(annual_demand, 2) as annual_demand,
  round(annual_holding_cost, 2) as annual_holding_cost_per_unit,
  CEIL(SQRT((2 * annual_demand * purchase_price) / annual_holding_cost)) AS optimal_eoq
from eoq_metrics
order by optimal_eoq desc
limit 10;
```

**Results:**

| sku_id | unit_cost | annual_demand | annual_holding_cost_per_unit | optimal_eoq |
| ------ | --------- | ------------- | ---------------------------- | ----------- |
| SKU_44 | 7.56      | 7336.60       | 1.51                         | 697         |
| SKU_34 | 7.86      | 7307.40       | 1.57                         | 682         |
| SKU_25 | 9.26      | 7318.00       | 1.85                         | 629         |
| SKU_47 | 9.61      | 7382.40       | 1.92                         | 620         |
| SKU_41 | 9.53      | 7306.40       | 1.91                         | 620         |
| SKU_14 | 9.97      | 7317.00       | 1.99                         | 606         |
| SKU_42 | 10.16     | 7327.40       | 2.03                         | 601         |
| SKU_24 | 10.16     | 7276.20       | 2.03                         | 599         |
| SKU_36 | 10.27     | 7318.80       | 2.05                         | 598         |
| SKU_5  | 10.34     | 7291.40       | 2.07                         | 594         |

**Analysis:**

* **Cost Sensitivity & Inverse Relationship:** As unit cost rises from **$\$7.56$** to **$\$10.34$**, holding cost per unit increases by **$37\%$**, causing optimal batch order sizes to drop from  **697 units down to 594 units** .
* **Demand Stability:** Annual demand is virtually uniform across all 10 products, averaging **7,318 units/year** (**$\sim 20$** units/day).
* **Cost Equilibrium:** At optimal EOQ, annual holding costs match annual ordering costs (each averaging **$\sim \$588$**/year per SKU), confirming cost minimization balance.
* **Replenishment Cadence:** Under these parameters, each SKU will require a restock order placed roughly **once every 30 to 35 days** (10 to 12 replenishment cycles per year).

---

### 2.4. Overstock vs. Optimal Stock Comparison Audit

Compares existing static reorder points against newly optimized dynamic ROP thresholds to identify capital reduction opportunities[cite: 1].

```sql
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
```

**Results:**

| sku_id | current_avg_inventory | current_static_rop | optimized_dynamic_rop | rop_reduction_delta |
| ------ | --------------------- | ------------------ | --------------------- | ------------------- |
| SKU_7  | 495                   | 325                | 125                   | 200                 |
| SKU_11 | 500                   | 318                | 138                   | 180                 |
| SKU_27 | 491                   | 310                | 134                   | 176                 |
| SKU_20 | 470                   | 305                | 135                   | 170                 |
| SKU_16 | 521                   | 350                | 190                   | 160                 |

**Analysis:**

![1787762615220](image/Documentation/1787762615220.png)

##### Transitioning from legacy static reorder points to dynamic demand-driven modeling across the 50 audited SKUs reduces total reorder stock triggers by  **4,871 units** , achieving an immediate  **32.46% overall inventory capital reduction** .

### Key Takeaways

* **Elimination of Blanket Over-Buffering:** The legacy static model assigned arbitrary ROP thresholds near ~300 units regardless of lead time or demand variance. Dynamic modeling drops ROP thresholds down to as low as 125 units (`SKU_7`) for items with stable sales and rapid vendor delivery.
* **Variable Lead Time Adjustments:** Products with minimal reductions (e.g., `SKU_3`, `SKU_36`, `SKU_50`) maintain dynamic ROPs close to their static baseline because their suppliers exhibit longer lead times or higher demand volatility, requiring a larger safety stock cushion.
* **Working Capital Optimization:** Lowering aggregate reorder thresholds by nearly a third prevents capital from locking up in unnecessary early reorders while maintaining the target service level.

---
