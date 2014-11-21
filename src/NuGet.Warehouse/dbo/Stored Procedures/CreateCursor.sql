CREATE PROCEDURE [dbo].[CreateCursor]
	@MinTimestamp DATETIME OUTPUT
,	@MaxTimestamp DATETIME2 OUTPUT -- DateTime2 to prevent 10:59:59.999 from getting rounded up to 11:00:00
AS

-- Floor our the max timestamp so that incomplete hours are ignored
-- This means 11:00:00.000 will assume the 10 o'clock hour has been
-- completed, and the max timestamp will be returned as 11:00:00,
-- which doesn't mean 11:00:00 has been cleared; it means it can be
-- used as an exclusive upper-bound
SET	@MaxTimestamp = DateTimeFromParts(
						DATEPART(year, @MaxTimestamp),
						DATEPART(month, @MaxTimestamp),
						DATEPART(day, @MaxTimestamp),
						DATEPART(hour, @MaxTimestamp), 0, 0, 0)


SELECT		@MinTimestamp = MIN([DateTime])
			-- Add one hour to our max datetime because we've used LESS THAN the max timestamp below
			-- which ensures that our upper-bound is exclusive.  But that also means we need to add
			-- the hour back so we retain that upper-bound being the end of the hour, which is represented
			-- as the next hour, on the hour.
		,	@MaxTimestamp = DATEADD(hour, 1, MAX([DateTime]))
FROM		(
			SELECT		[DateTime] = DateTimeFromParts(
											DATEPART(year, [Date]),
											DATEPART(month, [Date]),
											DATEPART(day, [Date]),
											[HourOfDay], 0, 0, 0)
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
		AND	NOT EXISTS(
				SELECT		*
				FROM		CollectorGap
				WHERE		[DateTime] >= CollectorGap.MinTimestamp
						AND	[DateTime] < CollectorGap.MaxTimestamp
			)
-- If we have a window to process, create the cursor record (which will fail if there's an exsting, overlapping cursor)
IF @MinTimestamp IS NOT NULL AND @MaxTimestamp IS NOT NULL BEGIN
	INSERT		CollectorCursor (MinTimestamp, MaxTimestamp)
	SELECT		@MinTimestamp, @MaxTimestamp
END

RETURN 0
