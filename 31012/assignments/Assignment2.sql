/***********************************************
** File: Assignment2-PartB.sql
** Desc: Manipulating, Categorizing, Sorting and Grouping & Summarizing Data 
** Author: Scott Shepard
** Date: 10/26/2018
************************************************/

############################### QUESTION 1 ###############################

# 1a) Show the list of databases.
show databases;

# 1b) Select sakila database.
use sakila;

# 1c) Show all tables in the sakila database.
show tables;

# 1d) Show each of the columns along with their data types for the actor table.
describe actor;

# 1e) Show the total number of records in the actor table.
select count(*) 
from actor;

# 1f) What is the first name and last name of all the actors in the actor table ?
select
	first_name
	, last_name
from 
	actor;

# 1g) Insert your first name and middle initial ( in the last name column ) into the actors table.
insert into actor (first_name, last_name)
values ('Scott', 'O');

# 1h) Update your middle initial with your last name in the actors table.
update actor
set last_name='Shepard'
where first_name='Scott'
	and last_name='O';

# 1i) Delete the record from the actor table where the first name matches your first name.
delete from actor
where first_name = 'Scott';

# 1j) Create a table payment_type with the following specifications and appropriate data types
# Table Name : “Payment_type”
# Primary Key: "payment_type_id”
# Column: “Type”
# Insert following rows in to the table: 1, “Credit Card” ; 2, “Cash”; 3, “Paypal” ; 4 , “Cheque”
create table if not exists payment_type (
	payment_type_id MEDIUMINT NOT NULL AUTO_INCREMENT,
    type CHAR(30) NOT NULL,
    PRIMARY KEY (payment_type_id)
);
insert into payment_type (payment_type_id, type)
values 
	(1, "Credit Card"),
    (2, "Cash"),
	(3, "Paypal"),
    (4, "Cheque");
select * from payment_type;
	
# 1k) Rename table payment_type to payment_types.
rename table payment_type to payment_types;

# 1l) Drop the table payment_types.
drop table payment_types;

############################### QUESTION 2 ############################### 

# 2a) List all the movies ( title & description ) that are rated PG-13 ?
select 
	title
    , description
from film
where rating = 'PG-13';

# 2b) List all movies that are either PG OR PG-13 using IN operator ?
select
	title
    , description
from film
where rating in ('PG', 'PG-13');

# 3c) Report all payments greater than and equal to $2 and Less than equal to $7 ?
# Note : write 2 separate queries conditional operator and BETWEEN keyword
select *
from payment
where 
	amount >= 2 
    and amount <= 7;
    
select *
from payment
where amount between 2 and 7;

# 2d) List all addresses that have phone number that contain digits 589, start with 140 or end with 589
# Note : write 3 different queries
select * 
from address
where phone like '%589%';

select * 
from address
where phone regexp '^140';

select * 
from address
where phone regexp '589$';

# 2e) List all staff members ( first name, last name, email ) whose password is NULL ?
select 
	first_name
    , last_name
    , email
from staff
where password is null;

# 2f) Select all films that have title names like ZOO and rental duration greater than or equal to 4
select
	film_id
    , title
    , rental_duration
from film
where 
	title like '%ZOO%'
    and rental_duration >= 4;

# 2g) What is the cost of renting the movie ACADEMY DINOSAUR for 2 weeks ?
# Note : use of column alias
select rental_rate * 2 as cost
from film
where title = 'ACADEMY DINOSAUR';

# 2h) List all unique districts where the customers, staff, and stores are located
select distinct district
from address
	left join customer on customer.address_id = address.address_id
    left join staff on staff.address_id = address.address_id
    left join store on store.address_id = address.address_id
where 
	customer.customer_id is not null
    or staff.staff_id is not null
    or store.store_id is not null;

# 2i) List the top 10 newest customers across all stores
select
	first_name
    , last_name
    , create_date
from customer
where store_id is not null
order by create_date desc;

############################### QUESTION 3 ###############################
# 3a) Show total number of movies
select count(*)
from film;

# 3b) What is the minimum payment received and max payment received across all transactions ?
select
	min(amount) as mimimum_payment,
    max(amount) as maximum_payment
from payment;

# 3c) Number of customers that rented movies between Feb-2005 & May-2005 ( based on paymentDate ).
select
	count(distinct rental.customer_id)
