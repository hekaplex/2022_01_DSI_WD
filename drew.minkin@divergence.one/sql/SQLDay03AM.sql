--date time conversions
SELECT DISTINCT 
	[InvoiceDate]
	, CONVERT(int,CONVERT(varchar(20),[InvoiceDate],112)) 
	, CONVERT(int,[InvoiceDate],112)
	, CONVERT(int,CONVERT(varchar(20),[InvoiceDate],12)) 
	, CONVERT(int,[InvoiceDate],12)
from Invoices


SELECT 
CONVERT(varchar, InvoiceDate) AS varcharDate,
CONVERT(varchar, InvoiceDate, 1) AS varcharDate_1,
CONVERT(varchar, InvoiceDate, 107) AS varcharDate_107,
CONVERT(varchar, InvoiceTotal) AS varcharTotal,
CONVERT(varchar, InvoiceTotal, 1) AS varcharTotal_1
,TRY_CONVERT(date, 'Feb 29 2019') AS invalidDate
FROM Invoices

--whitespace
SELECT VendorName + CHAR(13) + CHAR(10)
+ VendorAddress1 + CHAR(13) + CHAR(10)
+ VendorCity + ', ' + VendorState + ' ' 
+ VendorZipCode+ CHAR(13) + CHAR(10) + CHAR(13) + CHAR(10)
FROM Vendors