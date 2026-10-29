use zepto;
ALTER TABLE zepto_v2
ADD COLUMN product_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;
describe zepto_v2;
select * from zepto_v2;

select * from zepto_orders;



CREATE TABLE zepto_orders (
    order_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    order_date DATE NOT NULL,
    quantity_sold INT NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30),
    order_status VARCHAR(20)
);


INSERT INTO zepto_orders
(order_id, product_id, order_date, quantity_sold,
 selling_price, payment_method, order_status)
VALUES
(1001, 1, '2026-10-01', 2, 45.00, 'UPI', 'Delivered'),
(1002, 2, '2026-10-01', 1, 120.00, 'Card', 'Delivered'),
(1003, 3, '2026-10-02', 3, 30.00, 'UPI', 'Delivered'),
(1004, 1, '2026-10-02', 1, 45.00, 'Cash', 'Cancelled'),
(1005, 4, '2026-10-03', 2, 80.00, 'UPI', 'Delivered'),
(1006, 5, '2026-10-03', 4, 25.00, 'Card', 'Delivered'),
(1007, 2, '2026-10-04', 2, 120.00, 'UPI', 'Delivered'),
(1008, 3, '2026-10-04', 1, 30.00, 'Cash', 'Delivered'),
(1009, 6, '2026-10-05', 3, 65.00, 'UPI', 'Returned'),
(1010, 4, '2026-10-05', 1, 80.00, 'Card', 'Delivered'),
(1011, 1, '2026-10-06', 5, 45.00, 'UPI', 'Delivered'),
(1012, 5, '2026-10-06', 2, 25.00, 'Cash', 'Delivered'),
(1013, 2, '2026-10-07', 1, 120.00, 'UPI', 'Delivered'),
(1014, 6, '2026-10-07', 2, 65.00, 'Card', 'Delivered'),
(1015, 3, '2026-10-08', 4, 30.00, 'UPI', 'Delivered');

select * from zepto_orders;
select max(mrp),name from zepto_v2;


#DATA Exploration

#count of rows
select count(*)as total_rows from zepto_v2;

#sample data
select * from zepto_v2
limit 10;

#looking for null values?
SELECT * 
FROM zepto_v2
WHERE Category IS NULL
   OR name IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR availableQuantity IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;
   
#distinct category
select distinct category from zepto_v2 order by category;

#chceck how many products are in_stock and out of stock
select outofstock ,count(*) as quantity from zepto_v2
group by outofstock;

#Product name presnt multiple times
select name,count(*)  as number_of_product from  Zepto_v2 
group by name 
having count(*)>5
order by number_of_product desc  ;

####data celaning####

select * from zepto_v2
where mrp=0 ;
SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;
delete from zepto_v2
where mrp=0;
#update zepto paise into rupees
update zepto_v2
set mrp=mrp/100.0,
discountedSellingPrice = discountedSellingPrice/100.0;
select mrp,discountedSellingPrice from zepto_v2;
select * from zepto_v2;

#find the top 10 products based on the discount percentage %
select distinct(name) from zepto_v2
order by  discountedsellingprice desc limit 10;

#what are the products with high  MRP but outofstock
select distinct(name) from zepto_v2
where outofstock = "TRUE" and mrp>300
order by mrp desc;


# calculate estimated Revenue  for each category 
select sum(quantity * mrp) as revenue,Category from zepto_v2
group by Category;

#find all product where mrp is greater than 500 and discount less tahn 10%
select * from zepto_v2
where mrp >500 and discountPercent < 10;

#identitify top5 categories offering the highest average discount percentage
select (avg(discountPercent)) as avg_discount,Category from zepto_v2
group by Category
order by avg_discount desc 
limit 5 ;

#find the price per gram product above 100g and sort by best values
select * from zepto_v2;
select name,discountedSellingPrice,weightInGms,round(discountedSellingPrice/weightInGms,2) as value_per_gram
from zepto_v2
where weightInGms >=100
order by value_per_gram desc;

#group the products into categories like low,medium,bulk
select distinct(name),weightInGms,
case when weightInGms<1000 then 'LOW'
	when weightInGms<5000 then 'medium'
    else 'bulk'
    end as weight_category
from zepto_v2;

#Start with this query to understand the relationship:

SELECT
    o.order_id,
    o.order_date,
    z.name AS product_name,
    o.quantity_sold,
    o.selling_price,
    o.order_status
FROM zepto_orders o
INNER JOIN zepto_v2 z
    ON o.product_id = z.product_id;

#Find the best-selling products
SELECT o.order_id,z.name AS product_name,o.quantity_sold,o.selling_price,
sum(z.quantity * z.mrp) as revenue
FROM zepto_orders o INNER JOIN zepto_v2 z 
ON o.product_id = z.product_id
where order_status='Delivered'
group by product_name
order by revenue desc limit 5;

SELECT
    z.product_id,
    z.name AS product_name,
    SUM(o.quantity_sold) AS total_units_sold,
    SUM(o.quantity_sold * o.selling_price) AS revenue
FROM zepto_orders o
INNER JOIN zepto_v2 z
    ON o.product_id = z.product_id
WHERE o.order_status = 'Delivered'
GROUP BY
    z.product_id,
    z.name
ORDER BY revenue DESC
LIMIT 10;