from rental
  join payment on payment.rental_id = rental.rental_id
where payment_date between '2005-02-01' and '2005-05-31';

# 3d) List all movies where replacement_cost is greater than $15 or rental_duration is between 6 & 10 days
select title
from film
where replacement_cost > 15
	or rental_duration between 6 and 10;

# 3e) What is the total amount spent by customers for movies in the year 2005 ?
select sum(amount)
from payment
where year(payment_date) = '2005';

# 3f) What is the average replacement cost across all movies ?
select avg(replacement_cost)
from film;

# 3g) What is the standard deviation of rental rate across all movies ?
select stddev(rental_rate)
from film;

# 3h) What is the midrange of the rental duration for all movies
select (MAX(rental_duration) + MIN(rental_duration)) / 2 
from film;

############################### QUESTION 4 ###############################
# 4a) Customers sorted by first Name and last name in ascending order.
select
	first_name, 
    last_name
from customer
order by 
	first_name, 
    last_name;

# 4b) Group distinct addresses by district.
select district, count(*)
from address
group by 1;

# 4c) Count of movies that are either G/NC-17/PG-13/PG/R grouped by rating. 
select
	rating,
    count(*)
from film
where rating in ('G', 'NC-17', 'PG-17', 'PG', 'R')
group by 1;
    

# 4d) Number of addresses in each district.
select
	district,
	count(*)
from address
group by 1;
  

# 4e) Find the movies where rental rate is greater than 1$ and order result set by descending order.
select
	title,
    rental_rate
from film
where rental_rate > 1
order by rental_rate desc;
    

# 4f) Top 2 movies that are rated R with the highest replacement cost ? 
select
	title,
    replacement_cost
from film
where rating = 'R'
order by replacement_cost asc
limit 2;

# 4g) Find the most frequently occurring (mode) rental rate across products.
select *
from (
	select
		count(*) as c,
		rental_rate
	from film
	group by 2) t
order by c
limit 1;

# 4h) Find the top 2 movies with movie length greater than 50mins and which has commentaries as a special features.
select title
from film
where length > 50
	and special_features like '%Commentaries%'
limit 2;
    

# 4i) List the years with more than 2 movies released.
select *
from (
    select
		release_year,
		count(*) as c
	from film
	group by 1) t
where c > 2;

/***********************************************
** File: Assignment2-PartC.sql
** Desc: Combining Data, Nested Queries, Views and Indexes, Transforming Data ** Author:
** Date: 10/27/18
************************************************/

############################### QUESTION 1 ############################### 
# C1a) List the actors (firstName, lastName) who acted in more then 25 movies.
select
	first_name,
    last_name,
    count(*) as c
from actor a
	join film_actor fa on fa.actor_id = a.actor_id
	join film f on f.film_id = fa.film_id
group by 1, 2
having c > 25;
# Note: Also show the count of movies against each actor

# C1b) List the actors who have worked in the German language movies.
select
	first_name,
    last_name,
    title
from actor a
	join film_actor fa on fa.actor_id = a.actor_id
	join film f on f.film_id = fa.film_id
    join language l on l.language_id = f.language_id
where l.name = 'German';
    
# Note: Please execute the below SQL before answering this question. SET SQL_SAFE_UPDATES=0;
UPDATE film SET language_id=6 WHERE title LIKE "%ACADEMY%";
 
 
# c) List the actors who acted in horror movies.
 select 
	a.first_name,
    a.last_name,
    f.title
 from actor a
	join film_actor fa on fa.actor_id = a.actor_id
	join film f on f.film_id = fa.film_id
    join film_category fc on fc.film_id = f.film_id
    join category c on c.category_id = fc.category_id
where c.name = 'Horror';

# d) List all customers who rented more than 3 horror movies.
select
	c.first_name,
    c.last_name,
    count(distinct f.film_id) as horror_rentals
from customer c
  join rental r on r.customer_id = c.customer_id
  join inventory i on i.inventory_id = r.inventory_id
  join film f on i.film_id = f.film_id
  join film_category fc on fc.film_id = f.film_id
  join category cat on cat.category_id = fc.category_id
where cat.name = 'Horror'
group by 1,2
having horror_rentals > 3;

