-- Sales by region
SELECT region, SUM(sales)
FROM odb.sales_odb
GROUP BY region;

-- Profit by category
SELECT category, SUM(profit)
FROM odb.sales_odb
GROUP BY category;

-- Monthly sales
SELECT MONTH(order_date), SUM(sales)
FROM odb.sales_odb
GROUP BY MONTH(order_date);
