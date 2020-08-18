--*************************************************************************--
-- Title: Create the Data Warehouse
-- Desc:This file will drop and create the [DWCovid19] database, with all its objects. 
-- Change Log: When,Who,What
-- 2020-02-08,DHailu,Created database and tables
-- 2020-08-17,EDimikj, Suggested changes 
-- 2020-08-17, DHailu, Applied comments 
-- 2020=08-17, EDimikj, DimDates: added column [DateInt]
--						NursingHomes changed column types to int (were float) and sync column names 
--*************************************************************************--

-- ED 20-08-17: Database Name Purple_NursingHomes
USE [master]
GO
If Exists (SELECT * FROM Sysdatabases WHERE NAME = 'Purple_NursingHomes')
	BEGIN 
		ALTER DATABASE Purple_NursingHomes SET SINGLE_USER WITH ROLLBACK IMMEDIATE
		DROP DATABASE Purple_NursingHomes
	END
GO
CREATE DATABASE Purple_NursingHomes
Go

--********************************************************************--
-- Create the Tables
--********************************************************************--
USE Purple_NursingHomes
Go

/****** [dbo].[DimProducts] ******/
--Drop Tables if exists
IF OBJECT_ID('dbo.BingCovid', 'U') IS NOT NULL 
  DROP TABLE dbo.BingCovid;
GO

CREATE TABLE BingCovid
(
	--[ID] [float] NULL, -- ED 20-08-17: not needed 
	[Updated] date NULL, --fix date
	[Confirmed] int NULL,
	[ConfirmedChange] int NULL,
	[Deaths] int NULL,
	[DeathsChange] int NULL,
	[Recovered] int NULL,
	[RecoveredChange] int NULL,
	--[Latitude] [nvarchar](255) NULL, -- ED 20-08-17: not needed, we are using from USA_States
	--[Longitude] [nvarchar](255) NULL, -- ED 20-08-17: not needed, we are using from USA_States
	[ISO2] [nvarchar](2) NULL,
	[ISO3] [nvarchar](3) NULL,
	[Country_Region] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL, --renamed state ED 20-08-17: good call
	[County] [nvarchar](255) NULL --ED 20-08-17:since AdminRegion1 is Satate, this can be renamed County
) 
GO


--Drop Tables if exists
IF OBJECT_ID('dbo.NursingHomes', 'U') IS NOT NULL 
  DROP TABLE dbo.NursingHomes;


CREATE TABLE NursingHomes  --ED 20-08-17: just NursingHomes, it contains data for Residents and Staff --Good comment
(
	[Week_Ending] date not null
           , WeekNo int not NULL --ED 20-08-17: what kind of data will be stored here? DH '20-08-17: it is like week 27, 28, 29 so what do you think int but not addative?
		   --, [State] nvarchar(250) NULL --ED 20-08-17: StateAbv, to know that is not State Name--DH 20-08-17 we will get it by join when we create view but not neccessary because we have stateId in NursingHome table. You are right will remove
		   , StateId char(2) not NULL --DH 20-08-17 it is Provider_State in source table
		   , [County] nvarchar (250) NULL 
		   , [Residents_Weekly_Confirmed_COVID] int NULL
		   , [Residents_Total_Confirmed_COVID] int NULL
		   --, [Residents_Weekly_All_Deaths] float NULL -- ED 20-08-17: do we need this? DH 20-08-17 you are right
		   --, [Residents_Total_All_Deaths] float NULL -- ED 20-08-17: do we need this? DH 20-08-17 You are right
		   , [Residents_Weekly_Deaths_COVID] int NULL
		   , [Residents_Total_Deaths_COVID] int NULL
		   , [Staff_Weekly_Confirmed_COVID] int NULL
		   , [Staff_Total_Confirmed_COVID] int NULL
		   , [Staff_Weekly_Deaths_COVID] int NULL -- ED 200817: Staff covid Deaths weekly and total DH 20-08-17 Good comment
		   , [Staff_Total_Deaths_COVID] int NULL-- ED 200817: Staff covid Deaths weekly and total 
		   --, [Initial_Confirmed_COVID_19_Case_This_Week] float NULL -- ED 20-08-17: do we need this?
) 
GO

--Drop Tables if exists
IF OBJECT_ID('dbo.USA_States', 'U') IS NOT NULL 
  DROP TABLE dbo.USA_States;

CREATE TABLE USA_States
(
	[stateID] [nvarchar](2) NULL, ---- ED 20-08-17: StateAbv  --DH 20-08-17 it is State in source table
	[latitude] [float] NULL,
	[longitude] [float] NULL,
	[StateName] [nvarchar](255) NULL 
) 
GO

--Drop Tables if exists
IF OBJECT_ID('dbo.DimDate', 'U') IS NOT NULL 
  DROP TABLE dbo.DimDate;

CREATE TABLE DimDate
(
[Date] date not null
,[DateInt]  int not null
,TheDayName nvarchar(50) not null
,TheWeek int not null
,TheISOWeek int not null
,TheDayOfWeek int not null
,TheMonth int not null
,TheMonthName nvarchar(50) not null
,TheQuarter int not null
,TheYear int not null
,TheFirstOfTheMonth nvarchar(50) not null
,TheLastOfTheMonth nvarchar(50) not null
,DayofTheYear nvarchar(50) not null
,WeekStartDate date not null-- ED 20-08-17: we need this for relation with NursingHomes, WeekStartDate date not null --DH 20-08-17 thanks 
,WeekEndDate date not null-- ED 20-08-17: we need this for relation with NursingHomes	, WeekEndDate date not null --DH 20-08-17 thanks 
)
GO


Select 'Database Created'
Select Name, xType, CrDate from SysObjects 
Where xType in ('u', 'PK', 'F')
Order By xType desc, Name

