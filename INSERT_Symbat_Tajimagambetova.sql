-- 1. Добавляем фильм в таблицу film
INSERT INTO film (title, description, release_year, language_id, rental_duration, rental_rate, rating)
VALUES (
    'Interstellar',
    'A team of explorers travel through a wormhole in space in an attempt to ensure humanity''s survival.',
    2014,
    1,
    14,
    4.99,
    'PG-13'
);

-- 2. Добавляем актёров в таблицу actor
INSERT INTO actor (first_name, last_name)
VALUES ('Matthew', 'McConaughey');

INSERT INTO actor (first_name, last_name)
VALUES ('Anne', 'Hathaway');

INSERT INTO actor (first_name, last_name)
VALUES ('Jessica', 'Chastain');

-- 3. Связываем актёров с фильмом в film_actor
-- (film_id и actor_id берём из того, что только что вставили)
INSERT INTO film_actor (actor_id, film_id)
VALUES (
    (SELECT actor_id FROM actor WHERE first_name = 'Matthew' AND last_name = 'McConaughey'),
    (SELECT film_id FROM film WHERE title = 'Interstellar')
);

INSERT INTO film_actor (actor_id, film_id)
VALUES (
    (SELECT actor_id FROM actor WHERE first_name = 'Anne' AND last_name = 'Hathaway'),
    (SELECT film_id FROM film WHERE title = 'Interstellar')
);

INSERT INTO film_actor (actor_id, film_id)
VALUES (
    (SELECT actor_id FROM actor WHERE first_name = 'Jessica' AND last_name = 'Chastain'),
    (SELECT film_id FROM film WHERE title = 'Interstellar')
);

-- 4. Добавляем фильм в инвентарь магазина (store_id = 1)
INSERT INTO inventory (film_id, store_id)
VALUES (
    (SELECT film_id FROM film WHERE title = 'Interstellar'),
    1
);