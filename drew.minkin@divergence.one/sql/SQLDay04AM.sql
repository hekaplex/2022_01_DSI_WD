--TRY...CATCH
BEGIN TRY
	INSERT Invoices
	VALUES (799, 'ZXK-799', '2020-03-07', 299.95, 0, 0,
	1, '2020-04-06', NULL);
	PRINT 'SUCCESS: Record was inserted.';
END TRY
--catch an exception raised in the TRY block
--catch blocks handle teh exception to avoid breaking code upstream
BEGIN CATCH
	PRINT 'FAILURE: Record was not inserted.';
	PRINT 'Error ' + CONVERT(varchar, ERROR_NUMBER(), 1) 
	+ ': ' + ERROR_MESSAGE();
END CATCH;


RAISERROR()


INSERT Invoices
VALUES (799, 'ZXK-799', '2020-03-07', 299.95, 0, 0,1, '2020-04-06', NULL);



--dynamic SQL
SELECT DISTINCT 'INSERT INTO VENDOR select ' +  CAST(VendorID  AS varchar(20)) + ' AS VENDOR FROM foo' from Invoices


USE AP;
ALTER PROCEDURE magictable @TableNameVar varchar(128) = 'Invoices'
AS

SET @TableNameVar = 'Vendors';
EXEC ('SELECT * FROM ' + @TableNameVar )

magictable 'Vendors' JOIN Invoices on Vendors.VendoriD = Invoices.VendoriD 


USE AP;
DECLARE @DynamicSQL varchar(8000);

IF OBJECT_ID('XtabVendors') IS NOT NULL
DROP TABLE XtabVendors;

SET @DynamicSQL = 'CREATE TABLE XtabVendors ('

SELECT @DynamicSQL = @DynamicSQL + '[' +
VendorName + '] bit,'

FROM Vendors 
WHERE VendorID IN
(SELECT VendorID
FROM Invoices 
WHERE InvoiceTotal - CreditTotal - PaymentTotal > 0)
ORDER BY VendorName;

SET @DynamicSQL = @DynamicSQL + ');';
PRINT('query text: '+@DynamicSQL);
EXEC (@DynamicSQL);
SELECT * FROM XtabVendors
--system catalog information
SELECT sys.tables.name AS TableName,
sys.columns.name AS ColumnName,
sys.types.name AS Type 
INTO #TableSummary
FROM sys.tables
JOIN sys.columns
ON sys.tables.object_id = sys.columns.object_id
JOIN sys.types
ON sys.columns.system_type_id =
sys.types.system_type_id
WHERE sys.tables.name IN 
(SELECT name 
FROM sys.tables
WHERE name NOT IN ('dtproperties', 'TableSummary',
'AllUserTables'))

select * from #TableSummary

IF OBJECT_ID('tempdb..#AllUserTables') IS NOT NULL
DROP TABLE #AllUserTables;
CREATE TABLE #AllUserTables
(TableID int IDENTITY, TableName varchar(128));
GO
INSERT #AllUserTables (TableName)
SELECT name
FROM sys.tables
WHERE name NOT IN ('dtproperties', 'TableSummary',
'AllUserTables');
DECLARE @LoopMax int, @LoopVar int;
DECLARE @TableNameVar varchar(128), @ExecVar varchar(1000);
SELECT @LoopMax = MAX(TableID) FROM #AllUserTables;
SET @LoopVar = 1;
WHILE @LoopVar <= @LoopMax
BEGIN
SELECT @TableNameVar = TableName
FROM #AllUserTables
WHERE TableID = @LoopVar;
SET @ExecVar = 'DECLARE @CountVar int; ';
SET @ExecVar = @ExecVar +
'SELECT @CountVar = COUNT(*) ';
SET @ExecVar = @ExecVar + 'FROM ' +
@TableNameVar + '; ';
SET @ExecVar = @ExecVar + 'INSERT #TableSummary ';
SET @ExecVar = @ExecVar + 'VALUES (''' +
@TableNameVar + ''',';
SET @ExecVar = @ExecVar + '''*Row Count*'',';
SET @ExecVar = @ExecVar + ' @CountVar);';
EXEC (@ExecVar);
SET @LoopVar = @LoopVar + 1;
END;
SELECT * FROM #TableSummary
ORDER BY TableName, ColumnName;

select * from INFORMATION_SCHEMA.COLUMNS

select min(InvoiceDate) from Invoices
--sproc w output params
CREATE PROC spInvTotal3
@InvTotal money OUTPUT,
@DateVar date = NULL,
@VendorVar varchar(40) = '%'
AS
IF @DateVar IS NULL
SELECT @DateVar = MIN(InvoiceDate) FROM Invoices;
SELECT @InvTotal = SUM(InvoiceTotal)
FROM Invoices JOIN Vendors
ON Invoices.VendorID = Vendors.VendorID
WHERE (InvoiceDate >= @DateVar) AND
(VendorName LIKE @VendorVar);