# C1e) List all customers who rented the movie which starred SCARLETT BENING
select
	c.first_name,
    c.last_name
from customer c
  join rental r on r.customer_id = c.customer_id
  join inventory i on i.inventory_id = r.inventory_id
  join film f on i.film_id = f.film_id
  join film_actor fa on fa.film_id = f.film_id
  join actor a on fa.actor_id = a.actor_id
where a.first_name = 'SCARLETT' 
	and a.last_name = 'BENING';

# C1f) Which customers residing at postal code 62703 rented movies that were Documentaries.
select
	c.first_name,
    c.last_name
from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on i.film_id = f.film_id
	join film_category fc on fc.film_id = f.film_id
	join category cat on cat.category_id = fc.category_id
	join address ads on ads.address_id = c.address_id
where cat.name = 'Documentary'
	and ads.postal_code = '62703';

# C1g) Find all the addresses where the second address line is not empty (i.e., contains some text), and return these second addresses sorted.
select *
from address
where address2 is not null
	and address2 != ''
order by address2;


# C1h) How many films involve a “Crocodile” and a “Shark” based on film description ?
select count(*)
from film
where description like '%Crocodile%'
	and description like '%Shark%';

# C1i) List the actors who played in a film involving a “Crocodile” and a “Shark”, along with the release year of the movie, sorted by the actors’ last names.
select
	a.first_name,
    a.last_name,
    f.release_year
from film f
	join film_actor fa on fa.film_id = f.film_id
	join actor a on fa.actor_id = a.actor_id
where f.description like '%Crocodile%'
	and f.description like '%Shark%'
order by 2;

# C1j) Find all the film categories in which there are between 55 and 65 films. Return the names of categories and the number of films per category, sorted from highest to lowest by the number of films.
select 
	cat.name,
    count(distinct f.film_id) film_count
from film f
	join film_category fc on fc.film_id = f.film_id
	join category cat on cat.category_id = fc.category_id
group by 1
having film_count between 55 and 65
order by 2;

# C1k) In which of the film categories is the average difference between the film replacement cost and the rental rate larger than 17$?
select 
	cat.name,
	avg(f.replacement_cost - f.rental_rate) as avg_diff

from film f
	join film_category fc on fc.film_id = f.film_id
	join category cat on cat.category_id = fc.category_id
group by 1
having avg_diff > 17
order by 2 desc;


# C1l) Many DVD stores produce a daily list of overdue rentals so that customers can be contacted and asked to return their overdue DVDs. 
# To create such a list, search the rental table for films with a return date that is NULL and where the rental date is further in the past than the 
# rental duration specified in the film table. 
# If so, the film is overdue and we should produce the name of the film along with the customer name and phone number.
select
	c.first_name,
    c.last_name,
    rental_date,
    rental_duration,
    date_add(rental_date, INTERVAL f.rental_duration DAY) expected_return_date
from customer c
	join rental r on r.customer_id = c.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on i.film_id = f.film_id

where return_date is null
  and date_add(rental_date, INTERVAL f.rental_duration DAY) < current_date();


# C1m) Find the list of all customers and staff given a store id 
# Note : use a set operator, do not remove duplicates
set STORE_ID = 2;
select
  first_name,
  last_name,
  'customer' as type
from customer
where store_id = STORE_ID
UNION
select
  first_name,
  last_name,
  'staff' as type
from staff
where store_id = STORE_ID;

############################### QUESTION 2 ############################### 


# C2a) List actors and customers whose first name is the same as the first name of the actor with ID 8.
select
  first_name,
  last_name,
  'customer' as type
from customer
where first_name = (
	select first_name 
	from actor 
    where actor_id  = 8)
UNION
select
  first_name,
  last_name,
  'actor' as type
from actor
where first_name = (
	select first_name 
	from actor 
    where actor_id = 8);


# C2b) List customers and payment amounts, with payments greater than average the payment amount
select 
	first_name,
    last_name,
    amount
from customer c
	join payment p on p.customer_id = c.customer_id
where p.amount > (
	select avg(amount)
	from payment);


# C2c) List customers who have rented movies at least once 
# Note: use IN clause
select
	first_name,
    last_name
from customer c
where c.customer_id in (
	select customer_id 
    from rental
);


