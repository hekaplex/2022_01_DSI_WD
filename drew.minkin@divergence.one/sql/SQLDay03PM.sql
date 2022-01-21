use AdventureWorks2019
go
sp_depends [uspSearchCandidateResumes]


--sequence
CREATE SEQUENCE TestSequence3
AS int
START WITH 100 INCREMENT BY 10
MINVALUE 0 MAXVALUE 1000000
CYCLE CACHE 10;

CREATE TABLE SequenceTable(
SequenceNo INT,
Description VARCHAR(50));
--Insert the next value for a sequence
INSERT INTO SequenceTable
VALUES (NEXT VALUE FOR TestSequence3, 'First inserted row')
INSERT INTO SequenceTable
VALUES (NEXT VALUE FOR TestSequence3,
'Second inserted row')
INSERT INTO SequenceTable
VALUES (NEXT VALUE FOR TestSequence3,
'Third inserted row')

SELECT current_value FROM sys.sequences
WHERE name = 'TestSequence3';

select * from SequenceTable

--temp local vs global
select * into ##vendors from Vendors


select * into #vendors from Vendors

--DAX/Direct Query example from Performace Analyzer
select [$Table].[InvoiceID] as [InvoiceID],
    [$Table].[InvoiceSequence] as [InvoiceSequence],
    [$Table].[AccountNo] as [AccountNo],
    [$Table].[InvoiceLineItemAmount] as [InvoiceLineItemAmount],
    [$Table].[InvoiceLineItemDescription] as [InvoiceLineItemDescription]
from [dbo].[InvoiceLineItems] as [$Table]

select [_].[InvoiceID],
    [_].[InvoiceSequence],
    [_].[AccountNo],
    [_].[InvoiceLineItemAmount],
    [_].[InvoiceLineItemDescription]
from [dbo].[InvoiceLineItems] as [_]
where [_].[InvoiceLineItemDescription] = 'Freight'

CREATE VIEW PQ_Sample AS
select [$Outer].[InvoiceID2] as [InvoiceID],
    [$Outer].[AccountNo2] as [AccountNo],
    [$Outer].[InvoiceLineItemAmount] as [InvoiceLineItemAmount],
    [$Outer].[InvoiceLineItemDescription] as [InvoiceLineItemDescription],
    [$Outer].[AccountNo] as [AccountNo.1],
    [$Outer].[AccountDescription] as [AccountDescription],
    [$Inner].[InvoiceTotal] as [InvoiceTotal],
    [$Inner].[CreditTotal] as [CreditTotal]
from 
(
    select [$Outer].[InvoiceID] as [InvoiceID2],
        [$Outer].[AccountNo2] as [AccountNo2],
        [$Outer].[InvoiceLineItemAmount] as [InvoiceLineItemAmount],
        [$Outer].[InvoiceLineItemDescription] as [InvoiceLineItemDescription],
        [$Inner].[AccountNo] as [AccountNo],
        [$Inner].[AccountDescription] as [AccountDescription]
    from 
    (
        select [_].[InvoiceID] as [InvoiceID],
            [_].[AccountNo] as [AccountNo2],
            [_].[InvoiceLineItemAmount] as [InvoiceLineItemAmount],
            [_].[InvoiceLineItemDescription] as [InvoiceLineItemDescription]
        from [dbo].[InvoiceLineItems] as [_]
        where [_].[InvoiceLineItemDescription] = 'Freight'
    ) as [$Outer]
    inner join [dbo].[GLAccounts] as [$Inner] on ([$Outer].[AccountNo2] = [$Inner].[AccountNo])
) as [$Outer]
inner join [dbo].[Invoices] as [$Inner] on ([$Outer].[InvoiceID2] = [$Inner].[InvoiceID])


