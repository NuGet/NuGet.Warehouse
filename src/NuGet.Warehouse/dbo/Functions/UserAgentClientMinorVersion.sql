
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

        RETURN CAST(SUBSTRING(
                @value, 
                CHARINDEX('.', @value, CHARINDEX('/', @value) + 1) + 1, 
                (CHARINDEX('.', CONCAT(@value, '.'), CHARINDEX('.', @value, CHARINDEX('/', @value) + 1) + 1)) - ((CHARINDEX('.', @value, CHARINDEX('/', @value) + 1)) + 1)
            ) AS INT)

    RETURN 0
END
