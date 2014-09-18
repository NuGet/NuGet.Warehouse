CREATE PROCEDURE [dbo].[ClearDownloadFacts]
	@MinTimestamp DATETIME
,	@MaxTimestamp DATETIME
AS

DELETE		TOP (5000)
			Fact_Download
FROM		Fact_Download
INNER JOIN	(
			SELECT		Dimension_Date.Id AS Dimension_Date_Id
					,	[Date]
					,	Dimension_Time.Id AS Dimension_Time_Id
					,	HourOfDay
					,	[DateTime] = CAST(CAST([Date] AS VARCHAR(10)) + ' ' + CAST(HourOfDay AS VARCHAR(2)) + ':00' AS DATETIME)
			FROM		Dimension_Date
			CROSS JOIN	Dimension_Time
			) DateTimeRange
		ON	DateTimeRange.Dimension_Date_Id = Fact_Download.Dimension_Date_Id
		AND	DateTimeRange.Dimension_Time_Id = Fact_Download.Dimension_Time_Id
WHERE		[DateTime] >= @MinTimestamp
		AND	[DateTime] < @MaxTimestamp

RETURN @@ROWCOUNT
