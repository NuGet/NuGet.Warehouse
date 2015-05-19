
CREATE PROCEDURE [dbo].[AddDownloadFacts]
	@Facts XML
,	@CursorMinTimestamp DATETIME
,	@CursorMaxTimestamp DATETIME
,	@Cursor INT
AS

-- Fetch the '(unknown)' Operation to be used for unknown operations
DECLARE		@Unknown varchar(9) = '(unknown)'
DECLARE		@UnknownOperationId INT
SELECT		@UnknownOperationId = Id
FROM		Dimension_Operation
WHERE		Operation = @Unknown;

DECLARE		@FactsInput TABLE
(
			PackageId NVARCHAR(128)
		,	PackageVersion NVARCHAR(64)
		,	PackageListed INT
		,	PackageTitle NVARCHAR(256)
		,	PackageDescription NVARCHAR(MAX)
		,	PackageIconUrl NVARCHAR(MAX)
		,	DownloadUserAgent NVARCHAR(MAX)
		,	DownloadOperation NVARCHAR(32)
		,	DownloadTimestamp DATETIME
		,	DownloadProjectTypes NVARCHAR(MAX)
		,	DownloadDependentPackageId NVARCHAR(128)
		,	OriginalKey INT
)

;WITH		FactsData
(
			PackageId
		,	PackageVersion
		,	PackageListed
		,	PackageTitle
		,	PackageDescription
		,	PackageIconUrl
		,	DownloadUserAgent
		,	DownloadOperation
		,	DownloadTimestamp
		,	DownloadProjectTypes
		,	DownloadDependentPackageId
		,	OriginalKey
)
AS
(
    SELECT  PackageId = IsNull(Fact.value('(packageId)[1]', 'nvarchar(128)'), '')
        ,   PackageVersion = IsNull(Fact.value('(packageVersion)[1]', 'nvarchar(64)'), '')
        ,   PackageListed = Fact.value('(packageListed)[1]', 'int')
        ,   PackageTitle = IsNull(Fact.value('(packageTitle)[1]', 'nvarchar(256)'), '')
        ,   PackageDescription = IsNull(Fact.value('(packageDescription)[1]', 'nvarchar(MAX)'), '')
        ,   PackageIconUrl = IsNull(Fact.value('(packageIconUrl)[1]', 'nvarchar(MAX)'), '')
        ,   DownloadUserAgent = IsNull(Fact.value('(downloadUserAgent)[1]', 'nvarchar(MAX)'), '')
        ,   DownloadOperation = IsNull(Fact.value('(downloadOperation)[1]', 'nvarchar(32)'), '')
        ,   DownloadTimestamp = Fact.value('(downloadTimestamp)[1]', 'datetime')
        ,   DownloadProjectTypes = IsNull(Fact.value('(downloadProjectTypes)[1]', 'nvarchar(MAX)'), '')
        ,   DownloadDependentPackageId = IsNull(Fact.value('(downloadDependentPackageId)[1]', 'nvarchar(128)'), '')
        ,   OriginalKey = Fact.value('(originalKey)[1]', 'int')
	FROM	@Facts.nodes('//fact') AS Facts(Fact)
)
INSERT		@FactsInput
--OUTPUT		'INSERT' AS '@FactsInput'
--		,	inserted.*
SELECT		PackageId
		,	PackageVersion
		,	PackageListed
		,	PackageTitle
		,	PackageDescription
		,	PackageIconUrl
		,	DownloadUserAgent
		,	DownloadOperation
		,	DownloadTimestamp
		,	DownloadProjectTypes
		,	DownloadDependentPackageId
		,	OriginalKey
FROM		FactsData

-- Group the facts by all the dimensions, with the max original key and sum download count
-- We can bring in the fixed dimensions: Operation, Date, and Time
DECLARE		@FactsTable TABLE
(
			PackageId NVARCHAR(128)
		,	PackageVersion NVARCHAR(64)
		,	DownloadUserAgent NVARCHAR(MAX)
		,	Dimension_Operation_Id INT
		,	Dimension_Date_Id INT
		,	Dimension_Time_Id INT
		,	DownloadProjectTypes NVARCHAR(MAX)
		,	DownloadDependentPackageId NVARCHAR(128)
		,	MaxOriginalKey INT
		,	DownloadCount INT
)

