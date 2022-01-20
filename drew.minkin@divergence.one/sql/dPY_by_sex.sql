SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

alter view [dbo].[dPY_BY_SEX]
as
SELECT
	Sex
	,AVG(DollarPerYear ) AVG_DollarPerYear
FROM
	titanic1004  
GROUP BY 
	sex
GO
