--*************************************************************************--
-- Author: <YourNameHere>
-- Desc: ETL process and fill tables in [Purple_DejeneHailu] database
-- Change Log: When,Who,What
-- 2020-08-17,<DHailu>,Created File


USE Purple_DejeneHailu;
go
SET NoCount ON;
go

--================================================================
---Create procedure to flush tables
--================================================================
If Exists(Select * from Sys.objects where Name = 'pTruncateTables')
   Drop Procedure pTruncateTables;
go
CREATE OR ALTER PROCEDURE pTruncateTables
/* Author: <YourNameHere>
** Desc: Flush tables to make ready to fill
** Change Log: When,Who,What
** 2020-08-17,<DHailu>,Created procedure.
*/
AS
 BEGIN
  DECLARE @RC int = 0;
  BEGIN TRY
  	TRUNCATE TABLE [dbo].[BingCovid];
	TRUNCATE TABLE [dbo].[DimDate];
	TRUNCATE TABLE [dbo].[NursingHome];
	TRUNCATE TABLE [dbo].[USA_States];
   Set @RC = +1
  END TRY
  BEGIN CATCH
   Print Error_Message()
   Set @RC = -1
  END CATCH
  Return @RC;
 END
GO
/* Testing Code:
 Declare @Status int;
 Exec @Status = pTruncateTables;
 Print @Status;
*/

--================================================================
---Create view for NursingHome table
--================================================================
	If Exists(Select * from Sys.objects where Name = 'vNursingHome')
   Drop View vNursingHome;
go

CREATE or ALTER VIEW vNursingHome
/* Author: <YourNameHere>
** Desc: Extracts and transforms data for NursingHome
** Change Log: When,Who,What
** 2018-01-17,<DHailu>,Created view.
*/
AS 
SELECT [Week_Ending] = CAST( [Week_Ending] as date)
             , [Weeks] = datepart(week, [Week_Ending]) 
			 , [StateId] = cast([Provider_State] as char(2))
			 , [County] = cast([County] as nvarchar(250))
			 , [Residents_Weekly_Confirmed_COVID_19] = cast([Residents_Weekly_Confirmed_COVID_19] as float)
			 , [Residents_Total_Confirmed_COVID_19] = cast ([Residents_Total_Confirmed_COVID_19] as float)
			 , [Residents_Weekly_COVID_19_Deaths] = cast ([Residents_Weekly_COVID_19_Deaths] as float)
			 , [Residents_Total_COVID_19_Deaths] = cast( [Residents_Total_COVID_19_Deaths] as float)
			 , [Staff_Weekly_Confirmed_COVID_19] = cast( [Staff_Weekly_Confirmed_COVID_19] as float)
			 , [Staff_Total_Confirmed_COVID_19] = cast([Staff_Total_Confirmed_COVID_19] as float)
			 , [Staff_Weekly_COVID_19_Deaths] = cast([Staff_Weekly_COVID_19_Deaths] as float)
			 , [Staff_Total_COVID_19_Deaths] = cast([Staff_Total_COVID_19_Deaths] as float)
FROM [Covid19].[dbo].[COVID-19_Nursing_Home_Dataset (2)]
go
/* Testing Code:
 Select * From vNursingHome;
*/

--================================================================
---Create procedure to fill NursingHome table
--================================================================
	If Exists(Select * from Sys.objects where Name = 'pNursingHome')
   Drop Procedure pNursingHome;
