
CREATE FUNCTION [dbo].[UserAgentClientCategory] (@value NVARCHAR(900))
RETURNS VARCHAR(64)
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
		)
        RETURN 'NuGet'

		-- WebMatrix includes its own core version number as part of the client name, before the slash
		-- Therefore we don't include the slash in the match
    IF	CHARINDEX('WebMatrix', @value) > 0
        RETURN 'WebMatrix'

	IF	(
			-- NuGet Package Explorer
			CHARINDEX('NuGet Package Explorer Metro/', @value) > 0
		OR	CHARINDEX('NuGet Package Explorer/', @value) > 0
		)
		RETURN 'NuGet Package Explorer'

    IF (CHARINDEX('Mozilla', @value) > 0 or CHARINDEX('Opera', @value) > 0)
        RETURN 'Browser'

    RETURN ''
END
