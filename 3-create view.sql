
--*************************** Instructors Version ******************************--
-- Title:   [BIDD230Final_PurpleTeam_DWCovid19] Create Views
-- Dev: DHailu
-- Desc: This file create view for [DWCovid19] database.  
-- Change Log: When,Who,What
-- 2020-19-8,Dejene Hailu, Created view
--**************************************************************************--

USE [BIDD230Final_PurpleTeam_DWCovid19]
Go
Set NoCount On;
Go

/************************************************************************************************
---CREATE VIEW FOR TABLE [DimDate]
************************************************************************************************/
	IF Exists(SELECT * from Sys.objects WHERE Name = 'vDimDate')
   DROP VIEW VDimDate;
GO
CREATE OR ALTER VIEW VDimDate

AS
SELECT [Date]= CONVERT(date, [date])
	, [DateAsInteger]= Convert(nVarchar(50), [date], 112)
	, [Year]=YEAR([date])
	, [YearMonthNo]= CONCAT(YEAR([date]),'/',FORMAT(MONTH([date]),'0#'))
	, YearMonth = CONCAT( YEAR([date]),'/',FORMAT([date], 'MMM', 'en-US'))
	, MonthShort=FORMAT([date], 'MMM', 'en-US')
	, MonthLong=DATENAME(MONTH,[date])
	, [Day]=DAY([date])
	, [WeekDay] = DATENAME(WEEKDAY, [date]) 
	, WeekDayShort = FORMAT([date],'ddd', 'en-US')
	, WeekNo = DATEPART(WEEK, [date])
	, WeekStartDate = CAST(DATEADD(DD, -(DATEPART(DW, [date])-2), [date]) as date) 
	, WeekEndDate = CAST(DATEADD(DD, 8-(DATEPART(DW, [date])), [date]) as date)  
	, [Quarter] = CONCAT('Q',DATEPART(Quarter, [date]))
FROM [BIDD230Final_PurpleTeam_DWCovid19]..DimDate
WHERE [Date] BETWEEN '2020-07-01' AND '2020-08-01'
ORDER BY WeekEndDate DESC

/*Check the table: 
Select * From VDimDate
Print 'Report view created'
go 
*/


/************************************************************************************************
---CREATE VIEW FOR TABLE [BinCovid]
************************************************************************************************/
	IF Exists(SELECT * from Sys.objects WHERE Name = 'vBingCOVID')
   DROP VIEW vBingCOVID;
GO
CREATE or ALTER VIEW vBingCOVID

AS 
SELECT  [ReportingDate]=cast([Updated] as date)
         , [Confirmed]=cast([Confirmed] as int)
         , [ConfirmedChange]=cast([ConfirmedChange] as int)
         , [Deaths]=cast([Deaths] as int)
         , [DeathsChange]=cast([DeathsChange] as int)
         , [Recovered]=cast([Recovered] as int)
         , [RecoveredChange]=cast([RecoveredChange] as int)
         , [ISO2]
		 , [ISO3]
		 , [Country_Region]
	   	, [State]
		, County
FROM [BIDD230Final_PurpleTeam_DWCovid19]..[BingCovid]
WHERE [ISO3]='USA' AND 
STATE IS NOT NULL AND 
COUNTY IS NOT NULL;


/************************************************************************************************
---CREATE VIEW FOR TABLE [NursingHomes]
************************************************************************************************/
IF (Object_ID('vNursingHomes') is not null) DROP VIEW vNursingHomes;
GO

CREATE or ALTER VIEW vNursingHomes

AS
SELECT [ReportingWeekEndDate]=cast([Week_Ending] as date)
       , [WeekNo]
       , [ProviderStateAbv]=[StateId]
	   , [County]
       , [ResidentsConfirmedWeeklyChange]= [Residents_Weekly_Confirmed_COVID]
       , [ResidentsConfirmedTotal]= [Residents_Total_Confirmed_COVID]
       , [ResidentsDeathsWeeklyChange]= [Residents_Weekly_Deaths_COVID]
       , [ResidentsDeathsTotal]= [Residents_Total_Deaths_COVID]
       , [StaffConfirmedWeeklyChange]= [Staff_Weekly_Confirmed_COVID]
       , [StaffConfirmedTotal]= [Staff_Total_Confirmed_COVID]
       , [StaffDeathsWeeklyChange]= [Staff_Weekly_Deaths_COVID]
       , [StaffDeathsTotal]= [Staff_Total_Deaths_COVID]
FROM [BIDD230Final_PurpleTeam_DWCovid19]..[NursingHomes]



/************************************************************************************************
---CREATE VIEW FOR TABLE [States]
************************************************************************************************/

	IF Exists(SELECT * from Sys.objects WHERE Name = 'vStates')
   DROP VIEW vStates;
GO

CREATE or ALTER VIEW vStates

AS
SELECT  [StateAbv]=[stateID]
           , [StateLatitude]=[latitude]
           , [StateLongitude]=[longitude]
           , [StateName]
FROM [BIDD230Final_PurpleTeam_DWCovid19]..[USA_States]

/*
SELECT DISTINCT(WeekEndDate) FROM (
SELECT WeekEndDate = cast(DATEADD(DD, -(DATEPART(DW, [Week_Ending])), [Week_Ending]) as date) 
from [dbo].[NursingHomes]) D

SELECT DISTINCT(WeekEndDate) FROM (SELECT WeekEndDate = cast(DATEADD(DD, 8-(DATEPART(DW, [Week_Ending])), [Week_Ending]) as date) 
                                     FROM [dbo].[NursingHomes]) D order by WeekEndDate desc
SELECT DISTINCT([Week_Ending]) FROM [dbo].[NursingHomes] ORDER BY [Week_Ending] DESC
*/