SELECT 
TOP (1000001) *
FROM 
(

SELECT [t4].[VendorID],SUM([t4].[InvoiceTotal])
 AS [a0]
FROM 
(
(
select [$Table].[InvoiceID] as [InvoiceID],
    [$Table].[VendorID] as [VendorID],
    [$Table].[InvoiceNumber] as [InvoiceNumber],
    [$Table].[InvoiceDate] as [InvoiceDate],
    [$Table].[InvoiceTotal] as [InvoiceTotal],
    [$Table].[PaymentTotal] as [PaymentTotal],
    [$Table].[CreditTotal] as [CreditTotal],
    [$Table].[TermsID] as [TermsID],
    [$Table].[InvoiceDueDate] as [InvoiceDueDate],
    [$Table].[PaymentDate] as [PaymentDate],
    [$Table].[SelectionDate] as [SelectionDate]
from [dbo].[Invoices] as [$Table]
)
)
 AS [t4]
GROUP BY [t4].[VendorID]
)
 AS [MainTable]
WHERE 
(

NOT(
(
[a0] IS NULL 
)
)

)
 


 

--// DAX Query
--DEFINE
--  VAR __DS0Core = 
--    SUMMARIZECOLUMNS(
--      ROLLUPADDISSUBTOTAL('Invoices'[VendorID], "IsGrandTotalRowTotal"),
--      "SumInvoiceTotal", CALCULATE(SUM('Invoices'[InvoiceTotal]))
--    )

--  VAR __DS0PrimaryWindowed = 
--    TOPN(502, __DS0Core, [IsGrandTotalRowTotal], 0, 'Invoices'[VendorID], 1)

--EVALUATE
--  __DS0PrimaryWindowed

--ORDER BY
--  [IsGrandTotalRowTotal] DESC, 'Invoices'[VendorID]

--system catalog
select object_name(d.object_id) , d.name from sys.indexes d


SELECT 
sys.tables.object_id,
sys.tables.name AS TableName,
sys.schemas.name AS SchemaName
FROM sys.tables INNER JOIN sys.schemas
ON sys.tables.schema_id = sys.schemas.schema_id

select sys.indexes

--print example
USE AP;

DECLARE @TotalDue money;

--SET @TotalDue =
--(SELECT SUM(InvoiceTotal - PaymentTotal - CreditTotal)
--FROM Invoices);

SELECT  @TotalDue =
SUM(InvoiceTotal - PaymentTotal - CreditTotal)
FROM Invoices;


SET NOCOUNT ON
IF @TotalDue > 0
PRINT 'Total invoices due =
$' + CONVERT(varchar,@TotalDue,1);
ELSE
PRINT 'Invoices paid in full';

USE AP;
DECLARE 
@MaxInvoice money
,@MinInvoice money
,@PercentDifference decimal(8,2)
,@InvoiceCount int
, @VendorIDVar int;

SET @VendorIDVar = 95;

SET @MaxInvoice = (SELECT MAX(InvoiceTotal) FROM Invoices
WHERE VendorID = @VendorIDVar);

SELECT @MinInvoice = MIN(InvoiceTotal), 
@InvoiceCount = COUNT(*)
FROM Invoices
WHERE VendorID = @VendorIDVar;

SET @PercentDifference = (@MaxInvoice - @MinInvoice) /
@MinInvoice * 100

PRINT('Pct diff: '+ CONVERT(varchar,ROUND(@PercentDifference,2),1)+ '% !')
PRINT 'Maximum invoice is $' + 
CONVERT(varchar,@MaxInvoice,1) + '.';
PRINT 'Minimum invoice is $' + 
CONVERT(varchar,@MinInvoice,1) + '.';
PRINT 'Maximum is ' + CONVERT(varchar,@PercentDifference) +
'% more than minimum.';
PRINT 'Number of invoices: ' + 
CONVERT(varchar,@InvoiceCount) + '.'


--table variable
DECLARE @BigVendors table
(VendorID int,
VendorName varchar(50));

INSERT @BigVendors
	SELECT VendorID, VendorName
FROM Vendors
WHERE VendorID IN 
(SELECT VendorID FROM Invoices
WHERE InvoiceTotal > 5000);

SELECT * FROM @BigVendors;

SELECT  LEFT(CAST(CAST(CEILING(RAND()*10000000000) AS bigint)
AS varchar),9) as foo

--using random on row and table
CREATE TABLE ##RandomSSNs
(SSN_ID int IDENTITY,
SSN char(9) DEFAULT
LEFT(CAST(CAST(CEILING(RAND()*10000000000) AS bigint)
AS varchar),9));


