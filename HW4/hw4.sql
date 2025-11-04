use hw4;

-- Tables

-- Actor Table
CREATE TABLE actor (
	-- Attributes
    actor_id INT,
    first_name VARCHAR (50),
    last_name VARCHAR (50),
    
    -- Constraints
    CONSTRAINT PK_actor PRIMARY KEY (actor_id)
);

-- Language Table
CREATE TABLE language (
	-- Attributes
	language_id INT,
    name VARCHAR (50),
    
    -- Contraints
    CONSTRAINT PK_language PRIMARY KEY (language_id)
);

-- Country Table
CREATE TABLE country (
	-- Attributes
	country_id INT,
    country VARCHAR(100),
    
    -- Contraints
    CONSTRAINT PK_country PRIMARY KEY (country_id)
);

-- City Table
CREATE TABLE city (
	-- Attributes
	city_id	INT,
    city VARCHAR (100),
    country_id INT,
    
    -- Contraints
    CONSTRAINT PK_city PRIMARY KEY (city_id),
	CONSTRAINT FK_country_id FOREIGN KEY (country_id) REFERENCES country(country_id)
);

-- Category Table
CREATE TABLE category (
	-- Attributes
    category_id INT,
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
    address_id INT,
    address VARCHAR (100),
    address2 VARCHAR (100),
    district VARCHAR (100),
    city_id INT,
    postal_code INT, 	-- Added "NULL" into the data for missing values in 1-4
    phone VARCHAR (20),	-- ^^^^^ Just 1-2
    
    -- Contraints
    CONSTRAINT PK_address PRIMARY KEY (address_id),
    CONSTRAINT FK_addr_city FOREIGN KEY (city_id) REFERENCES city(city_id)
);

-- Film Table
CREATE TABLE film (
	-- Attributes
    film_id INT,
    title VARCHAR (100),
    description TEXT(20000),
    release_year YEAR,
    language_id INT,
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
    film_id INT,
    category_id INT,
    
    -- Contraints
    CONSTRAINT PK_film_category PRIMARY KEY (film_id, category_id),
    CONSTRAINT FK_fc_film FOREIGN KEY (film_id) REFERENCES film(film_id),
    CONSTRAINT FK_fc_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- Store Table
CREATE TABLE store (
	-- Attributes
    store_id INT,
    address_id INT,
    
    -- Contraints
    CONSTRAINT PK_store PRIMARY KEY (store_id),
    CONSTRAINT FK_store_addr FOREIGN KEY (address_id) REFERENCES address(address_id)
);

-- Customer Table
CREATE TABLE customer (
	-- Attributes
    customer_id INT,
    store_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100),
    address_id INT,
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
    staff_id INT,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    address_id INT,
    email VARCHAR(100),
    store_id INT,
    active BOOL,
    username VARCHAR(100),
    password VARCHAR(100),
    
    -- Contraints
	CONSTRAINT PK_staff PRIMARY KEY (staff_id),
	CONSTRAINT FK_staff_addr FOREIGN KEY (address_id) REFERENCES address(address_id),
    CONSTRAINT FK_staff_store FOREIGN KEY (store_id) REFERENCES store(store_id)
);

-- Inventory Table
CREATE TABLE inventory (
	-- Attributes
    inventory_id INT,
    film_id INT,
    store_id INT,
    
    -- Contraints
    CONSTRAINT PK_inventory PRIMARY KEY (inventory_id),
    CONSTRAINT FK_inv_film FOREIGN KEY (film_id) REFERENCES film(film_id),
    CONSTRAINT FK_inv_store FOREIGN KEY (store_id) REFERENCES store(store_id)
);

-- Rental Table
CREATE TABLE rental (
	-- Attributes
    rental_id INT,
    rental_date DATETIME,
	inventory_id INT,
    customer_id INT,
    return_date DATETIME,
    staff_id INT,
    
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
    payment_id INT,
    customer_id INT,
    staff_id INT,
    rental_id INT,
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
    actor_id INT,
    film_id INT,

	-- Contraints
	CONSTRAINT PK_film_actor PRIMARY KEY (actor_id, film_id),
    CONSTRAINT FK_fa_actor FOREIGN KEY (actor_id) REFERENCES actor(actor_id),
    CONSTRAINT FK_fa_film FOREIGN KEY (film_id) REFERENCES film(film_id)
);

-- Questions

-- 1. What is the average length of films in each category? List the results in alphabetic order of categories.

-- 2. Which categories have the longest and shortest average film lengths?

-- 3. Which customers have rented action but not comedy or classic movies?

-- 4. Which actor has appeared in the most English-language movies?

-- 5. How many distinct movies were rented for exactly 10 days from the store where Mike works?

-- 6. Alphabetically list actors who appeared in the movie with the largest cast of actors.
