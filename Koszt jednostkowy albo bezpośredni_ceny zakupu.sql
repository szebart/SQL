USE [ANALIZY_PJ_PK]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Raporty].[BS_Ceny zakupu]
AS
BEGIN
	-- Sprawdza ceny zakupu z kartoteki zapasu
	SELECT [No_]
		,[Item Category Code]
		,[Product Group Code]
		
		--,CAST(a.[Net Weight] AS FLOAT) AS [Waga netto]
		,CAST([Unit Cost] AS FLOAT) AS [Koszt jednostkowy]
		,CAST([Last Direct Cost] AS FLOAT) AS [Ostatni koszt bezposredni]
		,ROUND(CAST(CASE 
					WHEN [Unit Cost] = 0
						THEN [Last Direct Cost] * 1.23
					WHEN [Last Direct Cost] = 0
						THEN [Unit Cost] * 1.23
					ELSE [Unit Cost] * 1.23
					END AS FLOAT), 2) AS [Koszt jednostkowy VAT23]
		,[Primary Sales Price] AS [Cena pierwotna aktualna]
	FROM [navsql2].[Kazar].[dbo].[KAZAR$Item] WITH (NOLOCK)
	GROUP BY [No_]
		,[Item Category Code]
		,[Product Group Code]
		,[Season Code]
		,[Unit Cost]
		,[Last Direct Cost]
		,[Primary Sales Price]
	Order by [No_]
END