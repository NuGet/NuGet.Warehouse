CREATE PROCEDURE [dbo].[CreateCursor]
	@MinTimestamp SMALLDATETIME OUTPUT -- Note that these have to be a SMALL date time
,	@MaxTimestamp SMALLDATETIME OUTPUT -- to make sure we don't have sub-second ticks.
AS                                     -- That subtle difference would make us miss data!

SELECT		@MinTimestamp = MIN([DateTime])
		,	@MaxTimestamp = MAX([DateTime])
FROM		(
			SELECT		[DateTime] = CAST(CAST([Date] AS VARCHAR(10)) + ' ' + CAST(HourOfDay AS VARCHAR(2)) + ':00' AS DATETIME)
					,	Dimension_Date.Id AS Dimension_Date_Id
					,	Dimension_Time.Id AS Dimension_Time_Id
			FROM		Dimension_Date
			CROSS JOIN	Dimension_Time
			) DateTimeRange
WHERE		[DateTime] >= @MinTimestamp
		AND	[DateTime] < @MaxTimestamp
		AND	NOT EXISTS(
				SELECT		*
				FROM		Fact_Download
				WHERE		Fact_Download.Dimension_Date_Id = DateTimeRange.Dimension_Date_Id
						AND	Fact_Download.Dimension_Time_Id = DateTimeRange.Dimension_Time_Id
			)

-- Create the cursor record (which will fail if there's an exsting, overlapping cursor)
INSERT		CollectorCursor (MinTimestamp, MaxTimestamp)
SELECT		@MinTimestamp, @MaxTimestamp

RETURN 0
