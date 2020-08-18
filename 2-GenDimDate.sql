DECLARE @StartDate  date;
DECLARE @CutoffDate date 
SELECT @StartDate=DATEFROMPARTS(2020,1,1), @CutoffDate =DATEFROMPARTS(2020,12,31);

WITH seq(n) AS (  
	SELECT 0 
	UNION ALL 
	SELECT n + 1 FROM seq  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate))
		,d(d) AS (  SELECT DATEADD(DAY, n, @StartDate) FROM seq),src AS(  
	SELECT [Date]= CONVERT(date, d)
	, [DateInt]= Convert(nVarchar(50), d, 112)
	, [TheDayName] = DATENAME(WEEKDAY,   d)
	, [TheWeek] = DATEPART(WEEK, d)
	, [TheISOWeek] = DATEPART(ISO_WEEK,  d)
	, [TheDayOfWeek]= DATEPART(WEEKDAY,   d)
	, [TheMonth]=MONTH(d)
	, [TheMonthName]=DATENAME(MONTH,d)
	, [TheQuarter]=DATEPART(Quarter,   d)
	, [TheYear]=YEAR(d)
	, [TheFirstOfTheMonth]=DATEFROMPARTS(YEAR(d), MONTH(d), 1)
	, [TheLastOfTheMonth]=EOMONTH (d)
	, [DayofTheYear]= DATEPART(DAYOFYEAR, d)
	, [WeekStartDate]= DATEADD(DD, -(DATEPART(DW, d)-1), d)
	, [WeekEndDate]= DATEADD(DD, 7-(DATEPART(DW, d)), d)
	  FROM d)
INSERT INTO DimDate
SELECT * FROM src
ORDER BY [Date] OPTION (MAXRECURSION 0);