CREATE TABLE [dbo].[CollectorGap]
(
	[MinTimestamp] SMALLDATETIME NOT NULL ,
    [MaxTimestamp] SMALLDATETIME NOT NULL,
    [Comment] NVARCHAR(500) NOT NULL,
    PRIMARY KEY ([MinTimestamp],[MaxTimestamp]),
    CONSTRAINT [CK_CollectorGap_NoOverlaps] CHECK (dbo.OverlappingGapExists([MinTimestamp], [MaxTimestamp]) = 0)
)
