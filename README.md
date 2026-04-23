# Data Engineering Final Project

## Retail Data Pipeline with Kafka and MySQL Data Warehouse

---

# Overview

This project implements a complete data engineering pipeline using the Superstore retail dataset. The system simulates real-time data streaming using Kafka, loads data into an operational database (ODB), and then transforms it into a structured data warehouse (DW) using a star schema.

The final result supports analytical queries (OLAP) for business insights such as sales trends, profit analysis, and customer behavior.

---

# Architecture

The pipeline follows this flow:

```
CSV Dataset → Kafka Producer → Kafka Broker → Kafka Consumer → MySQL (ODB) → Data Warehouse (DW)
```

* **Producer** reads the CSV file and streams records into Kafka
* **Consumer** reads messages and inserts them into MySQL (ODB)
* **Data Warehouse** is built from ODB using a star schema
* **OLAP Queries** are used for analysis

---

# Database Implementation

The system uses MySQL to implement both an operational database (ODB) and a data warehouse (DW).

## Operational Database (ODB)

The operational database contains a table called `sales_odb`, which stores raw transactional data streamed from Kafka. The Kafka consumer reads messages from the Kafka topic and inserts each record into this table.

The table includes fields such as:
- Order ID
- Order Date
- Customer Name
- City, State, Region
- Product Name and Category
- Quantity, Sales, and Profit

This table acts as the raw data layer of the system.

## Data Warehouse (DW)

The data warehouse is implemented using a star schema to support analytical queries.

It consists of:
- `customer_dim`
- `product_dim`
- `location_dim`
- `date_dim`
- `sales_fact`

The dimension tables store descriptive attributes, while the fact table stores measurable values such as sales, profit, and quantity.

The fact table links to each dimension table using keys.

## Data Transformation

Data is loaded into the warehouse using SQL transformation queries.

- Dimension tables are populated using `SELECT DISTINCT` queries from the operational database
- The fact table is populated by joining the operational table with the dimension tables

This structure allows for efficient OLAP queries, such as:
- Total sales by region
- Profit by category
- Monthly sales trends
- Top customers by spending

## Notes

- Date values were converted into MySQL format before insertion
- The data warehouse is created in a separate database (`dw`) within the same MySQL server

---

# Project Structure

```
Data-Engineering-Final-Project/
├── data/
│   └── superstore.csv
├── scripts/
│   ├── producer.py
│   └── consumer.py
├── sql/
│   ├── odb_schema.sql
│   ├── dw_schema.sql
│   ├── load_dw.sql
│   └── queries.sql
├── docker-compose.yaml
├── requirements.txt
├── README.md
```

### Folder Explanation

