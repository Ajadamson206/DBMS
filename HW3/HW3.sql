-- DB Assignment 3
-- Albert Adamson
-- 10/21/25

USE hw3;

--
-- Create Tables
--

--  merchants(mid, name, city, state)

CREATE TABLE merchants (
	mid 	INT,
    name 	VARCHAR 	(100),
    city 	VARCHAR 	(100),
    state 	VARCHAR 	(100),
	
    -- Set mid as PK and check that it is greater than 0
    CONSTRAINT PK_merchants PRIMARY KEY (mid),
	CONSTRAINT CHK_mid CHECK (mid > 0)
);

--  products(pid, name, category, description)

CREATE TABLE products (
	pid 			INT,
    name 			VARCHAR 	(100),
    category 		VARCHAR 	(100),
    description 	VARCHAR 	(500),
	
    -- Set pid as the PK and check that it is greater than 0
    CONSTRAINT PK_products PRIMARY KEY (pid),
    CONSTRAINT CHK_pid CHECK (pid > 0),
    
    -- Verify that the name and category belong to one of these groups
    CONSTRAINT CHK_name CHECK (name IN ("Printer", "Ethernet Adapter", "Desktop", 
										"Hard Drive", "Laptop", "Router", "Network Card", 
                                        "Super Drive", "Monitor")),
	CONSTRAINT CHK_category CHECK (category IN ("Peripheral", "Networking", "Computer"))
);

--  sell(mid, pid, price, quantity_available)

CREATE TABLE sell (
	mid 				INT,
    pid 				INT,
    price 				DECIMAL	(10, 2),
    quantity_available 	INT,
	
    -- mid and pid are foreign keys
	CONSTRAINT FK_mid FOREIGN KEY (mid) REFERENCES merchants(mid),
	CONSTRAINT FK_pid FOREIGN KEY (pid) REFERENCES products(pid),
    
    -- Verify that price and quantity remain between these values
    CONSTRAINT CHK_price CHECK (price between 0.00 and 100000.00),
    CONSTRAINT CHK_qnt CHECK (quantity_available between 0 and 500)
);

--  orders(oid, shipping_method, shipping_cost)

CREATE TABLE orders (
	oid INT,
    shipping_method VARCHAR(50),
    shipping_cost DECIMAL(8,2),
	
    -- Set oid as the primary key
	CONSTRAINT PK_oid PRIMARY KEY (oid),
    
    -- Verify that the shipping method is in that group and the cost is between these values
    CONSTRAINT CHK_smtd CHECK (shipping_method in ("UPS", "FedEx", "USPS")),
    CONSTRAINT CHK_scost CHECK (shipping_cost BETWEEN 0.00 AND 500.00)
);

--  contain(oid, pid)

CREATE TABLE contain (
	oid INT,
    pid INT,
    
    -- oid and pid are foreign keys
    CONSTRAINT FK_oid FOREIGN KEY (oid) REFERENCES orders(oid),
    CONSTRAINT FK_cont_pid FOREIGN KEY (pid) REFERENCES products(pid) -- Didn't want to duplicate constraint names
);

--  customers(cid, fullname, city, state)

CREATE TABLE customers (
	cid 		INT,
    fullname 	VARCHAR	(100),
    city 		VARCHAR	(100),
    state 		VARCHAR	(100),
    
    -- Set cid as the primary key
    CONSTRAINT PK_cid PRIMARY KEY (cid)
);

--  place(cid, oid, order_date)

CREATE TABLE place (
	cid 		INT,
    oid 		INT,
    order_date 	DATE,
    
    -- Set cid and oid as foreign keys
    CONSTRAINT FK_cid FOREIGN KEY (cid) REFERENCES customers(cid),
    CONSTRAINT FK_place_oid FOREIGN KEY (oid) REFERENCES orders(oid) -- Didn't want to duplicate constraint names
);

-- SQL Querys

-- 1. List names and sellers of products that are no longer available (quantity=0)
select p.name as Product_name, m.name as Seller_name
from merchants as m					-- Used for seller name
inner join sell using(mid)			-- Has quantity variable
inner join products as p using(pid) -- Used for product name
where sell.quantity_available = 0;	-- Check that quantity = 0


-- 2. List names and descriptions of products that are not sold.
select p.name, p.description	-- Only need name and description
from products as p				-- Products contains the all the info needed
where p.pid not in (select pid 	-- Subquery gives the pid of every item that has been sold
					from sell);


-- 3. How many customers bought SATA drives but not any routers?
select count(distinct c.cid) as number_customers			-- Just need a count
from customers as c											-- Only compare cid in the subqueries
where c.cid in (	select p.cid							-- Subquery finds every cid of someone
					from place as p							-- who has bought a SATA Drive
					inner join contain using(oid)
					inner join products as pr using(pid)
                    where pr.description like '%SATA%')     -- SATA is in the Description not name
and c.cid not in (	select p2.cid							-- Subquery finds every cid of someone (Use not in from main query)
					from place as p2						-- who has bought a Router
					inner join contain using(oid)
					inner join products as pr2 using(pid)
					where pr2.category = 'Router');			-- Router is a category unlike SATA Drive


