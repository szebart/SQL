USE [ANALIZY_PJ_PK]
GO
/****** Object:  StoredProcedure [Raporty].[BS_Besty]    Script Date: 17.11.2021 14:37:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Raporty].[BS_Besty]
AS
BEGIN
DECLARE @tabela TABLE (
	[Item No_] VARCHAR(20)
	,[Quantity] INT
	,[Item Category Code] VARCHAR(10)
	,[Product Group Code] VARCHAR(10)
	,[Season Code] VARCHAR(10)
	,[Primary Sales Gross Price] INT
	,[Gross Amount] INT
	,[Net Amount] INT
	,[rn] INT
	,[[baze64Photo] VARCHAR(MAX)

	);
DECLARE @date DATE = getdate() - 15
DECLARE @Category TABLE ([Item Category Code] VARCHAR(10))

INSERT INTO @Category
VALUES ('OM')
	,('OD')
	,('TD')
	,('TM')
	,('TT')
	,('AL')
	,('AM')
	,('PO');

DECLARE @Item_season TABLE ([Season Code] VARCHAR(10))

INSERT INTO @Item_season
VALUES ('JZ21')
	,('WSZ')
	,('WSJZ')
	,('WSWL')
	,('WSO')
	,('LJ21')
	,('LJ20')
	,('LJ19');

WITH CTE
AS (
	SELECT [Store No_]
		,[Date]
		,[Item No_]
		,[Quantity]
		,[Net Amount]
		,[Gross Amount]
		,[Primary Sales Gross Price]
	FROM [Kazar_BI].[dbo].[SalesSTLines_BI] WITH (NOLOCK)

	UNION ALL
	
	SELECT [Store No_]
		,[Date]
		,[Item No_]
		,[Quantity]
		,[Net Amount]
		,[Gross Amount]
		,[Primary Sales Gross Price]
	FROM [Kazar_BI].[dbo].[ReturnsSTLines_BI] WITH (NOLOCK)
	)
	,CTE1
AS (
	SELECT [Item No_]
		,CAST(SUM([Quantity]) AS FLOAT) AS [Quantity]
		,CAST(SUM([Net Amount]) AS FLOAT) AS [Net Amount]
		,CAST(SUM([Gross Amount]) AS FLOAT) AS [Gross Amount]
		,[Primary Sales Gross Price]
		,b.[Item Category Code]
		,b.[Product Group Code]
		,b.[Season Code]
	FROM CTE a WITH (NOLOCK)
	LEFT JOIN [navsql2].[Kazar].[dbo].[KAZAR$Item] b WITH (NOLOCK)
		ON a.[Item No_] = b.[No_] collate Polish_100_CS_AS
	WHERE
		[Date] >= @date
		AND ([Store No_] != ('SMC'))
		AND ([Store No_] NOT LIKE ('H%'))
		AND ([Store No_] NOT LIKE ('C%'))
		AND ([Store No_] NOT LIKE ('M%'))
		AND ([Store No_] NOT LIKE ('R%'))
		AND (
			[Store No_] LIKE ('Z%')
			OR [Store No_] LIKE ('P%')
			OR [Store No_] LIKE ('S%')
			OR [Store No_] LIKE ('A%')
			)
		AND b.[Item Category Code] IN (
			SELECT [Item Category Code] collate Polish_100_CS_AS
			FROM @Category
			)
		AND b.[Season Code] IN (
			SELECT [Season Code] collate Polish_100_CS_AS
			FROM @Item_season
			)
		AND [Item No_] NOT LIKE ('%X%')
	GROUP BY [Item No_]
		,[Primary Sales Gross Price]
		,b.[Item Category Code]
		,b.[Product Group Code]
		,b.[Season Code]
	)
	,CTE2
AS (
	SELECT [Item No_]
		,[Quantity]
		,[Net Amount]
		,[Gross Amount]
		,[Primary Sales Gross Price]
		,[Item Category Code]
		,[Product Group Code]
		,[Season Code]
	FROM CTE1
	)
	,CTE3
AS (
	SELECT *
		,DENSE_RANK() OVER (
			PARTITION BY [Item Category Code]
			,[Season Code] ORDER BY [Net Amount] DESC
				,[Quantity] DESC
			) AS [rn]
	FROM CTE2
	)
	,CTE4
AS (
	SELECT *
	FROM CTE3
	WHERE [rn] <= 50
	)
INSERT INTO @tabela
SELECT [Item No_]
	,[Quantity]
	,[Item Category Code]
	,[Product Group Code]
	,[Season Code]
	,[Primary Sales Gross Price]
	,[Gross Amount]
	,[Net Amount]
	,[rn]
	--,[baze64Photo]
	,[zdjecie_1]
FROM CTE4 z
--LEFT JOIN [ANALIZY_PJ_PK].[dbo].[Tbl_000_NavPhotosBase64] e WITH (NOLOCK)
--	ON z.[Item No_] = e.Indeks COLLATE POLISH_CI_AS
LEFT JOIN [ANALIZY_PJ_PK].[dbo].[magento_zdjecia] e WITH (NOLOCK)
ON z.[Item No_] = e.[kazar_erp_item]

SELECT *
FROM @tabela
ORDER BY 3
	,5
	,9 ASC
		-- -- sprawdzenie zdjêæ
		-- select * 
		--FROM [navsql2].[Kazar].[dbo].[KAZAR$Item] a
		--LEFT JOIN [ANALIZY_PJ_PK].[dbo].[Tbl_000_NavPhotosBase64]  b WITH (NOLOCK)  ON a.[No_] = b.[Indeks]
		--WHERE a.[Season Code] = 'LJ21'
END