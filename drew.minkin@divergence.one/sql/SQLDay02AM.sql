--cross database query
use AP

SELECT VendorName, CustLastName, CustFirstName,
VendorState AS State, VendorCity AS City
FROM AP.dbo.Vendors AS Vendors
JOIN ProductOrders.dbo.Customers AS Customers
ON Vendors.VendorZipCode = Customers.CustZip
ORDER BY State, City

--multiple join conditions
SELECT 
	InvoiceNumber
	, InvoiceDate
	, InvoiceTotal
	, InvoiceLineItemAmount
FROM 
	Invoices 
JOIN 
	InvoiceLineItems AS LineItems
ON 
	(Invoices.InvoiceID = LineItems.InvoiceID) 
	AND
	(Invoices.InvoiceTotal > LineItems.InvoiceLineItemAmount)
ORDER BY
InvoiceNumber


SELECT 
	InvoiceNumber
	, InvoiceDate
	, InvoiceTotal
	, InvoiceLineItemAmount
FROM 
	Invoices 
JOIN 
	InvoiceLineItems AS LineItems
ON 
	(Invoices.InvoiceID = LineItems.InvoiceID) 
WHERE
	(Invoices.InvoiceTotal > LineItems.InvoiceLineItemAmount)
ORDER BY
InvoiceNumber


--self-join
SELECT 
	DISTINCT 
		Vendors1.VendorName
		,Vendors1.VendorCity
		,Vendors1.VendorState
FROM 
	Vendors AS Vendors1 
JOIN Vendors AS Vendors2
ON 
	(Vendors1.VendorCity = Vendors2.VendorCity) 
	AND
	(Vendors1.VendorState = Vendors2.VendorState) 
	--AND
	--(Vendors1.VendorID <> Vendors2.VendorID)
Order by VendorState,VendorCity

--five table query with six joins
SELECT 
	VendorName
	, InvoiceNumber
	, InvoiceDate
	,InvoiceLineItemAmount AS LineItemAmount
	,AccountDescription
	,TV.TermsDueDays
	,TI.TermsDueDays
FROM 
	Vendors
JOIN 
	Invoices 
	ON 
		Vendors.VendorID = Invoices.VendorID
JOIN 
	InvoiceLineItems
	ON 
		Invoices.InvoiceID = InvoiceLineItems.InvoiceID
JOIN 
	GLAccounts
	ON 
		InvoiceLineItems.AccountNo = GLAccounts.AccountNo
JOIN 
	Terms TI
	ON 
		TI.TermsID = Invoices.TermsID
JOIN 
	Terms TV
	ON 
		TV.TermsID = Vendors.DefaultTermsID


WHERE 
	InvoiceTotal - PaymentTotal - CreditTotal > 0
ORDER BY 
	VendorName, LineItemAmount DESC;

--outer join samples
SELECT VendorName, InvoiceNumber, InvoiceTotal
FROM Vendors 
LEFT 
JOIN Invoices
ON Vendors.VendorID = Invoices.VendorID
WHERE VendorName IS NULL
ORDER BY VendorName

use Examples
SELECT DeptName, LastName, ProjectNo
FROM Departments
FULL JOIN Employees
ON Departments.DeptNo = Employees.DeptNo
FULL JOIN Projects
ON Employees.EmployeeID = Projects.EmployeeID
ORDER BY DeptName, LastName, ProjectNo

use Examples
SELECT DeptName, LastName, ProjectNo
FROM Departments
CROSS JOIN Employees
--ON Departments.DeptNo = Employees.DeptNo
CROSS JOIN Projects
--ON Employees.EmployeeID = Projects.EmployeeID
ORDER BY DeptName, LastName, ProjectNo

--UNION
SELECT 'Active' AS Source, InvoiceNumber,
InvoiceDate, InvoiceTotal
FROM ActiveInvoices
WHERE InvoiceDate >= '02/01/2016'
UNION ALL
SELECT 'Paid' AS Source, InvoiceNumber,
InvoiceDate, InvoiceTotal
FROM PaidInvoices
WHERE InvoiceDate >= '02/01/2016'
ORDER BY InvoiceTotal DESC

use AP

--UNION + JOIN

SELECT InvoiceNumber, VendorName,
'33% Payment' AS PaymentType,
InvoiceTotal AS Total,
(InvoiceTotal * 0.333) AS Payment
FROM Invoices 
JOIN Vendors
	ON Invoices.VendorID = Vendors.VendorID
WHERE InvoiceTotal > 10000
UNION
SELECT InvoiceNumber, VendorName,
'50% Payment' AS PaymentType,
InvoiceTotal AS Total,
(InvoiceTotal * 0.5) AS Payment
FROM Invoices 
JOIN Vendors
	ON Invoices.VendorID = Vendors.VendorID
WHERE InvoiceTotal BETWEEN 500 AND 10000
UNION
SELECT InvoiceNumber, VendorName,
'Full amount' AS PaymentType,
InvoiceTotal AS Total,
InvoiceTotal AS Payment
FROM Invoices 
JOIN Vendors
ON Invoices.VendorID = Vendors.VendorID
WHERE InvoiceTotal < 500
ORDER BY PaymentType, VendorName, InvoiceNumber

use examples

--EXCEPT AND INTERSECT
SELECT CustomerFirst, CustomerLast
FROM Customers
EXCEPT
SELECT FirstName, LastName
FROM Employees
ORDER BY CustomerLast

SELECT CustomerFirst, CustomerLast
FROM Customers
INTERSECT
SELECT FirstName, LastName
FROM Employees
ORDER BY CustomerLast

use AP

--row level
SELECT (InvoiceTotal - PaymentTotal - CreditTotal)
AS TotalDue
FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0

