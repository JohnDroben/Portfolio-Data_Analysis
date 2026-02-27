-- 5. -- Запрос "Количество клиентов в аптеках"
SELECT 
    po.pharmacy_name,
    COUNT(DISTINCT po.customer_id) as unique_customers_count
FROM pharma_orders po
JOIN customers c ON po.customer_id = c.customer_id
GROUP BY po.pharmacy_name
ORDER BY unique_customers_count DESC;
