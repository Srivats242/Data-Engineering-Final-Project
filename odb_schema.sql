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