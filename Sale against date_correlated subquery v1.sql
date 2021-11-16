-- wynikiem jest co siê sprzeda³o przed 01-09-2021 a nie sprzeda³o po tej dacie
SELECT  
[Item No_],
(			
SELECT 
CASE WHEN (SELECT CAST(COUNT([Item No_])AS INT)) >0  THEN 'TRUE' ELSE 'FALSE' END AS 'warunek'
			FROM [dbo].[SalesSTLines_BI] sub
			WHERE main.[Item No_] = sub.[Item No_]
			AND [Date] >= '2021-09-01'
			AND [Store No_] IN ('ZAR')
) AS 'soldafter9'

FROM [dbo].[SalesSTLines_BI] main
WHERE [Store No_] IN ('ZAR')
	AND [Date] < '2021-09-01'
			
GROUP BY [Item No_]


-- wynikiem jest co siê sprzeda³o przed 01-09-2021 a nie sprzeda³o po tej dacie


--SELECT  
--[Item No_],
--(			
--SELECT 
--CASE WHEN EXISTS (SELECT [Item No_]  THEN 'TRUE' ELSE 'FALSE' END AS 'warunek'
--			FROM [dbo].[SalesSTLines_BI] sub
--			WHERE main.[Item No_] = sub.[Item No_]
--			AND [Date] >= '2021-09-01'
--			AND [Store No_] IN ('ZAR')
--) AS 'soldafter9'

--FROM [dbo].[SalesSTLines_BI] main
--WHERE [Store No_] IN ('ZAR')
--	AND [Date] < '2021-09-01'
			
--GROUP BY [Item No_]