* **data/** → Contains the raw dataset
* **scripts/** → Python scripts for Kafka producer and consumer
* **sql/** → SQL files for schema creation and queries
* **docker-compose.yaml** → Defines Kafka + MySQL containers
* **requirements.txt** → Python dependencies

---

# Prerequisites

Before running the project, make sure you have:

* Docker Desktop installed and running
* Python 3 installed
* pip installed

---

# Step-by-Step Setup

---

# 1. Start Docker Services

Run the following command in your project directory:

```bash
docker-compose up -d
```

This starts:

* Kafka
* Zookeeper
* MySQL database

---

# 2. Install Python Dependencies

```bash
pip install -r requirements.txt
```

---

# 3. Create Operational Database (ODB)

Enter the MySQL container:

```bash
docker exec -it final-project-mysql-odb-1 mysql -u root -p
```

Password:

```
secret
```

Then run:

```sql
USE odb;
```

---

# 4. Create ODB Table

```sql
CREATE TABLE sales_odb (
    order_id VARCHAR(20),
    order_date DATE,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(50),
    product_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    sales DECIMAL(10,2),
    profit DECIMAL(10,2)
);
```

Verify:

```sql
SHOW TABLES;
DESCRIBE sales_odb;
```

---

# 5. Run Kafka Pipeline

## Start Consumer (Terminal 1)

```bash
cd scripts
python consumer.py
```

## Start Producer (Terminal 2)

```bash
cd scripts
python producer.py
```

### What happens:

* Producer reads `data/superstore.csv`
* Consumer inserts records into MySQL
* Data flows in real-time

---

# 6. Verify Data in ODB

Go back to MySQL:

```sql
SELECT COUNT(*) FROM sales_odb;
SELECT * FROM sales_odb LIMIT 5;
```

If rows appear → pipeline is working 

---

# 7. Create Data Warehouse (DW)

```sql
CREATE DATABASE IF NOT EXISTS dw;
USE dw;
```

---

# 8. Create Star Schema

```sql
CREATE TABLE date_dim (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT,
    day INT
);

CREATE TABLE customer_dim (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE product_dim (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255),
    category VARCHAR(50)
);

CREATE TABLE location_dim (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(50)
);

CREATE TABLE sales_fact (
    sales_key INT AUTO_INCREMENT PRIMARY KEY,
    date_key INT,
    customer_key INT,
    product_key INT,
    location_key INT,
    quantity INT,
    sales_amount DECIMAL(10,2),
    profit_amount DECIMAL(10,2)
);
```

---

# 9. Load Dimension Tables

```sql
INSERT INTO customer_dim (customer_name)
SELECT DISTINCT customer_name FROM odb.sales_odb;

INSERT INTO product_dim (product_name, category)
SELECT DISTINCT product_name, category FROM odb.sales_odb;

INSERT INTO location_dim (city, state, region)
SELECT DISTINCT city, state, region FROM odb.sales_odb;

INSERT INTO date_dim (date_key, full_date, year, month, day)
SELECT DISTINCT
    YEAR(order_date) * 10000 + MONTH(order_date) * 100 + DAY(order_date),
    order_date,
    YEAR(order_date),
    MONTH(order_date),
    DAY(order_date)
FROM odb.sales_odb;
```

---

# 10. Load Fact Table

```sql
INSERT INTO sales_fact (
    date_key,
    customer_key,
    product_key,
    location_key,
    quantity,
    sales_amount,
    profit_amount
)
SELECT
    YEAR(o.order_date) * 10000 + MONTH(o.order_date) * 100 + DAY(o.order_date),
    c.customer_key,
    p.product_key,
    l.location_key,
    o.quantity,
    o.sales,
    o.profit
FROM odb.sales_odb o
JOIN customer_dim c ON o.customer_name = c.customer_name
JOIN product_dim p ON o.product_name = p.product_name AND o.category = p.category
JOIN location_dim l ON o.city = l.city AND o.state = l.state AND o.region = l.region;
```

---

# 11. Verify Data Warehouse

```sql
SELECT COUNT(*) FROM customer_dim;
SELECT COUNT(*) FROM product_dim;
SELECT COUNT(*) FROM location_dim;
SELECT COUNT(*) FROM date_dim;
SELECT COUNT(*) FROM sales_fact;
```

---

# 12. Run OLAP Queries

## Total Sales by Region

```sql
SELECT l.region, SUM(f.sales_amount)
FROM sales_fact f
JOIN location_dim l ON f.location_key = l.location_key
GROUP BY l.region;
```

## Profit by Category

```sql
SELECT p.category, SUM(f.profit_amount)
FROM sales_fact f
JOIN product_dim p ON f.product_key = p.product_key
GROUP BY p.category;
```

## Monthly Sales Trend

```sql
SELECT d.year, d.month, SUM(f.sales_amount)
FROM sales_fact f
JOIN date_dim d ON f.date_key = d.date_key
GROUP BY d.year, d.month;
```

## Top Customers

```sql
SELECT c.customer_name, SUM(f.sales_amount)
FROM sales_fact f
JOIN customer_dim c ON f.customer_key = c.customer_key
GROUP BY c.customer_name
ORDER BY SUM(f.sales_amount) DESC
LIMIT 10;
```
