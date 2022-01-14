USE [Examples]
GO

/****** Object:  Table [dbo].[titanic1004]    Script Date: 1/11/2022 4:19:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[titanic1004](
	[predict] [nvarchar](50) NOT NULL,
	[p0] [nvarchar](50) NOT NULL,
	[p1] [nvarchar](50) NOT NULL,
	[PassengerId] [nvarchar](50) NOT NULL,
	[Survived] [nvarchar](50) NOT NULL,
	[Pclass] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Sex] [nvarchar](50) NOT NULL,
	[Age] [nvarchar](50) NULL,
	[SibSp] [nvarchar](50) NOT NULL,
	[Parch] [nvarchar](50) NOT NULL,
	[Ticket] [nvarchar](50) NOT NULL,
	[Fare] [float] NOT NULL,
	[Cabin] [nvarchar](50) NULL,
	[Embarked] [nvarchar](50) NULL,
 CONSTRAINT [PK_titanic1004] PRIMARY KEY CLUSTERED 
(
	[PassengerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO


