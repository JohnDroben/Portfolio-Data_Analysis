--1. Запрос "Топ-3 аптеки" - Вывести топ 3 аптеки по объему продаж

SELECT 
    pharmacy_name,
    SUM(price * count) as total_sales
FROM pharma_orders
GROUP BY pharmacy_name
ORDER BY total_sales DESC
LIMIT 3;