INSERT ##RandomSSNs VALUES (DEFAULT);
INSERT ##RandomSSNs VALUES (DEFAULT);
SELECT * FROM ##RandomSSNs;

select * from ##RandomSSNs where SSN_ID = CEILING(RAND()*16)

DEclare @base int, @rows int
select @base = count(*) from ##RandomSSNs
set @rows = 3
select  * from ##RandomSSNs where SSN_ID = CEILING(RAND()*@base)

with base as
(select  * , ABS(CHECKSUM(NEWID())) % 1000 randokey from ##RandomSSNs 
)
select * from base where randokey %  < 2

SELECT TOP 2 * , NEWID() guid into test2 FROM ##RandomSSNs ORDER BY NEWID()
convert
sp_help test2


DECLARE @EarliestInvoiceDue date;

SELECT @EarliestInvoiceDue = MIN(InvoiceDueDate)
FROM Invoices 

--print(@EarliestInvoiceDue )

WHERE InvoiceTotal - PaymentTotal - CreditTotal > 0;
IF @EarliestInvoiceDue < dateadd(year,-7,GETDATE())

PRINT 'Outstanding invoices overdue!'
ELSE

PRINT 'Outstanding invoices NOT overdue!'


--while exercise
IF OBJECT_ID('tempdb..#InvoiceCopy') IS NOT NULL

DROP TABLE #InvoiceCopy;

SELECT 
	* 
	INTO 
		#InvoiceCopy 
FROM Invoices 
WHERE InvoiceTotal - CreditTotal - PaymentTotal > 0;

select * from 		#InvoiceCopy 

declare @target float, @ctr int

SELECT @target =
		SUM(InvoiceTotal - CreditTotal - PaymentTotal) FROM #InvoiceCopy
SET @ctr = 1		
WHILE 
@target  >= 20000 
	BEGIN
		--print (convert(char(20),@target))

		UPDATE #InvoiceCopy
		SET CreditTotal = CreditTotal + .05
		WHERE InvoiceTotal - CreditTotal -
		PaymentTotal > 0;

		IF (SELECT MAX(CreditTotal) FROM #InvoiceCopy) > 3000
			BEGIN
			print('num iterations: '+convert(char(10),@ctr))
			BREAK;
			END
		ELSE --(SELECT MAX(CreditTotal) FROM #InvoiceCopy)-- <= 3000
		SELECT @target =
		SUM(InvoiceTotal - CreditTotal - PaymentTotal) FROM #InvoiceCopy
		SET @ctr = @ctr + 1
			CONTINUE;
END;

SELECT InvoiceDate, InvoiceTotal, CreditTotal
FROM #InvoiceCopy;

USE AP;

DECLARE @InvoiceIDVar int, @InvoiceTotalVar money, 
@UpdateCount int;

SET @UpdateCount = 0;

DECLARE 
	Invoices_Cursor 
	CURSOR
			FOR
				SELECT 
					InvoiceID
					, InvoiceTotal 
				FROM Invoices
				WHERE 
					InvoiceTotal - PaymentTotal - CreditTotal > 0;

OPEN Invoices_Cursor;

FETCH NEXT FROM 
	Invoices_Cursor
	INTO 
		@InvoiceIDVar
		, @InvoiceTotalVar;
--end of the cursor's data
WHILE @@FETCH_STATUS <> -1
	BEGIN
		IF @InvoiceTotalVar > 1000
			BEGIN
				UPDATE Invoices
				SET CreditTotal = CreditTotal + (InvoiceTotal * .1)
				WHERE InvoiceID = @InvoiceIDVar;

				SET @UpdateCount = @UpdateCount + 1;
			END;
	FETCH NEXT FROM 
		Invoices_Cursor
	INTO @InvoiceIDVar, @InvoiceTotalVar;
	END;
	print(convert(varchar(2),@UpdateCount ))
CLOSE Invoices_Cursor;

DEALLOCATE Invoices_Cursor;

--pseducode for trickle delete
while (select whatevs from whatdoin where notdeleted = 'yes')
	BEGIN
		SET ROWCOUNT 1000
		delete...
	END


PRINT '';
PRINT CONVERT(varchar, @UpdateCount) + ' row(s) updated.';