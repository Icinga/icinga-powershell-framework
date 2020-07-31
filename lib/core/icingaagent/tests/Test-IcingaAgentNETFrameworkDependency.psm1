<#
.SYNOPSIS
   Test if .NET Framework 4.6.0 or above is installed which is required by
   the Icinga Agent. Returns either true or false - depending on if the
   .NET Framework 4.6.0 or above is installed or not
.DESCRIPTION
   Test if .NET Framework 4.6.0 or above is installed which is required by
   the Icinga Agent. Returns either true or false - depending on if the
   .NET Framework 4.6.0 or above is installed or not
.FUNCTIONALITY
   Test if .NET Framework 4.6.0 or above is installed
.EXAMPLE
   PS>Test-IcingaAgentNETFrameworkDependency;
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
   https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
#>

function Test-IcingaAgentNETFrameworkDependency()
{
    $RegistryContent = Get-ItemProperty -Path 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue;

    # We require at least .NET Framework 4.6.0 to be installed on the system
    # Version on Windows 10: 393295
    # Version on any other system: 393297
    # We do only require to check for the Windows 10 version, as the other Windows verions
    # do not cause an issue there then because of how the next versions are iterated

    if ($null -eq $RegistryContent -Or $RegistryContent.Release -lt 393295) {
        if ($null -eq $RegistryContent) {
            $RegistryContent = @{
                'Version' = 'Unknown'
            };
        }
        Write-IcingaConsoleError `
            -Message 'To install the Icinga Agent you will require .NET Framework 4.6.0 or later to be installed on the system. Current installed version: {0}' `
            -Objects $RegistryContent.Version;

        return $FALSE;
    }

    Write-IcingaConsoleNotice `
        -Message 'Found installed .NET Framework version {0}' `
        -Objects $RegistryContent.Version;

    return $TRUE;
}
