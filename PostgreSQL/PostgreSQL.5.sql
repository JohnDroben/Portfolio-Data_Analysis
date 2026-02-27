-- 4. -- Запрос "Накопленная сумма продаж по каждой аптеке"
SELECT 
    pharmacy_name,
    report_date,
    SUM(price * count) as daily_sales,
    SUM(SUM(price * count)) OVER (PARTITION BY pharmacy_name ORDER BY report_date) as cumulative_sales
FROM pharma_orders
GROUP BY pharmacy_name, report_date
ORDER BY pharmacy_name, report_date;