INSERT		@FactsTable
(
			PackageId
		,	PackageVersion
		,	DownloadUserAgent
		,	Dimension_Operation_Id
		,	Dimension_Date_Id
		,	Dimension_Time_Id
		,	DownloadProjectTypes
-- We're not presently recording this value
--		,	DownloadDependentPackageId
		,	MaxOriginalKey
		,	DownloadCount
)
--OUTPUT		'INSERT' AS '@FactsTable'
--		,	inserted.PackageId
--		,	inserted.PackageVersion
--		,	inserted.DownloadUserAgent
--		,	inserted.Dimension_Operation_Id
--		,	inserted.Dimension_Date_Id
--		,	inserted.Dimension_Time_Id
--		,	inserted.DownloadProjectTypes
--		,	inserted.DownloadDependentPackageId
--		,	inserted.MaxOriginalKey
--		,	inserted.DownloadCount
SELECT		PackageId
		,	PackageVersion
		,	IsNull(NullIf(DownloadUserAgent, ''), @Unknown) AS DownloadUserAgent
		,	Dimension_Operation.Id AS Dimension_Operation_Id
		,	Dimension_Date.Id AS Dimension_Date_Id
		,	Dimension_Time.Id AS Dimension_Time_Id
		,	IsNull(NullIf(DownloadProjectTypes, ''), @Unknown) AS DownloadProjectTypes
--		,	DownloadDependentPackageId
		,	MAX(OriginalKey) AS MaxOriginalKey
		,	COUNT(1) AS DownloadCount
FROM		@FactsInput FactsInput
-- The Operation dimension gets special treatment since we fall back to the Unknown operation
-- for operation values that aren't an explicit match
LEFT JOIN	Dimension_Operation
		ON	Dimension_Operation.Operation = FactsInput.DownloadOperation
INNER JOIN	Dimension_Date
		ON	Dimension_Date.[Date] = CAST(DownloadTimestamp AS DATE)
INNER JOIN	Dimension_Time
		ON	Dimension_Time.HourOfDay = DATEPART(HOUR, DownloadTimestamp)
GROUP BY	PackageId
		,	PackageVersion
		,	DownloadUserAgent
		,	Dimension_Operation.Id
		,	Dimension_Date.Id
		,	Dimension_Time.Id
		,	DownloadProjectTypes
--		,	DownloadDependentPackageId

-- Get the data related to the package dimension
DECLARE		@PackageData TABLE
(
			PackageId NVARCHAR(128)
		,	PackageVersion NVARCHAR(64)
		,	PackageListed INT
		,	PackageTitle NVARCHAR(256)
		,	PackageDescription NVARCHAR(MAX)
		,	PackageIconUrl NVARCHAR(MAX)
)

INSERT		@PackageData
(
			PackageId
		,	PackageVersion
		,	PackageListed
		,	PackageTitle
		,	PackageDescription
		,	PackageIconUrl
)
--OUTPUT		'INSERT' AS '@PackageData'
--		,	inserted.PackageId
--		,	inserted.PackageVersion
--		,	inserted.PackageListed
--		,	inserted.PackageTitle
--		,	inserted.PackageDescription
--		,	inserted.PackageIconUrl
SELECT		DISTINCT
			-- This is distinct because we need to reduce duplication
			-- from all of the dimensions other than package
			PackageData.PackageId
		,	PackageData.PackageVersion
		,	PackageData.PackageListed
		,	IsNull(PackageData.PackageTitle, '') AS PackageTitle
		,	IsNull(PackageData.PackageDescription, '') AS PackageDescription
		,	IsNull(PackageData.PackageIconUrl, '') AS PackageIconUrl
FROM		@FactsTable FactsTable
INNER JOIN	@FactsInput PackageData
		ON	PackageData.PackageId = FactsTable.PackageId
		AND	PackageData.PackageVersion = FactsTable.PackageVersion
		AND	PackageData.OriginalKey = FactsTable.MaxOriginalKey

