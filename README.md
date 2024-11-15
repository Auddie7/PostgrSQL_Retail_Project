# SQL Project: Retail Sales Analysis of a raw sales dataset using SQL queries to answer sales related questions

## Project Overview

**Project Title**: Retail Sales Analysis  
**Database**: `Retail_Sales_Analysis`

Through this project I will demonstrate my SQL skills and techniques to explore, clean, and analyze retail sales data. I will be setting up a retail sales database, performing exploratory data analysis, and answering specific business questions through SQL queries.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis**: Perform exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: TI start out by by creating a database named `Retail_Sales_Analysis`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE Retail_Sales_Analysis;

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
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.
```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

SELECT * FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;

DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **What is the average customer age?**: 
```sql
SELECT ROUND (AVG (AGE), 1)
FROM RETAIL_SALES;
```
2. **What is the breakdown of customers by gender?**:
```sql
SELECT 	SUM (CASE WHEN GENDER = 'Female' THEN 1 ELSE 0 END) AS FEMALE_COUNT,
		SUM (CASE WHEN GENDER = 'Male' THEN 1 ELSE 0 END) AS MALE_COUNT
FROM RETAIL_SALES;
```
3. **Which sales were made on '2022-11-05?**:
```sql
SELECT
	*
FROM
	RETAIL_SALES
WHERE
	SALE_DATE  = '2022-11-05';
```

4. **What arre all the transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022?**:
```sql
SELECT
	*
FROM
	RETAIL_SALES
WHERE
	CATEGORY = 'Clothing'
AND
	QUANTITY >= 4 
AND 
	TO_CHAR (SALE_DATE, 'YYYY-MM') = '2022-11';
```

5. **Calculate the total sales (total_sale) for each category.**:
```sql
SELECT
	CATEGORY,
	SUM (TOTAL_SALE) AS NET_SALES,
	COUNT(*) AS NUM_ORDERS
FROM
	RETAIL_SALES
GROUP BY 1
ORDER BY NET_SALES DESC;
```

6. **What is the average age of customers who purchased items from the 'Beauty' category?**:
```sql
SELECT ROUND (AVG (AGE), 2) AS BEAUTY_BUYERS_AGE
FROM RETAIL_SALES
WHERE CATEGORY = 'Beauty';
```

7. **Find all transactions where the total_sale is greater than 1000.**:
```sql
SELECT
	*
FROM
	RETAIL_SALES
WHERE 
	TOTAL_SALE > 1000;
```

8. **What is the total number of transactions (transaction_id) made by each gender in each category?**:
```sql
SELECT
	GENDER,
	CATEGORY,
	COUNT(TRANSACTIONS_ID) AS TRANS_COUNT
	
FROM
	RETAIL_SALES
GROUP BY 2, 1;
```

9. **Calculate the average sale for each month. Find out best selling month in each year.**:
```sql
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
WHERE RANKING = 1;
```

10. **What are the top 5 customers based on the highest total sales?**:
```sql
SELECT CUSTOMER_ID, 
		SUM(TOTAL_SALE) AS SPENDING
FROM RETAIL_SALES
GROUP BY CUSTOMER_ID
ORDER BY SPENDING DESC
LIMIT 5;
```

11. **What is the number of unique customers who purchased items from each category?**:
```sql
SELECT COUNT (DISTINCT CUSTOMER_ID) AS CUST_NUM, 
		CATEGORY
FROM RETAIL_SALES
GROUP BY 2;
```

12. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
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
	GROUP BY SHIFT;
	```

13. **How many customers bought items from each category?**:
```sql
WITH CTE AS (
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
	WHERE NUM_CAT = 3;
	```
## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.


## Author - Audrey Tam

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. Please reach out with any questions or feedback.

### Reach me

Website: https://datawithaudrey.com
Email: auddie7@gmail.com
LinkdIn: www.linkedin.com/in/audrey-tam-2771341a5


Thank you for stopping by, and I look forward to connecting with you.
