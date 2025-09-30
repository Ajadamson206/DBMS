
--
-- Assignment 2: Restaurant Database
-- Albert Adamson
--

use HW2; -- Schema is called HW2

-- Average Price of Foods at Each Restaurant

select 	restaurants.name as restaurant_name, 		-- We Want it to be in pairs of (Restaurant Name, Avg Food Price)
		avg(foods.price) as average_price			-- Since we grouped later, we calculate the group max price
from restaurants									-- Restaurant and Food are joined by the Serves Relation
inner join serves using(restID)
inner join foods using(foodID)
group by restaurants.name;							-- Group the restaurants together

-- Maximum Food Price at Each Restaurant

select 	restaurants.name as restaurant_name,		-- We Want it in pairs of (Restaurant Name, Max Price)
		max(foods.price) as maximum_price			-- Since we grouped later, we calculate the group max price
from restaurants									--  Restaurant and Food are joined by the Serves Relation
inner join serves using(restID)
inner join foods using(foodID)
group by restaurants.name;							-- Group the restaurants together

-- Count of Different Food Types Served at Each Restaurant

select 	combined.name as restaurant_name,			-- We want pairs of (Restaurant Name, Number of Types)
		count(combined.type) as number_food_types	-- Count how many different types there are
from (	select restaurants.name, foods.type			-- Subquery that generates (Restaurant Name, Food Type) pairs
		from restaurants							-- Note: This removes duplicates so we wont see (R1, Italian) multiple times
		inner join serves using(restID)				
		inner join foods using(foodID)
		group by restaurants.name, foods.type	) as combined	-- Group by pairs (restaurant.name, foods.type) to get a list of restaurants and food types
group by combined.name;								-- Group again and count how many times a restaurant appears

-- Average Price of Foods Served by Each Chef

select 	chefs.name as chef_name,					-- We want pairs of (Chef Name, Avg Food Price)
		avg(foods.price) as average_price
from chefs											-- Four way join (We can skip restaurants since Works and Serves share a common attribute)
inner join works using(chefID)
inner join serves using(restID) 
inner join foods using(foodID)
group by chefs.name;								-- Group by the chef name so we can avg their prices

-- Find the Restaurant with the Highest Average Food Price

select 	restaurants.name as restaurant_name,		-- We want pairs of (Restaurant name, AVG price)
		avg(foods.price) as average_price
from restaurants									-- Join Restaurants and Foods using relation Serves
inner join serves using(restID)
inner join foods using(foodID)
group by restaurants.name							-- Group by restaurant name so we can calculate their avg price
having avg(foods.price) >= all (select avg(foods.price) 			-- A sub query is used in case multiple restaurants have the same average
								from restaurants 					-- Same join + Group is used as main query
								inner join serves using(restID)
								inner join foods using(foodID)
								group by restaurants.name);			

-- Determine which chef has the highest average price of the foods served at the restaurants where they work. 
-- Include the chef’s name, the average food price, and the names of the restaurants where the chef works. 
-- Sort the  results by the average food price in descending order.

select 	chefs.name as chef_name, 									-- We want pairs of (Chef name, Restaurants worked at, Avg Food price)
		group_concat(distinct restaurants.name) as restaurants, 	-- Had to look this up, Combines the restaurant names into one output, removes duplicates
		avg(foods.price) as average_price
from chefs															-- 5 way join
inner join works using(chefID)
inner join restaurants using(restID)
inner join serves using(restID)
inner join foods using (foodID)
group by chefs.name													-- We group by chefs to find their restaurants and avg food price
order by avg(foods.price) desc;										-- Order by the food price, descending
