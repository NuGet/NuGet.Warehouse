
CREATE PROCEDURE [dbo].[RefreshUserAgents]
AS
BEGIN

	SELECT		*
	FROM		(
				SELECT		Value
						,	Client AS OldClient
						,	[dbo].[UserAgentClient](Value) AS NewClient
						,	ClientMajorVersion AS OldClientMajorVersion
						,	ClientMinorVersion AS OldClientMinorVersion
						,	[dbo].[UserAgentClientMajorVersion](Value) AS NewClientMajorVersion
						,	[dbo].[UserAgentClientMinorVersion](Value) AS NewClientMinorVersion
						,	ClientCategory As OldClientCategory
						,	[dbo].[UserAgentClientCategory](Value) AS NewClientCategory
				FROM		Dimension_UserAgent
				) Map
	WHERE		Map.NewClient <> Map.OldClient
			OR	Map.NewClientMajorVersion <> Map.OldClientMajorVersion
			OR	Map.NewClientMinorVersion <> Map.OldClientMinorVersion
			OR	Map.NewClientCategory <> Map.OldClientCategory
	ORDER BY	OldClientCategory
			,	NewClientCategory
			,	OldClient
			,	NewClient
			,	OldClientMajorVersion
			,	OldClientMinorVersion
			,	NewClientMajorVersion
			,	NewClientMinorVersion

	UPDATE		Dimension_UserAgent
	SET			Client = [dbo].[UserAgentClient](Value)
			,	ClientMajorVersion = [dbo].[UserAgentClientMajorVersion](Value)
			,	ClientMinorVersion = [dbo].[UserAgentClientMinorVersion](Value)
			,	ClientCategory = [dbo].[UserAgentClientCategory](Value)
	WHERE		Client <> [dbo].[UserAgentClient](Value)
			OR	ClientMajorVersion <> [dbo].[UserAgentClientMajorVersion](Value)
			OR	ClientMinorVersion <> [dbo].[UserAgentClientMinorVersion](Value)
			OR	ClientCategory <> [dbo].[UserAgentClientCategory](Value)

END
