# Phase 1: Environment Setup & Data Ingestion Documentation

## 1. Executive Overview

Phase 1 establishes the relational database foundation for TechElectro Inc.'s inventory optimization project. This phase focuses on database schema architectural design, strict data type definitions, high-throughput CSV data ingestion, and comprehensive structural data validation checks.

---

## 2. Environment Specifications

* **Database Engine:** MySQL Server 8.0+
* **SQL Interface:** MySQL Workbench / Command Line Interface (CLI)
* **Dataset Name:** `supply_chain_dataset1.csv`
* **Total Expected Records:** 91,250 rows
* **Total Attributes:** 15 columns

---

## 3. Database & Table Schema DDL

```sql
-- Step 1: Create Database Context
CREATE DATABASE IF NOT EXISTS techelectro_inventory;
USE techelectro_inventory;

-- Step 2: Drop existing table if recreating environment
DROP TABLE IF EXISTS supply_chain_data;

-- Step 3: Define Supply Chain Table Schema
CREATE TABLE supply_chain_data (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    record_date DATE NOT NULL,
    sku_id VARCHAR(20) NOT NULL,
    warehouse_id VARCHAR(20) NOT NULL,
    supplier_id VARCHAR(20) NOT NULL,
    region VARCHAR(50) NOT NULL,
    units_sold INT NOT NULL DEFAULT 0,
    inventory_level INT NOT NULL DEFAULT 0,
    supplier_lead_time_days INT NOT NULL,
    reorder_point INT NOT NULL,
    order_quantity INT NOT NULL DEFAULT 0,
    unit_cost DECIMAL(10, 2) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    promotion_flag TINYINT(1) NOT NULL DEFAULT 0,
    stockout_flag TINYINT(1) NOT NULL DEFAULT 0,
    demand_forecast DECIMAL(10, 2) NOT NULL,
  
    -- Table Performance Indexes
    INDEX idx_sku_date (sku_id, record_date),
    INDEX idx_warehouse (warehouse_id),
    INDEX idx_supplier (supplier_id),
    INDEX idx_region (region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 4. High-Performance Data Ingestion Scripts

### Method: Bulk Loading via MySQL CLI (`LOAD DATA INFILE`)

```sql
LOAD DATA INFILE '/var/lib/mysql-files/supply_chain_dataset1.csv'
INTO TABLE supply_chain_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(record_date, sku_id, warehouse_id, supplier_id, region, units_sold, 
 inventory_level, supplier_lead_time_days, reorder_point, order_quantity, 
 unit_cost, unit_price, promotion_flag, stockout_flag, demand_forecast);
```

---

## 5. Phase 1 Data Integrity & Verification Queries

### 5.1. Verification of Record Count

```sql
SELECT COUNT(*) AS total_records 
FROM supply_chain_data;
-- Expected Output: 91,250
```

### 5.2. Data Completeness & Null Checks

```sql
SELECT 
    SUM(CASE WHEN record_date IS NULL THEN 1 ELSE 0 END) AS null_dates,
    SUM(CASE WHEN sku_id IS NULL THEN 1 ELSE 0 END) AS null_skus,
    SUM(CASE WHEN warehouse_id IS NULL THEN 1 ELSE 0 END) AS null_warehouses,
    SUM(CASE WHEN supplier_id IS NULL THEN 1 ELSE 0 END) AS null_suppliers,
    SUM(CASE WHEN unit_cost IS NULL OR unit_cost <= 0 THEN 1 ELSE 0 END) AS invalid_costs
FROM supply_chain_data;
```

Results:

| null_dates | null_skus | null_warehouses | null_suppliers | invalid_costs |
| ---------- | --------- | --------------- | -------------- | ------------- |
| 0          | 0         | 0               | 0              | 0             |

### 5.3. Date Range and Granularity Validation

```sql
SELECT 
    MIN(record_date) AS dataset_start_date,
    MAX(record_date) AS dataset_end_date,
    DATEDIFF(MAX(record_date), MIN(record_date)) + 1 AS total_days
FROM supply_chain_data;
```

Results:

| max_date   | min_date   | Date_range |
| ---------- | ---------- | ---------- |
| 2024-12-30 | 2024-01-01 | 365        |

### 5.4. Domain Distinct Entity Checks

```sql
SELECT 
    COUNT(DISTINCT sku_id) AS total_skus,
    COUNT(DISTINCT warehouse_id) AS total_warehouses,
    COUNT(DISTINCT supplier_id) AS total_suppliers,
    COUNT(DISTINCT region) AS total_regions
FROM supply_chain_data;
```

Results:

| total_skus | total_warehouses | total_suppliers | total_regions |
| ---------- | ---------------- | --------------- | ------------- |
| 50         | 5                | 10              | 4             |

---

## 6. Phase 1 Verification Summary Matrix

| Audit Dimension       | Target Criteria           | Status   | Notes                                          |
| :-------------------- | :------------------------ | :------- | :--------------------------------------------- |
| **Row Count**   | 91,250 rows               | Complete | Loaded successfully without truncation         |
| **Date Span**   | 2024-01-01 to 2024-12-30  | Verified | 365 days of continuous time series             |
| **Unique SKUs** | 50 unique SKUs            | Verified | Correctly mapped                               |
| **Warehouses**  | 5 unique Warehouses       | Verified | WH_1 through WH_5                              |
| **Suppliers**   | 10 unique Suppliers       | Verified | SUP_1 through SUP_10                           |
| **Data Types**  | Strict schema constraints | Applied  | Decimal formats applied for pricing & forecast |
