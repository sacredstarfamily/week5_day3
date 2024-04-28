SELECT *
FROM film;

SELECT *
FROM actor;


SELECT *
FROM film_actor;


-- Join between the film and film_actor table
SELECT *
FROM film_actor fa
JOIN film f
ON f.film_id = fa.film_id;

-- Join between the actor and film_actor table
SELECT *
FROM film_actor fa
JOIN actor a
ON a.actor_id = fa.actor_id;


-- Multi Join
SELECT a.first_name, a.last_name, a.actor_id, fa.actor_id, fa.film_id, f.film_id, f.title, f.description
FROM actor a
JOIN film_actor fa 
ON a.actor_id = fa.actor_id 
JOIN film f
ON f.film_id = fa.film_id;


-- Display Customer name and film that they rented -- customer -> rental -> inventory -> film
SELECT c.first_name, c.last_name, c.customer_id, r.customer_id, r.rental_id, r.inventory_id, i.inventory_id, i.film_id, f.film_id, f.title
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
JOIN inventory i 
ON r.inventory_id = i.inventory_id
JOIN film f
ON i.film_id = f.film_id;

-- WE can still all of the other Fun DQL clauses
SELECT c.first_name, c.last_name, c.customer_id, r.customer_id, r.rental_id, r.inventory_id, i.inventory_id, i.film_id, f.film_id, f.title
FROM customer c
JOIN rental r
ON c.customer_id = r.customer_id
JOIN inventory i 
ON r.inventory_id = i.inventory_id
JOIN film f
ON i.film_id = f.film_id
WHERE c.first_name LIKE 'R%'
ORDER BY f.title
LIMIT 10
OFFSET 5;


-- Subqueries!!!
-- Subquery - A query within a query

-- Example: Which films have exactly 12 actors in it

-- Step 1. Find the film_ids from the film_actor table that have a count of 12
SELECT film_id, COUNT(*)
FROM film_actor
GROUP BY film_id
HAVING COUNT(*) = 12;

--film_id|
-- ------+
--    529|
--    802|
--     34|
--    892|
--    414|
--    517|

-- Step 2. Query the film table for films that match those IDS
SELECT *
FROM film
WHERE film_id IN (
	529,
	802,
	34,
	892,
	414,
	517
);


-- Put the two steps together into a subquery
-- The query that we want to execute first is the subquery
-- ** Subquery must return only ONE column **      *unless used in a FROM clause
SELECT *
FROM film
WHERE film_id IN (
	SELECT film_id
	FROM film_actor
	GROUP BY film_id
	HAVING COUNT(*) = 12
);


SELECT *
FROM film
JOIN (
	SELECT film_id
	FROM film_actor
	GROUP BY film_id
	HAVING COUNT(*) = 12
) AS temp_table
ON temp_table.film_id = film.film_id;


-- Subquery vs Join
-- Which employee has sold the most rentals (use the rental table)
SELECT *
FROM staff
WHERE staff_id = (
	SELECT staff_id
	FROM rental
	GROUP BY staff_id
	ORDER BY COUNT(*) DESC
	LIMIT 1
);

SELECT s.staff_id, first_name, last_name, COUNT(*)
FROM rental r
JOIN staff s
ON r.staff_id = s.staff_id 
GROUP BY s.staff_id
ORDER BY COUNT(*) DESC;


-- Use subqueries for calculations
-- Find all of the payments that are more than the average payment

SELECT *
FROM payment p 
WHERE amount > (
	SELECT AVG(amount)
	FROM payment
);



-- Subqueries with the FROM clause
-- *Subquery in a FROM must be in parenteses - alias optional (as of Postgresql 16)*

-- Find the average number of rentals per customer

-- Step 1. Get the count for each customer
SELECT customer_id, COUNT(*) AS num_rentals
FROM rental
GROUP BY customer_id;

-- Step 2. Use the temp table from step 1 as the table to find the average via subquery
SELECT AVG(num_rentals)
FROM (
	SELECT customer_id, COUNT(*) AS num_rentals
	FROM rental
	GROUP BY customer_id
) AS customer_rental_totals;


-- Other DQL clauses still work
SELECT *
FROM (
	SELECT customer_id, COUNT(*) AS num_rentals
	FROM rental
	GROUP BY customer_id
)
WHERE num_rentals > 40
ORDER BY num_rentals;


-- Subqueries can also be used in DML statements

-- setup -> add loyalty_member column with Boolean datatype
ALTER TABLE customer
ADD COLUMN loyalty_member BOOLEAN;

-- Set the loyalty_member column to False for all customers
UPDATE customer
SET loyalty_member = FALSE;

SELECT *
FROM customer;

-- Update the customer table and set any customer who has over 25 rentals to be a loyalty_member

