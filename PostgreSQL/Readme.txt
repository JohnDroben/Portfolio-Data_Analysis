
*ЗАДАНИЕ*
 -------------
 1. Запрос "Топ-3 аптеки"

   a. Вывести топ 3 аптеки по объему продаж (GROUP BY, LIMIT)

2. Запрос "Топ-3 лекарства"

   a.  Вывести топ 3 лекарства по объему продаж

3. Запрос "Аптеки от 1.8 млн оборота"

    a. Вывести аптеки, имеющие более 1.8 млн оборота (HAVING)

4. Запрос "Накопленная сумма продаж по каждой аптеке" (OVER)

5. Запрос "Количество клиентов в аптеках"

    a. Соединить таблицы заказов и клиентов (JOIN)

    b. Посчитать кол-во уникальных клиентов на каждую аптеку (DISTINCT)

    c. Отсортировать аптеки по убыванию кол-ва клиентов (ORDER BY)

6. Запрос "Лучшие клиенты"

    a. Соединить таблицы заказов и клиентов (JOIN)

    b. Посчитать тотал сумму заказов для каждого клиента

    c. Проранжировать клиентов по убыванию суммы заказа (row_number)

    d. Оставить топ-10 клиентов

7. Запрос "Накопленная сумма по клиентам"

    a. Соединить таблицы заказов и клиентов

    b. Соединить ФИО в одно поле

    c. Рассчитать накопленную сумму по каждому клиенту

8. Запрос "Самые частые клиенты аптек Горздрав и Здравсити"

    a Сделать две временные таблицы: для аптеки горздрав и здравсити (WITH)

    b. Внутри каждой соединить таблицы заказов и клиентов (JOIN)

    c. Внутри каждой привести данные в формат "клиент - кол-во заказов в аптеке"

    d. Внутри каждой оставить топ 10 клиентов каждой аптеки

    e. Объединить клиентов с помощью UNION .
----------------

**Для выполнения задания был подготовлен ряд запросов с использованием ключевых технологий и методов,
 использованных в решении:**
-------
*GROUP BY* + агрегатные функции - для анализа данных по группам

*HAVING* - фильтрация результатов агрегации

Оконные функции (*OVER*) - для расчетов накопленных сумм и ранжирования

*JOIN* - объединение таблиц для комплексного анализа

*CTE (WITH)* - создание временных таблиц для сложных запросов

*ROW_NUMBER()* - нумерация строк для определения топ-позиций

*UNION ALL* - объединение результатов из разных выборок

*CONCAT()* - форматирование строковых данных
-------------
Данные запросы демонстрируют навыки анализа фармацевтического бизнеса, включая оценку эффективности аптек,
 анализ продаж лекарств, сегментацию клиентов и изучение покупательского поведения.

*ЗАПРОСЫ*

-- =============================================
-- ЗАДАЧА 1: ТОП-3 АПТЕКИ ПО ОБЪЕМУ ПРОДАЖ
-- Анализ эффективности аптек по общему доходу
-- Используются: GROUP BY, агрегатные функции, LIMIT
-- =============================================
SELECT 
    pharmacy_name AS "Аптека",
    SUM(price * count) AS "Общий объем продаж, руб",
    COUNT(*) AS "Количество заказов"
FROM pharma_orders
GROUP BY pharmacy_name
ORDER BY "Общий объем продаж, руб" DESC
LIMIT 3;

-- =============================================
-- ЗАДАЧА 2: ТОП-3 ЛЕКАРСТВА ПО ОБЪЕМУ ПРОДАЖ
-- Анализ популярности и доходности лекарственных препаратов
-- Используются: GROUP BY, агрегатные функции, LIMIT
-- =============================================
SELECT 
    drug AS "Лекарство",
    SUM(price * count) AS "Объем продаж, руб",
    SUM(count) AS "Количество проданных упаковок",
    ROUND(AVG(price), 2) AS "Средняя цена за упаковку"
FROM pharma_orders
GROUP BY drug
ORDER BY "Объем продаж, руб" DESC
LIMIT 3;

-- =============================================
-- ЗАДАЧА 3: АПТЕКИ С ОБОРОТОМ СВЫШЕ 1.8 МЛН РУБ
-- Фильтрация высокодоходных аптек
-- Используются: GROUP BY, HAVING для фильтрации после агрегации
-- =============================================
SELECT 
    pharmacy_name AS "Аптека",
    SUM(price * count) AS "Оборот, руб",
    COUNT(DISTINCT customer_id) AS "Количество клиентов"
FROM pharma_orders
GROUP BY pharmacy_name
HAVING SUM(price * count) > 1800000
ORDER BY "Оборот, руб" DESC;

-- =============================================
-- ЗАДАЧА 4: НАКОПЛЕННАЯ СУММА ПРОДАЖ ПО АПТЕКАМ
-- Анализ динамики продаж с использованием оконных функций
-- Используются: OVER(), PARTITION BY, ORDER BY для кумулятивной суммы
-- =============================================
SELECT 
    pharmacy_name AS "Аптека",
    report_date AS "Дата",
    SUM(price * count) AS "Дневная выручка, руб",
    SUM(SUM(price * count)) OVER (
        PARTITION BY pharmacy_name 
        ORDER BY report_date
    ) AS "Накопленная выручка, руб"
