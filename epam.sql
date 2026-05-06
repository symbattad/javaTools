

-- ============================================================
-- TASK 1: Which staff members made the highest revenue
--         for each store for the year 2017?
-- ============================================================

SELECT
    store_id,
    staff_id,
    first_name,
    last_name,
    total_revenue
FROM (
    SELECT
        s.store_id,
        s.staff_id,
        st.first_name,
        st.last_name,
        SUM(p.amount) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY s.store_id ORDER BY SUM(p.amount) DESC) AS rn
    FROM payment p
    JOIN staff st ON p.staff_id = st.staff_id
    JOIN store s ON st.store_id = s.store_id
    WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
    GROUP BY s.store_id, s.staff_id, st.first_name, st.last_name
) ranked
WHERE rn = 1;


-- Solution 2: Using subquery with MAX
SELECT
    s.store_id,
    st.staff_id,
    st.first_name,
    st.last_name,
    SUM(p.amount) AS total_revenue
FROM payment p
JOIN staff st ON p.staff_id = st.staff_id
JOIN store s ON st.store_id = s.store_id
WHERE EXTRACT(YEAR FROM p.payment_date) = 2017
GROUP BY s.store_id, st.staff_id, st.first_name, st.last_name
HAVING SUM(p.amount) = (
    SELECT MAX(sub.total)
    FROM (
        SELECT
            st2.store_id,
            SUM(p2.amount) AS total
        FROM payment p2
        JOIN staff st2 ON p2.staff_id = st2.staff_id
        WHERE EXTRACT(YEAR FROM p2.payment_date) = 2017
        GROUP BY st2.store_id, p2.staff_id
    ) sub
    WHERE sub.store_id = s.store_id
)
ORDER BY s.store_id;


--
-- TASK 2: Which 5 movies were rented the most, and what is
--         the expected age of the audience?

-- Solution 1: JOIN chain with LIMIT
SELECT
    f.title,
    COUNT(r.rental_id) AS rental_count,
    f.rating,
    CASE f.rating
        WHEN 'G'     THEN 'All ages'
        WHEN 'PG'    THEN '8+'
        WHEN 'PG-13' THEN '13+'
        WHEN 'R'     THEN '17+'
        WHEN 'NC-17' THEN '18+'
        ELSE 'Unknown'
    END AS expected_audience_age
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY f.film_id, f.title, f.rating
ORDER BY rental_count DESC
LIMIT 5;


-- Solution 2: Using CTE
WITH film_rentals AS (
    SELECT
        f.film_id,
        f.title,
        f.rating,
        COUNT(r.rental_id) AS rental_count
    FROM film f
    JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY f.film_id, f.title, f.rating
)
SELECT
    title,
    rental_count,
    rating,
    CASE rating
        WHEN 'G'     THEN 'All ages'
        WHEN 'PG'    THEN '8+'
        WHEN 'PG-13' THEN '13+'
        WHEN 'R'     THEN '17+'
        WHEN 'NC-17' THEN '18+'
        ELSE 'Unknown'
    END AS expected_audience_age
FROM film_rentals
ORDER BY rental_count DESC
LIMIT 5;


-- TASK 3: Which actors/actresses had the longest gap
--         between their films (inactive for the longest time)?


-- Solution 1: Using LAG() window function to find max gap per actor
WITH actor_film_years AS (
    SELECT
        a.actor_id,
        a.first_name,
        a.last_name,
        f.release_year,
        LAG(f.release_year) OVER (
            PARTITION BY a.actor_id ORDER BY f.release_year
        ) AS prev_year
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film f ON fa.film_id = f.film_id
),
actor_gaps AS (
    SELECT
        actor_id,
        first_name,
        last_name,
        MAX(release_year - prev_year) AS max_gap
    FROM actor_film_years
    WHERE prev_year IS NOT NULL
    GROUP BY actor_id, first_name, last_name
)
SELECT
    first_name,
    last_name,
    max_gap AS longest_inactive_years
FROM actor_gaps
ORDER BY max_gap DESC
LIMIT 5;


-- Solution 2: Self-join to find gaps between consecutive film years
WITH actor_years AS (
    SELECT DISTINCT
        a.actor_id,
        a.first_name,
        a.last_name,
        f.release_year
    FROM actor a
    JOIN film_actor fa ON a.actor_id = fa.actor_id
    JOIN film f ON fa.film_id = f.film_id
),
actor_gaps AS (
    SELECT
        ay1.actor_id,
        ay1.first_name,
        ay1.last_name,
        MAX(ay2.release_year - ay1.release_year) AS max_gap
    FROM actor_years ay1
    JOIN actor_years ay2
        ON ay1.actor_id = ay2.actor_id
        AND ay2.release_year > ay1.release_year
        AND NOT EXISTS (
            SELECT 1 FROM actor_years ay3
            WHERE ay3.actor_id = ay1.actor_id
              AND ay3.release_year > ay1.release_year
              AND ay3.release_year < ay2.release_year
        )
    GROUP BY ay1.actor_id, ay1.first_name, ay1.last_name
)
SELECT
    first_name,
    last_name,
    max_gap AS longest_inactive_years
FROM actor_gaps
ORDER BY max_gap DESC
LIMIT 5;