BEGIN TRY
	BEGIN TRANSACTION

		--PRINT 'Update/Insert Package dimensions'
		MERGE		Dimension_Package
		USING		(
					SELECT		Packages.PackageId
							,	Packages.PackageVersion
							,	Packages.PackageListed
							,	Packages.PackageTitle
							,	Packages.PackageDescription
							,	Packages.PackageIconUrl
					FROM		@PackageData Packages
					) AffectedPackages
		ON			(
						Dimension_Package.PackageId = AffectedPackages.PackageId
					AND	Dimension_Package.PackageVersion = AffectedPackages.PackageVersion
					)
		WHEN MATCHED AND	(
								Dimension_Package.PackageListed != AffectedPackages.PackageListed
							OR	Dimension_Package.PackageTitle != AffectedPackages.PackageTitle
							OR	Dimension_Package.PackageDescription != AffectedPackages.PackageDescription
							OR	Dimension_Package.PackageIconUrl != AffectedPackages.PackageIconUrl
							)
					THEN UPDATE SET
								Dimension_Package.PackageListed = AffectedPackages.PackageListed
							,	Dimension_Package.PackageTitle = AffectedPackages.PackageTitle
							,	Dimension_Package.PackageDescription = AffectedPackages.PackageDescription
							,	Dimension_Package.PackageIconUrl = AffectedPackages.PackageIconUrl
		WHEN NOT MATCHED
					THEN INSERT (
									PackageId
								,	PackageVersion
								,	PackageListed
								,	PackageTitle
								,	PackageDescription
								,	PackageIconUrl
								)
						 VALUES (
									AffectedPackages.PackageId
								,	AffectedPackages.PackageVersion
								,	AffectedPackages.PackageListed
								,	AffectedPackages.PackageTitle
								,	AffectedPackages.PackageDescription
								,	AffectedPackages.PackageIconUrl
								)
		--OUTPUT		$action AS 'Dimension_Package'
		--		,	inserted.Id
		--		,	inserted.PackageId
		--		,	inserted.PackageVersion
		--		,	inserted.PackageListed
		--		,	inserted.PackageTitle
		--		,	inserted.PackageDescription
		--		,	inserted.PackageIconUrl
		;

		--PRINT 'Insert new UserAgent dimensions'
		MERGE		Dimension_UserAgent
		USING		(SELECT DISTINCT DownloadUserAgent FROM @FactsTable) Facts
		ON			(Dimension_UserAgent.Value = Facts.DownloadUserAgent)
		WHEN NOT MATCHED
					THEN INSERT (Value, Client, ClientMajorVersion, ClientMinorVersion, ClientCategory)
						 VALUES (
									Facts.DownloadUserAgent
								,	[dbo].[UserAgentClient](Facts.DownloadUserAgent)
								,	[dbo].[UserAgentClientMajorVersion](Facts.DownloadUserAgent)
								,	[dbo].[UserAgentClientMinorVersion](Facts.DownloadUserAgent)
								,	[dbo].[UserAgentClientCategory](Facts.DownloadUserAgent)
								)
		--OUTPUT		$action AS 'Dimension_UserAgent'
		--		,	inserted.Id
		--		,	inserted.Value
		--		,	inserted.Client
		--		,	inserted.ClientMajorVersion
		--		,	inserted.ClientMinorVersion
		--		,	inserted.ClientCategory
		;

		--PRINT 'Insert new Project dimensions'
		MERGE		Dimension_Project
		USING		(SELECT DISTINCT DownloadProjectTypes FROM @FactsTable) Facts
		ON			(Dimension_Project.ProjectTypes = Facts.DownloadProjectTypes)
		WHEN NOT MATCHED
					THEN INSERT (ProjectTypes)
						 VALUES (Facts.DownloadProjectTypes)
		--OUTPUT		$action AS 'Dimension_Project'
		--		,	inserted.Id
		--		,	inserted.ProjectTypes
		;

		--PRINT 'Update/Insert Facts'
		MERGE		Fact_Download
		USING		(
					SELECT		Dimension_UserAgent_Id = Dimension_UserAgent.Id
							,	Dimension_Package_Id = Dimension_Package.Id
							,	Dimension_Date_Id
							,	Dimension_Time_Id
							,	IsNull(Dimension_Operation_Id, @UnknownOperationId) AS Dimension_Operation_Id
							,	Dimension_Project_Id = Dimension_Project.Id
							,	SUM(Facts.DownloadCount) AS DownloadCount
					FROM		@FactsTable Facts
					INNER JOIN	Dimension_Package
							ON	Dimension_Package.PackageId = Facts.PackageId
							AND	Dimension_Package.PackageVersion = Facts.PackageVersion
					INNER JOIN	Dimension_UserAgent
							ON	Dimension_UserAgent.Value = Facts.DownloadUserAgent
					INNER JOIN	Dimension_Project
							ON	Dimension_Project.ProjectTypes = Facts.DownloadProjectTypes
					GROUP BY	Dimension_UserAgent.Id
							,	Dimension_Package.Id
							,	Dimension_Date_Id
							,	Dimension_Time_Id
							,	Dimension_Operation_Id
							,	Dimension_Project.Id
					) FactSource
		ON			(
						Fact_Download.Dimension_UserAgent_Id = FactSource.Dimension_UserAgent_Id
					AND	Fact_Download.Dimension_Package_Id = FactSource.Dimension_Package_Id
					AND	Fact_Download.Dimension_Date_Id = FactSource.Dimension_Date_Id
					AND	Fact_Download.Dimension_Time_Id = FactSource.Dimension_Time_Id
					AND	Fact_Download.Dimension_Operation_Id = FactSource.Dimension_Operation_Id
					AND	Fact_Download.Dimension_Project_Id = FactSource.Dimension_Project_Id
					)
		WHEN MATCHED
					THEN UPDATE SET Fact_Download.DownloadCount = Fact_Download.DownloadCount + FactSource.DownloadCount

		WHEN NOT MATCHED
					THEN INSERT (Dimension_UserAgent_Id, Dimension_Package_Id, Dimension_Date_Id, Dimension_Time_Id, Dimension_Operation_Id, Dimension_Project_Id, DownloadCount)
						 VALUES (
									FactSource.Dimension_UserAgent_Id
								,	FactSource.Dimension_Package_Id
								,	FactSource.Dimension_Date_Id
								,	FactSource.Dimension_Time_Id
								,	FactSource.Dimension_Operation_Id
								,	FactSource.Dimension_Project_Id
								,	FactSource.DownloadCount
								)
		--OUTPUT		$action AS 'Fact_Download'
		--		,	inserted.Dimension_UserAgent_Id
		--		,	inserted.Dimension_Package_Id
		--		,	inserted.Dimension_Date_Id
		--		,	inserted.Dimension_Time_Id
		--		,	inserted.Dimension_Operation_Id
		--		,	inserted.Dimension_Project_Id
		--		,	inserted.DownloadCount
		--		,	deleted.DownloadCount AS '(Old DownloadCount)'
		;

		--PRINT 'Update our Package Dirty table and insert new dirty markers'
		MERGE		PackageReportDirty
		USING		(SELECT DISTINCT PackageId FROM @PackageData) PackageData
		ON			(PackageReportDirty.PackageId = PackageData.PackageId)
		WHEN MATCHED THEN UPDATE SET PackageReportDirty.DirtyCount = PackageReportDirty.DirtyCount + 1
		WHEN NOT MATCHED BY TARGET THEN INSERT (PackageId, DirtyCount) VALUES (PackageData.PackageId, 1)
		--OUTPUT		$action AS PackageReportDirty
		--		,	inserted.PackageId
		--		,	inserted.DirtyCount
		--		,	deleted.DirtyCount AS '(Old DirtyCount)'
		;

		-- Update the cursor
		UPDATE		CollectorCursor
		SET			[Cursor] = @Cursor
		WHERE		MinTimestamp = @CursorMinTimestamp
				AND	MaxTimestamp = @CursorMaxTimestamp

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION

    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT
        @ErrorMessage = ERROR_MESSAGE(),
        @ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState = ERROR_STATE();

    -- Use RAISERROR inside the CATCH block to return error
    -- information about the original error that caused
    -- execution to jump to the CATCH block.
    RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               )
END CATCH
