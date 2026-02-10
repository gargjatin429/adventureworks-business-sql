--Multi-Year Sales Matrix by Territory 
--Database: AdventureWorks 2025 (OLTP) 
--Technique: Conditional Aggregation (Pivoting with CASE)

/*
1. The Business Case
Stakeholder: Sales Director / Executive Board 
Problem: The executive team finds long, vertical lists of transactional data difficult to compare. 
They require a "Matrix" or "Cross-Tab" view where territories are rows and years are columns. 
This format allows for immediate year-over-year comparison without needing external BI tools. 
Requirement: Transform row-based sales data into a column-based summary table for the years 2022, 2023, and 2024.

2. The Solution Strategy
Technique Selection: I chose Conditional Aggregation (SUM(CASE WHEN...)) over the specific PIVOT operator.

Reason 1 (Portability): This is standard ANSI SQL and works on any database (PostgreSQL, MySQL, Oracle), 
whereas PIVOT is proprietary to SQL Server.

Reason 2 (Flexibility): It allows for complex logic inside the aggregation 
(e.g., handling specific flags or partial years) which the rigid PIVOT syntax often struggles with.

Data Aggregation: Grouped the primary dataset by TerritoryName to establish the rows, 
then "rotated" the OrderDate dimension into columns using boolean logic.

3. The SQL Code */

/* ========================================================================
   Query: Yearly Sales Matrix (Cross-Tab)
   Author: Jatin Garg
   Description: Rotates data from rows to columns using Conditional Aggregation.
   ========================================================================
*/

SELECT 
    t.Name AS TerritoryName,
    
    -- 2022 Column
    -- Logic: "If the order is in 2022, add the SubTotal. Otherwise, add 0."
    SUM(CASE 
        WHEN YEAR(s.OrderDate) = 2022 THEN s.SubTotal 
        ELSE 0 
    END) AS Sales_2022,
    
    -- 2023 Column
    SUM(CASE 
        WHEN YEAR(s.OrderDate) = 2023 THEN s.SubTotal 
        ELSE 0 
    END) AS Sales_2023,
    
    -- 2024 Column
    SUM(CASE 
        WHEN YEAR(s.OrderDate) = 2024 THEN s.SubTotal 
        ELSE 0 
    END) AS Sales_2024,
    
    -- Total Across All Years (Horizontal Sum)
    -- This adds a helpful summary column at the end.
    SUM(CASE 
        WHEN YEAR(s.OrderDate) IN (2022, 2023, 2024) THEN s.SubTotal 
        ELSE 0 
    END) AS GrandTotal_3Yr

FROM Sales.SalesOrderHeader AS s
INNER JOIN Sales.SalesTerritory AS t
    ON s.TerritoryID = t.TerritoryID

-- Filter to optimize performance (only scan relevant years)
WHERE s.OrderDate >= '2022-01-01' AND s.OrderDate < '2025-01-01'

GROUP BY t.Name
ORDER BY t.Name;