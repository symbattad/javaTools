
UPDATE film
SET
    rental_duration = 21,
    rental_rate = 9.99
WHERE title = 'Interstellar';

UPDATE customer
SET
    first_name  = 'Estiyar',
    last_name   = 'Akhmetov',
    email       = 'estiyar.akhmetov@email.com',
    address_id  = (SELECT address_id FROM address LIMIT 1),
    create_date = CURRENT_DATE,
    active      = 1
WHERE customer_id = (
    SELECT c.customer_id
    FROM customer c
    JOIN rental  r ON r.customer_id = c.customer_id
    JOIN payment p ON p.customer_id = c.customer_id
    GROUP BY c.customer_id
    HAVING COUNT(DISTINCT r.rental_id)  >= 10
       AND COUNT(DISTINCT p.payment_id) >= 10
    ORDER BY c.customer_id
    LIMIT 1
);

SELECT customer_id, first_name, last_name, email, address_id, create_date
FROM customer
WHERE first_name = 'Estiyar';