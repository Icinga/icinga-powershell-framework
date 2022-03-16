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
