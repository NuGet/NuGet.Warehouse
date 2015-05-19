
CREATE FUNCTION [dbo].[UserAgentClient] (@value nvarchar(900))
RETURNS NVARCHAR(128)
AS
BEGIN
	-- NUGET CLIENTS

	-- VS NuGet 2.8+ User Agent Strings
	IF CHARINDEX('NuGet VS PowerShell Console/', @value) > 0
		RETURN 'NuGet VS PowerShell Console'
	IF CHARINDEX('NuGet VS Packages Dialog - Solution/', @value) > 0
		RETURN 'NuGet VS Packages Dialog - Solution'
	IF CHARINDEX('NuGet VS Packages Dialog/', @value) > 0
		RETURN 'NuGet VS Packages Dialog'

	-- VS NuGet (pre-2.8) User Agent Strings
    IF CHARINDEX('NuGet Add Package Dialog/', @value) > 0
        RETURN 'NuGet Add Package Dialog'
    IF CHARINDEX('NuGet Command Line/', @value) > 0
        RETURN 'NuGet Command Line'
    IF CHARINDEX('NuGet Package Manager Console/', @value) > 0
        RETURN 'NuGet Package Manager Console'
    IF CHARINDEX('NuGet Visual Studio Extension/', @value) > 0
        RETURN 'NuGet Visual Studio Extension'
    IF CHARINDEX('Package-Installer/', @value) > 0
        RETURN 'Package-Installer'

		-- WebMatrix includes its own core version number as part of the client name, before the slash
		-- Therefore we don't include the slash in the match
    IF CHARINDEX('WebMatrix', @value) > 0
        RETURN 'WebMatrix'

    -- ECOSYSTEM PARTNERS

	-- Refer to npe.codeplex.com
    IF CHARINDEX('NuGet Package Explorer Metro/', @value) > 0
        RETURN 'NuGet Package Explorer Metro'
    IF CHARINDEX('NuGet Package Explorer/', @value) > 0
        RETURN 'NuGet Package Explorer'

	-- Refer to www.jetbrains.com for details
	-- TeamCity uses a space to separate the client from the version instead of a /
    IF CHARINDEX('JetBrains TeamCity ', @value) > 0
        RETURN 'JetBrains TeamCity'

	-- Refer to www.sonatype.com for details
	-- Make sure to use the slash here because there are "Nexus" phones that match otherwise
    IF CHARINDEX('Nexus/', @value) > 0
        RETURN 'Sonatype Nexus'

	-- Refer to www.jfrog.com for details
    IF CHARINDEX('Artifactory/', @value) > 0
        RETURN 'JFrog Artifactory'

	-- Refer to www.myget.org
	-- MyGet doesn't send a version at all, so be sure to omit the /
    IF CHARINDEX('MyGet', @value) > 0
        RETURN 'MyGet'

	-- Refer to www.inedo.com for details
    IF CHARINDEX('ProGet/', @value) > 0
        RETURN 'Inedo ProGet'

		-- Refer to xamarin.com for details
    IF CHARINDEX('Xamarin', @value) > 0
        RETURN 'Xamarin'

	-- Refer to www.monodevelop.com for details
    IF CHARINDEX('MonoDevelop', @value) > 0
        RETURN 'MonoDevelop'

	-- Refer to http://fsprojects.github.io/Paket/
	-- Paket 0.x doesn't send a version at all, so be sure to omit the /
    IF CHARINDEX('Paket', @value) > 0
        RETURN 'Paket'

    RETURN 'Other'
END
