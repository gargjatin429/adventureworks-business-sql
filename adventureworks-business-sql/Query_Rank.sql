--Regional Top Performer Analysis using Window Functions 
--Database: AdventureWorks 2025 (OLTP) 
--Technique: DENSE_RANK(), CTEs, SARGable Filtering
/*
1. The Business Case
Stakeholder: Regional Sales Manager 
Problem: The sales contest requires identifying the top 3 performing salespeople within each territory. 
A global ranking would bias results toward larger territories (like North America), 
ignoring high performers in smaller emerging markets. 
Requirement: Generate a ranked list of salespeople partitioned by Territory, 
filtering strictly for the Top 3. Ties must be handled inclusively (e.g., if two people tie for 3rd, both qualify).

2. The Solution Strategy
Granularity: Aggregated sales transactions to the SalesPerson level within each Territory.
Ranking Logic: Utilized DENSE_RANK() instead of ROW_NUMBER().
Why? In a contest, if two salespeople have the exact same sales figure, they should share the rank. 
DENSE_RANK ensures that if there is a tie for 1st place, 
the next person is 2nd (not 3rd), preserving the "Top 3" slots fairly.

Performance: Used a "SARGable" date range filter (>= AND <) 
rather than YEAR() functions to ensure index utilization on the OrderDate column.

3. The SQL Code */

/* ========================================================================
   Query: Top 3 Salespeople Per Territory (Fiscal Year 2024)
   Author: Jatin Garg
   Description: Ranks salespeople within their specific territories using 
                DENSE_RANK to handle ties fairly.
   ========================================================================
*/

WITH CTE_Territory_Performance AS (
    -- Step 1: Aggregation & Data Retrieval
    -- We join tables and group by Territory/Person to get the total sales first.
    SELECT 
        t.Name AS TerritoryName,
        t.[Group] AS TerritoryGroup,
        p.FirstName + ' ' + p.LastName AS SalesPersonName,
        SUM(s.SubTotal) AS TotalSales
    FROM Sales.SalesOrderHeader AS s
    INNER JOIN Person.Person AS p
        ON s.SalesPersonID = p.BusinessEntityID
    LEFT JOIN Sales.SalesTerritory AS t
        ON s.TerritoryID = t.TerritoryID
    
    -- SARGable Date Filter: 
    -- Using a range ensures the database engine can use the index on OrderDate.
    WHERE s.OrderDate >= '2024-01-01' AND s.OrderDate < '2025-01-01'
    
    GROUP BY t.Name, t.[Group], p.FirstName, p.LastName
),

CTE_Ranked_Sales AS (
    -- Step 2: Apply Window Function
    -- We rank the rows created in the previous step.
    SELECT 
        TerritoryName,
        SalesPersonName,
        TotalSales,
        -- PARTITION BY Territory: Restarts the ranking for every new territory.
        -- ORDER BY TotalSales DESC: The highest earner gets Rank 1.
        DENSE_RANK() OVER (
            PARTITION BY TerritoryName 
            ORDER BY TotalSales DESC
        ) AS RankInTerritory
    FROM CTE_Territory_Performance
)

-- Step 3: Final Filtering
-- Window functions cannot be filtered in the same clause they are defined,
-- so we filter the CTE result here.
SELECT *
FROM CTE_Ranked_Sales
WHERE RankInTerritory <= 3
ORDER BY TerritoryName, RankInTerritory;