DECLARE @MyInvTotal money;
EXEC @MyInvTotal  = spInvTotal3 @MyInvTotal, '2020-01-01', 'P%';
print(cast(@MyInvTotal as char(10)))


CREATE PROC spInvCount
	@DateVar date = NULL,
	@VendorVar varchar(40) = '%'
AS
	IF @DateVar IS NULL
		SELECT @DateVar = MIN(InvoiceDate) FROM Invoices;
		DECLARE @InvCount int;
		SELECT @InvCount = COUNT(InvoiceID)
		FROM Invoices JOIN Vendors
		ON Invoices.VendorID = Vendors.VendorID
		WHERE (InvoiceDate >= @DateVar) 
			AND
				(VendorName LIKE @VendorVar);
		RETURN @InvCount;

DECLARE @InvCount int;
EXEC @InvCount = spInvCount '2016-01-01', 'P%';
PRINT 'Invoice count: ' + CONVERT(varchar, @InvCount);

--THROW
CREATE PROC spInsertInvoice
	@VendorID int,
	@InvoiceNumber varchar(50),
	@InvoiceDate date,
	@InvoiceTotal money,
	@TermsID int,
	@InvoiceDueDate date
AS
	IF EXISTS(SELECT * FROM Vendors WHERE VendorID = @VendorID)
		INSERT Invoices
		VALUES (@VendorID, @InvoiceNumber,
		@InvoiceDate, @InvoiceTotal, 0, 0,
		@TermsID, @InvoiceDueDate, NULL);
	ELSE 
		THROW 50001, 'Not a valid VendorID!', 1;


		BEGIN TRY
			EXEC spInsertInvoice
			799,'ZXK-799','2020-03-01',299.95,1,'2020-04-01';
		END TRY
		BEGIN CATCH
			PRINT 'An error occurred.';
			PRINT 'Message: ' + CONVERT(varchar, ERROR_MESSAGE());
			IF ERROR_NUMBER() >= 50000
			PRINT 'This is a custom error message.';
		END CATCH;


USE AP;
GO
IF OBJECT_ID('spInsertInvoice') IS NOT NULL
DROP PROC spInsertInvoice;
GO
CREATE PROC spInsertInvoice
@VendorID int = NULL,
@InvoiceNumber varchar(50) = NULL,
@InvoiceDate date = NULL,
@InvoiceTotal money = NULL,
@PaymentTotal money = NULL,
@CreditTotal money = NULL,
@TermsID int = NULL,
@InvoiceDueDate date = NULL,
@PaymentDate date = NULL
AS
IF NOT EXISTS (SELECT * FROM Vendors
WHERE VendorID = @VendorID)
THROW 50001, 'Invalid VendorID.', 1;
IF @InvoiceNumber IS NULL
THROW 50001, 'Invalid InvoiceNumber.', 1;
IF @InvoiceDate IS NULL OR @InvoiceDate > GETDATE() 
OR DATEDIFF(dd, @InvoiceDate, GETDATE()) > 30
THROW 50001, 'Invalid InvoiceDate.', 1;
IF @InvoiceTotal IS NULL OR @InvoiceTotal <= 0
THROW 50001, 'Invalid InvoiceTotal.', 1;
IF @PaymentTotal IS NULL
SET @PaymentTotal = 0;
IF @CreditTotal IS NULL
SET @CreditTotal = 0;
IF @CreditTotal > @InvoiceTotal
THROW 50001, 'Invalid CreditTotal.', 1;
IF @PaymentTotal > @InvoiceTotal - @CreditTotal
THROW 50001, 'Invalid PaymentTotal.', 1;
IF NOT EXISTS (SELECT * FROM Terms
WHERE TermsID = @TermsID)
IF @TermsID IS NULL
SELECT @TermsID = DefaultTermsID
FROM Vendors
WHERE VendorID = @VendorID;
ELSE -- @TermsID IS NOT NULL
THROW 50001, 'Invalid TermsID.', 1;
IF @InvoiceDueDate IS NULL
BEGIN
DECLARE @TermsDueDays int;
SELECT @TermsDueDays = TermsDueDays
FROM Terms
WHERE TermsID = @TermsID;
SET @InvoiceDueDate =
DATEADD(day, @TermsDueDays, @InvoiceDate);
END
ELSE -- @InvoiceDueDate IS NOT NULL
IF @InvoiceDueDate < @InvoiceDate OR
DATEDIFF(dd, @InvoiceDueDate, @InvoiceDate)
> 180
THROW 50001, 'Invalid InvoiceDueDate.', 1;
IF @PaymentDate < @InvoiceDate OR
DATEDIFF(dd, @PaymentDate, GETDATE()) > 14
THROW 50001, 'Invalid PaymentDate.', 1;
INSERT Invoices
VALUES (@VendorID, @InvoiceNumber, @InvoiceDate,
@InvoiceTotal, @PaymentTotal, @CreditTotal,
@TermsID, @InvoiceDueDate, @PaymentDate);
RETURN @@IDENTITY;


