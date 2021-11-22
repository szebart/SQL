--SALON1 vs SALONX / miesi¹c wstecz . 3 najlepsze rzeczy, które sie sprzeda³y w SALON1 a nie w SALON2 / order po iloœci sprzeda¿y/ tylko OD i OM/ tylko pierwszy cz³on indeksu
-- V4
DECLARE @Storemain TABLE ([Store No_] NVARCHAR(7)); -- Sklep MAIN do którego porównujemy
INSERT INTO @Storemain VALUES
('ZAR');

DECLARE @TABELOZA TABLE ([Store No_] NVARCHAR(5)); -- Sklepy które porównujemy do MAIN - w nich nie sprzeda³y sie te rzeczy któe sprzeda³y siê w MAIN
INSERT INTO @TABELOZA VALUES
('ZKG'),
('ZAL'),
('ZSB'),
('ZGB'),
('ZWW'),
('ZGS'),
('ZAB'),
('ZSI');

WITH CTE AS (
		SELECT 
		 a.[Store No_]  AS 'Store'
		,b.[Item Category Code]
		,a.[Item No_]
		,REPLACE(SUBSTRING(a.[Item No_], 1, 5), '-', '') AS 'Item_short'
		,SUM(a.[Quantity]) AS 'SUMA_SALE'
			FROM [Kr_BI].[dbo].[SSTLines_BI] a
			LEFT JOIN  [Kr_BI].[dbo].[Item_BI] b
			ON a.[Item No_] = b.[No_]
				WHERE (a.[Store No_]  IN (SELECT [Store No_] collate Polish_100_CS_AS FROM @TABELOZA) OR a.[Store No_] IN (SELECT [Store No_] collate Polish_100_CS_AS FROM @Storemain))
					AND MONTH(a.[Date]) = MONTH(DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) - 1, 0))
				    AND YEAR(a.[Date]) = YEAR(GETDATE()) 
					AND b.[Item Category Code] IN ('OM','OD')
					GROUP BY a.[Store No_]
								   ,b.[Item Category Code]
								   ,a.[Item No_]
								   ,REPLACE(SUBSTRING(a.[Item No_], 1, 5), '-', '')
)
,CTE2 AS (
SELECT * FROM(	
			SELECT * 
			,ROW_NUMBER() over (partition by [Item_short] order by [Item_short] DESC) rn 
			,LEAD(Item_short) over (order by [Item_short]) ld
			FROM CTE
			) x
	WHERE x.Store IN (SELECT [Store No_] collate Polish_100_CS_AS FROM @Storemain) --sklep MAIN do którego porownuje pozosta³e
	AND  x.Item_short<> x.ld    --  je¿eli ld równy Item_short to znaczy ¿e w sklepie pod spodem w kolumnie wystêpuje ten indeks wiêc te¿ jest to dublet
	AND x.rn=1  -- partycja jest po indeksie i po indeksie posortowana. Je¿eli rn wiêkszy od 1 to znaczy ¿e to sprzeda³o siê w innym sklepie
	--ORDER BY  x.SUMA_SALE DESC -- koniec 
	)
	SELECT 
	[Store],
	[Item Category Code],
	[Item_short],
	[Item No_],
	[SUMA_SALE]
	FROM CTE2
		ORDER BY  SUMA_SALE DESC