# C2d) Find the floor of the maximum, minimum and average payment amount
select
	floor(max(amount)),
    floor(min(amount)),
    floor(avg(amount))
from payment;

############################### QUESTION 3 ############################### 


# C3a) Create a view called actors_portfolio which contains information about actors and films ( including titles and category).
create view actor_porfiolo as
select
	a.first_name,
    a.last_name,
    f.release_year,
    f.title,
    cat.name as category
from film f
	join film_actor fa on fa.film_id = f.film_id
	join actor a on fa.actor_id = a.actor_id
    join film_category fc on fc.film_id = f.film_id
	join category cat on cat.category_id = fc.category_id;

# C3b) Describe the structure of the view and query the view to get information on the actor ADAM GRANT
describe actor_porfiolo;
select * from actor_porfiolo 
where first_name = 'ADAM' and last_name = 'GRANT';

# C3c) Insert a new movie titled Data Hero in Sci-Fi Category starring ADAM GRANT
insert into actor_porfiolo (first_name, last_name)
values ('ADAM', 'GRANT');
update actor_porfiolo set title = 'Data Hero' 
where first_name = 'ADAM' 
	and last_name = 'GRANT'
	and title is null;
update actor_porfiolo set category = 'Sci-Fi' 
where first_name = 'ADAM' 
	and last_name = 'GRANT'
	and category is null;    

############################### QUESTION 4 ############################### 

# C4a) Extract the street number ( characters 1 through 4 ) from customer addressLine1
select substring(address, 1, 4)
from address
where address_id in (select address_id from customer);

# C4b) Find out actors whose last name starts with character A, B or C.
select *
from actor
where substring(last_name, 1, 1) in ('A', 'B', 'C');


# C4c) Find film titles that contains exactly 10 characters
select title
from film
where char_length(title) = 10;


# C4d) Format a payment_date using the following format e.g "22/1/2016"
select DATE_FORMAT(DATE(payment_date), "%m/%d/%Y")
from payment
limit 10;

# C4e) Find the number of days between two date values rental_date & return_date
select datediff(return_date, rental_date)
from rental
where return_date is not null
limit 10;

############################### QUESTION 5 ############################### 
# Provide eight additional queries and indicate the specific business use cases they address.

# C5a) Number of rentals per week at all stores. This can be used to look at trends and forecasting
select
	year(rental_date) as year,
    week(rental_date) as week,
    count(*) as n_rentals
from rental
group by 1, 2
order by 1, 2;

# C5b) The most popular actor staring in rented films per store.
#      This could be used for marketing materials at that store
with rental_counts as (
	select
		i.store_id,
		a.first_name,
		a.last_name,
		count(distinct r.rental_id) rentals
	from rental r
		join inventory i on i.inventory_id = r.inventory_id
		join film f on i.film_id = f.film_id
		join film_actor fa on fa.film_id = f.film_id
		join actor a on fa.actor_id = a.actor_id
	group by 1,2,3
), max_rentals as (

select 
	store_id,
    max(rentals) as max_rentals
from rental_counts
group by 1
)
select * 
from rental_counts rc 
	join max_rentals mr on rc.store_id = mr.store_id
where max_rentals = rentals
;

# C5c) First and last rental per store
select 
	store_id,
    min(rental_date),
	max(rental_date)
from rental r
	join inventory i on i.inventory_id = r.inventory_id
group by 1;


# C5d) Count the number of films by language
select 
	l.name,
    count(*) as films
from film f
  join language l on l.language_id = f.language_id
group by 1;

# C5e) How many employees are active?
select
  active,
  count(*)
from staff
group by 1;

# C5f) Which actors have never acted in a film?
select	
	first_name,
    last_name
from actor
where actor_id not in (
	select actor_id 
    from film_actor
);

# C5g) Are there any films where film_text.title doesn't match the film title?
select *
from film f
	join film_text ft on ft.film_id = f.film_id
where ft.title != f.title;

# C5h) Which category has the highest total amount of payments?
select
	cat.name as category,
    sum(p.amount) as total_payment
from film f
    join film_category fc on fc.film_id = f.film_id
	join category cat on cat.category_id = fc.category_id
    join inventory i on i.film_id = f.film_id
    join rental r on r.inventory_id = r.inventory_id
    join payment p on p.rental_id = r.rental_id
group by 1
order by 2 desc;