go
CREATE OR ALTER PROCEDURE pNursingHome
/* Author: <YourNameHere>
** Desc: Updates data in NursingHome using the vNursingHome view
** Change Log: When,Who,What
** 2020-08-17,<DHailu>,Created procedure.
*/
AS
 BEGIN
  DECLARE @RC int = 0;
  BEGIN TRY
  
  INSERT INTO [Purple_DejeneHailu]..[NursingHome]
  ([Week_Ending], [Weeks], [StateId], [County], [Residents_Weekly_Confirmed_COVID_19], [Residents_Total_Confirmed_COVID_19], [Residents_Weekly_COVID_19_Deaths], [Residents_Total_COVID_19_Deaths], [Staff_Weekly_Confirmed_COVID_19], [Staff_Total_Confirmed_COVID_19], [Staff_Weekly_COVID_19_Deaths], [Staff_Total_COVID_19_Deaths])
  SELECT * FROM vNursingHome
   Set @RC = +1
  END TRY
  BEGIN CATCH
   Print Error_Message()
   Set @RC = -1
  END CATCH
  Return @RC;
 END
GO
/* Testing Code:
 Declare @Status int;
 Exec @Status = PNursingHome;
 Print @Status;
 Exec PNursingHome
 Select * From [dbo].[NursingHome] Order By [Week_Ending]
*/

--================================================================
---Create view for BingCovid table
--================================================================
	If Exists(Select * from Sys.objects where Name = 'vBingCovid')
   Drop View vBingCovid;
go

CREATE or ALTER VIEW vBingCovid
/* Author: <YourNameHere>
** Desc: Extracts and transforms data for BingCovid
** Change Log: When,Who,What
** 2018-01-17,<DHailu>,Created view.
*/
AS 
SELECT [Updated] = cast ([Updated] as date)
           , [Confirmed] = CAST([Confirmed] as float)
		   , [ConfirmedChange] = cast([ConfirmedChange] as float)
		   , [Deaths] = cast([Deaths] as float)
		   , [DeathsChange] = cast ([DeathsChange] as float)
		   , [Recovered] = cast([Recovered] as float)
		   , [RecoveredChange] = cast([RecoveredChange] as float)
		   , [ISO2] = cast([ISO2] as nvarchar(255))
		   , [ISO3] = cast([ISO3] as nvarchar(255))
		   , [Country_Region] = cast([Country_Region] as nvarchar(255))
		   , [State] = cast([AdminRegion1] as nvarchar(255))
		   , [County] = cast([AdminRegion2] as nvarchar(255))
FROM [Covid19]..[Bing-COVID19-Data (1)]
go
/* Testing Code:
 Select * From vBingCovid;
*/


--================================================================
---Create procedure to fill BingCovid table
--================================================================
If Exists(Select * from Sys.objects where Name = 'pBingCovid')
   Drop Procedure pBingCovid;
go
CREATE OR ALTER PROCEDURE pBingCovid
/* Author: <YourNameHere>
** Desc: Flush tables to make ready to fill
** Change Log: When,Who,What
** 2020-08-17,<DHailu>,Created procedure.
*/
AS
 BEGIN
  DECLARE @RC int = 0;
  BEGIN TRY
 
  INSERT INTO [Purple_DejeneHailu]..[BingCovid]
  ([Updated], [Confirmed], [ConfirmedChange], [Deaths], [DeathsChange], [Recovered], [RecoveredChange], [ISO2], [ISO3], [Country_Region], [State], [County])
  SELECT * FROM [Purple_DejeneHailu]..[vBingCovid]

   Set @RC = +1
  END TRY
  BEGIN CATCH
   Print Error_Message()
   Set @RC = -1
  END CATCH
  Return @RC;
 END
GO

/* Testing Code:
 Declare @Status int;
 Exec @Status = pBingCovid;
 Print @Status;
 Exec pBingCovid
 SELECT * FROM [Purple_NursingHomes]..[BingCovid]
*/

--================================================================
---Create view for USA_State table
--================================================================
	If Exists(Select * from Sys.objects where Name = 'vState')
   Drop View vState;
go

CREATE or ALTER VIEW vState
/* Author: <YourNameHere>
** Desc: Extracts and transforms data for State
** Change Log: When,Who,What
** 2018-01-17,<DHailu>,Created view.
*/
AS 
SELECT [stateID] = cast([state] as char(2))
         , [latitude]
		 , [longitude]
		 , [StateName] = [name]
