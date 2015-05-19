
CREATE FUNCTION [dbo].[UserAgentClientMinorVersion] (@value NVARCHAR(900))
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

			-- WebMatrix includes its own core version number as part of the client name, before the slash
			-- Therefore we don't include the slash in the match
        OR	CHARINDEX('WebMatrix', @value) > 0

			-- NuGet Package Explorer
		OR	CHARINDEX('NuGet Package Explorer Metro/', @value) > 0
        OR	CHARINDEX('NuGet Package Explorer/', @value) > 0
		)

	BEGIN
        -- The following 'IF' condition truncates OS information that may be present at the end of the User Agent string inside braces
        -- OS information may have version information. So, truncating that out helps in a simplified and accurate parsing of UserAgent client minor version
        -- NOTE that, despite truncating OS information, it is assumed that the User Agent string from NuGet clients will always have the major and minor version
        IF  (CHARINDEX('(', @value) != 0) SET	@value = SUBSTRING(@value, 0, CHARINDEX('(', @value))
        RETURN CAST(SUBSTRING(
                @value,
                -- Start 1 character after the first dot after the /
                CHARINDEX('.', @value, CHARINDEX('/', @value) + 1) + 1,
                -- And determine our string length
                (
                    -- CONCAT: Add a dot to the end to make sure we can find a dot
                    -- Find the position of the next dot, starting 1 character after the first dot after the / (like we did above)
                    CHARINDEX('.', CONCAT(@value, '.'), CHARINDEX('.', @value, CHARINDEX('/', @value) + 1) + 1))
                    -- And now subtract the starting point we used to get the length of the string
                    - ((CHARINDEX('.', @value, CHARINDEX('/', @value) + 1)) + 1
                )
            ) AS INT)
    END

    RETURN 0
END
