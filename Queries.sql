-- This is the SQL Sales Analysis list of queries organized by tasks

-- PART 1 : DATABASE CREATION AND DATA IMPORT

-- I will create a table with all the columns contained in the CSV raw data
DROP TABLE IF EXISTS RETAIL_SALES;

CREATE TABLE RETAIL_SALES (
	TRANSACTIONS_ID INT PRIMARY KEY,
	SALE_DATE DATE,
	SALE_TIME TIME,
	CUSTOMER_ID INT,
	GENDER VARCHAR(15),
	AGE INT,
	CATEGORY VARCHAR(15),
	QUANTITY INT,
	PRICE_PER_UNIT FLOAT,
	COGS FLOAT,
	TOTAL_SALE FLOAT
);

-- After importing the data into my newly created table, I check that I have a table with all the appropriate columns
SELECT
	*
FROM
	RETAIL_SALES
LIMIT
	10;
	
	-- I also check to make sure that all the data has been uploaded.  I expect 2000 records from the CSV file
SELECT
	COUNT(*)
FROM
	RETAIL_SALES;


-- PART 2: DATA CLEANING


	-- Now I examine the data to check for null values, starting with the primary key column, transactions_id
	-- and working my way through all the columns
SELECT
	*
FROM
	RETAIL_SALES
WHERE
	TRANSACTIONS_ID IS NULL
	OR
	SALE_DATE IS NULL
	OR
	SALE_TIME IS NULL
	OR
	CUSTOMER_ID IS NULL
	OR
	GENDER IS NULL
	OR
	AGE IS NULL
	OR
	CATEGORY IS NULL
	OR
	QUANTITY IS NULL
	OR
	PRICE_PER_UNIT IS NULL
	OR
	COGS IS NULL
	OR
	TOTAL_SALE IS NULL;

-- I realize that there are indeed rowa with null values so I will clean the data by deleting those rows
	
	DELETE FROM RETAIL_SALES
	WHERE
	TRANSACTIONS_ID IS NULL
	OR
	SALE_DATE IS NULL
	OR
	SALE_TIME IS NULL
	OR
	CUSTOMER_ID IS NULL
	OR
	GENDER IS NULL
	OR
	AGE IS NULL
	OR
	CATEGORY IS NULL
	OR
	QUANTITY IS NULL
	OR
	PRICE_PER_UNIT IS NULL
	OR
	COGS IS NULL
	OR
	TOTAL_SALE IS NULL;


--  PART 3 : DATA EXPLORATION

-- As part of the data exploration, I am seeking to answer a series of questions.  
-- The first question is how many unique customers do we have?  The query below yields 155

SELECT COUNT (DISTINCT CUSTOMER_ID) 
FROM RETAIL_SALES


-- How many categories do we have? The query below yields 3

SELECT COUNT (DISTINCT CATEGORY) 
FROM RETAIL_SALES

-- What is the average age of our customers? The query below yields an average age of 41.4

SELECT ROUND (AVG (AGE), 1)
FROM RETAIL_SALES

-- What is the number breakdown of genders among our customers? 
-- The query below yields 1012 Females vs 975 Males, so roughly half and half

SELECT 	SUM (CASE WHEN GENDER = 'Female' THEN 1 ELSE 0 END) AS FEMALE_COUNT,
		SUM (CASE WHEN GENDER = 'Male' THEN 1 ELSE 0 END) AS MALE_COUNT
FROM RETAIL_SALES


-- PART 3- DATA ANALYSIS AND BUSINES KEY PROBLEMS AND ANSWERS


-- I RECEIVED A SERIES OF QUESTIONS FROM THE STAKEHOLDERS I WILL NOW ANSWER

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'. 
-- 11 sales were made on this date.
SELECT
	*
FROM
	RETAIL_SALES
WHERE
	SALE_DATE  = '2022-11-05'

	
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is at least 4 in the month of Nov-2022
-- There were 17 such sales.

SELECT
	*
FROM
	RETAIL_SALES
WHERE
	CATEGORY = 'Clothing'
AND
	QUANTITY >= 4 
AND 
	TO_CHAR (SALE_DATE, 'YYYY-MM') = '2022-11'

	
-- Q.3 Write a SQL query to calculate the total sales and number of orders for each category.
-- Electronics has the highest net sales of 311,445, even though clothing has the most orders, 698
SELECT
	CATEGORY,
	SUM (TOTAL_SALE) AS NET_SALES,
	COUNT(*) AS NUM_ORDERS
FROM
	RETAIL_SALES
GROUP BY 1
ORDER BY NET_SALES DESC

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT ROUND (AVG (AGE), 2) AS BEAUTY_BUYERS_AGE
FROM RETAIL_SALES
WHERE CATEGORY = 'Beauty'

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT
	*
FROM
	RETAIL_SALES
WHERE 
	TOTAL_SALE > 1000

-- Q.6 Write a SQL query to find the total number of transactions made by each gender in each category.

SELECT
	GENDER,
	CATEGORY,
	COUNT(TRANSACTIONS_ID) AS TRANS_COUNT
	
FROM
	RETAIL_SALES
GROUP BY 2, 1

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

WITH CTE AS (
		SELECT
			EXTRACT (YEAR FROM SALE_DATE) AS YEAR_OF_SALE,
			EXTRACT (MONTH FROM SALE_DATE) AS MONTH_OF_SALE,
			ROUND (AVG(TOTAL_SALE)) AS AVERAGE,
			RANK () OVER (PARTITION BY EXTRACT (YEAR FROM SALE_DATE) ORDER BY AVG(TOTAL_SALE) DESC ) as RANKING
		FROM
		RETAIL_SALES
		GROUP BY 1,2
		)
SELECT YEAR_OF_SALE, 
		MONTH_OF_SALE,
		AVERAGE,
		RANKING
	
FROM CTE
WHERE RANKING = 1


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT CUSTOMER_ID, 
		SUM(TOTAL_SALE) AS SPENDING
FROM RETAIL_SALES
GROUP BY CUSTOMER_ID
ORDER BY SPENDING DESC
LIMIT 5

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT COUNT (DISTINCT CUSTOMER_ID) AS CUST_NUM, 
		CATEGORY
FROM RETAIL_SALES
GROUP BY 2


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH CTE AS (
		SELECT  *,
				CASE WHEN EXTRACT (HOUR FROM SALE_TIME) < 12 THEN 'MORNING'
					 WHEN EXTRACT (HOUR FROM SALE_TIME) BETWEEN 12 AND 17 THEN 'AFTERNOON'
				     ELSE  'EVENING'
				END AS SHIFT
				
		FROM RETAIL_SALES
		)
	SELECT SHIFT, 
			COUNT (TRANSACTIONS_ID) AS NUM_ORDERS
	FROM CTE 
	GROUP BY SHIFT
	
-- Q.11 How many customers bought items from each category?
WITH CTE AS (
SELECT CUSTOMER_ID, CATEGORY
FROM RETAIL_SALES
GROUP BY CUSTOMER_id, CATEGORY
ORDER BY CUSTOMER_ID
)
SELECT COUNT(*) FROM
	(SELECT CUSTOMER_ID,
			COUNT (CUSTOMER_ID) AS NUM_CAT
	FROM CTE
	GROUP BY CUSTOMER_ID)
	WHERE NUM_CAT = 3