--Multi-Period Sales Trend Analysis using Window Functions 
--Database: AdventureWorks 2025 (OLTP) 
--Tech Stack: SQL Server 2025, T-SQL
/*
1. The Business Case
Stakeholder: VP of Sales Problem: Monthly sales figures are volatile due to seasonality and random variances. 
Viewing raw monthly totals makes it difficult to identify long-term performance trends for individual sales representatives. 
Requirement: Create a report that calculates a 3-Month Rolling Average for every salesperson. 
This metric will smooth out short-term fluctuations, allowing management to see the underlying trend of sales performance over time.

2. The Technical Solution
To solve this, I employed a multi-step Common Table Expression (CTE) approach:

A. Data Cleaning: Filtered out non-human transactions (Online Sales) using INNER JOIN.

B. Aggregation: Grouped transaction-level data into Monthly Totals using DATETRUNC.

C. Window Functions: Applied AVG() OVER() with a specific frame clause (ROWS BETWEEN) 
   to calculate the moving average without losing the monthly granularity.

3. The SQL Code */


/* ========================================================================
   Query: Rolling 3-Month Sales Average per Salesperson
   Author: Jatin Garg
   Description: Calculates a moving average of sales to analyze trends 
                while preserving monthly granularity.
   ========================================================================
*/

WITH CTE_Raw_Data AS (
    -- Step 1: Data Extraction & Cleaning
    -- We join Header to Person to get names.
    -- Crucial: We use INNER JOIN to filter out 'NULL' SalesPersonIDs. 
    -- This automatically excludes "Online/Website" orders, ensuring we 
    -- only analyze employee performance.
    SELECT 
        p.FirstName + ' ' + p.LastName AS SalesPersonName,
        
        -- Granularity Control:
        -- We use DATETRUNC (available in SQL Server 2022+) to truncate the 
        -- specific order time down to the first of the month.
        -- This is faster and more storage-efficient than string formatting.
        DATETRUNC(MONTH, s.OrderDate) AS OrderMonth,
        
        s.SubTotal
    FROM Sales.SalesOrderHeader AS s
    INNER JOIN Person.Person AS p
        ON s.SalesPersonID = p.BusinessEntityID
),

CTE_Monthly_Stats AS (
    -- Step 2: Pre-Aggregation
    -- Window functions cannot easily operate on raw transactional rows 
    -- (too much noise). We must first aggregate transactions into 
    -- a single total per salesperson, per month.
    SELECT 
        SalesPersonName,
        OrderMonth,
        SUM(SubTotal) AS MonthlyTotal
    FROM CTE_Raw_Data
    GROUP BY SalesPersonName, OrderMonth
)

-- Step 3: Analytical Window Function
SELECT 
    SalesPersonName,
    OrderMonth,
    MonthlyTotal,
    
    -- The Core Logic:
    -- 1. PARTITION BY: Resets the calculation for each new salesperson.
    -- 2. ORDER BY: Ensures the average respects the chronological timeline.
    -- 3. ROWS BETWEEN: Defines the "Moving Window" as the current month 
    --    plus the previous two months.
    AVG(MonthlyTotal) OVER (
        PARTITION BY SalesPersonName 
        ORDER BY OrderMonth 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Rolling3MonthAvg
    
FROM CTE_Monthly_Stats
ORDER BY SalesPersonName, OrderMonth;