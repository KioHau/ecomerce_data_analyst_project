--Tổng số đơn hàng
SELECT DISTINCT COUNT(od.order_id) AS count_total_order
FROM dbo.olist_orders_dataset od
--Tổng revenue là bao nhiêu
SELECT ROUND(SUM(oi.price),2) AS total_price
FROM dbo.olist_order_items_dataset oi
--Doanh thu theo tháng 
SELECT YEAR(od.order_purchase_timestamp) as year_price,MONTH(od.order_purchase_timestamp) as month_price, ROUND(SUM(oi.price),2) AS total_price_of_month
FROM dbo.olist_orders_dataset od LEFT JOIN dbo.olist_order_items_dataset oi
ON od.order_id = oi.order_id
WHERE od.order_status != 'canceled' AND od.order_status != 'unavailable'
AND YEAR(od.order_purchase_timestamp) = 2018
GROUP BY MONTH(od.order_purchase_timestamp), YEAR(od.order_purchase_timestamp);
--MoM Growth
WITH t AS (
SELECT YEAR(od.order_purchase_timestamp) as year, MONTH(od.order_purchase_timestamp) as month, ROUND(SUM(oi.price),2) AS total_price_of_month
FROM dbo.olist_orders_dataset od LEFT JOIN dbo.olist_order_items_dataset oi
ON od.order_id = oi.order_id
WHERE od.order_status != 'canceled' AND od.order_status != 'unavailable'
GROUP BY MONTH(od.order_purchase_timestamp), YEAR(od.order_purchase_timestamp))

SELECT month, s.total_price_of_month, prev_price, (s.total_price_of_month - s.prev_price) * 1.0/s.prev_price AS growwth_rate
FROM(
SELECT t.month, t.year, t.total_price_of_month, LAG(t.total_price_of_month) OVER (ORDER BY t.month, t.year) AS prev_price
FROM t) AS s