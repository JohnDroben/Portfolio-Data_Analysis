-- 2.Запрос "Топ-3 лекарства" - Вывести топ 3 лекарства по объему продаж


SELECT 
    drug as medicine_name,
    SUM(count) as total_quantity,
    SUM(price * count) as total_sales
FROM pharma_orders
GROUP BY drug
ORDER BY total_sales DESC
LIMIT 3;