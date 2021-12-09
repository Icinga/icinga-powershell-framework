<#
.SYNOPSIS
    Disables the debug mode of the Framework
.DESCRIPTION
    Disables the debug mode of the Framework
.FUNCTIONALITY
    Disables the Icinga for Windows Debug-Log
.EXAMPLE
    PS>Disable-IcingaFrameworkDebugMode;
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaFrameworkDebugMode()
{
    $Global:Icinga.Protected.DebugMode = $FALSE;
    Set-IcingaPowerShellConfig -Path 'Framework.DebugMode' -Value $FALSE;
}
