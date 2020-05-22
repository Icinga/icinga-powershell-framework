<#
.SYNOPSIS
   Get the current debug mode configuration of the Framework
.DESCRIPTION
   Get the current debug mode configuration of the Framework
.FUNCTIONALITY
   Get the current debug mode configuration of the Framework
.EXAMPLE
   PS>Get-IcingaFrameworkDebugMode;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.OUTPUTS
   System.Boolean
#>

function Get-IcingaFrameworkDebugMode()
{
    $DebugMode = Get-IcingaPowerShellConfig -Path 'Framework.DebugMode';
    
    if ($null -eq $DebugMode) {
        return $FALSE;
    }

    return $DebugMode;
}
