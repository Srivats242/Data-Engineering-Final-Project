CREATE TABLE date_dim (
    date_key INT PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT
);

CREATE TABLE customer_dim (
    customer_key INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE product_dim (
    product_key INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50)
);

CREATE TABLE location_dim (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    city VARCHAR(50),
    state VARCHAR(50),
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