show databases;
use mavenmovies;
select * from film_actor;
-- Assignment 4 Normalisation and CTE queries

-- 1 First Normal Form (1NF>
-- Identify a table in the Sakila database that violates 1NF Explain how you would normalize it to achieve 1NF
    -- solution
-- Upon review, we can find that the film_actor table in the Sakila database violates 1NF. This table associates actors with films,
-- but each film can have multiple actors, resulting in multiple values stored in the actor_id column for a single film.
 -- in film_id table we have  film_id | actor_id
 -- The actor_id column contains multiple actor IDs separated by commas for each film, violating 1NF.
 -- Create a new table named film_actor_normalized with the following schema:
     -- film_id | actor_id
     -- Create the film_actor_normalized table
CREATE TABLE film_actor_normalized (
    film_id SMALLINT UNSIGNED NOT NULL,
    actor_id SMALLINT UNSIGNED NOT NULL,
    FOREIGN KEY (film_id) REFERENCES film (film_id),
    FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
    PRIMARY KEY (film_id, actor_id)
);

-- Move each actor ID from the actor_id column in the film_actor table to a separate row in the film_actor_normalized table, associating each actor with the corresponding film_id.
-- After normalizing the film_actor table, it would look like this: film_actor table:     
       -- film_id | actor_id
-- By splitting the actor_id column into a separate table (film_actor_normalized), we ensure that each column in the film_actor 
-- table contains only atomic values, adhering to the First Normal Form (1NF). This helps improve data integrity and simplifies data management.



-- 2 Second Normal Form (2NF>
-- Choose a table in Sakila and describe how you would determine whether it is 2NF If it violates 2NF, explain the steps to normalize it

-- ANS
/*
-- The potential violation arises from the non-prime attribute language_id being partially dependent on the primary key (film_id). 
-- If multiple films have the same language_id, it suggests a partial dependency on the composite key (film_id, language_id).

-- To normalize the table to 2NF, you could create a new table for languages, removing the dependency on the composite key. 
-- This modification ensures that the language_id is now fully dependent on its own primary key in the language table, resolving the 2NF violation in the film table.

*/


-- 3 Third Normal Form (3NF>
-- Identify a table in Sakila that violates 3NF Describe the transitive dependencies present and outline the steps to normalize the table to 3NF
-- ANS

-- Looking at the Sakila database, the film table seems to violate the Third Normal Form (3NF) due to transitive dependencies.

-- One potential transitive dependency is between original_language_id and language_id, where original_language_id depends on language_id. If we consider original_language_id as the dependent attribute and language_id as the determinant, we can identify this transitive dependency.

-- To normalize the film table to 3NF, we need to remove the transitive dependency. Here are the steps:

-- Create a New Table for Languages:
-- Create a new table named language to store language information, with language_id as the primary key.

CREATE TABLE language (
  language_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (language_id)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;


-- Update film Table:
-- Remove the original_language_id column from the film table and replace it with a foreign key constraint referencing the language table.

ALTER TABLE film
ADD CONSTRAINT fk_film_language_new
FOREIGN KEY (original_language_id)
REFERENCES language (language_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE film
DROP COLUMN original_language_id;


-- By performing these steps, we eliminate the transitive dependency in the film table and achieve 3NF normalization.


-- 4 Normalization Process>
-- Take a specific table in Sakila and guide through the process of normalizing it from the initial unnormalized form up to at least 2NFa
-- ANS

-- Let's consider the payment table from the Sakila database and guide through the process of normalizing it up to at least the Second Normal Form (2NF).

-- Initial Unnormalized Form (UNF):
-- The payment table contains information about payments made by customers, including the payment amount, payment date, customer ID, staff ID, and rental ID.

-- First Normal Form (1NF):
-- The payment table is already in 1NF because each column holds atomic values, and there are no repeating groups.

-- Second Normal Form (2NF):
-- To achieve 2NF, we need to identify any partial dependencies and remove them by splitting the table into two or more tables.

-- Analysis:
-- Looking at the payment table, we can see that the payment_amount, payment_date, customer_id, staff_id, and rental_id attributes all appear to be independent.

-- Create a New Table for Payments:
-- We'll create a new table named payment_details to store payment-specific information.

CREATE TABLE payment_details (
  payment_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  payment_amount DECIMAL(5,2) NOT NULL,
  payment_date DATETIME NOT NULL,
  PRIMARY KEY (payment_id)
) ENGINE=InnoDB DEFAULT CHARSET=UTF8MB4;


-- Modify payment Table:
-- We'll remove the payment_amount and payment_date columns from the payment table and replace them with a foreign key constraint referencing the payment_details table.

ALTER TABLE payment
ADD COLUMN payment_id SMALLINT UNSIGNED NOT NULL,
ADD CONSTRAINT fk_payment_details
FOREIGN KEY (payment_id)
REFERENCES payment_details (payment_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- Update Data:
-- We need to update the payment table to set appropriate values for the payment_id column based on the payment details.

UPDATE payment p
JOIN payment_details pd ON p.payment_amount = pd.payment_amount
AND p.payment_date = pd.payment_date
SET p.payment_id = pd.payment_id;


-- y following these steps, we've normalized the payment table up to the Second Normal Form (2NF) 
-- by removing the partial dependencies between payment attributes. Now, the payment table conforms to 2NF.


-- 5 CTE Basics>
-- Write a query using a CTE to retrieve the distinct list of actor names and the number of films they have
-- acted in from the actor and film_actor tables.
with actor_list as (
select actor.actor_id, concat(first_name," ",last_name) as Actor_name, count(distinct film_id) as totalCount
from actor join film_actor on film_actor.actor_id = actor.actor_id
 group by actor_id 
)
select actor_id, Actor_name, totalcount from actor_list;

-- 6 RecuVsive CTE>
-- Use a recursive CTE to generate a hierarchical list of categories and their subcategories from the category table in Sakila

WITH RECURSIVE CategoryHierarchy AS (
    SELECT category_id,name AS category_name,NULL AS parent_category_id,0 AS level
    FROM category WHERE parent_category_id IS NULL
    UNION ALL
    SELECT 
        c.category_id,c.name AS category_name,ch.category_id AS parent_category_id,ch.level + 1 AS level
    FROM category c JOIN CategoryHierarchy ch ON c.parent_category_id = ch.category_id
)
SELECT 
    category_id,
    category_name,
    parent_category_id,
    level
FROM 
    CategoryHierarchy
ORDER BY 
    level, category_id;
    
-- 7 CTE with Joins>
-- Create a CTE that combines information from the film and language tables to display the film title, language name, and rental rate  
select * from film;
select * from language;
with combineInformation as (
select title, name as language_name, rental_rate from film join language on language.language_id = film.language_id
) 
select title, language_name, rental_rate from combineInformation;

-- 8 CTE for Aggregation>
-- Write a query using a CTE to find the total revenue generated by each customer (sum of payments) from
-- the customer and payment tables

with totalrevenue as (
select c.customer_id, concat(first_name," ",last_name) as customer_name , sum(amount) as totalrevenue from customer c
join payment on payment.customer_id = c.customer_id group by c.customer_id
)
select customer_id, customer_name, totalrevenue from totalrevenue;

-- 9 CTE with Window Functions>
-- Utilize a CTE with a window function to rank films based on their rental duration from the film table
select * from film;
with filmRanking as (
select film_id, rental_duration ,rank() 
over(order by rental_duration desc ) as film_Rank from film
)
select film_id, rental_duration , film_Rank from  filmRanking;

-- 10 CTE and Filtering>
-- Create a CTE to list customers who have made more than two rentals, and then join this CTE with the customer
-- table to retrieve additional customer details

with customerDetails as (
select c.customer_id, count(rental_id) as rentals from customer c
join rental r on r.customer_id = c.customer_id group by c.customer_id having rentals > 2
)
select * from customerDetails cd join customer ct on ct.customer_id = cd.customer_id;

-- 11 CTE foV Date Calculations>
-- Write a query using a CTE to find the total number of rentals made each month, considering the rental_date from the rental table
select * from rental;
with totalRentalMonths as (
select  monthname(rental_date) as month_name, count(rental_id) as rental from rental
group by month_name
)
select month_name , rental from totalRentalMonths;

-- 12 CTE for Pivot Operations>
-- Use a CTE to pivot the data from the payment table to display the total payments made by each customer in
-- separate columns for different payment methods
select * from payment;
with totalPayments as (
select c.customer_id, first_name, last_name, SUM(amount) total_payment, 
'Unknown' AS payment_method from customer c 
join payment on payment.customer_id = c.customer_id group by c.customer_id
)
select customer_id, first_name, last_name, total_payment, payment_method from totalPayments;
-- payment methods data is not available in DB

-- 13 CTE and Self-Join>
-- Create a CTE to generate a report showing pairs of actors who have appeared in the same film together,
-- using the film_actor table

with actor_pairs as(select 
fa.actor_id as actor_1, ft.actor_id as actor_2,
title 
from film_actor fa
join  film_actor ft on fa.film_id = ft.film_id and fa.actor_id < ft.actor_id
join film f on fa.film_id = f.film_id
)
select actor_1,actor_2,title from actor_pairs;

-- 14 CTE for Recursive Search>
-- Implement a recursive CTE to find all employees in the staff table who report to a specific manager,considering the report_to column.
  WITH RECURSIVE employeeReports AS (
  SELECT staff_id, first_name,last_name,'unknown' AS reports_to
   FROM staff WHERE staff_id = 'manager_id'  -- Replace 'manager_id' with the ID of the specific manager
   UNION ALL
   SELECT s.staff_id,s.first_name,s.last_name,e.reports_to
   FROM staff s JOIN employeeReports e ON s.staff_id = e.staff_id
 )
 SELECT staff_id,first_name,last_name,reports_to
 FROM employeeReports;
-- NO MANGER DATA AND REPORTS TO DATA AVAILABEL















