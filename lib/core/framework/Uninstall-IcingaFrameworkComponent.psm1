<#
.SYNOPSIS
    Uninstalls a specific module within the icinga-powershell-* namespace
    inside your PowerShell module folder
.DESCRIPTION
    Uninstalls a specific module within the icinga-powershell-* namespace
    inside your PowerShell module folder
.FUNCTIONALITY
    Uninstalls a specific module within the icinga-powershell-* namespace
    inside your PowerShell module folder
.PARAMETER Component
    The component you want to uninstall, like 'plugins' or 'mssql'
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Uninstall-IcingaFrameworkComponent()
{
    param (
        [string]$Component
    );

    $ModuleBase         = Get-IcingaFrameworkRootPath;
    $UninstallComponent = [string]::Format('icinga-powershell-{0}', $Component);
    $UninstallPath      = Join-Path -Path $ModuleBase -ChildPath $UninstallComponent;

    if ((Test-Path $UninstallPath) -eq $FALSE) {
        Write-IcingaConsoleNotice -Message 'The Icinga for Windows component "{0}" at "{1}" could not ne found.' -Objects $UninstallComponent, $UninstallPath;
        return $FALSE;
    }

    Write-IcingaConsoleNotice -Message 'Uninstalling Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
    if (Remove-ItemSecure -Path $UninstallPath -Recurse -Force) {
        Write-IcingaConsoleNotice -Message 'Successfully removed Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
        if ($UninstallComponent -ne 'icinga-powershell-framework') {
            Remove-Module $UninstallComponent -Force -ErrorAction SilentlyContinue;
        }
        return $TRUE;
    } else {
        Write-IcingaConsoleError -Message 'Unable to uninstall Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
    }

    return $FALSE;
}
