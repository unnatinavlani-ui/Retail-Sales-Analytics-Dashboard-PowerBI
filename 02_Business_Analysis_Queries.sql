-- ===========================================
-- Retail Sales Business Analysis Queries
-- ===========================================
-- Project: Retail Sales Analytics Dashboard
-- Database: sales_analysis
-- Author: Unnati Navlani
-- Description:
-- This file contains SQL queries used to analyze
-- retail sales data and generate business insights.
-- ===========================================

USE sales_analysis;

-- Query 1: Calculate Total Sales
SELECT
    SUM(Quantity * Price) AS Total_Sales
FROM sales;

-- Query 2: Count Total Orders
SELECT
    COUNT(Order_id) AS Total_Orders
FROM sales;

-- Query 3: Count Unique Customers
SELECT
    COUNT(DISTINCT Customer_name) AS Total_Unique_Customers
FROM sales;

-- Query 4: Sales by Category
SELECT
    Category,
    SUM(Quantity * Price) AS Total_Sales
FROM sales
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Query 5: Sales by City
SELECT
    City,
    SUM(Quantity * Price) AS Total_Sales
FROM sales
GROUP BY City
ORDER BY Total_Sales DESC;

-- Query 6: Monthly Sales Trend
SELECT
    MONTH(Order_Date) AS Month_Number,
    MONTHNAME(Order_Date) AS Month_Name,
    SUM(Quantity * Price) AS Total_Sales
FROM sales
GROUP BY Month_Number, Month_Name
ORDER BY Month_Number;

-- Query 7: Top 5 Products by Sales
SELECT
    Product,
    SUM(Quantity * Price) AS Total_Sales
FROM sales
GROUP BY Product
ORDER BY Total_Sales DESC
LIMIT 5;

-- Query 8: Top 5 Customers by Sales
SELECT
    Customer_name,
    SUM(Quantity * Price) AS Total_Sales
FROM sales
GROUP BY Customer_name
ORDER BY Total_Sales DESC
LIMIT 5;

-- Query 9: Calculate Average Order Value
SELECT
    ROUND(SUM(Quantity * Price) / COUNT(Order_id), 2) AS Average_Order_Value
FROM sales;

-- Query 10: Calculate Electronics Sales
SELECT
    SUM(Quantity * Price) AS Electronics_Sales
FROM sales
WHERE Category = 'Electronics';

-- Query 11: Category-wise Sales Contribution
SELECT
    Category,
    SUM(Quantity * Price) AS Total_Sales,
    ROUND(
        (SUM(Quantity * Price) * 100.0) /
        (SELECT SUM(Quantity * Price) FROM sales),
        2
    ) AS Sales_Percentage
FROM sales
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Query 12: Customer Spending Analysis (CTE)
WITH Customer_Spending AS (
    SELECT
        Customer_name,
        SUM(Quantity * Price) AS Total_Spending
    FROM sales
    GROUP BY Customer_name
)
SELECT
    Customer_name,
    Total_Spending
FROM Customer_Spending
ORDER BY Total_Spending DESC;

-- Query 13: Rank Products by Total Sales
SELECT
    Product,
    SUM(Quantity * Price) AS Total_Sales,
    DENSE_RANK() OVER (
        ORDER BY SUM(Quantity * Price) DESC
    ) AS Product_Rank
FROM sales
GROUP BY Product;

-- Query 14: Running Total of Monthly Sales
SELECT
    MONTH(Order_Date) AS Month_Number,
    MONTHNAME(Order_Date) AS Month_Name,
    SUM(Quantity * Price) AS Monthly_Sales,
    SUM(SUM(Quantity * Price)) OVER (
        ORDER BY MONTH(Order_Date)
    ) AS Running_Total
FROM sales
GROUP BY MONTH(Order_Date), MONTHNAME(Order_Date)
ORDER BY Month_Number;

