CREATE PROCEDURE [dbo].[RebuildIndexes]
AS

ALTER INDEX [PK_Fact_Download] ON [Fact_Download] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Fact_Download_NCI_DownloadCount] ON [Fact_Download] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Fact_Download_NCI_Package_Id] ON [Fact_Download] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Fact_Download_NCI_Date_Id] ON [Fact_Download] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_Package_2] ON [Dimension_Package] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_Package_NCI_PackageId_PackageVersion] ON [Dimension_Package] REBUILD WITH (ONLINE=ON);
ALTER INDEX [PK_Dimension_Project] ON [Dimension_Project] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_Project_NCI_ProjectTypes] ON [Dimension_Project] REBUILD WITH (ONLINE=ON);
ALTER INDEX [PK_Dimension_UserAgent] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_UserAgent_2] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_UserAgent_3] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_UserAgent_4] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_UserAgent_5] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_UserAgent_NCI_Value] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_UserAgent_NCI_Client] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_UserAgent_NCI_ClientMajorVersion_ClientMinorVersion] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_UserAgent_NCI_ClientCategory] ON [Dimension_UserAgent] REBUILD WITH (ONLINE=ON);
ALTER INDEX [PK_PackageReportDirty] ON [PackageReportDirty] REBUILD WITH (ONLINE=ON);
ALTER INDEX [PK_Dimension_Date] ON [Dimension_Date] REBUILD WITH (ONLINE=ON);
ALTER INDEX [Dimension_Date_NCI_Date] ON [Dimension_Date] REBUILD WITH (ONLINE=ON);

EXEC sp_updatestats