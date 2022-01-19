--derived table compatible with CTE
WITH
base
as
	(
		SELECT 
			InvoiceNumber
			, InvoiceDate
			, InvoiceTotal
			, PaymentTotal
			, CreditTotal
			, InvoiceTotal - PaymentTotal - CreditTotal
					AS BalanceDue
		FROM 
			Invoices 
	)
--use of derived table
SELECT * from base
WHERE 
	BalanceDue > 0
ORDER BY 
	InvoiceDate;


--equivalent but not best practice
--use of derived table without CTE support
SELECT * from 
(
		SELECT 
			InvoiceNumber
			, InvoiceDate
			, InvoiceTotal
			, PaymentTotal
			, CreditTotal
			, InvoiceTotal - PaymentTotal - CreditTotal
					AS BalanceDue
		FROM 
			Invoices 
	) base
WHERE 
	BalanceDue > 0
ORDER BY 
	InvoiceDate;

--join example
SELECT 
	  v.VendorName
	, i.InvoiceNumber
	, i.InvoiceDate
	, i.InvoiceTotal
FROM 
	Vendors v
INNER JOIN 
	Invoices i
	ON 
		v.VendorID = i.VendorID
WHERE 
	i.InvoiceTotal >= 500
ORDER BY v.VendorName, i.InvoiceTotal DESC

--sample simplified query
SELECT 
	  v.VendorName
FROM 
	Vendors v
ORDER BY v.VendorName DESC

SELECT 
	  DISTINCT v.VendorName
FROM 
	Vendors v
INNER JOIN 
	Invoices i
	ON 
		v.VendorID = i.VendorID
WHERE 
	i.InvoiceTotal >= 500

--Basic DML

INSERT INTO 
	Invoices 
	(
		VendorID
		, InvoiceNumber
		, InvoiceDate
		, InvoiceTotal
		, TermsID
		, InvoiceDueDate
	)
--SELECT
VALUES (12, '3289175', '2/18/2020', 165, 3, '3/18/2020')

--SAMPLE oltp QUERY
SELECT 
	* 
FROM
	Invoices
WHERE InvoiceNumber = '3289176'

SELECT
12, '3289175', '2/18/2020', 165, 3, '3/18/2020'

INSERT INTO 
	Invoices 
	(
		VendorID
		, InvoiceDate
		, InvoiceNumber
		, InvoiceTotal
		, TermsID
		, InvoiceDueDate

	)
--SELECT
VALUES (12, '2/18/2020', '3289176', 165, 3, '3/18/2020')



--OLAP insert
INSERT INTO 
	Invoices 
	(
		VendorID
		, InvoiceNumber
		, InvoiceDate
		, InvoiceTotal
		, TermsID
		, InvoiceDueDate
	)
SELECT
12, '3289178', '2/18/2020', 165, 3, '3/18/2020'

-- Best practice: SELECT before update or delete
UPDATE Invoices
SET CreditTotal = 35.89
WHERE InvoiceNumber = '367447';


SELECT 
	*, CreditTotal as OldCT,  35.89 as NewCT
FROM
	Invoices
--SET CreditTotal = 35.89
WHERE InvoiceNumber = '367447';

GO

BEGIN TRAN



UPDATE v
SET DefaultTermsID = v.DefaultTermsID + max(v.DefaultTermsID )
--select v.*
FROM
	Vendors v
INNER JOIN 
	Invoices i
	ON 
		v.VendorID = i.VendorID
WHERE 
	i.InvoiceTotal >= 1000
	and v.DefaultTermsID != 3

COMMIT TRAN
/*
Yesmed, Inc
Pollstar
Franchise Tax Board
Ingram
IBM
Computerworld
Dean Witter Reynolds
Cahners Publishing Company
*/

DELETE FROM Invoices
WHERE InvoiceNumber = '4-342-8069';

SELECT * 
--INTO scratch_invoice
FROM Invoices
WHERE InvoiceNumber = '4-342-8069';

SET IDENTITY_INSERT Invoices ON

INSERT INTO Invoices
([InvoiceID], [VendorID], [InvoiceNumber], [InvoiceDate], [InvoiceTotal], [PaymentTotal], [CreditTotal], [TermsID], [InvoiceDueDate], [PaymentDate])
select * from scratch_invoice

SET IDENTITY_INSERT Invoices OFF


SELECT * 
--INTO scratch_invoice
FROM iNvOiCeS
WHERE InvoiceNumber = '4-342-8069';


select char(60)
select unicode('<')


CREATE VIEW VendorsMin AS
SELECT VendorName, VendorState, VendorPhone
FROM Vendors

select * from VendorsMin 


select distinct VendorState from Vendors;
/*
AZ
CA
CT
DC
FL
IA
*/
--base query before making storedproc
	SELECT 
		VendorName
		, VendorState
		, VendorPhone
	FROM 
		Vendors
	WHERE 
		VendorState = 'FL'
	ORDER BY 
		VendorName;

--example of ad-hoc SQL with a variable

DECLARE @StateVar char(2) 
SET @StateVar = 'FL'
	SELECT 
		VendorName
		, VendorState
		, VendorPhone
	FROM 
		Vendors
	WHERE 
		VendorState = @StateVar
	ORDER BY 
		VendorName;
--simple sproc
CREATE PROCEDURE 
	spVendorsByState 
	@StateVar char(2) 
AS
	SELECT 
		VendorName
		, VendorState
		, VendorPhone
	FROM 
		Vendors
	WHERE 
		VendorState = @StateVar
	ORDER BY 
		VendorName;
--fully qualifies database object
EXEC AP.dbo.spVendorsByState 'CA'

ALTER PROCEDURE 
	spVendorsByState 
	@StateVar char(2) ='FL'
AS
	SELECT 
		VendorName
		, VendorState
		, VendorPhone
	FROM 
		Vendors
	WHERE 
		VendorState = @StateVar
	ORDER BY 
		VendorName;

EXEC AP.dbo.spVendorsByState @StateVar='IA'

