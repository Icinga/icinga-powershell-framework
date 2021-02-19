<#
.SYNOPSIS
   Allows to disable any console output for this PowerShell session
.DESCRIPTION
   Allows to disable any console output for this PowerShell session
.FUNCTIONALITY
   Allows to disable any console output for this PowerShell session
.EXAMPLE
   PS>Disable-IcingaFrameworkConsoleOutput;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaFrameworkConsoleOutput()
{
    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    if ($global:Icinga.ContainsKey('DisableConsoleOutput') -eq $FALSE) {
        $global:Icinga.Add('DisableConsoleOutput', $TRUE);
    } else {
        $global:Icinga.DisableConsoleOutput = $TRUE;
    }
}
