USE [ANALIZY]
GO
/****** Object:  StoredProcedure [Raporty].[BS_History Stock per today_3 years]    Script Date: 20.05.2021 15:28:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Raporty].[BS_History Stock per today_3 years]
AS
BEGIN
	-- Pokazuje stoki na dzień dzisiejszy i ten sam 3 lata wstecz
SELECT
	   a.[Posting Date]
	  ,a.[Item No_]
      ,a.[Location Code]
      ,CAST((a.[Inventory]) AS INT) AS Ile
	  ,b.[Item Category Code]

 FROM [Kr_BI].[dbo].[HistoryStock_BI] a WITH (nolock)
 LEFT JOIN [Kr_BI].[dbo].[Item_BI] b WITH (nolock) on a.[Item No_] = b.[No_]
 WHERE (a.[Location Code] LIKE ('Z%')
 OR a.[Location Code] LIKE ('S%')
 OR a.[Location Code] LIKE ('P%'))
 AND a.[Location Code] NOT LIKE '%\_W' ESCAPE '\'
 AND a.[Location Code] <> 'ZIK'
 AND b.[Item Category Code] IN ('TT', 'TD', 'OD', 'OM', 'TM', 'AM', 'AL')
  AND (a.[Posting Date] = CONVERT(DATE, GETDATE()) OR a.[Posting Date] = DATEADD(mm,-12,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0)) OR a.[Posting Date] = DATEADD(mm,-24,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0))
  OR a.[Posting Date] = DATEADD(mm,-36,DATEADD(dd,DATEDIFF(dd,0,GETDATE()),0))) 
  GROUP BY 
  a.[Posting Date]
 ,a.[Inventory]
 ,a.[ItemVariantKey]
 ,a.[Location Code]
 ,a.[Item No_]
 ,b.[Item Category Code]
  Order by 2

END