--SQL type
CREATE TYPE LineItems AS
TABLE
(InvoiceID INT NOT NULL,
InvoiceSequence SMALLINT NOT NULL,
AccountNo INT NOT NULL,
ItemAmount MONEY NOT NULL,
ItemDescription VARCHAR(100) NOT NULL,
PRIMARY KEY (InvoiceID, InvoiceSequence));

CREATE PROC spInsertLineItems
@LineItems LineItems READONLY
AS
INSERT INTO InvoiceLineItems
SELECT *
FROM @LineItems


DECLARE @LineItems LineItems;
INSERT INTO @LineItems
VALUES (199, 1, 553, 127.75, 'Freight');
INSERT INTO @LineItems
VALUES (200, 2, 553, 29.25, 'Freight');
INSERT INTO @LineItems
VALUES (201, 3, 553, 48.50, 'Freight');
EXEC spInsertLineItems @LineItems


--utility system sprocs
sp_Help spInsertLineItems 
sp_HelpText spInsertLineItems 
sp_HelpDb AP
sp_Who 55
sp_Columns InvoiceLineItems

--UDF Scalar

CREATE FUNCTION fnVendorID
(@VendorName varchar(50))
RETURNS int
BEGIN
RETURN (SELECT VendorID FROM Vendors
WHERE VendorName = @VendorName);
END

--declare @vid int
--SELECT @vid = dbo.fnVendorID('Aztek Label')
--print (cast(@vid as char(3)))
print(cast(dbo.fnVendorID('Aztek Label') as char(3)))

CREATE FUNCTION fnBalanceDue()
RETURNS money
BEGIN
RETURN (SELECT SUM(InvoiceTotal - PaymentTotal -
CreditTotal)
FROM Invoices
WHERE InvoiceTotal - PaymentTotal -
CreditTotal > 0);
END;

PRINT 'Balance due: $' +
CONVERT(varchar, dbo.fnBalanceDue(), 1)


CREATE FUNCTION fnTopVendorsDue
(@CutOff money = 0)
RETURNS table
RETURN
(SELECT VendorName, SUM(InvoiceTotal) AS TotalDue
FROM Vendors JOIN Invoices
ON Vendors.VendorID = Invoices.VendorID
WHERE InvoiceTotal - CreditTotal - PaymentTotal > 0
GROUP BY VendorName
HAVING SUM(InvoiceTotal) >= @CutOff)

SELECT * FROM dbo.fnTopVendorsDue(5000);


SELECT * FROM dbo.fnTopVendorsDue(DEFAULT);

SELECT Vendors.VendorName, VendorCity, TotalDue
FROM Vendors JOIN dbo.fnTopVendorsDue(DEFAULT)
AS TopVendors
ON Vendors.VendorName = TopVendors.VendorName

CREATE FUNCTION fnCreditAdj (@HowMuch money)
RETURNS @OutTable table
(InvoiceID int, VendorID int, InvoiceNumber varchar(50),
InvoiceDate date, InvoiceTotal money,
PaymentTotal money, CreditTotal money)
BEGIN
INSERT @OutTable
SELECT InvoiceID, VendorID, InvoiceNumber, InvoiceDate,
InvoiceTotal, PaymentTotal, CreditTotal
FROM Invoices
WHERE InvoiceTotal - CreditTotal - PaymentTotal > 0;
WHILE (SELECT SUM(InvoiceTotal - CreditTotal - PaymentTotal)
FROM @OutTable) >= @HowMuch
UPDATE @OutTable
SET CreditTotal = CreditTotal + .01
WHERE InvoiceTotal - CreditTotal - PaymentTotal > 0;
RETURN;
END;

SELECT VendorName, SUM(CreditTotal) AS CreditRequest
FROM Vendors JOIN dbo.fnCreditAdj(25000) AS CreditTable
ON Vendors.VendorID = CreditTable.VendorID
GROUP BY VendorName

--triggers
CREATE TRIGGER Vendors_INSERT_UPDATE
ON Vendors
AFTER INSERT,UPDATE
AS
UPDATE Vendors
SET VendorState = UPPER(VendorState)
WHERE VendorID IN (SELECT VendorID FROM Inserted)