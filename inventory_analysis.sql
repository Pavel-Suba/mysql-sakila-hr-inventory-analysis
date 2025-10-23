USE sakila10_155;

SELECT
    s.first_name,
    s.last_name,
    COUNT(p.payment_id) AS total_payments,
    SUM(p.amount) AS total_sales_amount
FROM sakila10_155.staff AS s
JOIN sakila10_155.payment AS p ON s.staff_id = p.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY total_sales_amount DESC;

-- Krok 1: Vytvoříme CTE pro výpočet tržeb na úrovni filmu (Zde se propojují platby a inventář)
WITH FilmSales AS (
    SELECT
        i.film_id,
        SUM(p.amount) AS total_revenue
    FROM sakila10_155.payment AS p
    JOIN sakila10_155.rental AS r ON p.rental_id = r.rental_id
    JOIN sakila10_155.inventory AS i ON r.inventory_id = i.inventory_id
    GROUP BY i.film_id
)
-- Krok 2: Hlavní dotaz - Spojíme tržby s kategoriemi a sečteme je
SELECT
    c.name AS category_name,
    SUM(fs.total_revenue) AS category_revenue
FROM sakila10_155.category AS c
JOIN sakila10_155.film_category AS fc ON c.category_id = fc.category_id
JOIN FilmSales AS fs ON fc.film_id = fs.film_id
GROUP BY c.name
ORDER BY category_revenue DESC
LIMIT 5;


SELECT
    f.title,
    f.release_year
FROM sakila10_155.film AS f
WHERE f.film_id NOT IN (
    -- Poddotaz: Seznam všech film_id, které se objevily v inventáři A BYLY PŮJČENY
    SELECT DISTINCT i.film_id
    FROM sakila10_155.inventory AS i
    JOIN sakila10_155.rental AS r ON i.inventory_id = r.inventory_id
);