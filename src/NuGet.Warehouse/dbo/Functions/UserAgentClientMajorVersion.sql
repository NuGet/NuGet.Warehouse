
CREATE FUNCTION [dbo].[UserAgentClientMajorVersion] (@value NVARCHAR(900))
RETURNS INT
AS
BEGIN
    IF	(
			-- VS NuGet 2.8+ User Agent Strings
			CHARINDEX('NuGet VS PowerShell Console/', @value) > 0
		OR	CHARINDEX('NuGet VS Packages Dialog - Solution/', @value) > 0
		OR	CHARINDEX('NuGet VS Packages Dialog/', @value) > 0

			-- VS NuGet (pre-2.8) User Agent Strings
		OR	CHARINDEX('NuGet Add Package Dialog/', @value) > 0
        OR	CHARINDEX('NuGet Command Line/', @value) > 0
        OR	CHARINDEX('NuGet Package Manager Console/', @value) > 0
        OR	CHARINDEX('NuGet Visual Studio Extension/', @value) > 0
        OR	CHARINDEX('Package-Installer/', @value) > 0

			-- WebMatrix NuGet User Agent String
        OR	CHARINDEX('WebMatrix', @value) > 0

			-- NuGet Package Explorer
		OR	CHARINDEX('NuGet Package Explorer Metro/', @value) > 0
        OR	CHARINDEX('NuGet Package Explorer/', @value) > 0
		)

        -- NOTE that it is assumed that the User Agent string from NuGet clients will always have the major and minor version
        -- Parsing logic below gets the major version from between the '/' and the first dot after the '/'
        -- If there is no minor version (i.e, no dot in the client version, the following method will throw)
        RETURN CAST(SUBSTRING(
            @value,
            -- Start 1 character after the /
            CHARINDEX('/', @value) + 1,
            -- To determine string length, subtract (position of first slash, determined as above) from
            -- (Position of first dot occuring after first slash)
            CHARINDEX('.', @value, CHARINDEX('/', @value) + 1) - (CHARINDEX('/', @value) + 1)
        ) AS INT)

    RETURN 0
END