--aggregate at ALL level (no decomposition)
SELECT 
	COUNT(*) AS NumberOfInvoices,
	SUM(InvoiceTotal - PaymentTotal - CreditTotal)
AS TotalDue
FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0

/*
Is there a pattern on Due invoces by Terms?
*/
SELECT 
	VendorID
	,COUNT(*) AS NumberOfInvoices
	,SUM(InvoiceTotal - PaymentTotal - CreditTotal)
AS TotalDue
FROM Invoices
WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0
GROUP BY 	VendorID

SELECT 'On/After 2016-03-01' AS SelectionDate, COUNT(*) AS 
NumberOfInvoices,
AVG(InvoiceTotal) AS AverageInvoiceAmount,
SUM(InvoiceTotal) AS TotalInvoiceAmount
FROM Invoices
WHERE InvoiceDate >= '2016-03-01'
UNION
SELECT 'Before  2016-03-01' AS SelectionDate, COUNT(*) AS 
NumberOfInvoices,
AVG(InvoiceTotal) AS AverageInvoiceAmount,
SUM(InvoiceTotal) AS TotalInvoiceAmount
FROM Invoices
WHERE InvoiceDate < '2016-03-01'

--EDA 101
SELECT 
YEAR(InvoiceDate )
,MONTH(InvoiceDate )
,COUNT(*) NumInvoices
FROM Invoices
GROUP BY YEAR(InvoiceDate )
,MONTH(InvoiceDate )

ALTER TABLE Invoices ADD SelectionDate AS 
	CASE 
		WHEN  InvoiceDate >= '2016-03-01'
		THEN 'On/After 2016-03-01'
		ELSE 'Before 2016-03-01'
END



SELECT
CASE 
		WHEN  InvoiceDate >= '2016-03-01'
		THEN 'On/After 2016-03-01'
		ELSE 'Before 2016-03-01'
END
, count(*)
from Invoices
group by CASE 
		WHEN  InvoiceDate >= '2016-03-01'
		THEN 'On/After 2016-03-01'
		ELSE 'Before 2016-03-01'
END



SELECT 
	TI.TermsDescription
	,SelectionDate
	, COUNT(*) AS NumberOfInvoices,
AVG(InvoiceTotal) AS AverageInvoiceAmount,
SUM(InvoiceTotal) AS TotalInvoiceAmount,
MIN(InvoiceTotal) AS MinInvoiceAmount,
MAX(InvoiceTotal) AS MaxInvoiceAmount

FROM Invoices
JOIN 
	Terms TI
	ON 
		TI.TermsID = Invoices.TermsID
GROUP BY 	SelectionDate, 	TI.TermsDescription
UNION

SELECT 
 
	TI.TermsDescription
	,
	'ALL' SelectionDate
	, COUNT(*) AS NumberOfInvoices,
AVG(InvoiceTotal) AS AverageInvoiceAmount,
SUM(InvoiceTotal) AS TotalInvoiceAmount,
MIN(InvoiceTotal) AS MinInvoiceAmount,
MAX(InvoiceTotal) AS MaxInvoiceAmount
FROM Invoices
JOIN 
	Terms TI
	ON 
		TI.TermsID = Invoices.TermsID
GROUP BY  
	TI.TermsDescription



--Categorical  Analysis
SELECT MIN(VendorName) AS FirstVendor,
MAX(VendorName) AS LastVendor,
COUNT(VendorName) AS NumberOfVendors
FROM Vendors;

--COUNT Distinct
SELECT COUNT(DISTINCT VendorID) AS NumberOfVendors,
COUNT(VendorID) AS NumberOfInvoices,
AVG(InvoiceTotal) AS AverageInvoiceAmount,
SUM(InvoiceTotal) AS TotalInvoiceAmount
FROM Invoices
WHERE InvoiceDate > '2015-07-01'

SELECT DISTINCT VendorID AS NumberOfVendors
FROM Invoices

--HAVING clause example
SELECT 
	VendorID
	, AVG(InvoiceTotal) AS AverageInvoiceAmount
--	, SUM(InvoiceTotal) AS TotalInvoiceAmount
FROM Invoices
GROUP BY VendorID
HAVING AVG(InvoiceTotal) * 2 < SUM(InvoiceTotal) 
ORDER BY AverageInvoiceAmount DESC;

--WHERE AND Agg
SELECT VendorName, COUNT(*) AS InvoiceQty,
AVG(InvoiceTotal) AS InvoiceAvg
FROM Vendors JOIN Invoices
ON Vendors.VendorID = Invoices.VendorID
WHERE InvoiceTotal > 500
GROUP BY VendorName
ORDER BY InvoiceQty DESC;

--ROLLUP
SELECT 
	VendorID
	, COUNT(*) AS InvoiceCount
	, SUM(InvoiceTotal) AS InvoiceTotal
FROM Invoices
--GROUP BY VendorID WITH ROLLUP;
GROUP BY ROLLUP(VendorID);

--CUBE
SELECT 
	VendorID
	, COUNT(*) AS InvoiceCount
	, SUM(InvoiceTotal) AS InvoiceTotal
FROM Invoices
GROUP BY CUBE(VendorID);


SELECT VendorState, VendorCity, COUNT(*) AS QtyVendors
FROM Vendors
WHERE VendorState IN ('IA', 'NJ')
GROUP BY ROLLUP(VendorState, VendorCity)
ORDER BY VendorState DESC, VendorCity DESC;

--grouping sets
SELECT VendorState, VendorCity, COUNT(*) AS QtyVendors
FROM Vendors
WHERE VendorState IN ('IA', 'NJ')
GROUP BY GROUPING SETS(VendorState, VendorCity)
ORDER BY VendorState DESC, VendorCity DESC;
