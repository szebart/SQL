-- najlepsze 5 indeks�w OM OD w miesi�cu 8.2021 i ich ruchy magazynowe z MKC na inne lokacje
DECLARE @date INT
DECLARE @year INT

SET @date =8
SET @year = 2021;

WITH CTE AS -- sprzeda� ze zwrotami 
(
SELECT  
[Item No_],
[Date],
[Store No_],
[Quantity]
FROM [dbo].[ReturnsSTLines_BI]

UNION ALL

SELECT 
[Item No_],
[Date],
[Store No_],
[Quantity]
FROM [dbo].[SalesSTLines_BI]
) 

, CTE2 AS ( -- do��czam ITEMBI
SELECT DISTINCT 
[No_],
[Item Category Code]
FROM [Kazar_BI].[dbo].[Item_BI]
)
,CTE3 AS ( -- filtruj� OM OD po dacie
SELECT
a.[Item No_],
b.[Item Category Code],
SUM(a.[Quantity]) AS 'Quantity'
FROM CTE a
JOIN CTE2 b ON a.[Item No_] = b.[No_]
WHERE b.[Item Category Code] IN ('OM', 'OD') AND MONTH(a.[Date]) = @date AND YEAR(a.[Date]) = @year

GROUP BY 
a.[Item No_],
b.[Item Category Code]
)

,CTE4 AS ( -- zapytanie o transfery z drugiej tabeli transfer�w
SELECT [Item No_],
COUNT([Item No_]) AS 'NO. Transfers from MKC TO OTHER'
from  [Kazar_BI].[dbo].[StockTransactions_BI]  
	WHERE [Location Code] = 'MKC'
	AND [Positive] = 0
	AND [Entry Type] = 4
	GROUP BY [Item No_]
)
SELECT TOP 5 -- z��czenie tabel i wynik ko�cowy
	a.[Item No_],
	CAST(a.[Quantity] AS FLOAT) as 'Quantity',
	a.[Item Category Code],
	b.[NO. Transfers from MKC TO OTHER]
	FROM CTE3 a
	JOIN CTE4 b
	ON a.[Item No_] = b.[Item No_]
	Order by Quantity DESC