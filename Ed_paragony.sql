/* Stosunek paragonów zawieraj¹cych w sobie dwie wskazane kategorie, do wszystkich paragonów w puli wg daty*/

DECLARE @datefrom DATE
SET @datefrom = '2020-08-01';

DECLARE @kat1 NVARCHAR(2) 
DECLARE @kat2 NVARCHAR(2) 
SET @kat1 = 'OM'
SET @kat2 = 'TM';

WITH CTE
AS (
	SELECT [Document No_],
		[Date],
		[Item No_],
		[Quantity],
		i.[Item Category Code],
		COUNT(*) OVER (
			PARTITION BY [Document No_] ORDER BY [Quantity]
			) rn,
		CONCAT (
			[Document No_],
			i.[Item Category Code] collate Polish_100_CS_AS
			) AS konkat
	FROM [dbo].[SalesSTLines_BI] a
	INNER JOIN [navsql2].[Kazar].[dbo].[KAZAR$Item] i WITH (NOLOCK)
		ON a.[Item No_] = i.[No_] collate Polish_100_CS_AS
	WHERE [Date] > @datefrom
		AND i.[Item Category Code] IN (@kat1)
		OR i.[Item Category Code] IN (@kat2)
	
	
	UNION
	
	SELECT [Document No_],
		NULL AS '[Date]',
		NULL AS '[Item No_]',
		NULL AS '[Quantity]',
		NULL AS '[Item Category Code]',
		NULL AS '[rn]',
		NULL AS '[konkat]'
	FROM [dbo].[SalesSTLines_BI] a
	INNER JOIN [navsql2].[Kazar].[dbo].[KAZAR$Item] i WITH (NOLOCK)
		ON a.[Item No_] = i.[No_] collate Polish_100_CS_AS
	WHERE [Date] > @datefrom
		AND i.[Item Category Code] IN (@kat1)
		OR i.[Item Category Code] IN (@kat2)
			
	),
CTE2
AS (
	--paragony selekcja wg parametrów
	SELECT [Document No_],
		[Date],
		[Item No_],
		[Quantity],
		[Item Category Code],
		rn,
		CONCAT (
			konkat,
			LAG(konkat) OVER (
				PARTITION BY [Document No_] ORDER BY konkat
				)
			) AS konkator
	FROM CTE
	WHERE rn > 1
	),
CTE3 -- wszystkie paragony w puli
AS (
	SELECT COUNT(DISTINCT [Document No_]) AS aa
	FROM CTE
	),
CTE4 -- wszystkie wg wybranych kategorii
AS (
	SELECT COUNT(*) AS bb
	FROM CTE2
	WHERE konkator LIKE ('%'+@kat1+'%')
		AND konkator LIKE  ('%'+@kat2+'%')
	)
SELECT aa AS 'Wszystkie paragony',
	bb AS 'Paragony kombinacja',
	ROUND((CAST(bb AS FLOAT) / CAST(aa AS FLOAT)), 4) * 100 AS '%'
FROM CTE3 a
FULL JOIN CTE4 b
	ON a.aa <> b.bb