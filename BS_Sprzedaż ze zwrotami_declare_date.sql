ALTER PROC [Raporty].[BS_Sprzeda¿ ze zwrotami_declare_date]
AS BEGIN

DECLARE @date1 INT
DECLARE @date2 INT
DECLARE @year INT

SET @date1 =  YEAR(GETDATE())
SET @date2 = YEAR(GETDATE())-1
SET @year = YEAR(GETDATE())-1;

WITH CTE
AS -- sprzeda¿ ze zwrotami 
	(
	SELECT [Item No_],
		[Date],
		[Store No_],
		[Quantity]
	FROM [dbo].[ReturnsSTLines_BI]
	
	UNION ALL
	
	SELECT [Item No_],
		[Date],
		[Store No_],
		[Quantity]
	FROM [dbo].[SalesSTLines_BI]
)
, CTE1
AS (
	SELECT 
	[Item No_],
	[Date],
	DAY([Date]) AS 'DAY',
	MONTH([Date]) AS 'MONTH',
	YEAR([Date]) AS 'YEAR',
	CAST(SUM([Quantity]) AS FLOAT) AS 'Quantity'
	FROM CTE
WHERE
				 YEAR([Date]) IN (@date1,@date2)
				 --AND YEAR([Date]) = @year
				AND [Store No_] NOT LIKE '%ZLD%'
			
	GROUP BY
	[Item No_],
	[Date],
	DAY([Date]),
	MONTH([Date]),
	YEAR([Date])
	)
	select * from CTE1


	END