FROM [Covid19]..[USA_States]
go
/* Testing Code:
 Select * From vState;
*/



--================================================================
---Create procedure to fill USA_state table
--================================================================
If Exists(Select * from Sys.objects where Name = 'pState')
   Drop Procedure pState;
go
CREATE OR ALTER PROCEDURE pState
/* Author: <YourNameHere>
** Desc: Flush tables to make ready to fill
** Change Log: When,Who,What
** 2020-08-17,<DHailu>,Created procedure.
*/
AS
 BEGIN
  DECLARE @RC int = 0;
  BEGIN TRY
 
  INSERT INTO [Purple_DejeneHailu]..[USA_States]
([stateID], [latitude], [longitude], [StateName])
  SELECT * FROM [Purple_DejeneHailu]..[vState]

   Set @RC = +1
  END TRY
  BEGIN CATCH
   Print Error_Message()
   Set @RC = -1
  END CATCH
  Return @RC;
 END
GO

/* Testing Code:
 Declare @Status int;
 Exec @Status = pState;
 Print @Status;
 Exec pState
 SELECT * FROM [Purple_DejeneHailu]..[USA_States]
*/


--================================================================
---Create procedure to fill DimDate table
--================================================================
If Exists(Select * from Sys.objects where Name = 'pDimDate')
   Drop Procedure pDimDate;
go
CREATE OR ALTER PROCEDURE pDimDate
/* Author: <YourNameHere>
** Desc: Flush tables to make ready to fill
** Change Log: When,Who,What
** 2020-08-17,<DHailu>,Created procedure.
*/
AS
 BEGIN
  DECLARE @RC int = 0;
  BEGIN TRY
 
 DECLARE @StartDate  date = '20200701';
DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 31, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    TheDate         = CONVERT(date, d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheISOWeek      = DATEPART(ISO_WEEK,  d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d),
    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d),
	WeekStartDate   =DATEPART(WEEK, d),
	WeekEndDate     =DATEPART(WEEK, d)
  FROM d
)

INSERT INTO DimDate
	SELECT 
	* 
	FROM src
	WHERE TheDate < '2020-08-01' --added this in to only grab July 2020
	OPTION (MAXRECURSION 0);

   Set @RC = +1
  END TRY
  BEGIN CATCH
   Print Error_Message()
   Set @RC = -1
  END CATCH
  Return @RC;
 END
GO

/* Testing Code:
 Declare @Status int;
 Exec @Status = pDimDate;
 Print @Status;
 Exec pDimDate
 SELECT * FROM [Purple_DejeneHailu]..[DimDate]
 */

 --================================================================
---Create view for DimDate table
--================================================================
	If Exists(Select * from Sys.objects where Name = 'vDimDate')
   Drop View vDimDate;
go

CREATE or ALTER VIEW vDimDate
/* Author: <YourNameHere>
** Desc: Extracts and transforms data for DimDate
** Change Log: When,Who,What
** 2018-01-17,<DHailu>,Created view.
*/
AS 
SELECT [ReportingDate]
           , [TheDayName]
		   , [TheWeek]
		   , [TheSOWeek]
		   , [TheDayOfWeek]
		   , [TheMonth]
		   , [TheMonthName]
		   , [TheQuarter]
		   , [TheYear]
		   , [TheFirstOfTheMonth]
		   , [TheLastOfTheMonth]
		   , [DayofTheYear]
		   , [WeekStartDate]
		   , [WeekEndDate]

FROM [Purple_DejeneHailu]..[DimDate]
go
/* Testing Code:
 Select * From [Purple_DejeneHailu]..vDimDate;
*/


 EXEC pBingCovid
 EXEC pDimDate
 EXEC pNursingHome
 EXEC pState

 SELECT * FROM [dbo].[BingCovid]
 SELECT * FROM [dbo].[DimDate]
 SELECT * FROM [dbo].[NursingHome]
 SELECT * FROM [dbo].[USA_States]
















