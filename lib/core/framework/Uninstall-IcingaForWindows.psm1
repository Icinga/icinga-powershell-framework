<#
.SYNOPSIS
    Uninstalls every PowerShell module within the icinga-powershell-* namespace
    including the Icinga Agent with all components (like certificates) as well as
    the Icinga for Windows service and the Icinga PowerShell Framework.
.DESCRIPTION
    Uninstalls every PowerShell module within the icinga-powershell-* namespace
    including the Icinga Agent with all components (like certificates) as well as
    the Icinga for Windows service and the Icinga PowerShell Framework.
.FUNCTIONALITY
    Uninstalls every PowerShell module within the icinga-powershell-* namespace
    including the Icinga Agent with all components (like certificates) as well as
    the Icinga for Windows service and the Icinga PowerShell Framework.
.PARAMETER IcingaUser
    In case the Icinga Security profile was installed with a defined user any other than
    "icinga", you require to specify the user to remove it entirely
.PARAMETER Force
    Suppress the question if you are sure to uninstall everything
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Uninstall-IcingaForWindows()
{
    param (
        $IcingaUser    = 'icinga',
        [switch]$Force = $FALSE
    );

    $ModuleList      = Get-Module 'icinga-powershell-*' -ListAvailable;
    [string]$Modules = [string]::Join(', ', $ModuleList.Name);

    if ($Force -eq $FALSE) {
        Write-IcingaConsoleWarning -Message 'You are about to uninstall the Icinga Agent with all components (including certificates) and all Icinga for Windows Components: {0}{1}Are you sure you want to proceed? (y/N)' -Objects $Modules, (New-IcingaNewLine);
        $Input = Read-Host 'Confirm uninstall';
        if ($input -ne 'y') {
            return;
        }
    }

    $CurrentLocation = Get-Location;

    if ($CurrentLocation -eq (Get-IcingaFrameworkRootPath)) {
        Set-Location -Path (Get-IcingaForWindowsRootPath);
    }

    Write-IcingaConsoleNotice 'Uninstalling Icinga for Windows from this host';
    Write-IcingaConsoleNotice 'Uninstalling Icinga Security configuration if applied';
    Uninstall-IcingaSecurity -IcingaUser $IcingaUser;
    Write-IcingaConsoleNotice 'Uninstalling Icinga Agent';
    Uninstall-IcingaAgent -RemoveDataFolder | Out-Null;
    Write-IcingaConsoleNotice 'Uninstalling Icinga for Windows service';
    Uninstall-IcingaForWindowsService | Out-Null;

    $HasErrors = $FALSE;

    foreach ($module in $ModuleList.Name) {
        [string]$ModuleName = $module.Replace('icinga-powershell-', '');

        if ((Uninstall-IcingaFrameworkComponent -Name $ModuleName)) {
            continue;
        }

        $HasErrors = $TRUE;
    }

    Remove-Module 'icinga-powershell-framework' -Force -ErrorAction SilentlyContinue;

    if ($HasErrors) {
        Write-IcingaConsoleWarning 'Not all components could be removed. Please ensure no other PowerShell/Application is currently open and accessing Icinga for Windows files';
    } else {
        Write-IcingaConsoleNotice 'Icinga for Windows was removed from this host.';
    }
}
