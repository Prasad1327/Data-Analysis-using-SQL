/* MYSQL Project */
USE prasad_db;
select * from cryptopunkdata;


/* 1. How many sales occurred during this time period?  */

Select count(*)
From cryptopunkdata;

/* Each row of the dataset represents a sale of an NFT hence Hence,
I have written a query which will find out the count of rows which is 19920*/   


/* 2. Return the top 5 most expensive transactions (by USD price) for this data set.
 Return the name, ETH price, and USD price, as well as the date. */
 
Select name, eth_price, usd_price, day
From cryptopunkdata
Order by usd_price desc limit 5;

/* 3. Return a table with a row for each transaction with an event column, a USD price column, 
and a moving average of USD price that averages the last 50 transactions.  */

SELECT day, usd_price, AVG(usd_price)
OVER(ORDER BY day ROWS BETWEEN 50 PRECEDING AND CURRENT ROW) as avg_usd_price
FROM cryptopunkdata;
 
 /* 4. Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.  */

Select name, avg(usd_price) as average_price
From cryptopunkdata
Group by name
Order by average_price desc;
 
 /* 5)  Return each day of the week and the number of sales that occurred on that day of the week, 
  as well as the average price in ETH. Order by the count of transactions in ascending order.   */
 
Select dayname(day) as Weekday, count(*) as NumberOfSales, Avg(eth_price)
From cryptopunkdata
Group by weekday
Order by NumberOfSales;

/*6) Construct a column that describes each sale and is called summary. The sentence should include 
   who sold the NFT name, who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
   Here’s an example summary:
   “CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14”  */

SELECT CONCAT(name, " was sold for $", ROUND(usd_price,-3), " to ", ﻿buyer_address, " from ", seller_address, " on ", day) FROM cryptopunkdata;


/* 7) Create a view called “1919_purchases” and contains any sales 
    where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.*/
    
Create view 1919_purchases AS
Select * 
From cryptopunkdata
where ﻿buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

select * from 1919_purchases;

/* 8. Create a histogram of ETH price ranges. Round to the nearest hundred value. */

Select Round(eth_price,-2) as eth_price_range, COUNT(*) AS COUNT
From cryptopunkdata
Group BY eth_price_range
Order BY eth_price_range;

/* 9. Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” 
with a query that has the lowest price each NFT was bought for and the status column saying “lowest”.
 The table should have a name column, a price column called price, and a status column. 
 Order the result set by the name of the NFT, and the status, in ascending order.    */

(SELECT name, MAX(usd_price) AS price, 'highest' AS status FROM cryptopunkdata GROUP BY name)
UNION
(SELECT name, MIN(usd_price) AS price, 'lowest' AS status FROM cryptopunkdata GROUP BY name)
ORDER BY name, status ASC;
  
/* 10) What NFT sold the most each month / year combination? 
Also, what was the name and the price in USD? Order in chronological format.    */
   
SELECT name, date_format(utc_timestamp,'%Y/%M') AS month_year, COUNT(*) FROM cryptopunkdata
GROUP BY name, month_year
ORDER BY month_year, COUNT(*) desc;

/* 11) Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year). */

Select CONCAT(Month(utc_timestamp), '/', YEAR(utc_timestamp)) AS month_year,
ROUND(SUM(usd_price), -2) AS total_volume
From cryptopunkdata 
GROUP BY month_year
ORDER BY total_volume ASC;

/* 12) Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.   */

Select count(*) as Transaction_Count
From cryptopunkdata
where ﻿buyer_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685' or seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

/* 13) Create an “estimated average value calculator” that has a representative price of the collection every day based off of these criteria:
 - Exclude all daily outlier sales where the purchase price is below 10% of the daily average price
 - Take the daily average of remaining transactions
 a) First create a query that will be used as a subquery.
    Select the event date, the USD price, and the average USD price for each day using a window function. Save it as a temporary table.
 b) Use the table you created in Part A to filter out rows where the USD prices is 
 below 10% of the daily average and return a new estimated value which is just the daily average of the filtered data. */

create temporary table temp_table as
select utc_timestamp, usd_price, Avg(usd_price)
Over (Partition by utc_timestamp) as Avg_USD_Price
from cryptopunkdata;

SELECT utc_timestamp, AVG(usd_price) AS estimated_value
FROM temp_table
WHERE usd_price >= 0.1 * avg_usd_price
GROUP BY utc_timestamp;