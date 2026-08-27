USE techelectro_inventory;

-- Step 1: Drop existing table to clear any duplicate column schema definitions
DROP TABLE IF EXISTS supply_chain_data;

-- Step 2: Create clean table (15 columns matching CSV exactly)
CREATE TABLE supply_chain_data (
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
    
    PRIMARY KEY (sku_id, warehouse_id, record_date),
    INDEX idx_warehouse (warehouse_id),
    INDEX idx_supplier (supplier_id),
    INDEX idx_region (region)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Step 3: Run Bulk Load Statement
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/supply_chain_dataset1.csv'
INTO TABLE supply_chain_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(record_date, sku_id, warehouse_id, supplier_id, region, 
units_sold, inventory_level, supplier_lead_time_days, 
reorder_point, order_quantity, unit_cost, unit_price, 
promotion_flag, stockout_flag, demand_forecast);

SELECT COUNT(*) AS total_rows FROM supply_chain_data;

select*
from techelectro_inventory.supply_chain_data;