-- Step 1. Find all the customer IDs of those customer who have rented 25+ films
SELECT customer_id
FROM rental
GROUP BY customer_id
HAVING COUNT(*) >= 25;


-- Step 2. Make an update statement and update all customers with those IDs
UPDATE customer 
SET loyalty_member = TRUE
WHERE customer_id IN (
	SELECT customer_id
	FROM rental
	GROUP BY customer_id
	HAVING COUNT(*) >= 25
);


SELECT loyalty_member, COUNT(*)
FROM customer
GROUP BY loyalty_member;
-- quuestion 1 homework
--1. List all customers with their address who live in Texas (use JOINs)
-- answer daniel alfredo dorothy thelma leonard
SELECT c.customer_id,c.first_name ,c.first_name, a.address, a.district 
FROM customer c
JOIN address a ON c.customer_id = a.address_id 
WHERE a.district  = 'Texas';

-- question 2 homework 
--2. List all payments of more than $7.00 with the customer’s first and last name
-- answer 1406 customer payments over 7$
SELECT c.first_name, c.last_name, p.amount
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
WHERE p.amount > 7.00;

-- question 3 homework
--3. Show all customer names who have made over $175 in payments (use
subqueries)
-- answer karl, rhonda, clarra, eleanor, marion, tommy
SELECT c.first_name, c.last_name
FROM customer c
WHERE customer_id IN (
    SELECT customer_id
    FROM payment p
    GROUP BY customer_id
    HAVING SUM(amount) > 175
);


SELECT *
FROM country c ;

SELECT  * FROM address a ;
--question 4 homework
--4. List all customers that live in Argentina (use multiple joins)
-- 597 people
SELECT DISTINCT c.customer_id, c.first_name, c.last_name , a.address,co.country 
FROM customer c
JOIN address a ON c.customer_id = a.address_id 
JOIN city c2 ON	a.city_id  = a.city_id
JOIN country co ON c2.country_id  = co.country_id
WHERE co.country = 'Argentina';

-- question 5 homework
-- 5. Show all the film categories with their count in descending order
--answer 	
-- 1    Action	2006-02-15 09:46:27.000
-- 2	Animation	2006-02-15 09:46:27.000
-- 3	Children	2006-02-15 09:46:27.000
-- 4	Classics	2006-02-15 09:46:27.000
-- 5	Comedy	2006-02-15 09:46:27.000
-- 6	Documentary	2006-02-15 09:46:27.000
-- 7	Drama	2006-02-15 09:46:27.000
-- 8	Family	2006-02-15 09:46:27.000
-- 9	Foreign	2006-02-15 09:46:27.000
-- 10	Games	2006-02-15 09:46:27.000
-- 11	Horror	2006-02-15 09:46:27.000
-- 12	Music	2006-02-15 09:46:27.000
-- 13	New	2006-02-15 09:46:27.000
-- 14	Sci-Fi	2006-02-15 09:46:27.000
-- 15	Sports	2006-02-15 09:46:27.000
-- 16	Travel	2006-02-15 09:46:27.000
SELECT  *
FROM category c ;
SELECT c.name, COUNT(*) AS category_count
FROM category c
GROUP BY c.name
ORDER BY category_count DESC;

-- question 6 homework
-- 6. What film had the most actors in it (show film info)?
-- aanswer
SELECT *
FROM film_actor fa;
SELECT  *
FROM film f;
SELECT f.film_id, f.title, COUNT(*) AS actor_count
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id, f.title
ORDER BY actor_count DESC
LIMIT 1;
-- question 7
-- 7. Which actor has been in the least movies?
-- answer emmily
SELECT *
FROM actor a ;
SELECT a.actor_id, a.first_name, COUNT(*) AS movie_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name
ORDER BY movie_count ASC
LIMIT 1;
-- question 8
-- 8. Which country has the most cities?
-- answer
SELECT * 
FROM country c ;
SELECT *
FROM city c;
SELECT *
FROM address a ;
SELECT co.country, COUNT(*) AS city_count
FROM country co
JOIN address a ON co.country = a.district 
JOIN city c ON c.city_id = a.city_id 
GROUP BY co.country;
ORDER BY city_count DESC
LIMIT 1;

-- question 9
-- 9. List the actors who have been in between 20 and 25 films.
/*
--answer 
Jessica
Christian
Michael
Bette
Gene
Christopher
Ellen
Charlize
Sylvester
Cuba
Nick
Burt
Frances
Meryl
Nick
Ben
Parker
Tim
Spencer
Tom
Burt
Cameron
Kevin
Salma
Julia
Debbie
Milla
Dan
Susan
Lisa
Fay
*/
SELECT a.actor_id, a.first_name, COUNT(*) AS movie_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
GROUP BY a.actor_id, a.first_name
HAVING COUNT(*) BETWEEN 20 AND 25;




