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
.PARAMETER ComponentsOnly
    Only uninstalls components like Icinga Agent, plugins, and so on and keeps the Framework
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
        $IcingaUser             = 'icinga',
        [switch]$Force          = $FALSE,
        [switch]$ComponentsOnly = $FALSE
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

    Set-IcingaPSLocation;

    Write-IcingaConsoleNotice 'Uninstalling Icinga for Windows from this host';
    Write-IcingaConsoleNotice 'Uninstalling Icinga Security configuration if applied';
    Uninstall-IcingaSecurity -IcingaUser $IcingaUser;
    Write-IcingaConsoleNotice 'Uninstalling Icinga Agent';
    Uninstall-IcingaAgent -RemoveDataFolder | Out-Null;
    if ($ComponentsOnly -eq $FALSE) {
        Write-IcingaConsoleNotice 'Uninstalling Icinga for Windows EventLog';
        Unregister-IcingaEventLog;
        # Ensure we close the IMC in case being open and we uninstall the Framework
        Set-IcingaForWindowsManagementConsoleClosing;
    }
    Write-IcingaConsoleNotice 'Uninstalling Icinga for Windows service';
    Uninstall-IcingaForWindowsService -RemoveFiles | Out-Null;

    $HasErrors = $FALSE;

    foreach ($module in $ModuleList.Name) {
        [string]$ModuleName = $module.Replace('icinga-powershell-', '').ToLower();

        if ($ModuleName -eq 'framework' -And $ComponentsOnly) {
            continue;
        }

        if ((Uninstall-IcingaFrameworkComponent -Name $ModuleName)) {
            continue;
        }

        $HasErrors = $TRUE;
    }

    if ($ComponentsOnly -eq $FALSE) {
        Remove-Module 'icinga-powershell-framework' -Force -ErrorAction SilentlyContinue;
    }

    if ($HasErrors) {
        Write-Host 'Not all components could be removed. Please ensure no other PowerShell/Application is currently open and accessing Icinga for Windows files';
    } else {
        Write-Host 'Icinga for Windows was removed from this host.';
    }
}
