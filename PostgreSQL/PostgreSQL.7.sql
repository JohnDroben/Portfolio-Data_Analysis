-- 6. -- Запрос "Лучшие клиенты"

WITH customer_totals AS (
    SELECT 
        c.customer_id,
        CONCAT(c.last_name, ' ', c.first_name, ' ', c.second_name) as full_name,
        SUM(po.price * po.count) as total_spent,
        ROW_NUMBER() OVER (ORDER BY SUM(po.price * po.count) DESC) as rank
    FROM pharma_orders po
    JOIN customers c ON po.customer_id = c.customer_id
    GROUP BY c.customer_id, c.last_name, c.first_name, c.second_name
)
SELECT 
    customer_id,
    full_name,
    total_spent,
    rank
FROM customer_totals
WHERE rank <= 10
ORDER BY rank;