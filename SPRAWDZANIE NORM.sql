DECLARE @INDEKS AS varchar (15)
SET @INDEKS = '50065-TK-50' -- TUTAJ WPISZ INDEKS--;




SELECT [Entry No_] AS [Nr zapisu]
,convert(varchar, [Date and Time], 120) AS [Data i godzina]
,[User ID]

,CASE 
WHEN [Field No_] = 11 THEN 'Zmieniona norma MAX' 
WHEN [Field No_] = 12 THEN 'Zmieniona norma MIN'
WHEN [Field No_] = 17 THEN 'Zmieniona War-Logistyczna'
WHEN [Field No_] = 15 THEN 'Aktywacja/Deaktywacja'
ELSE 'Norma usuniêta' END AS [Typ zapisu]
,CASE 
WHEN [Type of Change] = 2 THEN 'USUNIÊCIE' ELSE 'ZMIANA' END AS [Typ zmiany]

,CASE 
WHEN [Old Value] = 'true' THEN 'Deaktywacja normy' 
WHEN [Old Value] = 'false' THEN 'Aktywacja normy' ELSE [Old Value] END AS [stara wartoœæ]
,CASE
WHEN [New Value] = 'false' THEN 'Aktywacja normy' 
WHEN [New Value] = 'true' THEN 'Deaktywacja normy' ELSE [New Value] END AS [nowa wartoœæ]


--,[Old Value] AS [Poprzednia norma/war-log] -- false to aktywacja, true to deaktywacja
--,[New Value] AS [Nowa norma/war-log]
,[Primary Key Field 1 Value] AS [Numer indeksu]
,[Primary Key Field 2 Value] AS [Rozmiar]
,[Primary Key Field 3 Value] AS [Salon]

	FROM
		[navsql2].[Kazar].[dbo].[KAZAR$Change Log Entry] WITH (NOLOCK)
		WHERE [Table No_] = '10012206' AND [Primary Key Field 1 Value] = @INDEKS AND [Field No_] NOT IN (1,2,3,5,9,21,23,26,27,28,29,30,31,50001)

		--ewentualnie mo¿na sobie wyszukaæ po dacie/godzinie lub u¿ytkowniku, lub salonie doklejaj¹c poni¿sze linijki do wiersza powy¿ej:
		--AND [Date and Time] > '2020-06-25 00:00:00.000' 
		--AND [User ID] = 'KAZARFOOTWEAR\BSZETERLAK' 
		--AND [Primary Key Field 3 Value] = 'ZWO'

		ORDER BY [Date and Time] DESC