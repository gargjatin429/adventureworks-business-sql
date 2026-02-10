--Cumulative Revenue Analysis (Running Totals) 
--Database: AdventureWorks 2025 (OLTP) 
--Technique: Window Aggregates with Optimized Framing

/*
1. The Business Case
Stakeholder: CFO / Finance Department 
Problem: Management needs to track the velocity of 
revenue accumulation throughout the fiscal year.
Standard monthly reports are static; 
a running total allows the finance team to see exactly when 
we hit specific revenue milestones (e.g., "On what date did we cross the $10M mark?"). 
Requirement: Generate a transaction-level report showing the cumulative sum of sales, resetting annually.

2. The Solution Strategy
Window Aggregate: Used SUM() OVER(...) to create a running total.
Performance Optimization: Explicitly defined the window frame as ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.
Why? The default SQL behavior (RANGE) incurs a heavy performance penalty 
due to spooling operations in TempDB when handling duplicate dates. 
The ROWS mode forces a strictly physical row-based calculation, which is faster and memory-efficient.

3. The SQL Code */

/* ========================================================================
   Query: Running Total of Sales (YTD)
   Author: Jatin Garg
   Description: Calculates cumulative sales. optimized for performance 
                using strict row framing.
   ========================================================================
*/

SELECT 
    s.SalesOrderNumber,
    CAST(s.OrderDate AS DATE) AS OrderDate,
    s.SubTotal AS OrderValue,
    
    -- The Running Total
    -- 1. ORDER BY OrderDate: dictates the sequence of accumulation.
    -- 2. ROWS BETWEEN...: Ensures we only sum rows "seen so far".
    -- 3. (Optional Optimization): Add SalesOrderNumber to ORDER BY 
    --    to handle same-day orders deterministically.
    SUM(s.SubTotal) OVER (
        ORDER BY s.OrderDate, s.SalesOrderNumber
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningTotal_YTD

FROM Sales.SalesOrderHeader AS s
WHERE s.OrderDate >= '2024-01-01' AND s.OrderDate < '2025-01-01'
ORDER BY s.OrderDate;
