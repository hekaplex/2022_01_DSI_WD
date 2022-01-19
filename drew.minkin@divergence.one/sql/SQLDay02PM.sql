--CUBE
SELECT VendorState, VendorCity, COUNT(*) AS QtyVendors
FROM Vendors
WHERE VendorState IN ('IA', 'NJ')
GROUP BY CUBE(VendorState, VendorCity)
ORDER BY VendorState DESC, VendorCity DESC;

--GROUPING SET
SELECT 
	VendorState
	, VendorCity
	, VendorZipCode
	,COUNT(*) AS QtyVendors
FROM 
	Vendors
WHERE 
	VendorState IN ('IA', 'NJ')
GROUP BY 
	GROUPING SETS(
					(VendorState, VendorCity), 
					VendorZipCode, ()
				)
ORDER BY VendorState DESC, VendorCity DESC

--OVER...PARTITION
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal,
SUM(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateTotal
,
COUNT(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateCount
,
AVG(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateAvg
FROM Invoices

--OVER..ORDER
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal,
SUM(InvoiceTotal) OVER (ORDER BY InvoiceDate) AS CumTotal,
COUNT(InvoiceTotal) OVER (ORDER BY InvoiceDate) AS Count,
AVG(InvoiceTotal) OVER (ORDER BY InvoiceDate) AS MovingAvg,
SUM(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateTotal
,
COUNT(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateCount
,
AVG(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateAvg
FROM Invoices;

--OVER..PARTITION..ORDER
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal,
SUM(InvoiceTotal) OVER (ORDER BY InvoiceDate) AS CumTotal,
COUNT(InvoiceTotal) OVER (ORDER BY InvoiceDate) AS Count,
AVG(InvoiceTotal) OVER (ORDER BY InvoiceDate) AS MovingAvg,
SUM(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateTotal
,
COUNT(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateCount
,
AVG(InvoiceTotal) OVER (PARTITION BY InvoiceDate) AS DateAvg
FROM Invoices;

SELECT InvoiceNumber, InvoiceDate, InvoiceTotal, TermsID,
SUM(InvoiceTotal) OVER (PARTITION BY TermsID ORDER BY InvoiceDate) AS CumTotal,
COUNT(InvoiceTotal) OVER (PARTITION BY TermsID ORDER BY InvoiceDate) AS Count,
AVG(InvoiceTotal) OVER (PARTITION BY TermsID ORDER BY InvoiceDate) AS MovingAvg,
SUM(InvoiceTotal) OVER (PARTITION BY InvoiceDate ORDER BY TermsID) AS DateTotal
,
COUNT(InvoiceTotal) OVER (PARTITION BY InvoiceDate ORDER BY TermsID) AS DateCount
,
AVG(InvoiceTotal) OVER (PARTITION BY InvoiceDate ORDER BY TermsID) AS DateAvg
FROM Invoices;



Use AdventureWorks2019

SELECT BusinessEntityID, TerritoryID   
    ,CONVERT(VARCHAR(20),SalesYTD,1) AS SalesYTD  
    ,DATEPART(yy,ModifiedDate) AS SalesYear  
    ,CONVERT(
		VARCHAR(20)
		,SUM(SalesYTD) 
			OVER 
				(PARTITION BY TerritoryID   
                 ORDER BY DATEPART(yy,ModifiedDate)   
                 ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING )
			,1) AS CumulativeTotal  
FROM Sales.SalesPerson  
WHERE TerritoryID IS NULL OR TerritoryID < 5;

--subquery of scalar from table
use AP

declare @avgit float
SELECT @avgit  = AVG(InvoiceTotal) FROM Invoices

SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE InvoiceTotal > --@avgit 
(SELECT AVG(InvoiceTotal)
FROM Invoices)
ORDER BY InvoiceTotal;

--ALL keyword

SELECT 
	VendorName, InvoiceNumber, InvoiceTotal
FROM Invoices 
JOIN Vendors
ON Invoices.VendorID = Vendors.VendorID
WHERE InvoiceTotal > ALL
(SELECT InvoiceTotal
FROM Invoices
WHERE VendorID = 34) 
/*
116.54
1083.58
*/
ORDER BY VendorName;

--ANY
SELECT VendorName, InvoiceNumber, InvoiceTotal
FROM Vendors 
JOIN Invoices 
ON Vendors.VendorID = Invoices.VendorID
WHERE InvoiceTotal < ANY
(SELECT InvoiceTotal
FROM Invoices
WHERE VendorID = 115);

SELECT 
	VendorName, InvoiceNumber, InvoiceTotal
FROM Invoices 
JOIN Vendors
ON Invoices.VendorID = Vendors.VendorID
WHERE InvoiceTotal > ANY
(SELECT InvoiceTotal
FROM Invoices
WHERE VendorID = 34) 
/*
116.54
1083.58
*/
ORDER BY VendorName;

SELECT VendorID, VendorName, VendorState
FROM Vendors
WHERE NOT EXISTS
(SELECT *
FROM Invoices
WHERE Invoices.VendorID = Vendors.VendorID);

--complex subquery
SELECT 
	 Summary1.VendorState
	,Summary1.VendorName
	,TopInState.SumOfInvoices
FROM
	(
		SELECT 
			V_Sub.VendorState
			, V_Sub.VendorName
			,SUM(I_Sub.InvoiceTotal) AS SumOfInvoices
		FROM 
			Invoices AS I_Sub 
		JOIN 
			Vendors AS V_Sub
			ON 
				I_Sub.VendorID = V_Sub.VendorID
	GROUP BY 
		V_Sub.VendorState
		, V_Sub.VendorName
	)
	AS Summary1
JOIN
	(
		SELECT 
			Summary2.VendorState
			,MAX(Summary2.SumOfInvoices) AS SumOfInvoices
		FROM
			(
				SELECT 
					V_Sub.VendorState
					, V_Sub.VendorName
					,SUM(I_Sub.InvoiceTotal) AS SumOfInvoices
				FROM Invoices AS I_Sub 
				JOIN Vendors AS V_Sub
					ON 
						I_Sub.VendorID = V_Sub.VendorID
		GROUP BY 
			V_Sub.VendorState
			, V_Sub.VendorName
			)
			AS Summary2
	GROUP BY Summary2.VendorState
	) 
	AS TopInState
	ON 
		Summary1.VendorState = TopInState.VendorState 
		AND
		Summary1.SumOfInvoices = TopInState.SumOfInvoices
ORDER BY Summary1.VendorState

--CTE
WITH
Summary1 	AS 
	(
		SELECT 
			V_Sub.VendorState
			, V_Sub.VendorName
			,SUM(I_Sub.InvoiceTotal) AS SumOfInvoices
		FROM 
			Invoices AS I_Sub 
		JOIN 
			Vendors AS V_Sub
			ON 
				I_Sub.VendorID = V_Sub.VendorID
	GROUP BY 
		V_Sub.VendorState
		, V_Sub.VendorName
	)
, TopInState
	AS
	(
		SELECT 
			Summary2.VendorState
			,MAX(Summary2.SumOfInvoices) AS SumOfInvoices
		FROM
			Summary1
			AS Summary2
	GROUP BY Summary2.VendorState
	)

SELECT 
	 Summary1.VendorState
	,Summary1.VendorName
	,TopInState.SumOfInvoices
FROM Summary1
JOIN 
TopInState
	ON 
		Summary1.VendorState = TopInState.VendorState 
		AND
		Summary1.SumOfInvoices = TopInState.SumOfInvoices
ORDER BY Summary1.VendorState

Use Examples
--resursive CTE
WITH EmployeesCTE AS
(
-- Anchor member
SELECT EmployeeID, 
FirstName + ' ' + LastName As EmployeeName, 
1 As Rank
FROM Employees
WHERE ManagerID IS NULL
UNION ALL
-- Recursive member
SELECT Employees.EmployeeID, 
FirstName + ' ' + LastName, 
Rank + 1
FROM Employees JOIN EmployeesCTE
ON Employees.ManagerID = EmployeesCTE.EmployeeID
)
SELECT *,SUBSTRING (EmployeeName,1,5), CHARINDEX(' ',EmployeeName),
--first char to last before space
SUBSTRING (EmployeeName,1,CHARINDEX(' ',EmployeeName)-1) AS FirstName
,SUBSTRING (EmployeeName,CHARINDEX(' ',EmployeeName)+1,Len(EmployeeName)-CHARINDEX(' ',EmployeeName)) AS LastName
FROM EmployeesCTE
ORDER BY Rank, EmployeeID;

use ap
--fallthrough
SELECT 
	InvoiceNumber
	, InvoiceTotal
	, InvoiceDate
	,InvoiceDueDate
	,CASE
		WHEN DATEDIFF(day, InvoiceDueDate, GETDATE()) > 30
		THEN 'Over 30 days past due'
		WHEN DATEDIFF(day, InvoiceDueDate, GETDATE()) > 0
		THEN '1 to 30 days past due'
		ELSE 'Current'
	END AS Status
FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0


SELECT VendorID, SUM(InvoiceTotal) AS SumInvoices,
--IIF(SUM(InvoiceTotal) < 1000, 'Low', 'High')
CASE 
	WHEN SUM(InvoiceTotal) < 1000
	THEN 'Low'
	ELSE 'High'
END
AS InvoiceRange
FROM Invoices
GROUP BY VendorID;

--CHOOSE
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal,
--CHOOSE(TermsID, '10 days', '20 days', '30 days','60 days', '90 days') AS NetDue
CASE TermsID
	WHEN 1 THEN '10 days'
	WHEN 2 THEN '20 days'
	WHEN 3 THEN '30 days'
	WHEN 4 THEN '60 days'
	ELSE '90 days'
END AS NetDue
FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0

--rank/row number function
SELECT ROW_NUMBER() OVER(PARTITION BY VendorState
ORDER BY VendorName) As RowNumber, VendorName,
VendorState
FROM Vendors;

SELECT RANK() OVER (ORDER BY InvoiceTotal) As Rank, 
DENSE_RANK() OVER (ORDER BY InvoiceTotal)
As DenseRank, InvoiceTotal, InvoiceNumber
FROM Invoices


--ntile
SELECT NTILE(3) OVER (ORDER BY InvoiceTotal) As Bucket, 
DENSE_RANK() OVER (ORDER BY InvoiceTotal)
As DenseRank, InvoiceTotal, InvoiceNumber
FROM Invoices

use examples
--lag

SELECT RepID, SalesYear, SalesTotal AS CurrentSales,
LAG(SalesTotal, 1, 0)
OVER (PARTITION BY RepID ORDER BY SalesYear)
AS LastSales,
SalesTotal - LAG(SalesTotal, 1, 0)
OVER (PARTITION BY REPID ORDER BY SalesYear)
AS Change
FROM SalesTotals;

SELECT RepID, SalesYear, SalesTotal AS CurrentSales,
LAG(SalesTotal, 2, 0)
OVER (PARTITION BY RepID ORDER BY SalesYear)
AS LastSales,
SalesTotal - LAG(SalesTotal, 2, 0)
OVER (PARTITION BY REPID ORDER BY SalesYear)
AS Change
FROM SalesTotals;


--analytic functions - complex
SELECT 
	SalesYear
	, RepID
	, SalesTotal
	,DENSE_RANK() 
		OVER 
			(
			PARTITION BY SalesYear
			ORDER BY SalesTotal
			) 
			AS DnsRank
	,RANK() 
		OVER 
			(
			PARTITION BY SalesYear
			ORDER BY SalesTotal
			) 
			AS Rank

	,PERCENT_RANK() 
		OVER 
			(
			PARTITION BY SalesYear
			ORDER BY SalesTotal
			) 
			AS PctRank
	,CUME_DIST() 
		OVER 
			(
			PARTITION BY SalesYear
			ORDER BY SalesTotal
			) 
			AS CumeDist
	,PERCENTILE_CONT(.5) 
		WITHIN GROUP 
			(ORDER BY SalesTotal)	 
		OVER 
			(PARTITION BY SalesYear) 
		AS PercentileCont
	,PERCENTILE_DISC(.5) 
		WITHIN GROUP 
			(ORDER BY SalesTotal) 
		OVER 
			(PARTITION BY SalesYear) 
		AS PercentileDisc
FROM SalesTotals;