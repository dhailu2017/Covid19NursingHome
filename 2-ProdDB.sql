/***************************************************************************
BI Final Project: 
Dev: Emilija Dimikj
Date:8/11/2020
Desc: This is a Production Database for Final Project.
ChangeLog: (Who, When, What) 
	EDimikj, 8/11/20, Created file
	EDimikj, 8/14/20, NursingHomes: Summarized data by State and Date 
	DHailu, 08/19/20, Commented 
*****************************************************************************************/
Use Master;
go

If Exists (Select * From Sys.databases where Name = 'Purple_EmilijaEDimikj')
  Begin
   Alter Database Purple_EmilijaEDimikj set single_user with rollback immediate;
   Drop Database Purple_EmilijaEDimikj;
  End
go

Create Database Purple_EmilijaEDimikj;
go

USE Purple_EmilijaEDimikj;
GO

DROP TABLE IF EXISTS USA_States;
select [StateAbv]=[state]
, [StateLatitude]=[latitude]
, [StateLongitude]=[longitude]
, [StateName]=[name]
into USA_States
from [Temp_Purple_EmilijaDimikj].dbo.USA_States$;

DROP TABLE IF EXISTS BingCovid;
select [ReportingDate]=cast([Updated] as date)   
, [Confirmed]=cast([Confirmed] as int)
, [ConfirmedChange]=cast([ConfirmedChange] as int)
, [Deaths]=cast([Deaths] as int)
, [DeathsChange]=cast([DeathsChange] as int)
, [Recovered]=cast([Recovered] as int)
, [RecoveredChange]=cast([RecoveredChange] as int)
, [ISO2], [ISO3], [Country_Region], [AdminRegion1], [AdminRegion2]
into BingCovid
from [Temp_Purple_EmilijaDimikj].dbo.['Bing-COVID19-Data$']
where [ISO3]='USA';

DROP TABLE IF EXISTS NursingHomes;
select [ReportingWeekEndDate]=cast([Week Ending] as date)
, [ProviderStateAbv]=[Provider State]
, [ResidentsAdmissionsWeeklyChange]=sum([Residents Weekly Admissions COVID-19])   --DH 2020-08-19 our DWH DB design not includeded adminition weeklly
, [ResidentsAdmissionsTotal]=sum([Residents Total Admissions COVID-19])  --DH 2020-08-19 our DWH DB design not includeded adminition Total
, [ResidentsConfirmedWeeklyChange]=sum([Residents Weekly Confirmed COVID-19])
, [ResidentsConfirmedTotal]=sum([Residents Total Confirmed COVID-19])
, [ResidentsSuspectedWeeklyChange]=sum([Residents Weekly Suspected COVID-19])  -- DH-2020-08-19 our DWH DB design not included SuspectedWeekly
, [ResidentsSuspectedTotal]=sum([Residents Total Suspected COVID-19])    -- DH-2020-08-19 our DWH DB design not included SuspectedWeekly
, [ResidentsDeathsWeeklyChange]=sum([Residents Weekly COVID-19 Deaths])
, [ResidentsDeathsTotal]=sum([Residents Total COVID-19 Deaths])
, [AllBeds]=sum([Number of All Beds])   -- DH-2020-08-19 our DWH DB design not included [AllBeds]
, [OccupiedBedsTotal]=sum([Total Number of Occupied Beds]) -- -- DH-2020-08-19 our DWH DB design not included  total [AllBeds]
, [StaffConfirmedWeeklyChange]=sum([Staff Weekly Confirmed COVID-19])
, [StaffConfirmedTotal]=sum([Staff Total Confirmed COVID-19])
, [StaffDeathsWeeklyChange]=sum([Staff Weekly COVID-19 Deaths])
, [StaffDeathsTotal]=sum([Staff Total COVID-19 Deaths])
into NursingHomes
from [Temp_Purple_EmilijaDimikj].dbo.['COVID-19_Nursing_Home_Dataset$']
where [Submitted Data]='Y' and [Passed Quality Assurance Check]='Y'
group by [Week Ending],[Provider State];

drop table IF EXISTS DimDate;
CREATE TABLE DimDate(
[Date] date not null
	, [DateAsInteger] int not null
	, [Year] int not null
	, [MonthNo] int not null
	, [YearMonthNo] nvarchar(7)
	, YearMonth nvarchar(20)
	, MonthShort nvarchar(3)
	, MonthLong nvarchar(10)
	, [Day] int not null
	, [WeekDay] nvarchar(10) not null
	, WeekDayShort nvarchar(3) not null
	, WeekNo int not null
	, WeekStartDate date not null
	, WeekEndDate date not null
	, [Quarter] nvarchar(2)
	);
GO

DECLARE @StartDate  date;
DECLARE @CutoffDate date 
SELECT @StartDate=MIN([ReportingDate]), @CutoffDate =MAX([ReportingDate]) FROM BingCovid;

WITH seq(n) AS (  
	SELECT 0 
	UNION ALL 
	SELECT n + 1 FROM seq  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate))
		,d(d) AS (  SELECT DATEADD(DAY, n, @StartDate) FROM seq),src AS(  
	SELECT [Date]= CONVERT(date, d)
	, [DateAsInteger]= Convert(nVarchar(50), d, 112)
	, [Year]=YEAR(d)
	, [MonthNo]= MONTH(d)
	, [YearMonthNo]= CONCAT(YEAR(d),'/',FORMAT(MONTH(d),'0#'))
	, YearMonth = CONCAT( YEAR(d),'/',FORMAT(d, 'MMM', 'en-US'))
	, MonthShort=FORMAT(d, 'MMM', 'en-US')
	, MonthLong=DATENAME(MONTH,d)
	, [Day]=DAY(d)
	, [WeekDay] = DATENAME(WEEKDAY, d)
	, WeekDayShort = FORMAT(d,'ddd', 'en-US')
	, WeekNo = DATEPART(WEEK, d)
	, WeekStartDate = DATEADD(DD, -(DATEPART(DW, d)-1), d) --DH-2020-08-19 Our nursing data week start date is Monday but this query givs Saterday
	                                                       ---Recomendation - cast(DATEADD(DD, 8-(DATEPART(DW, getdate())), getdate()) as date) 
	, WeekEndDate = DATEADD(DD, 7-(DATEPART(DW, d)), d)  --DH-2020-08-19 Our nursing data week end date (Reporting date) is Sunday but this query givs Sunday
	                                                       ---Recomendation - cast(DATEADD(DD, -(DATEPART(DW, getdate())-2), getdate()) as date)
														   /*---PROOF--SELECT DISTINCT(WeekEndDate) FROM (
                                                                                                         SELECT WeekEndDate = cast(DATEADD(DD, 8-(DATEPART(DW, [Week_Ending])), [Week_Ending]) as date) 
                                                                                                         FROM [dbo].[NursingHomes]) D
														   */
	, [Quarter] = CONCAT('Q',DATEPART(Quarter, d))
	  FROM d)
INSERT INTO DimDate
SELECT * FROM src
ORDER BY [Date] OPTION (MAXRECURSION 0);