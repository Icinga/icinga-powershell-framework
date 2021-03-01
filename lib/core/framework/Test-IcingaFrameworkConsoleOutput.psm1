<#
.SYNOPSIS
   Allows to test if console output can be written or not for this PowerShell session
.DESCRIPTION
   Allows to test if console output can be written or not for this PowerShell session
.FUNCTIONALITY
   Allows to test if console output can be written or not for this PowerShell session
.EXAMPLE
   PS>Enable-IcingaFrameworkConsoleOutput;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaFrameworkConsoleOutput()
{
    if ($null -eq $global:Icinga) {
        return $TRUE;
    }

    if ($global:Icinga.ContainsKey('DisableConsoleOutput') -eq $FALSE) {
        return $TRUE;
    }

    return (-Not ($global:Icinga.DisableConsoleOutput));
}
