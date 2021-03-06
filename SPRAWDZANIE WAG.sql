USE [ANALIZY]
GO
/****** Object:  StoredProcedure [Raporty].[BS_Weight check]    Script Date: 16.03.2021 14:38:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Raporty].[BS_Weight check]
AS
BEGIN
	--Sprawdza wagi dla CZ i HU. Warunki: Założona norma na indeks, na stoku MKC, brak wagi. Pokazuje stoki dla magazynów oraz stok dla ZIK. budując tabelę przestawną wyciągasz opcje mające dyspozycje na salony HU ale towary nie wyjadą bo nie mają wprowadzonych wag.
  
  WITH CTE1 AS( 
       select
  [Item No_]
  ,[Variant Code]
  ,[Location Code]
  ,[Maximum Inventory] AS [Norma max]
  ,[Reorder Point] AS [Norma min]
  , CASE WHEN
             [Exclude from Replenishment] = 1 THEN 'NIE'
             ELSE 'TAK'
       END AS [Czy aktywna]
  ,[Transfer Multiple] AS [Wartosc logistyczna]
  FROM [SQL2].[Kr].[dbo].[KR HU$Replen_ Item Store Rec] AS SR WITH(NOLOCK)

UNION ALL
    select
  [Item No_]
  ,[Variant Code]
  ,[Location Code]
  ,[Maximum Inventory] AS [Norma max]
  ,[Reorder Point] AS [Norma min]
  , CASE WHEN
             [Exclude from Replenishment] = 1 THEN 'NIE'
             ELSE 'TAK'
       END AS [Czy aktywna]
  ,[Transfer Multiple] AS [Wartosc logistyczna]
  FROM [SQL2].[Kr].[dbo].[KR CZ$Replen_ Item Store Rec] AS SR WITH(NOLOCK))

,cte2 AS(
SELECT
       [Item No_]
       ,[Variant Code]
       ,SUM([Remaining Quantity]) AS [Sum]
FROM 
       [SQL2].[Kr].[dbo].[KR$Item Ledger Entry] AS SR WITH(NOLOCK)
WHERE
       [Open] = '1'
       AND
       [Positive] = '1'
       AND
       [Location Code] IN ('MKC')
GROUP BY
       [Item No_]
       ,[Variant Code])



SELECT
       ct1.[Item No_]
       ,ct1.[Variant Code]
       ,ct1.[Location Code]
       ,CAST(ct1.[Norma max] AS INT) AS [Norma max]
       ,CAST(ct1.[Norma min] AS INT) AS [Norma min]
       ,ct1.[Czy aktywna]
       ,CAST(ct1.[Wartosc logistyczna] AS INT) AS [Wartosc logistyczna]
       ,it.[Product Group Code]
       ,it.[Item Category Code]
       ,it.[Season Code]
       ,CAST(it.[Net Weight] AS float) AS [Net Weight]
       ,ISNULL(CAST(ct2.[Sum] AS INT), 0) AS [Na MKC i MZK]
       ,CASE WHEN ISNULL(CAST(ct2.[Sum] AS INT), 0) <> 0 AND CAST(it.[Net Weight] AS float) = 0 THEN 'ERROR' ELSE 'OK' END AS [Czy wagi są]
FROM
       CTE1 ct1
       LEFT JOIN
       [sql2].[Kr].[dbo].[KR$Item] it WITH (NOLOCK)
       ON ct1.[Item No_] = it.[No_]
       LEFT JOIN
       cte2 ct2
       ON ct1.[Item No_] + ct1.[Variant Code] = ct2.[Item No_] + ct2.[Variant Code]


END
