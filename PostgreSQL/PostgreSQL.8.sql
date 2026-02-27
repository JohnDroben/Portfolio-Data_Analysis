-- 7. -- Запрос "Накопленная сумма по клиентам"

SELECT 
    c.customer_id,
    CONCAT(c.last_name, ' ', c.first_name, ' ', c.second_name) as full_name,
    po.report_date,
    po.price * po.count as order_amount,
    SUM(po.price * po.count) OVER (PARTITION BY c.customer_id ORDER BY po.report_date) as cumulative_amount
FROM pharma_orders po
JOIN customers c ON po.customer_id = c.customer_id
ORDER BY c.customer_id, po.report_date;