FROM pharma_orders
GROUP BY pharmacy_name, report_date
ORDER BY pharmacy_name, report_date;

-- =============================================
-- ЗАДАЧА 5: КОЛИЧЕСТВО КЛИЕНТОВ В АПТЕКАХ
-- Анализ клиентской базы каждой аптеки
-- Используются: JOIN, COUNT(DISTINCT), ORDER BY
-- =============================================
SELECT 
    po.pharmacy_name AS "Аптека",
    COUNT(DISTINCT po.customer_id) AS "Количество уникальных клиентов",
    COUNT(*) AS "Общее количество заказов"
FROM pharma_orders po
JOIN customers c ON po.customer_id = c.customer_id
GROUP BY po.pharmacy_name
ORDER BY "Количество уникальных клиентов" DESC;

-- =============================================
-- ЗАДАЧА 6: ЛУЧШИЕ КЛИЕНТЫ (ТОП-10)
-- Выявление наиболее ценных клиентов по сумме покупок
-- Используются: JOIN, агрегатные функции, ROW_NUMBER(), CTE
-- =============================================
WITH customer_totals AS (
    SELECT 
        c.customer_id AS "ID клиента",
        CONCAT(c.last_name, ' ', c.first_name, ' ', c.second_name) AS "ФИО клиента",
        SUM(po.price * po.count) AS "Общая сумма покупок, руб",
        COUNT(*) AS "Количество заказов",
        ROW_NUMBER() OVER (ORDER BY SUM(po.price * po.count) DESC) AS "Ранг"
    FROM pharma_orders po
    JOIN customers c ON po.customer_id = c.customer_id
    GROUP BY c.customer_id, c.last_name, c.first_name, c.second_name
)
SELECT 
    "ID клиента",
    "ФИО клиента", 
    "Общая сумма покупок, руб",
    "Количество заказов",
    "Ранг"
FROM customer_totals
WHERE "Ранг" <= 10
ORDER BY "Ранг";

-- =============================================
-- ЗАДАЧА 7: НАКОПЛЕННАЯ СУММА ПО КЛИЕНТАМ
-- Анализ покупательского поведения клиентов во времени
-- Используются: JOIN, CONCAT(), оконные функции
-- =============================================
SELECT 
    c.customer_id AS "ID клиента",
    CONCAT(c.last_name, ' ', c.first_name, ' ', c.second_name) AS "ФИО клиента",
    po.report_date AS "Дата заказа",
    po.drug AS "Лекарство",
    po.price * po.count AS "Сумма заказа, руб",
    SUM(po.price * po.count) OVER (
        PARTITION BY c.customer_id 
        ORDER BY po.report_date
    ) AS "Накопленная сумма, руб",
    COUNT(*) OVER (
        PARTITION BY c.customer_id 
        ORDER BY po.report_date
    ) AS "Накопленное количество заказов"
FROM pharma_orders po
JOIN customers c ON po.customer_id = c.customer_id
ORDER BY c.customer_id, po.report_date;

-- =============================================
-- ЗАДАЧА 8: САМЫЕ ЧАСТЫЕ КЛИЕНТЫ АПТЕК ГОРЗДРАВ И ЗДРАВСИТИ
-- Сравнительный анализ лояльности клиентов двух конкурирующих аптек
-- Используются: WITH (CTE), JOIN, ROW_NUMBER(), UNION ALL
-- =============================================
WITH 
-- Клиенты аптеки Горздрав с ранжированием по количеству заказов
gorzdrav_customers AS (
    SELECT 
        c.customer_id,
        CONCAT(c.last_name, ' ', c.first_name, ' ', c.second_name) AS full_name,
        COUNT(*) AS order_count,
        SUM(po.price * po.count) AS total_spent,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM pharma_orders po
    JOIN customers c ON po.customer_id = c.customer_id
    WHERE po.pharmacy_name = 'Горздрав'
    GROUP BY c.customer_id, c.last_name, c.first_name, c.second_name
),
-- Клиенты аптеки Здравсити с ранжированием по количеству заказов
zdravsiti_customers AS (
    SELECT 
        c.customer_id,
        CONCAT(c.last_name, ' ', c.first_name, ' ', c.second_name) AS full_name,
        COUNT(*) AS order_count,
        SUM(po.price * po.count) AS total_spent,
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS rank
    FROM pharma_orders po
    JOIN customers c ON po.customer_id = c.customer_id
    WHERE po.pharmacy_name = 'Здравсити'
    GROUP BY c.customer_id, c.last_name, c.first_name, c.second_name
)
-- Объединение результатов с указанием принадлежности к аптеке
SELECT 
    'Горздрав' AS pharmacy_name,
    full_name AS "ФИО клиента",
    order_count AS "Количество заказов",
    total_spent AS "Общая сумма покупок, руб",
    rank AS "Ранг"
FROM gorzdrav_customers
WHERE rank <= 10

UNION ALL

SELECT 
    'Здравсити' AS pharmacy_name,
    full_name AS "ФИО клиента",
    order_count AS "Количество заказов",
    total_spent AS "Общая сумма покупок, руб",
    rank AS "Ранг"
FROM zdravsiti_customers
WHERE rank <= 10
ORDER BY pharmacy_name, rank;