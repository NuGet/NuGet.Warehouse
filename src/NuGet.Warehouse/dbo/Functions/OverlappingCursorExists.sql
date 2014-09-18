CREATE FUNCTION [dbo].[OverlappingCursorExists]
(
	@MinTimestamp DATETIME
,	@MaxTimestamp DATETIME
)
RETURNS BIT
AS
BEGIN
	DECLARE		@TimestampExists BIT

	SELECT		@TimestampExists = COUNT(*) - 1 -- Ignore our own row
	FROM		CollectorCursor
	WHERE		(-- The requested min Timestamp is between an existing min/max pair (our min CAN match an existing max though, since max is exclusive)
					@MinTimestamp >= MinTimestamp
				AND	@MinTimestamp < MaxTimestamp
				)
			OR	(-- The requested max Timestamp is between an existing min/max pair (our max CAN match an existing min though, since max is exclusive)
					@MaxTimestamp > MinTimestamp
				AND	@MaxTimestamp <= MaxTimestamp
				)
			OR	(-- An existing min Timestamp is between the requested min/max pair (an existing min CAN match our max though, since max is exclusive)
					MinTimestamp >= @MinTimestamp
				AND	MinTimestamp < @MaxTimestamp
				)
			OR	(-- An existing max Timestamp is between the requested min/max pair (an existing max CAN match our min though, since max is exclusive)
					MaxTimestamp > @MinTimestamp
				AND	MaxTimestamp <= @MaxTimestamp
				)

	RETURN @TimestampExists
END
