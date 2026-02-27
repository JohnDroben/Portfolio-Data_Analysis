-- 4. -- Запрос "Аптеки от 1.8 млн оборота" - Вывести аптеки, имеющие более 18000 оборота
SELECT 
    pharmacy_name,
    SUM(price * count) as total_revenue
FROM pharma_orders
GROUP BY pharmacy_name
HAVING SUM(price * count) > 18000
ORDER BY total_revenue DESC;