<#
.SYNOPSIS
    Enables the debug mode of the Framework to print additional details into
    the Windows Event Log with Id 1000
.DESCRIPTION
    Enables the debug mode of the Framework to print additional details into
    the Windows Event Log with Id 1000
.FUNCTIONALITY
    Enables the Icinga for Windows Debug-Log
.EXAMPLE
    PS>Enable-IcingaFrameworkDebugMode;
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaFrameworkDebugMode()
{
    $Global:Icinga.Protected.DebugMode = $TRUE;
    Set-IcingaPowerShellConfig -Path 'Framework.DebugMode' -Value $TRUE;
}
