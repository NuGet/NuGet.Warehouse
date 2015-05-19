CREATE PROCEDURE [dbo].[GetIndexFragmentation]
AS
	SELECT name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (
		   DB_ID(N'NuGetWarehouse_Test_A2')
		 , OBJECT_ID('Fact_Download')
		 , NULL
		 , NULL
		 , NULL) AS a
	JOIN sys.indexes AS b
	ON a.object_id = b.object_id AND a.index_id = b.index_id

	UNION SELECT name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (
		   DB_ID(N'NuGetWarehouse_Test_A2')
		 , OBJECT_ID('Dimension_Package')
		 , NULL
		 , NULL
		 , NULL) AS a
	JOIN sys.indexes AS b
	ON a.object_id = b.object_id AND a.index_id = b.index_id

	UNION SELECT name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (
		   DB_ID(N'NuGetWarehouse_Test_A2')
		 , OBJECT_ID('Dimension_Project')
		 , NULL
		 , NULL
		 , NULL) AS a
	JOIN sys.indexes AS b
	ON a.object_id = b.object_id AND a.index_id = b.index_id

	UNION SELECT name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (
		   DB_ID(N'NuGetWarehouse_Test_A2')
		 , OBJECT_ID('Dimension_UserAgent')
		 , NULL
		 , NULL
		 , NULL) AS a
	JOIN sys.indexes AS b
	ON a.object_id = b.object_id AND a.index_id = b.index_id

	UNION SELECT name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (
		   DB_ID(N'NuGetWarehouse_Test_A2')
		 , OBJECT_ID('Dimension_Date')
		 , NULL
		 , NULL
		 , NULL) AS a
	JOIN sys.indexes AS b
	ON a.object_id = b.object_id AND a.index_id = b.index_id

	UNION SELECT name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (
		   DB_ID(N'NuGetWarehouse_Test_A2')
		 , OBJECT_ID('Dimension_Time')
		 , NULL
		 , NULL
		 , NULL) AS a
	JOIN sys.indexes AS b
	ON a.object_id = b.object_id AND a.index_id = b.index_id

	UNION SELECT name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (
		   DB_ID(N'NuGetWarehouse_Test_A2')
		 , OBJECT_ID('Dimension_Operation')
		 , NULL
		 , NULL
		 , NULL) AS a
	JOIN sys.indexes AS b
	ON a.object_id = b.object_id AND a.index_id = b.index_id

	UNION SELECT name, avg_fragmentation_in_percent
	FROM sys.dm_db_index_physical_stats (
		   DB_ID(N'NuGetWarehouse_Test_A2')
		 , OBJECT_ID('PackageReportDirty')
		 , NULL
		 , NULL
		 , NULL) AS a
	JOIN sys.indexes AS b
	ON a.object_id = b.object_id AND a.index_id = b.index_id