-- 4. HP has a 20% sale on all its Networking products.
select p.pid, p.name as product_name, s.price as old_price, s.price * 0.8 as new_price	-- Show discounted price
from merchants as m
inner join sell as s on s.mid = m.mid
inner join products as p on s.pid = p.pid
where p.category = "Networking" and m.name = "HP";	-- The sale is only on HP Networking products

-- 5. What did Uriel Whitney order from Acer? (make sure to at least retrieve product names and prices).
select p.name as product_name, p.description, sell.price, count(*) as quantity
from merchants as m
inner join sell using(mid)
inner join products as p using(pid)						
inner join contain using(pid)							-- Assume that each PID is sold by one Merchant (Impossible otherwise)
inner join place using(oid)
inner join customers as c using(cid)
where c.fullname = 'Uriel Whitney' and m.name = 'Acer'	-- Check for entries Acer and Uriel Whitney
group by p.pid											-- Apply the count aggregate to the number of times a product appears
order by p.name;										-- Unneeded I just like how it looks



-- 6. List the annual total sales for each company (sort the results along the company and the year attributes).
select m.name as company_name, YEAR(pl.order_date) as year, sum(sell.price) as total_sales	-- Use YEAR() function to get only the year from the datetime
from merchants as m																			
inner join sell using(mid)
inner join contain using(pid)							-- Assume that each PID is sold by one Merchant (Impossible otherwise)
inner join place as pl using(oid)
group by m.name, year																		-- Group by name, year so the sum() aggregate is applied only to individual company yearly totals
order by m.name, year desc;																	-- Sort by name than the year

-- 7. Which company had the highest annual revenue and in what year?
select m.name as company_name, YEAR(pl.order_date) as year, sum(sell.price) as total_sales	-- Use YEAR() function to get annual values
from merchants as m																			
inner join sell using(mid)
inner join contain using(pid)																-- Assume that each PID is sold by one Merchant (Impossible otherwise)
inner join place as pl using(oid)
group by m.name, year 																		-- Group by name, year so sum() aggregate is applied to individual companies and their totals
having total_sales >= all (	select sum(sell.price)											-- Subquery to find which one is the highest (Just lists the sums to compare to total_sales)
							from merchants as m2
							inner join sell using(mid)
							inner join contain using(pid)
							inner join place as pl2 using(oid)
							group by m2.name, YEAR(pl2.order_date));						-- Same group by as before

-- 8. On average, what was the cheapest shipping method used ever?
select shipping_method, avg(shipping_cost)							-- Interpreted as which shipping method is usually the cheapest
from orders
group by shipping_method											-- Group by the shipping methods
having avg(shipping_cost) <= all (	select avg(shipping_cost)		-- We want the smallest value (Subquery finds all averages per shipping method)
									from orders
									group by shipping_method);		-- Apply avg() aggregate to the grouped shipping methods

-- 9. What is the best sold ($) category for each company?
select m.name as company_name, p.category, sum(sell.price) as revenue	--
from merchants as m
inner join sell using(mid)
inner join products as p using(pid)
inner join contain using(pid)											-- Assume that each PID is sold by one Merchant (Impossible otherwise)
group by m.name, p.category												-- Group by company, category to apply the sum aggrate to them
having sum(sell.price) >= all (	select sum(sell.price)					-- Subquery is used to find the best for each company
								from merchants as m2
								inner join sell using(mid)
								inner join products as p2 using(pid)
								inner join contain using(pid)
                                where m.mid = m2.mid					-- m.mid comes from main query (So we only compare similar companies)
								group by m2.name, p2.category);			-- Group by same values as the main query


-- 10. For each company find out which customers have spent the most and the least amounts.
select m.name as company_name, c.fullname as customer_name, sum(sell.price) as total_spent
from merchants as m
inner join sell using(mid)
inner join contain using(pid)										-- Assume that each PID is sold by one Merchant (Impossible otherwise)
inner join place using(oid)
inner join customers as c using(cid)
group by m.mid, c.cid
having sum(sell.price) >= all (	select sum(sell.price)				-- Calculates which customer spent the most
								from merchants as m2
								inner join sell using(mid)
								inner join contain using(pid)
								inner join place using(oid)
								inner join customers as c2 using(cid)
                                where m.name = m2.name				-- Verify that we are comparing the same company as main query
								group by m2.mid, c2.cid)			-- Groups by the same as the main query
or sum(sell.price) <= all (	select sum(sell.price)					-- Calculates which customer spent the least amount (Joins it to output by an or)
							from merchants as m3
							inner join sell using(mid)
							inner join contain using(pid)
							inner join place using(oid)
							inner join customers as c3 using(cid)
							where m.name = m3.name					-- Verify that we are comparing the same company as main query
							group by m3.mid, c3.cid)				-- Group by the same as the main query
order by m.name, sum(sell.price) desc;								-- Not needed, I just like the way that it looks
