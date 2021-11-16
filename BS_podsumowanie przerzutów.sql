USE [ANALIZY_PJ_PK]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- pokazuje wszystkie towary w drodze - potrzebne do przerzutów i podsumowania/sprawdzenia
ALTER PROCEDURE [Raporty].[BS_podsumowanie przerzutów]
AS
BEGIN

SELECT

	a.[Transfer-to Code] AS 'Mag docelowy'
	,a.[Item No_] AS 'Nr indeksu'
	,a.[Variant Code] AS 'Rozmiar'
	,a.[Shipment Date]
	,CAST(SUM(a.[Quantity]) AS INT) AS 'Iloœæ ogólna'
	,SUM(CASE 
			WHEN a.[Realization Status] = 1
				THEN CAST(a.[Quantity] AS INT)
			ELSE '0'
			END) AS [Nowy]
	,SUM(CASE 
			WHEN a.[Realization Status] = 2
				AND a.[Not To Ship] = 1
				THEN CAST(a.[Quantity] AS INT)
			ELSE '0'
			END) AS [W toku zakryte]
	,SUM(CASE 
			WHEN a.[Realization Status] = 2
				AND a.[Not To Ship] = 0
				THEN CAST(a.[Quantity] AS INT)
			ELSE '0'
			END) AS [W toku odkryte]
	,SUM(CASE 
			WHEN a.[Realization Status] = 3
				THEN CAST(a.[Quantity] AS INT)
			ELSE '0'
			END) AS [Wydane]

	,a.[Item Category Code]
	,a.[Product Group Code]
	,a.[Transfer-from Code] AS 'Mag Ÿród³owy'
,CONCAT(CASE 
	WHEN a.[Not To Ship] = 1
		THEN 'Zakryty'
	WHEN a.[Not To Ship] = 0
		THEN 'Odkryty'
	END
,'_'
,CASE 
	WHEN a.[Realization Status] = 1
		THEN 'Nowy'
	WHEN a.[Realization Status] = 2
		THEN 'W toku'
	WHEN a.[Realization Status] = 3
		THEN 'Wydane'
	ELSE 'inny'
	END) AS [REALIZACION]
,CASE 
	WHEN a.[Not To Ship] = 1
		THEN 'Zakryty'
	WHEN a.[Not To Ship] = 0
		THEN 'Odkryty'
	END AS [Nie do wydania?]
,CASE 
	WHEN a.[Realization Status] = 1
		THEN 'Nowy'
	WHEN a.[Realization Status] = 2
		THEN 'W toku'
	WHEN a.[Realization Status] = 3
		THEN 'Wydane'
	ELSE 'inny'
	END AS 'Status realizacji'
,CASE 
	WHEN b.[WMS Shipment Status] = 0
		THEN 'WMS Nowy'
	WHEN b.[WMS Shipment Status] = 1
		THEN 'WMS Nowy'
	WHEN b.[WMS Shipment Status] = 2
		THEN 'WMS Przetwarzanie_czeka na spakowanie'
	WHEN b.[WMS Shipment Status] = 3
		THEN 'WMS zakoñczone & spakowane'
	WHEN b.[WMS Shipment Status] = 4
		THEN 'WMS w trakcie pakowania'
	WHEN b.[WMS Shipment Status] = 5
		THEN 'WMS zamkniête'
	ELSE 'inny'
	END AS [WMS Shipment Status]
,ISNULL(b.[SSCC], 'niewydane') AS 'Nr kartonu'
,ISNULL(b.[WMS Document No_], 'niewydane') AS 'Nr_dok WMS_pierwotny nr zam_BSz'
,a.[Document No_] AS 'Nr dok_okno do pobrania'
,ISNULL(b.[No_], 'niewydane') AS 'Nr dok_okno do przyjêcia'
,a.[Transfer Description] AS 'Opis MM'
,a.[Shipment Date] AS 'Data zam'
--,b.[WMS Shipment Status]
,a.[Net Weight] AS 'Waga netto'
,ISNULL(b.[Created by], 'niewydane') AS 'Stworzone przez'
FROM [navsql2].[Kazar].[dbo].[KAZAR$Transfer Line] a WITH (NOLOCK)
FULL JOIN [navsql2].[Kazar].[dbo].[KAZAR$Transfer Header] b WITH (NOLOCK) ON a.[Document No_] = b.[No_]
WHERE 


	    a.[Completely Shipped] IN (
		'1'
		,'0'
		)
	AND (
		a.[Transfer-from Code] IN (
			'MKC'
			,'MZK'
			,'MWH'
			)
		OR a.[Transfer-from Code] LIKE 'Z%'
		OR a.[Transfer-from Code] LIKE 'S%'
		OR a.[Transfer-from Code] LIKE 'P%'
		)
	AND (
		a.[Transfer-to Code] LIKE ('Z%')
		OR a.[Transfer-to Code] LIKE ('S%')
		OR a.[Transfer-to Code] LIKE ('P%')
		)
GROUP BY a.[Transfer-to Code]
	,a.[Transfer-from Code]
	,a.[Item No_]
	,a.[Item Category Code]
	,a.[Variant Code]
	,a.[Product Group Code]
,a.[Not To Ship]
,a.[Realization Status]
,a.[Shipment Date]
,b.[WMS Shipment Status]
,b.[SSCC]
,b.[WMS Document No_]
,a.[Document No_]
,b.[No_]
,a.[Transfer Description]
,a.[Shipment Date]
,a.[Net Weight]
,b.[Created by]
		,CONCAT(CASE 
	WHEN a.[Not To Ship] = 1
		THEN 'Zakryty'
	WHEN a.[Not To Ship] = 0
		THEN 'Odkryty'
	END
,CASE 
	WHEN a.[Realization Status] = 1
		THEN 'Nowy'
	WHEN a.[Realization Status] = 2
		THEN 'W toku'
	WHEN a.[Realization Status] = 3
		THEN 'Wydane'
	ELSE 'inny'
	END
	)
ORDER BY a.[Shipment Date]

	END