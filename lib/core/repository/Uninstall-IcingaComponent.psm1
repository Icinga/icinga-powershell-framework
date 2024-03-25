function Uninstall-IcingaComponent()
{
    param (
        [string]$Name               = '',
        [switch]$RemovePackageFiles = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify a component name to uninstall';
        return $FALSE;
    }

    Set-IcingaServiceEnvironment;

    if ($Name.ToLower() -eq 'agent') {
        return (Uninstall-IcingaAgent -RemoveDataFolder:$RemovePackageFiles);
    }

    if ($Name.ToLower() -eq 'service') {
        return (Uninstall-IcingaForWindowsService -RemoveFiles:$RemovePackageFiles);
    }

    $ModuleBase         = Get-IcingaForWindowsRootPath;
    $UninstallComponent = [string]::Format('icinga-powershell-{0}', $Name);
    $UninstallPath      = Join-Path -Path $ModuleBase -ChildPath $UninstallComponent;

    if ((Test-Path $UninstallPath) -eq $FALSE) {
        Write-IcingaConsoleNotice -Message 'The Icinga for Windows component "{0}" at "{1}" could not ne found.' -Objects $UninstallComponent, $UninstallPath;
        return $FALSE;
    }

    # Set our current location to the PowerShell modules folder, to prevent possible folder lock during uninstallation
    Set-IcingaPSLocation -Path $UninstallPath;

    Write-IcingaConsoleNotice -Message 'Uninstalling Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
    if (Remove-ItemSecure -Path $UninstallPath -Recurse -Force) {
        Write-IcingaConsoleNotice -Message 'Successfully removed Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
        if ($UninstallComponent -ne 'icinga-powershell-framework') {
            Remove-Module $UninstallComponent -Force -ErrorAction SilentlyContinue;
            # In case we are not removing the framework itself, set the location to the Icinga for Windows Folder
            Set-IcingaPSLocation -Path $UninstallPath;
        }
        return $TRUE;
    } else {
        Write-IcingaConsoleError -Message 'Unable to uninstall Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
    }

    return $FALSE;
}
