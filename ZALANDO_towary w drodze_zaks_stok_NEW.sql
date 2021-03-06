USE [ANALIZY]
GO
/****** Object:  StoredProcedure [Raporty].[BS_Zalando]    Script Date: 02.03.2021 10:17:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Raporty].[BS_Zalando]
AS
BEGIN
	-- Towary w rezerwacjach na ZALANDO oraz info co jest na jakim etapie, co zostało wydane i pod jakimi numerami zleceń
	SELECT a.[Item No_] AS 'Nr indeksu'
		,a.[Variant Code] AS 'Rozmiar'
		,a.[Quantity] AS 'Ilość'
		,a.[Item Category Code]
		,a.[Product Group Code]
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
			END AS [Status realizacji]
		,CASE 
			WHEN b.[WMS Shipment Status] = 0
				THEN 'WMS Nowy'
			WHEN b.[WMS Shipment Status] = 1
				THEN 'WMS Nowy'
			WHEN b.[WMS Shipment Status] = 2
				THEN 'WMS Przetwarzanie_czeka na spakowanie'
			WHEN b.[WMS Shipment Status] = 3
				THEN 'WMS zakończone & spakowane'
			WHEN b.[WMS Shipment Status] = 4
				THEN 'WMS w trakcie pakowania'
			WHEN b.[WMS Shipment Status] = 5
				THEN 'WMS zamknięte-nie wyjedzie'
			ELSE 'inny'
			END AS 'WMS Shipment Status'
		,ISNULL(b.[SSCC], 'niewydane') AS 'Nr kartonu'
		,ISNULL(b.[WMS Document No_], 'niewydane') AS 'Nr_dok WMS_pierwotny nr zam_BSz'
		,a.[Document No_] AS 'Nr dok_okno do pobrania'
		,ISNULL(b.[No_], 'niewydane') AS 'Nr dok_okno do przyjęcia'
		,a.[Transfer Description] AS 'Opis MM'
		,a.[Transfer-from Code] AS 'Mag źródłowy'
		,a.[Transfer-to Code] AS 'Mag docelowy'
		,b.[In-Transit Code]
		,a.[Shipment Date] AS 'Data zam'
		--,b.[WMS Shipment Status]
		,a.[Net Weight] AS 'Waga netto'
		,ISNULL(b.[Created by], 'niewydane') AS 'Stworzone przez'
		,a.[timestamp]
		,b.[timestamp]
	FROM [sql2].[Kr].[dbo].[KR$Transfer Line] a WITH (NOLOCK)
	FULL JOIN [sql2].[Kr].[dbo].[KR$Transfer Header] b WITH (NOLOCK) ON a.[Document No_] = b.[No_]
	WHERE a.[Completely Shipped] IN (
			'1'
			,'0'
			)
		AND a.[Transfer-from Code] IN ('MKC', 'MWH')
		AND a.[Transfer-to Code] IN (
			'MOE'
			,'MZA'
			)
		AND a.[Transfer Description] LIKE '%ZALAND%'

	ORDER BY b.[SSCC] DESC
END
