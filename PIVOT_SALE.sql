	USE [ANALIZY_PJ_PK]
GO

alter PROCEDURE [Raporty].[BS_12_months_sale]
AS
BEGIN


DECLARE @item NVARCHAR(15)
SET @item = '34899-27-00' ;  ----- wpisz item, który chcesz sprawdziæ JE¯ELI TYLKO JEDEN I WIERSZ 57 ODFAJKUJ


WITH CTE AS 
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

	
SELECT 
rok, 
[Item No_],
ISNULL([1],0) AS '1',
ISNULL([2],0) AS '2',
ISNULL([3],0) AS '3',
ISNULL([4],0) AS '4',
ISNULL([5],0) AS '5',
ISNULL([6],0) AS '6',
ISNULL([7],0) AS '7',
ISNULL([8],0) AS '8',
ISNULL([9],0) AS '9',
ISNULL([10],0) AS '10',
ISNULL([11],0) AS '11',
ISNULL([12],0) AS '12'

FROM
		(
		SELECT
		[Item No_],
		YEAR([Date]) 'rok',
		MONTH([Date]) 'miesiac',
		CAST(SUM([Quantity])  AS FLOAT) AS 'ilosc'
	
		FROM CTE
		WHERE [Date] > '2019-01-01' 
		--AND [Item No_] = @item --MO¯NA WG ZADEKLAROWANEGO ITEMU
		GROUP BY 
		[Item No_],
		[Date],
		[Store No_]  
		) a

	PIVOT 
	(
	SUM([ilosc])
	FOR [miesiac]  IN ( [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
	)
	) AS pvt


	ORDER BY [rok] ASC

	end