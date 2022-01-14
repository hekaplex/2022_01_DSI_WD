/*
Goal : Avg DollayPerYear by sex
:)		1. create NewAge column
2. create DPY
3. aggregate query
*/

--1. create NewAge column
UPDATE 
	titanic1004 
SET 
	Age = 30
WHERE 
	Age IS  NULL

ALTER TABLE 	titanic1004  ALTER COLUMN AGE float

ALTER TABLE 
	titanic1004  
ADD  DollarPerYear AS Fare/[Age]

SELECT
	Sex
	,AVG(DollarPerYear )
FROM
	titanic1004  
GROUP BY 
	sex

create view dPY_BY_SEX
as
SELECT
	Sex
	,AVG(DollarPerYear ) AVG_DollarPerYear
FROM
	titanic1004  
GROUP BY 
	sex


SELECT * FROM dPY_BY_SEX
