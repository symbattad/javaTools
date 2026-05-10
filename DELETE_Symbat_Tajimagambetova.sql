DELETE FROM rental
WHERE inventory_id IN (
    SELECT inventory_id
    FROM inventory
    WHERE film_id = (
        SELECT film_id FROM film WHERE title = 'Interstellar'
    )
);

-- Шаг 1.2: Удаляем сам фильм из inventory
DELETE FROM inventory
WHERE film_id = (
    SELECT film_id FROM film WHERE title = 'Interstellar'
);



-- Шаг 2.1: Удаляем payment записи нашего клиента
DELETE FROM payment
WHERE customer_id = (
    SELECT customer_id FROM customer WHERE first_name = 'Estiyar'
);

-- Шаг 2.2: Удаляем rental записи нашего клиента
DELETE FROM rental
WHERE customer_id = (
    SELECT customer_id FROM customer WHERE first_name = 'Estiyar'
);


