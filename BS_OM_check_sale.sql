USE [ANALIZY]
GO
/****** Object:  StoredProcedure [Raporty].[BS_OM_check_sale]    Script Date: 16.11.2021 15:05:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--CREATE TABLE BS_TABELA_INDEKS (Item NVARCHAR(15))
--ALTER TABLE BS_TABELA_INDEKS ALTER COLUMN Item NVARCHAR(15) COLLATE Polish_CI_AS
--SELECT * FROM BS_TABELA_INDEKS
--INSERT INTO BS_TABELA_INDEKS (Item) VALUES



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
--EXEC sp_rename 'Raporty.BS_OM_check_sale',  '[Raporty].[BS_OM_check_sale]'
ALTER PROC [Raporty].[BS_OM_check_sale]
AS
BEGIN

-- sprzeda¿ bez ZALANDO - tylko PL SIEÆ
DECLARE @date1 DATE
DECLARE @date2 DATE
DECLARE @year INT

SET @date1 = '2021-09-01' --data startowa od pocz¹tku sezonu
SET @date2 = GETDATE() -- data dzi
SET @year = '2021';-- rok;

WITH CTE
AS -- sprzeda¿ ze zwrotami 
	(
	SELECT [Item No_],
		[Date],
		[Store No_],
		[Quantity],
		[Net Amount]
	FROM [dbo].[RSTLines_BI]
	
	UNION ALL
	
	SELECT [Item No_],
		[Date],
		[Store No_],
		[Quantity],
		[Net Amount]
	FROM [dbo].[SSTLines_BI]
	),
CTE1 --tylko dla indeksów z mojej tabeli
AS (
	SELECT [Item No_],
		[Date],
		[Store No_],
		CAST(SUM([Quantity]) AS FLOAT) AS 'Quantity',
		CAST(SUM([Net Amount]) AS FLOAT) AS 'Net Sales'
	FROM CTE main
	WHERE main.[Item No_] IN (
			SELECT [Item]
			FROM [ANALIZY].[dbo].[BS_TABELA_INDEKS] sub
			WHERE main.[Item No_] = sub.[Item]
				AND ([Date]) >= @date1
				AND YEAR([Date]) = @year
				AND main.[Store No_] NOT LIKE '%ZLD%'
			)
	GROUP BY [Item No_],
		[Date],
		[Store No_]
	),
CTE2
AS (
	SELECT [Item No_],
		SUM([Quantity]) AS 'Sum Quantity Sold',
		SUM([Net Sales]) AS 'SumNet Sales'
	FROM CTE1
	GROUP BY [Item No_]
	),
CTE3
AS (
	-- Kr BI
	SELECT DISTINCT [No_],
		[Season Code],
		[Item Category Code],
		[Special Group Code]
	FROM [dbo].[Item_BI]
	)
SELECT a.[Item No_],
	b.[Item Category Code] AS 'Cat',
	b.[Season Code] AS 'Season',
	b.[Special Group Code] AS 'Group',
	a.[Sum Quantity Sold] AS 'QSales',
	ROUND(a.[SumNet Sales],0) AS 'Net Sales',
	DENSE_RANK() OVER (ORDER BY a.[Sum Quantity Sold] DESC) 'Rank over QSales',
	DENSE_RANK() OVER (ORDER BY a.[SumNet Sales] DESC) 'Rank over Net Sales',
	e.[zdjecie_1] AS Photo

FROM CTE2 a
JOIN CTE3 b
	ON a.[Item No_] = b.[No_]
	--WHERE b.[Special Group Code] = 'K2'
LEFT JOIN [ANALIZY].[dbo].[magento_zdjecia] e WITH (NOLOCK)
ON a.[Item No_] = e.[kr_erp_item]
	END