-- Query 15: Top Customer in Each City
WITH Customer_Spending AS
(
    SELECT 
        City,
        Customer_name,
        SUM(Quantity * Price) AS Total_Spending
    FROM sales
    GROUP BY City, Customer_name
),
Customer_Ranking AS
(
    SELECT
        City,
        Customer_name,
        Total_Spending,
        ROW_NUMBER() OVER(
            PARTITION BY City 
            ORDER BY Total_Spending DESC
        ) AS Customer_Rank
    FROM Customer_Spending
)
SELECT
    City,
    Customer_name,
    Total_Spending
FROM Customer_Ranking
WHERE Customer_Rank = 1;

-- Query 16: Previous Month vs Current Month Sales Analysis
WITH Monthly_Sales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        SUM(Quantity * Price) AS Monthly_Total_Sales
    FROM sales
    GROUP BY 
        YEAR(Order_Date),
        MONTH(Order_Date)
),

Previous_Month_Sales AS
(
    SELECT
        Sales_Year,
        Sales_Month,
        Monthly_Total_Sales,
        LAG(Monthly_Total_Sales) OVER(
            ORDER BY Sales_Year, Sales_Month
        ) AS Previous_Month_Sales
    FROM Monthly_Sales
)
SELECT
    Sales_Year,
    Sales_Month,
    Monthly_Total_Sales,
    Previous_Month_Sales,
    (Monthly_Total_Sales - Previous_Month_Sales) AS Sales_Difference
FROM Previous_Month_Sales;

-- Query 17: Highest Selling Product in Each Category
WITH Product_Sales AS
(
    SELECT
        Category,
        Product,
        SUM(Quantity * Price) AS Total_Sales
    FROM sales
    GROUP BY 
        Category, Product
),
Product_Ranking AS
(
    SELECT
        Category, Product, Total_Sales,
        ROW_NUMBER() OVER(
            PARTITION BY Category
            ORDER BY Total_Sales DESC
        ) AS Product_Rank
    FROM Product_Sales
)
SELECT
    Category, Product, Total_Sales
FROM Product_Ranking
WHERE Product_Rank = 1;

-- Query 18: Monthly Sales Growth Percentage
WITH Monthly_Sales AS
(
    SELECT
        YEAR(Order_Date) AS Sales_Year,
        MONTH(Order_Date) AS Sales_Month,
        SUM(Quantity * Price) AS Monthly_Total_Sales
    FROM sales
    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date)
),
Sales_With_Previous_Month AS
(
    SELECT
        Sales_Year,
        Sales_Month,
        Monthly_Total_Sales,
        LAG(Monthly_Total_Sales) OVER(
            ORDER BY Sales_Year, Sales_Month
        ) AS Previous_Month_Sales
    FROM Monthly_Sales
)
SELECT
    Sales_Year,
    Sales_Month,
    Monthly_Total_Sales,
    Previous_Month_Sales,
    ROUND(
        ((Monthly_Total_Sales - Previous_Month_Sales)
        / Previous_Month_Sales) * 100,
        2
    ) AS Sales_Growth_Percentage
FROM Sales_With_Previous_Month;

-- Query 19: Customer Purchase Frequency Analysis
SELECT
    Customer_id,
    Customer_name,
    COUNT(Order_id) AS Total_Purchases,
    SUM(Quantity * Price) AS Total_Spending
FROM sales
GROUP BY
    Customer_id,
    Customer_name
ORDER BY
    Total_Purchases DESC;
    
-- Query 20: Business Performance Summary
SELECT
    COUNT(DISTINCT Order_id) AS Total_Orders,
    COUNT(DISTINCT Customer_id) AS Total_Customers,
    SUM(Quantity * Price) AS Total_Sales,
    ROUND(
        SUM(Quantity * Price) / COUNT(DISTINCT Order_id),
        2
    ) AS Average_Order_Value,
    SUM(Quantity) AS Total_Quantity_Sold
FROM sales;
