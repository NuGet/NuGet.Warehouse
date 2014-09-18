CREATE PROCEDURE [dbo].[GetCursor]
	@MinTimestamp SMALLDATETIME OUTPUT -- Note that these have to be a SMALL date time
,	@MaxTimestamp SMALLDATETIME OUTPUT -- to make sure we don't have sub-second ticks.
AS

	SELECT		[Cursor]
	FROM		CollectorCursor
	WHERE		MinTimestamp = @MinTimestamp
			AND	MaxTimestamp = @MaxTimestamp

RETURN 0
