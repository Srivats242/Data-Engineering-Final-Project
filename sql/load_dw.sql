INSERT INTO customer_dim (customer_name)
SELECT DISTINCT customer_name FROM odb.sales_odb;

INSERT INTO product_dim (product_name, category)
SELECT DISTINCT product_name, category FROM odb.sales_odb;

INSERT INTO location_dim (city, state, region)
SELECT DISTINCT city, state, region FROM odb.sales_odb;
