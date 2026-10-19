-- ==================================================
-- STEP 1: DATABASE SETUP & DATA QUALITY CHECKS
-- ==================================================

-- Use the correct database
USE Sales_Data;

-- Check total number of rows in the data
SELECT 
    COUNT(*) AS Total_Rows
FROM sales;

-- Check for missing values (Nulls) in all columns
SELECT 
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Missing_ID,
    SUM(CASE WHEN sale_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Date,
    SUM(CASE WHEN Sales_Rep IS NULL THEN 1 ELSE 0 END) AS Missing_Rep,
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS Missing_Region,
    SUM(CASE WHEN Sales_Amount IS NULL THEN 1 ELSE 0 END) AS Missing_Sales_Amount,
    SUM(CASE WHEN Quantity_Sold IS NULL THEN 1 ELSE 0 END) AS Missing_Qty_Sold,
    SUM(CASE WHEN Product_Category IS NULL THEN 1 ELSE 0 END) AS Missing_Pct_catgy,
    SUM(CASE WHEN Unit_Cost IS NULL THEN 1 ELSE 0 END) AS Missing_Unt_Cost,
    SUM(CASE WHEN Unit_Price IS NULL THEN 1 ELSE 0 END) AS Missing_Unt_Price,
    SUM(CASE WHEN Customer_Type IS NULL THEN 1 ELSE 0 END) AS Missing_Cust_Type,
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS Missing_Discount,
    SUM(CASE WHEN Payment_Method IS NULL THEN 1 ELSE 0 END) AS Missing_Pyt_Med,
    SUM(CASE WHEN Sales_Channel IS NULL THEN 1 ELSE 0 END) AS Missing_Sales_Channel,
    SUM(CASE WHEN Region_and_Sales_Rep IS NULL THEN 1 ELSE 0 END) AS Missing_Regn_Sales_Rep
FROM sales;


-- ==================================================
-- STEP 2: DATA CLEANING & TRANSFORMATION (VIEW)
-- ==================================================

-- Create a clean view with calculated business columns
CREATE VIEW VW_Cleaned_Sales AS 
SELECT 
    Product_ID,
    Sale_Date,
    Sales_Rep,
    Region,
    Quantity_Sold,
    Product_Category,
    Unit_Cost,
    Unit_Price,
    Customer_Type,
    Discount,
    Payment_Method,
    Sales_Channel,
    Region_and_Sales_Rep,
    
    -- Calculate money metrics
    ROUND((Quantity_Sold * Unit_Price), 2) AS Gross_Sales,
    ROUND((Quantity_Sold * Unit_Price) * (1 - Discount), 2) AS Net_Sales,
    ROUND((Quantity_Sold * Unit_Cost), 2) AS Total_Cost,
    ROUND(((Quantity_Sold * Unit_Price) * (1 - Discount)) - (Quantity_Sold * Unit_Cost), 2) AS Total_Profit
FROM sales;


-- ==================================================
-- STEP 3: PRODUCT ANALYSIS
-- ==================================================

-- Top 3 categories by total revenue (money)
SELECT TOP 3 
    Product_Category,
    ROUND(SUM(Net_Sales), 2) AS Total_Revenue
FROM VW_Cleaned_Sales
GROUP BY Product_Category
ORDER BY Total_Revenue DESC;

-- Top 3 categories by total quantity sold (items)
SELECT TOP 3
    Product_Category,
    SUM(Quantity_Sold) AS Total_Qty_Sold
FROM VW_Cleaned_Sales
GROUP BY Product_Category
ORDER BY Total_Qty_Sold DESC;

-- Top 3 categories by total profit
SELECT TOP 3
    Product_Category,
    ROUND(SUM(Total_Profit), 2) AS Total_Profit_Product_Catg
FROM VW_Cleaned_Sales
GROUP BY Product_Category
ORDER BY Total_Profit_Product_Catg DESC;

-- Highest and average price for each category
SELECT TOP 3 
    Product_Category,
    ROUND(MAX(Unit_Price), 2) AS Highest_Price,
    ROUND(AVG(Unit_Price), 2) AS Average_Price
FROM VW_Cleaned_Sales
GROUP BY Product_Category
ORDER BY Highest_Price DESC;

-- Highest and average cost for each category
SELECT TOP 3 
    Product_Category,
    ROUND(MAX(Unit_Cost), 2) AS Highest_Cost,
    ROUND(AVG(Unit_Cost), 2) AS Average_Cost
FROM VW_Cleaned_Sales
GROUP BY Product_Category
ORDER BY Highest_Cost DESC;

-- Average discount given for each category
SELECT 
    Product_Category,
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percentage
FROM VW_Cleaned_Sales
GROUP BY Product_Category
ORDER BY Average_Discount_Percentage DESC;


-- ==================================================
-- STEP 4: TIME, REGION & TEAM ANALYSIS
-- ==================================================

-- Top 3 months by total revenue
SELECT TOP 3
    MONTH(Sale_Date) AS Month,
    ROUND(SUM(Net_Sales), 2) AS Total_Revenue
FROM VW_Cleaned_Sales
GROUP BY MONTH(Sale_Date)
ORDER BY Total_Revenue DESC;

-- Top 3 regions by total revenue
SELECT TOP 3 
    Region,
    ROUND(SUM(Net_Sales), 2) AS Total_Revenue
FROM VW_Cleaned_Sales
GROUP BY Region
ORDER BY Total_Revenue DESC;

-- Top category sold in each region (by quantity)
SELECT TOP 1
    Product_Category,
    Region,
    SUM(Quantity_Sold) AS Total_Qty_Sold
FROM VW_Cleaned_Sales
GROUP BY Product_Category, Region
ORDER BY Total_Qty_Sold DESC;

-- Top 3 sales reps by total revenue
SELECT TOP 3
    Sales_Rep,
    ROUND(SUM(Net_Sales), 2) AS Total_Revenue
FROM VW_Cleaned_Sales
GROUP BY Sales_Rep
ORDER BY Total_Revenue DESC;


-- ==================================================
-- STEP 5: CUSTOMER & SALES CHANNEL ANALYSIS
-- ==================================================

-- Total revenue by customer type
SELECT 
    Customer_Type,
    ROUND(SUM(Net_Sales), 2) AS Total_Revenue
FROM VW_Cleaned_Sales
GROUP BY Customer_Type
ORDER BY Total_Revenue DESC;

-- Total revenue by payment method
SELECT 
    Payment_Method,
    ROUND(SUM(Net_Sales), 2) AS Total_Revenue
FROM VW_Cleaned_Sales
GROUP BY Payment_Method
ORDER BY Total_Revenue DESC;

-- Best sales channel by transactions and revenue
SELECT 
    Sales_Channel,
    COUNT(*) AS Total_Transactions,
    ROUND(SUM(Net_Sales), 2) AS Total_Revenue
FROM VW_Cleaned_Sales
GROUP BY Sales_Channel
ORDER BY Total_Revenue DESC;

-- Sales channels used by returning customers
SELECT 
    Customer_Type,
    Sales_Channel,
    COUNT(Customer_Type) AS Count_Customers_Type
FROM VW_Cleaned_Sales
WHERE Customer_Type = 'Returning'
GROUP BY Sales_Channel, Customer_Type
ORDER BY Count_Customers_Type DESC;