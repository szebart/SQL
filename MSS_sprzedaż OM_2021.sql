USE [ANALIZY_PJ_PK]

  --tabela z indeksami OM na MSS = SELECT * FROM [ANALIZY_PJ_PK].[dbo].[MSS_2021_OM_table]
  --USE [ANALIZY_PJ_PK]
  --TRUNCATE TABLE [MSS_2021_OM_table]
  --INSERT INTO [MSS_2021_OM_table]
  --VALUES
  --('64330-04-00'),
  --('_____'),


DECLARE @month1 INT
DECLARE @month2 INT
DECLARE @year INT

SET @month1 = 9
SET @month2 = 10
SET @year = 2021;

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
	SELECT [Item No_],
				[Date],
				[Store No_],
				CAST(SUM([Quantity]) AS FLOAT) AS 'Quantity'
	FROM CTE main
	WHERE main.[Item No_] IN (
			SELECT [INDEKS]
			FROM [ANALIZY_PJ_PK].[dbo].[MSS_2021_OM_table] sub
			WHERE main.[Item No_] = sub.[INDEKS]
				AND MONTH([Date]) IN (@month1,	@month2)
				AND YEAR([Date]) = @year
				AND main.[Store No_] NOT LIKE '%ZLD%'
			)
	GROUP BY [Item No_],
					[Date],
					[Store No_]
	)
, CTE2 AS (
	SELECT [Item No_],
				SUM([Quantity]) AS 'SumQuantitySold'
				FROM CTE1
				GROUP BY 
				[Item No_]	
	)
	SELECT 
	[Item No_],
	[SumQuantitySold],
	DENSE_RANK() OVER (ORDER BY [SumQuantitySold] DESC	) 'Dense_rank'
	FROM CTE2