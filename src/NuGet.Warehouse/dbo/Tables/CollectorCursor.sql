CREATE TABLE [dbo].[CollectorCursor]
(
    [MinTimestamp] DATETIME NOT NULL,
    [MaxTimestamp] DATETIME NOT NULL,
    [Cursor] INT NULL,
    PRIMARY KEY ([MinTimestamp],[MaxTimestamp]),
    CONSTRAINT [CK_CollectorCursor_NoOverlaps] CHECK (dbo.OverlappingCursorExists([MinTimestamp], [MaxTimestamp]) = 0)
)
