/*
    AdventureWorksDW2025 - Simple Sales Analysis

*/

USE AdventureWorksDW2025;

/* 1. What are total Internet sales, product costs, and gross profit? */
SELECT
    SUM(SalesAmount) AS TotalSales,
    SUM(TotalProductCost) AS TotalProductCost,
    SUM(SalesAmount - TotalProductCost) AS GrossProfit,
    COUNT(DISTINCT SalesOrderNumber) AS NumberOfOrders
FROM dbo.FactInternetSales;
GO

/* 2. How much Internet sales revenue did the business make each year? */
SELECT
    d.CalendarYear,
    SUM(s.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales AS s
JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;
GO

/* 3. Which months had the highest Internet sales? */
SELECT
    d.CalendarYear,
    d.MonthNumberOfYear,
    d.EnglishMonthName,
    SUM(s.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales AS s
JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear, d.MonthNumberOfYear, d.EnglishMonthName
ORDER BY TotalSales DESC;
GO

/* 4. Which product categories bring in the most Internet sales? */
SELECT
    pc.EnglishProductCategoryName AS ProductCategory,
    SUM(s.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales AS s
JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey
JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName
ORDER BY TotalSales DESC;
GO

/* 5. Which product subcategories earn the most gross profit? */
SELECT
    ps.EnglishProductSubcategoryName AS ProductSubcategory,
    SUM(s.SalesAmount) AS TotalSales,
    SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit
FROM dbo.FactInternetSales AS s
JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey
JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
GROUP BY ps.EnglishProductSubcategoryName
ORDER BY GrossProfit DESC;
GO

/* 6. What are the top 10 products by Internet sales revenue? */
SELECT TOP (10)
    p.EnglishProductName AS ProductName,
    SUM(s.SalesAmount) AS TotalSales,
    SUM(s.OrderQuantity) AS UnitsSold
FROM dbo.FactInternetSales AS s
JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY TotalSales DESC;
GO

/* 7. Which product colors sell the most units online? */
SELECT
    p.Color,
    SUM(s.OrderQuantity) AS UnitsSold,
    SUM(s.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales AS s
JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey
GROUP BY p.Color
ORDER BY UnitsSold DESC;
GO

/* 8. Which sales territories generate the most Internet revenue? */
SELECT
    t.SalesTerritoryGroup,
    t.SalesTerritoryCountry,
    t.SalesTerritoryRegion,
    SUM(s.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales AS s
JOIN dbo.DimSalesTerritory AS t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryGroup, t.SalesTerritoryCountry, t.SalesTerritoryRegion
ORDER BY TotalSales DESC;
GO

/* 9. Which 15 customers have spent the most online? */
SELECT TOP (15)
    s.CustomerKey,
    SUM(s.SalesAmount) AS TotalSales,
    COUNT(DISTINCT s.SalesOrderNumber) AS NumberOfOrders
FROM dbo.FactInternetSales AS s
GROUP BY s.CustomerKey
ORDER BY TotalSales DESC;
GO

/* 10. Which customers have placed more than one Internet order? */
SELECT
    s.CustomerKey,
    COUNT(DISTINCT s.SalesOrderNumber) AS NumberOfOrders,
    SUM(s.SalesAmount) AS TotalSales
FROM dbo.FactInternetSales AS s
GROUP BY s.CustomerKey
HAVING COUNT(DISTINCT s.SalesOrderNumber) > 1
ORDER BY NumberOfOrders DESC;
GO

/* 11. Which promotions are associated with the most Internet sales? */
SELECT
    p.EnglishPromotionName AS PromotionName,
    SUM(s.SalesAmount) AS TotalSales,
    SUM(s.DiscountAmount) AS TotalDiscount,
    COUNT(DISTINCT s.SalesOrderNumber) AS NumberOfOrders
FROM dbo.FactInternetSales AS s
JOIN dbo.DimPromotion AS p
    ON s.PromotionKey = p.PromotionKey
GROUP BY p.EnglishPromotionName
ORDER BY TotalSales DESC;
GO

/* 12. Which resellers generate the most sales revenue? */
SELECT TOP (15)
    r.ResellerName,
    r.BusinessType,
    SUM(s.SalesAmount) AS TotalSales
FROM dbo.FactResellerSales AS s
JOIN dbo.DimReseller AS r
    ON s.ResellerKey = r.ResellerKey
GROUP BY r.ResellerName, r.BusinessType
ORDER BY TotalSales DESC;
GO

/* 13. Which reseller business types generate the most revenue? */
SELECT
    r.BusinessType,
    SUM(s.SalesAmount) AS TotalSales,
    COUNT(DISTINCT s.SalesOrderNumber) AS NumberOfOrders
FROM dbo.FactResellerSales AS s
JOIN dbo.DimReseller AS r
    ON s.ResellerKey = r.ResellerKey
GROUP BY r.BusinessType
ORDER BY TotalSales DESC;
GO

/* 14. How do reseller sales change from year to year? */
SELECT
    d.CalendarYear,
    SUM(s.SalesAmount) AS TotalSales
FROM dbo.FactResellerSales AS s
JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey
GROUP BY d.CalendarYear
ORDER BY d.CalendarYear;
GO

/* 15. Which product categories have the largest average line discount? */
SELECT
    pc.EnglishProductCategoryName AS ProductCategory,
    AVG(s.UnitPriceDiscountPct) * 100 AS AverageDiscountPct
FROM dbo.FactInternetSales AS s
JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey
JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName
ORDER BY AverageDiscountPct DESC;
GO

/* 16. How much did Internet sales grow or decline compared with the previous year?
   CTE: totals sales by year.
*/
WITH AnnualSales AS
(
    SELECT
        d.CalendarYear,
        SUM(s.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales AS s
    JOIN dbo.DimDate AS d
        ON s.OrderDateKey = d.DateKey
    GROUP BY d.CalendarYear
)
SELECT
    CalendarYear,
    TotalSales,
    LAG(TotalSales) OVER (ORDER BY CalendarYear) AS PreviousYearSales,
    TotalSales - LAG(TotalSales) OVER (ORDER BY CalendarYear) AS ChangeFromPreviousYear
FROM AnnualSales
ORDER BY CalendarYear;
GO

/* 17. What is the running total of Internet sales by month?
*/
WITH MonthlySales AS
(
    SELECT
        d.CalendarYear,
        d.MonthNumberOfYear,
        d.EnglishMonthName,
        SUM(s.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales AS s
    JOIN dbo.DimDate AS d
        ON s.OrderDateKey = d.DateKey
    GROUP BY d.CalendarYear, d.MonthNumberOfYear, d.EnglishMonthName
)
SELECT
    CalendarYear,
    MonthNumberOfYear,
    EnglishMonthName,
    TotalSales,
    SUM(TotalSales) OVER
        (ORDER BY CalendarYear, MonthNumberOfYear ROWS UNBOUNDED PRECEDING) AS RunningTotalSales
FROM MonthlySales
ORDER BY CalendarYear, MonthNumberOfYear;
GO

/* 18. Which are the top three products by sales in each product category?
*/
WITH ProductSales AS
(
    SELECT
        pc.EnglishProductCategoryName AS ProductCategory,
        p.EnglishProductName AS ProductName,
        SUM(s.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales AS s
    JOIN dbo.DimProduct AS p
        ON s.ProductKey = p.ProductKey
    JOIN dbo.DimProductSubcategory AS ps
        ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
    JOIN dbo.DimProductCategory AS pc
        ON ps.ProductCategoryKey = pc.ProductCategoryKey
    GROUP BY pc.EnglishProductCategoryName, p.EnglishProductName
),
RankedProducts AS
(
    SELECT
        ProductCategory,
        ProductName,
        TotalSales,
        RANK() OVER (PARTITION BY ProductCategory ORDER BY TotalSales DESC) AS ProductRank
    FROM ProductSales
)
SELECT ProductCategory, ProductName, TotalSales, ProductRank
FROM RankedProducts
WHERE ProductRank <= 3
ORDER BY ProductCategory, ProductRank;
GO

/* 19. Who are the top five customers by sales in each territory?

*/
WITH CustomerTerritorySales AS
(
    SELECT
        t.SalesTerritoryRegion,
        s.CustomerKey,
        SUM(s.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales AS s
    JOIN dbo.DimSalesTerritory AS t
        ON s.SalesTerritoryKey = t.SalesTerritoryKey
    GROUP BY t.SalesTerritoryRegion, s.CustomerKey
),
RankedCustomers AS
(
    SELECT
        SalesTerritoryRegion,
        CustomerKey,
        TotalSales,
        ROW_NUMBER() OVER
            (PARTITION BY SalesTerritoryRegion ORDER BY TotalSales DESC) AS CustomerRank
    FROM CustomerTerritorySales
)
SELECT SalesTerritoryRegion, CustomerKey, TotalSales, CustomerRank
FROM RankedCustomers
WHERE CustomerRank <= 5
ORDER BY SalesTerritoryRegion, CustomerRank;
GO

/* 20. How did quarterly Internet sales change from the previous quarter?
*/
WITH QuarterlySales AS
(
    SELECT
        d.CalendarYear,
        d.CalendarQuarter,
        SUM(s.SalesAmount) AS TotalSales
    FROM dbo.FactInternetSales AS s
    JOIN dbo.DimDate AS d
        ON s.OrderDateKey = d.DateKey
    GROUP BY d.CalendarYear, d.CalendarQuarter
)
SELECT
    CalendarYear,
    CalendarQuarter,
    TotalSales,
    LAG(TotalSales) OVER (ORDER BY CalendarYear, CalendarQuarter) AS PreviousQuarterSales,
    TotalSales - LAG(TotalSales) OVER
        (ORDER BY CalendarYear, CalendarQuarter) AS ChangeFromPreviousQuarter
FROM QuarterlySales
ORDER BY CalendarYear, CalendarQuarter;
GO
