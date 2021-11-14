
WITH CTE AS (
SELECT 
a.[country]
,a.[customer_name]
	 FROM 
    [AdventureWorksDW2019].[dbo].[jbckzr_customers] a
UNION
	SELECT
	b.country,
	b.[order_number]
	FROM [AdventureWorksDW2019].[dbo].[jbckzr_orders] b
)

,CTE2 AS (
SELECT
[country]
,CASE 
	WHEN [customer_name] LIKE '%cli%' THEN [customer_name] END AS 'customer name' 
,CASE	
	WHEN [customer_name] NOT LIKE '%cli%' THEN [customer_name]  END AS 'order number'

 FROM CTE
 )
 SELECT 

 [country],
 [customer name],
 [order number]
 FROM CTE2
 