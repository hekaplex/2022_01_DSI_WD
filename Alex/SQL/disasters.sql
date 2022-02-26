/****** Script for SelectTopNRows command from SSMS  ******/
SELECT 

       [Disaster_Subgroup]
      ,[Disaster_Type]
      ,[Country]
      ,[StartDate]
	  ,CPI_Adjusted_Estimated_Cost_In_Billions
  FROM disasters
  JOIN bdevents
ON disasters.StartDate BETWEEN bdevents.Begin_Date and DATEADD(day,3,bdevents.Begin_Date)
WHERE Country='United States of America (the)'


SELECT 
       [Disaster_Subgroup]
      ,Disaster_Type
	  ,Disaster_Subtype
      ,Event
      ,[StartDate]
	  ,begin_date
	  ,CPI_Adjusted_Estimated_Cost_In_Billions
	  ,Total_Deaths
	  ,Deaths
  FROM bdevents
  JOIN disasters
 ON bdevents.Begin_Date BETWEEN disasters.StartDate and DATEADD(day,2,disasters.StartDate)
WHERE Country='United States of America (the)'


SELECT 
       [Disaster_Subgroup]
      ,[Disaster_Type]
      ,[Country]
      ,[StartDate]
	  ,CPI_Adjusted_Estimated_Cost_In_Billions
  FROM disasters
  JOIN bdevents
ON disasters.StartDate=bdevents.Begin_Date 
WHERE Country='United States of America (the)'

SELECT *
     --  [Disaster_Subgroup]
     -- ,[Disaster_Type]
     -- ,[Country]
     -- ,[StartDate]
  FROM disasters
WHERE Country='United States of America (the)'
AND StartDate='1980-08-09'
ORDER BY StartDate DESC

SELECT 
       [Disaster_Subgroup]
      ,[Disaster_Type]
      ,[Country]
      ,StartDate
	  ,Total_Deaths
	  ,CPI_Adjusted_Estimated_Cost_In_Billions
  FROM disasters
  JOIN bdevents
ON disasters.Total_Deaths=bdevents.Deaths 
WHERE Country='United States of America (the)'

SELECT 
       [Disaster_Subgroup]
      ,[Disaster_Type]
      ,[Country]
      
	  ,Deaths
	  ,CPI_Adjusted_Estimated_Cost_In_Billions
  FROM bdevents
  JOIN disasters
 ON bdevents.Deaths=disasters.Total_Deaths
--WHERE Country='United States of America (the)'

SELECT 
	  DISTINCT Disaster_Subgroup
	  ,Disaster_Type
	  ,Disaster_Subtype
	  ,Disaster_Subsubtype
	  --,COUNT(*) as TOTAL_Disaster
  FROM disasters
--WHERE Country='United States of America (the)'
--GROUP BY Disaster_Subsubtype

SELECT 
	   Disaster_Subgroup
	  --,Disaster_Type
	  --,Disaster_Subtype
	  --,Disaster_Subsubtype
	  ,COUNT(*) as TOTAL_Disasters
  FROM disasters
--WHERE Country='United States of America (the)'
GROUP BY Disaster_Subgroup
ORDER BY TOTAL_Disasters DESC

SELECT  
	  Disaster_Type
	  ,Disaster_Subgroup
	  ,Disaster_Subtype
	  --,Disaster_Subsubtype
	  ,COUNT(*) as TOTAL_Disasters
  FROM disasters
--WHERE Country='United States of America (the)'
GROUP BY ROLLUP (Disaster_Type, Disaster_Subgroup, Disaster_Subtype)
ORDER BY TOTAL_Disasters 

SELECT  
	  Disaster_Type
	  ,Disaster_Subgroup
	  ,Disaster_Subtype
	  --,Disaster_Subsubtype
	  ,COUNT(*) as TOTAL_Disasters
  FROM disasters
--WHERE Country='United States of America (the)'
GROUP BY 
GROUPING SETS 
( ROLLUP (Disaster_Type, Disaster_Subgroup, Disaster_Subtype), 
CUBE (Disaster_Type, Disaster_Subgroup, Disaster_Subtype) )
ORDER BY TOTAL_Disasters DESC



--UPDATED RAW/CHANGED 31 to 30 DAYS FOR MONTH OF SEPTEMBER
UPDATE disasters
SET Start_Day=30, End_Day=30
WHERE Dis_No='1992-0063-AFG'
AND Dis_No='1992-0083-IND'

UPDATE disasters
SET End_Day=30
WHERE Dis_No='2017-0257-IND'
AND Dis_No='1996-0491-SLE'
AND Dis_No='1992-0083-IND' 

UPDATE disasters
SET End_Day=28
WHERE Dis_No='1998-0570-PER'

--CONVERTING THREE DATE COLUMNS (YEAR, MONTH, DAY COLUMNS) TO ONE (YEAR-MONTH-DAY)
SELECT 
	DATEFROMPARTS(Start_Year, Start_Month, Start_Day) as Start_Date
 FROM disasters

SELECT *
	--try_convert(date, concat([End_Year],'/',[End_Month],'/', End_Day)) as End_day
FROM disasters


--CREATING A VIEW
CREATE VIEW Disaster AS
SELECT [YEAR]
	  ,[Disaster_Subgroup]
      ,[Disaster_Type]
	  ,[Disaster_Subtype]
      ,[Country]
	  ,ISO
	  ,REGION
	  ,Continent
	  ,try_convert(date, concat([Start_Year],'/',[Start_Month],'/', Start_Day)) as Start_day
	  ,try_convert(date, concat([End_Year],'/',[End_Month],'/', End_Day)) as End_day
	  ,[Total_Deaths]
 FROM disasters

 

SELECT 
       [Disaster_Subgroup]
      ,[Disaster_Type]
      ,[Country]
	  ,bdevents2.[CPI_Adjusted_Estimated_Cost_In_Billions]
	  ,[Start_day]
	  ,[End_Day] 
FROM disaster
	JOIN bdevents AS bdevents1
		ON disaster.Start_day BETWEEN bdevents1.Begin_Date and DATEADD(day,2,bdevents1.Begin_Date)
	JOIN bdevents AS bdevents2
		ON disaster.End_day BETWEEN bdevents2.End_Date and DATEADD(day,2,bdevents2.Begin_Date)

WHERE Country='United States of America (the)'

--TWO JOINS AND UNION
SELECT 
       [Disaster_Subgroup]
      ,[Disaster_Type]
      ,[Country]
	  ,[CPI_Adjusted_Estimated_Cost_In_Billions]
	  ,[Start_day]
	  ,[End_Day] 
FROM disaster
	FULL OUTER JOIN bdevents
		ON disaster.Start_day BETWEEN bdevents.Begin_Date and DATEADD(day,3,bdevents.Begin_Date)
WHERE Country='United States of America (the)'

UNION 
SELECT 
       [Disaster_Subgroup]
      ,[Disaster_Type]
      ,[Country]
	  ,[CPI_Adjusted_Estimated_Cost_In_Billions]
	  ,[Start_day]
	  ,[End_Day] 
FROM disaster
	FULL OUTER JOIN bdevents
		ON disaster.End_day BETWEEN bdevents.End_Date and DATEADD(day,3,bdevents.Begin_Date)
WHERE Country='United States of America (the)'
ORDER BY Start_day, End_Day

SELECT *
FROM disaster
WHERE Country='United States of America (the)'