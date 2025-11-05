use hw4;

-- Tables

-- Actor Table
CREATE TABLE actor (
	-- Attributes
    actor_id INT NOT NULL,
    first_name VARCHAR (50),
    last_name VARCHAR (50),
    
    -- Constraints
    CONSTRAINT PK_actor PRIMARY KEY (actor_id)
);

-- Language Table
CREATE TABLE language (
	-- Attributes
	language_id INT NOT NULL,
    name VARCHAR (50),
    
    -- Contraints
    CONSTRAINT PK_language PRIMARY KEY (language_id)
);

-- Country Table
CREATE TABLE country (
	-- Attributes
	country_id INT NOT NULL,
    country VARCHAR(100),
    
    -- Contraints
    CONSTRAINT PK_country PRIMARY KEY (country_id)
);

-- City Table
CREATE TABLE city (
	-- Attributes
	city_id	INT NOT NULL,
    city VARCHAR (100),
    country_id INT NOT NULL,
    
    -- Contraints
    CONSTRAINT PK_city PRIMARY KEY (city_id),
	CONSTRAINT FK_country_id FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- Category Table
CREATE TABLE category (
	-- Attributes
    category_id INT NOT NULL,
    name VARCHAR (20),
    
    -- Contraints
    CONSTRAINT PK_category PRIMARY KEY (category_id),
    CONSTRAINT CK_cat_name CHECK (name IN (	"Animation", "Comedy", "Family", "Foreign", 
											"Sci-Fi", "Travel", "Children", "Drama", 
											"Horror", "Action", "Classics", "Games", 
                                            "New", "Documentary", "Sports", "Music"))
);

-- Address Table
CREATE TABLE address (
	-- Attributes
    address_id INT NOT NULL,
    address VARCHAR (100),
    address2 VARCHAR (100),
    district VARCHAR (100),
    city_id INT NOT NULL,
    postal_code INT, 	-- Added "NULL" into the data for missing values in 1-4
    phone VARCHAR (20),	-- ^^^^^ Just 1-2
    
    -- Contraints
    CONSTRAINT PK_address PRIMARY KEY (address_id),
    CONSTRAINT FK_addr_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

-- Film Table
CREATE TABLE film (
	-- Attributes
    film_id INT NOT NULL,
    title VARCHAR (100),
    description TEXT(20000),
    release_year YEAR,
    language_id INT NOT NULL,
    rental_duration INT,
    rental_rate DECIMAL(10, 2),
    length INT,
    replacement_cost DECIMAL(10,2),
    rating VARCHAR(10),
    special_features SET("Behind the Scenes", "Commentaries", "Deleted Scenes", "Trailers"),
    
    -- Contraints
    CONSTRAINT PK_film PRIMARY KEY (film_id),
    CONSTRAINT FK_film_language FOREIGN KEY (language_id) REFERENCES language(language_id),
    CONSTRAINT CK_film_rent CHECK (rental_duration BETWEEN 2 AND 8),
    CONSTRAINT CK_film_rate CHECK (rental_rate BETWEEN 0.99 AND 6.99),
    CONSTRAINT CK_film_length CHECK (length BETWEEN 30 AND 200),
    CONSTRAINT CK_film_rating CHECK (rating IN ("PG", "G", "NC-17", "PG-13", "R")),
    CONSTRAINT CK_film_repl_cost CHECK (replacement_cost BETWEEN 5.00 AND 100.00)
);

-- Film Category Table
CREATE TABLE film_category (
	-- Attributes
    film_id INT NOT NULL,
    category_id INT NOT NULL,
    
    -- Contraints
    CONSTRAINT PK_film_category PRIMARY KEY (film_id, category_id),
    CONSTRAINT FK_fc_film FOREIGN KEY (film_id) REFERENCES film(film_id),
    CONSTRAINT FK_fc_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- Store Table
CREATE TABLE store (
	-- Attributes
    store_id INT NOT NULL,
    address_id INT NOT NULL,
    
    -- Contraints
    CONSTRAINT PK_store PRIMARY KEY (store_id),
    CONSTRAINT FK_store_addr FOREIGN KEY (address_id) REFERENCES address(address_id)
);

-- Customer Table
CREATE TABLE customer (
	-- Attributes
    customer_id INT NOT NULL,
    store_id INT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100),
    address_id INT NOT NULL,
    active BOOL,
    
    -- Contraints
    CONSTRAINT PK_customer PRIMARY KEY (customer_id),
    CONSTRAINT FK_customer_store FOREIGN KEY (store_id) REFERENCES store(store_id),
    CONSTRAINT FK_customer_addr FOREIGN KEY (address_id) REFERENCES address(address_id),
    CONSTRAINT CK_customer_active CHECK (active in (0, 1))
);

-- Staff Table
CREATE TABLE staff (
	-- Attributes
    staff_id INT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    address_id INT NOT NULL,
    email VARCHAR(100),
    store_id INT NOT NULL,
    active BOOL,
    username VARCHAR(100),
    password VARCHAR(100),
    
    -- Contraints
	CONSTRAINT PK_staff PRIMARY KEY (staff_id),
	CONSTRAINT FK_staff_addr FOREIGN KEY (address_id) REFERENCES address(address_id),
    CONSTRAINT FK_staff_store FOREIGN KEY (store_id) REFERENCES store(store_id),
    CONSTRAINT CK_staff_active CHECK (active in (0, 1))
);

-- Inventory Table
CREATE TABLE inventory (
	-- Attributes
    inventory_id INT NOT NULL,
    film_id INT NOT NULL,
    store_id INT NOT NULL,
    
    -- Contraints
    CONSTRAINT PK_inventory PRIMARY KEY (inventory_id),
    CONSTRAINT FK_inv_film FOREIGN KEY (film_id) REFERENCES film(film_id),
    CONSTRAINT FK_inv_store FOREIGN KEY (store_id) REFERENCES store(store_id)
);

-- Rental Table
CREATE TABLE rental (
	-- Attributes
    rental_id INT NOT NULL,
    rental_date DATETIME,
	inventory_id INT NOT NULL,
    customer_id INT NOT NULL,
    return_date DATETIME,
    staff_id INT NOT NULL,
    
    -- Contraints
    CONSTRAINT PK_rental PRIMARY KEY (rental_id),
    CONSTRAINT FK_rental_inv FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id),
    CONSTRAINT FK_rental_cust FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT FK_rental_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    CONSTRAINT UQ_rental_inv UNIQUE (inventory_id, customer_id, rental_date)
);

-- Payment Table
CREATE TABLE payment (
	-- Attributes
    payment_id INT NOT NULL,
    customer_id INT NOT NULL,
    staff_id INT NOT NULL,
    rental_id INT NOT NULL,
    amount DECIMAL(14, 2),
    payment_date DATETIME,
    
    -- Contraints
    CONSTRAINT PK_payment PRIMARY KEY (payment_id),
    CONSTRAINT FK_payment_cust FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    CONSTRAINT FK_payment_staff FOREIGN KEY (staff_id) REFERENCES staff(staff_id),
    CONSTRAINT FK_payment_rent FOREIGN KEY (rental_id) REFERENCES rental(rental_id),
    CONSTRAINT CK_payment_amt CHECK (amount >= 0)
);

-- Film Actor Table
CREATE TABLE film_actor (
	-- Attributes
    actor_id INT NOT NULL,
    film_id INT NOT NULL,

	-- Contraints
	CONSTRAINT PK_film_actor PRIMARY KEY (actor_id, film_id),
    CONSTRAINT FK_fa_actor FOREIGN KEY (actor_id) REFERENCES actor(actor_id),
    CONSTRAINT FK_fa_film FOREIGN KEY (film_id) REFERENCES film(film_id)
);

-- Questions

-- 1. What is the average length of films in each category? List the results in alphabetic order of categories.

select cat.name, avg(film.length)				-- We only need these 2 values
from category as cat							-- Alias category
inner join film_category using(category_id)		-- inner join: Category -> Film_category -> film
inner join film using(film_id)
group by cat.name								-- Apply avg(film.length) to members of name group
order by cat.name;								-- Alphabetical Ordering

-- 2. Which categories have the longest and shortest average film lengths?
select cat.name, avg(film.length)							-- Need Name + Avg. Film Length
from category as cat										-- Category -> film_category -> film
inner join film_category using(category_id)
inner join film using(film_id)
group by cat.name											-- Group by category name, Apply these conditions AFTER
having avg(film.length) >= all (select avg(film2.length)						-- Find Largest Average
								from category as cat2							-- Same grouping as main query
								inner join film_category using(category_id)
								inner join film as film2 using(film_id)
								group by cat2.name )
or avg(film.length) <= all (select avg(film3.length)							-- Find Shortest Average
							from category as cat3								-- Same grouping as main query
							inner join film_category using(category_id)
							inner join film as film3 using(film_id)
							group by cat3.name );

-- 3. Which customers have rented action but not comedy or classic movies?

select customer.first_name, customer.last_name									-- Just need customer First name + last name
from customer
where customer.customer_id in (	select distinct rental.customer_id				-- Customers who rented action movies (Distinct is redundant)
								from rental										-- Rental -> inventory -> film -> film_category -> category
								inner join inventory using (inventory_id)
								inner join film using (film_id)
								inner join film_category using (film_id)
								inner join category using (category_id)
								where category.name = "Action")					-- Pull only action movies
and customer.customer_id not in (	select distinct rental.customer_id			-- Customers who have rented comedy or classics (Apply not afterwards)
									from rental									-- Rental -> inventory -> film -> film_category -> category
									inner join inventory using (inventory_id)
									inner join film using (film_id)
									inner join film_category using (film_id)
									inner join category using (category_id)
									where category.name = "Comedy" 				-- Pull Comedy and Classics movies
                                    or category.name = "Classics");

-- 4. Which actor has appeared in the most English-language movies?
select actor.first_name, actor.last_name						-- Just need actor name
from actor
where actor.actor_id in(select film_actor.actor_id				-- Subquery for actor id in most english language movies
						from film_actor							-- Film_actor -> film -> language
						inner join film using (film_id)
						inner join language using (language_id)
						where language.name = "English"			-- Pull only English movies
						group by film_actor.actor_id			-- Group by film_actor.id since it is in film_actor
						having count(*) >= all (select count(*)							-- Subquery for findind person with most English Movies
												from film_actor							-- Film_actor -> film -> language
												inner join film using (film_id)
												inner join language using (language_id)
												where language.name = "English"			-- Filter English Movies only
												group by film_actor.actor_id));			-- Group by film_actor.id since it is in film_actor

-- 5. How many distinct movies were rented for exactly 10 days from the store where Mike works?

select count(distinct film.film_id)														-- Count only distinct films
from rental																				-- Rental -> inventory -> film
inner join inventory using (inventory_id)	
inner join film using (film_id)
where inventory.store_id = (select store_id from staff where first_name = "Mike")		-- Make sure it is only from Mike's store
and DATE_SUB(DATE(rental.return_date), INTERVAL 10 DAY) = DATE(rental.rental_date);		-- Make sure it is exactly 10 days (Ignore Time)

-- 6. Alphabetically list actors who appeared in the movie with the largest cast of actors.

select actor.first_name, actor.last_name								-- Only need actor names
from actor																-- actor -> film_actor
inner join film_actor using (actor_id)
where film_actor.film_id = (select film_id								-- Subquery for finding movie with most actors
							from film_actor
							group by film_id							-- Group by film_id
							having count(*) >= all (select count(*) 	-- Find max number of actors
													from film_actor 
                                                    group by film_id)
                            limit 1)									-- Make sure only one film_id is outputted
order by actor.last_name, actor.first_name;								-- Sort Alphabetically

