-- 1a. Display the first and last names of all actors from the table `actor`.
Select first_name, last_name from sakila.actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
Select concat(upper(first_name), ' ',  upper(last_name) )Actor_Name from sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
Select actor_id, first_name, last_name  from sakila.actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
Select  actor_id, first_name, last_name from sakila.actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select actor_id, first_name, last_name from sakila.actor where last_name like '%LI%' order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from sakila.country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. Hint: you will need to specify the data type.
 ALTER TABLE `sakila`.`actor` 
 ADD COLUMN `middle_name` VARCHAR(45) NULL AFTER `first_name`;

--  3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.
ALTER TABLE `sakila`.`actor` 
CHANGE COLUMN `middle_name` `middle_name` BLOB NULL DEFAULT NULL ;

--  3c. Now delete the `middle_name` column.
ALTER TABLE `sakila`.`actor` 
DROP COLUMN `middle_name`;

-- 4a. List the last names of actors, as well as how many actors have that last name.
Select last_name, count(*)  last_name_count from sakila.actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
Select last_name, count(*)  last_name_count from sakila.actor  group by last_name having count(*) >= 2;

-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. 
-- Write a query to fix the record.
Select * from sakila.actor where last_name = 'Williams' and first_name = 'Groucho';

update sakila.actor set first_name = 'HARPO' where actor_id = 172;

 -- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, 
 -- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be 
-- with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)

select * from sakila.actor where actor_id = 172;

update sakila.actor set first_name = CASE WHEN  first_name = 'HARPO' THEN  'GROUCHO' ELSE 'MUCHO GROUCHO' END where actor_id = 172;

 -- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
--  Hint: <https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html>

show create table  sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select s.first_name, s.last_name, a.address  from sakila.staff s  join sakila.address a on a.address_id = s.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select s.first_name, s.last_name, sum(p.amount) Total_Amount
 from sakila.staff s
 join sakila.payment p on p.staff_id = s.staff_id
 where month(payment_date) = 8 and year(payment_date) = 2005
 group by  s.first_name, s.last_name;
 
--  6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title, count( fa.actor_id) from sakila.film f
inner join sakila.film_actor fa on fa.film_id = f.film_id
group by f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
select title, count(inventory_id) number_copies from sakila.film f 
join sakila.inventory i on i.film_id = f.film_id
where f.title = 'Hunchback Impossible'
group by title;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
--  	![Total amount paid](Images/total_payment.png)

select first_name, last_name , sum(amount) Total_Amount_Paid
from sakila.customer c
join sakila.payment p on p.customer_id = c.customer_id
group by first_name, last_name
order by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select title
from sakila.film f
where f.language_id = 
	(
		select l.language_id from sakila.language l where l.name = 'English'
	)
and (
			f.title IN
				(
					Select f1.title from sakila.film f1 where f1.title like 'K%'
				)
	  or  f.title IN 
				(
					Select f2.title from sakila.film f2 where f2.title like 'Q%'
				)
		);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select a.first_name, a.last_name
from sakila.actor a
where a.actor_id in 
	(
		select actor_id from sakila.film_actor fa where fa.film_id = 
			(
				select film_id from sakila.film f where f.title = 'Alone Trip'
			)
	);
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
select cu.first_name, cu.last_name, cu.email
 from sakila.customer cu
 join sakila.address ad on ad.address_id = cu.address_id
 join sakila.city on city.city_id = ad.city_id
 join sakila.country c on c.country_id  = city.country_id
 where c.country = 'Canada';
 
-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.
select f.title, c.name category
 from sakila.film f 
join sakila.film_category fc on fc.film_id = f.film_id
join sakila.category c on c.category_id = fc.category_id
where name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
select f.title, count(r.rental_id) number_rented from sakila.rental r
join sakila.inventory i on i.inventory_id = r.inventory_id
join sakila.film f on f.film_id = i.film_id
group by f.title
order by  2 desc;


-- 7f. Write a query to display how much business, in dollars, each store brought in.

select s.store_id, sum(p.amount) Total_amount
 from sakila.store s 
 join sakila.staff st on st.store_id = s.store_id
 join sakila.payment p on p.staff_id = st.staff_id
 group by s.store_id;
 
-- 7g. Write a query to display for each store its store ID, city, and country.
select s.store_id  , c.city, co.country
 from sakila.store s
join sakila.address ad on ad.address_id = s.address_id
join sakila.city	c on c.city_id = ad.city_id
join sakila.country co on co.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
Select c.name Genre, sum(amount) Gross_Revenue
  from sakila.category c
  join sakila.film_category fc on  fc.category_id = c.category_id
  join sakila.film f on f.film_id = fc.film_id
  join sakila.inventory i on i.film_id = f.film_id
  join sakila.rental r on r.inventory_id = i.inventory_id
  join sakila.payment p on p.rental_id = r.rental_id
  group by c.name
  order by 2 desc limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view.
--  If you haven't solved 7h, you can substitute another query to create a view.
Create view sakila.top_5_genres
as

Select c.name Genre, sum(amount) Gross_Revenue
  from sakila.category c
  join sakila.film_category fc on  fc.category_id = c.category_id
  join sakila.film f on f.film_id = fc.film_id
  join sakila.inventory i on i.film_id = f.film_id
  join sakila.rental r on r.inventory_id = i.inventory_id
  join sakila.payment p on p.rental_id = r.rental_id
  group by c.name
  order by 2 desc limit 5;
  
  
-- 8b. How would you display the view that you created in 8a?

Select * from sakila.top_5_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view sakila.top_5_genres;


## Appendix: List of Tables in the Sakila DB

/*A schema is also available as `sakila_schema.svg`. Open it with a browser to view.

```sql
	'actor'
	'actor_info'
	'address'
	'category'
	'city'
	'country'
	'customer'
	'customer_list'
	'film'
	'film_actor'
	'film_category'
	'film_list'
	'film_text'
	'inventory'
	'language'
	'nicer_but_slower_film_list'
	'payment'
	'rental'
	'sales_by_film_category'
	'sales_by_store'
	'staff'
	'staff_list'
	'store'
```

## Uploading Homework

* To submit this homework using BootCampSpot:

  * Create a GitHub repository.
  * Upload your .sql file with the completed queries.
  * Submit a link to your GitHub repo through BootCampSpot.

*/