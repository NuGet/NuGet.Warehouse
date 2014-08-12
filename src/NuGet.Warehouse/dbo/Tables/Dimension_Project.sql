CREATE TABLE [dbo].[Dimension_Project] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [ProjectTypes] NVARCHAR (450) NULL,
    CONSTRAINT [PK_Dimension_Project] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Dimension_Project_NCI_ProjectTypes]
    ON [dbo].[Dimension_Project]([ProjectTypes] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

