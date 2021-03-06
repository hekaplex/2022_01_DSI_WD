USE [AP]
GO
/****** Object:  StoredProcedure [dbo].[spInsertInvoice]    Script Date: 1/18/2022 2:56:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[spInsertInvoice]
       @VendorID    int,
       @InvoiceNumber  varchar(50),
       @InvoiceDate smalldatetime,
       @InvoiceTotal   money,
       @TermsID     int,
       @InvoiceDueDate smalldatetime
AS

IF EXISTS(SELECT * FROM Vendors WHERE VendorID = @VendorID)
    INSERT Invoices
    VALUES (@VendorID, @InvoiceNumber,
            @InvoiceDate, @InvoiceTotal, 0, 0,
            @TermsID, @InvoiceDueDate, NULL);
ELSE 
    THROW 50001, 'Not a valid VendorID!', 1;

	 --SELECT GETDATE()


--EXEC SPROC WITH exPLICIT MAPPING
[spInsertInvoice]
       @VendorID = 12,
       @InvoiceNumber = 'BLAH',
       @InvoiceDate = '2022-01-18 15:00:08.343',
       @InvoiceTotal = 100,
       @TermsID = 3,
       @InvoiceDueDate = '2022-01-31 15:00:08.343'

--EXEC SPROC WITH IMPLICIT ORDINAL MAPPING
[spInsertInvoice]
        12,
        'BLAH',
        '2022-01-18 15:00:08.343',
        100,
        3,
        '2022-01-31 15:00:08.343'


select * from sys.objects where type_desc like '%L_TR%'


UPDATE v
SET DefaultTermsID = v.DefaultTermsID + max(v.DefaultTermsID )
--select v.*
FROM
	Vendors v,	Invoices i
WHERE 
	i.InvoiceTotal >= 1000
	and v.DefaultTermsID != 3
AND		v.VendorID = i.VendorID


SELECT        Invoices.InvoiceNumber, Invoices.PaymentTotal
FROM            Invoices INNER JOIN
                         Vendors ON Invoices.VendorID = Vendors.VendorID
WHERE        (Invoices.PaymentTotal < 100)

--sample from Edit Query Ctrl+Shift+Q
SELECT        
FROM            Production.Product INNER JOIN
                         Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID INNER JOIN
                         Production.ProductCategory ON Production.ProductSubcategory.ProductCategoryID = Production.ProductCategory.ProductCategoryID INNER JOIN
                         Sales.SalesOrderDetail ON Production.Product.ProductID = Sales.SalesOrderDetail.ProductID 


SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE 
--search argument or sarg
--BETWEEN is inclusive on both sides
	InvoiceDate BETWEEN '2016-01-01' AND '2016-01-31'
AND
	InvoiceTotal BETWEEN 50 AND 250

ORDER BY InvoiceTotal 

--between examples
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE InvoiceDate BETWEEN '2020-01-01' AND '2020-03-31'
ORDER BY InvoiceDate

/*
SELECT 
[ALL|DISTINCT] 
[TOP n [PERCENT] [WITH TIES]]=
column_specification [[AS] result_column]
*/

SELECT top 49 percent InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE InvoiceDate BETWEEN '2016-01-01' AND '2016-03-31'
ORDER BY InvoiceDate


SELECT top 4 InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE InvoiceDate BETWEEN '2016-01-01' AND '2016-03-31'
ORDER BY InvoiceDate
--LIMIT 4

SELECT 
	InvoiceNumber
	,InvoiceDate
	,VendorContactFName + ' ' + VendorContactLName AS FullName
	,VendorContactFName + VendorContactLName AS FullNameJr
	,VendorCity + ', ' + VendorState + ' ' + VendorZipCode AS [home Address]
	,GETDATE() AS CurrentDate
	,DATEDIFF(YEAR,GETDATE(),InvoiceDate) as foo 
	,VendorName + '''s Address: '
	,VendorName + Char(39)+'s Address: '
	,VendorCity + ', ' + VendorState + ' ' + VendorZipCode
	,InvoiceTotal
	,InvoiceTotal % 10
	,cast(InvoiceTotal as int) / 10
	,convert(int, InvoiceTotal) / 10
	--modulo operator for simple splits and cyclical sequences
	,cast(InvoiceTotal as int) % 10
	,InvoiceID
,3* InvoiceID + 7  AS OrderOfPrecedence2
,InvoiceID + 7 * 3 AS OrderOfPrecedence
,(InvoiceID + 7) * 3 AS AddFirst
FROM Invoices i join Vendors v on i.VendorID = v.VendorID


--time intelligence
SELECT   
   GETDATE() AS UnconvertedDateTime,  
   CAST(GETDATE() AS NVARCHAR(30)) AS UsingCast,  
   CONVERT(nvarchar(30), GETDATE(), 126) AS UsingConvertTo_ISO8601    
   ,CONVERT(nvarchar(30), GETDATE(), 25) AS ODBC25
   ,CONVERT(nvarchar(30), GETDATE(), 121) AS ODBC_121
   ,CONVERT(nvarchar(30), GETDATE(), 21) AS ODBC_21  ;  

GO
select 5.0 / 114.0

--top & ties
SELECT  TOP 4 percent   WITH TIES 
VendorID, InvoiceDate
FROM Invoices
WHERE VendorID != 122
--WHERE VendorID <> 122
ORDER BY InvoiceDate ASC

SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE InvoiceDate BETWEEN '2016-01-01' AND '2016-03-31'
ORDER BY InvoiceDate

--bad
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE InvoiceDate >= 'y2016m01d01' 
AND InvoiceDate <= '2016/03/31'
ORDER BY InvoiceDate

--same as between
SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE InvoiceDate >= '2016/01/01' 
AND InvoiceDate <= '2016/03/31'
ORDER BY InvoiceDate


SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE NOT (InvoiceTotal >= 5000)


SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE NOT (InvoiceTotal >= 5000 OR 
NOT InvoiceDate <= '2016-02-01')
ORDER BY --InvoiceTotal DESC, 
InvoiceDate

SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE NOT InvoiceTotal >= 5000 OR 
NOT InvoiceDate <= '2016-02-01'
ORDER BY --InvoiceTotal DESC, 
InvoiceDate


SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE (InvoiceTotal < 5000
AND InvoiceDate > '2016-02-01')

SELECT InvoiceNumber, InvoiceDate, InvoiceTotal
FROM Invoices
WHERE (InvoiceTotal < 5000
AND InvoiceDate > '2016-02-01')