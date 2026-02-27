-- 8. -- Запрос "Самые частые клиенты аптек Горздрав и Здравсити"
WITH gorzdrav_customers AS (
    SELECT 
        c.customer_id,
        CONCAT(c.last_name, ' ', c.first_name, ' ', c.second_name) as full_name,
        COUNT(*) as order_count,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as rank
    FROM pharma_orders po
    JOIN customers c ON po.customer_id = c.customer_id
    WHERE po.pharmacy_name = 'Горздрав'
    GROUP BY c.customer_id, c.last_name, c.first_name, c.second_name
),
zdravsiti_customers AS (
    SELECT 
        c.customer_id,
        CONCAT(c.last_name, ' ', c.first_name, ' ', c.second_name) as full_name,
        COUNT(*) as order_count,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as rank
    FROM pharma_orders po
    JOIN customers c ON po.customer_id = c.customer_id
    WHERE po.pharmacy_name = 'Здравсити'
    GROUP BY c.customer_id, c.last_name, c.first_name, c.second_name
)
SELECT 
    'Горздрав' as pharmacy,
    full_name,
    order_count,
    rank
FROM gorzdrav_customers
WHERE rank <= 10

UNION ALL

SELECT 
    'Здравсити' as pharmacy,
    full_name,
    order_count,
    rank
FROM zdravsiti_customers
WHERE rank <= 10
ORDER BY pharmacy, rank;