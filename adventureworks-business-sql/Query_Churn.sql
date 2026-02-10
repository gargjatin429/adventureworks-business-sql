--Customer Purchase Frequency Analysis (Time-Between-Orders) 
--Database: AdventureWorks 2025 (OLTP) 
--Technique: LAG() Window Function, Date Arithmetic
/*
1. The Business CaseStakeholder: Marketing Director
Problem: To identify customers at risk of "churning" (stopping their business with us), 
we need to measure the engagement gap. The "Days Since Last Order" metric is critical for 
triggering automated "We Miss You" email campaigns.
Requirement: Calculate the exact number of days between a customer's current order 
and their immediately preceding order.

2. The Solution Strategy
Window Functions: Used LAG() to access data from the previous row without a self-join.
Efficiency: Self-joins grow exponentially slower as table size increases.
LAG() is a linear operation, making it highly performant for large transaction tables.
Partitioning: Used PARTITION BY CustomerID to ensure the calculation resets for every new customer 
(preventing data bleed between Customer A and Customer B).

3. The SQL Code */

/* ========================================================================
   Query: Days Since Last Order Calculation
   Author: Jatin Garg
   Description: Uses LAG() to compare current order date vs previous order date.
   ========================================================================
*/

WITH CTE_Clean_Orders AS (
    -- Step 1: Data Preparation
    -- Isolate the key columns and cast DateTime to Date for cleaner calculation.
    SELECT 
        s.CustomerID,
        s.SalesOrderNumber,
        CAST(s.OrderDate AS DATE) AS OrderDate
    FROM Sales.SalesOrderHeader AS s
),

CTE_Lagged_Orders AS (
    -- Step 2: The "Look Back"
    -- LAG(Column, 1) grabs the value from the previous row within the partition.
    SELECT 
        CustomerID,
        SalesOrderNumber,
        OrderDate,
        LAG(OrderDate, 1) OVER (
            PARTITION BY CustomerID 
            ORDER BY OrderDate ASC
        ) AS PreviousOrderDate
    FROM CTE_Clean_Orders
)

-- Step 3: The Calculation
-- We calculate the gap in days.
-- Note: The first order for any customer will have a NULL 'PreviousOrderDate',
-- resulting in a NULL 'DaysSinceLastOrder', which is correct business logic.
SELECT 
    CustomerID,
    SalesOrderNumber,
    OrderDate,
    PreviousOrderDate,
    DATEDIFF(DAY, PreviousOrderDate, OrderDate) AS DaysSinceLastOrder
FROM CTE_Lagged_Orders
ORDER BY CustomerID, OrderDate;