SELECT
    z.product_id,
    z.name AS product_name,
    SUM(o.quantity_sold) AS total_units_sold,
    SUM(o.quantity_sold * o.selling_price) AS revenue
FROM zepto_orders o
INNER JOIN zepto_v2 z
    ON o.product_id = z.product_id
WHERE o.order_status = 'Delivered'
GROUP BY
    z.product_id,
    z.name
ORDER BY revenue DESC
LIMIT 10;

SELECT
    z.product_id,
    z.name AS product_name,
    SUM(o.quantity_sold) AS total_units_sold,
    SUM(o.quantity_sold * o.selling_price) AS revenue
FROM zepto_orders o
INNER JOIN zepto_v2 z
    ON o.product_id = z.product_id
WHERE o.order_status = 'Delivered'
GROUP BY
    z.product_id,
    z.name
ORDER BY revenue DESC
LIMIT 10;


select * from zepto_orders;
select count(product_id) from zepto_orders;

SELECT 
    COUNT(DISTINCT order_id) AS purchase_frequency,
    SUM(quantity_sold * selling_price) AS lifetime_value
FROM zepto_orders
WHERE order_status = 'Delivered'
GROUP BY product_id
ORDER BY purchase_frequency DESC
LIMIT 10;

ALTER TABLE zepto_orders
ADD COLUMN customer_id INT;

UPDATE zepto_orders
SET customer_id = CASE order_id
    WHEN 1001 THEN 501
    WHEN 1002 THEN 502
    WHEN 1003 THEN 503
    WHEN 1004 THEN 501
    WHEN 1005 THEN 504
    
END
WHERE order_id IN (1001, 1002, 1003, 1004, 1005);


UPDATE zepto_orders
SET customer_id = CASE order_id
    WHEN 1001 THEN 509
    WHEN 1002 THEN 507
    WHEN 1003 THEN 507
    WHEN 1004 THEN 509
    WHEN 1005 THEN 510
    WHEN 1006 THEN 511
    WHEN 1007 THEN 511
    WHEN 1008 THEN 513
    WHEN 1009 THEN 514
    WHEN 1010 THEN 511
    WHEN 1011 THEN 516
    WHEN 1012 THEN 516
    WHEN 1013 THEN 518
    WHEN 1014 THEN 519
    WHEN 1015 THEN 520
END
WHERE order_id BETWEEN 1001 AND 1015;
select * from zepto_orders;

#2Customers Who Purchase Most Often (Loyalty targeting)
select count(customer_id) as frequency_of_cutomer ,csutomer_id from zepto_orders
where order_status='Delivered'
group by customer_id
having frequency_of_cutomer>1
order by frequency_of_cutomer desc;


#Products with Low Stock but High Demand
SELECT 
    z.name AS product_name, 
    z.availableQuantity AS current_stock,
    SUM(o.quantity_sold) AS total_units_sold
FROM zepto_v2 z
INNER JOIN zepto_orders o ON z.product_id = o.product_id
WHERE o.order_status = 'Delivered'
GROUP BY 
    z.product_id, 
    z.name, 
    z.availableQuantity
HAVING current_stock < 50 
ORDER BY total_units_sold DESC
LIMIT 10;

#Business question: Which products sell the most units?
SELECT o.order_id,o.order_date,z.name AS product_name,o.quantity_sold,o.selling_price,
    o.order_status
FROM zepto_orders AS o
INNER JOIN zepto_v2 AS z
    ON o.product_id = z.product_id
LIMIT 20;






#How many orders are delivered, cancelled or in other statuses?
SELECT
    z.name AS product_name,
    SUM(o.quantity_sold) AS total_quantity_sold,
    ROUND(
        SUM(o.quantity_sold * o.selling_price), 2
    ) AS total_revenue
FROM zepto_orders AS o
INNER JOIN zepto_v2 AS z
    ON o.product_id = z.product_id
WHERE o.order_status = 'Delivered'
GROUP BY z.name
ORDER BY total_revenue DESC;






#total_delivered_orders: number of distinct delivered orders.
#total_units_sold: number of delivered units sold.
#total_revenue: sum of delivered sales, assuming selling_price is a per-unit price.
#revenue_per_order: delivered sales revenue divided by distinct delivered orders.

SELECT
    COUNT(DISTINCT order_id) AS total_delivered_orders,
    SUM(quantity_sold) AS total_units_sold,
    ROUND(
        SUM(quantity_sold * selling_price), 2
    ) AS total_revenue,
    ROUND(
        SUM(quantity_sold * selling_price)
        / NULLIF(COUNT(DISTINCT order_id), 0), 2
    ) AS revenue_per_order
FROM zepto_orders
WHERE order_status = 'Delivered';



#Explanation: Checks the number of records, distinct orders and missing values in important sales fields.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    COUNT(*) - COUNT(order_id) AS missing_order_ids,
    SUM(quantity_sold IS NULL) AS missing_quantities,
    SUM(selling_price IS NULL) AS missing_prices
FROM zepto_orders;


describe zepto_orders;


describe zepto_v2;


SELECT * FROM zepto_v2 LIMIT 10;


SELECT * FROM zepto_orders LIMIT 10;













SELECT o.order_id,o.order_date,
z.name AS product_name,
o.quantity_sold,o.selling_price,o.order_status 
FROM zepto_orders AS o INNER JOIN zepto_v2 AS z 
ON o.product_id = z.product_id LIMIT 20;






