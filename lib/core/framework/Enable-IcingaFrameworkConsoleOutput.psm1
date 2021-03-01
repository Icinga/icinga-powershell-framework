<#
.SYNOPSIS
   Allows to enable any console output for this PowerShell session
.DESCRIPTION
   Allows to enable any console output for this PowerShell session
.FUNCTIONALITY
   Allows to enable any console output for this PowerShell session
.EXAMPLE
   PS>Enable-IcingaFrameworkConsoleOutput;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaFrameworkConsoleOutput()
{
    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    if ($global:Icinga.ContainsKey('DisableConsoleOutput') -eq $FALSE) {
        $global:Icinga.Add('DisableConsoleOutput', $FALSE);
    } else {
        $global:Icinga.DisableConsoleOutput = $FALSE;
    }
}
