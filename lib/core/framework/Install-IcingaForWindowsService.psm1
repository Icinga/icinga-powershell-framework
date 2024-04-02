<#
.SYNOPSIS
    Installs the Icinga PowerShell Services as a Windows service
.DESCRIPTION
    Uses the Icinga Service binary which is already installed on the system to register
    it as a Windows service and sets the proper user for it
.FUNCTIONALITY
    Installs the Icinga PowerShell Services as a Windows service
.EXAMPLE
    PS>Install-IcingaForWindowsService -Path C:\Program Files\icinga-service\icinga-service.exe;
.EXAMPLE
    PS>Install-IcingaForWindowsService -Path C:\Program Files\icinga-service\icinga-service.exe -User 'NT Authority\NetworkService';
.PARAMETER Path
    The location on where the service binary executable is found
.PARAMETER User
    The service user the service is running with
.PARAMETER Password
    If the specified service user is requiring a password for registering you can provide it here as secure string
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Install-IcingaForWindowsService()
{
    param(
        $Path,
        $User                   = 'NT Authority\NetworkService',
        [SecureString]$Password
    );

    if ([string]::IsNullOrEmpty($Path)) {
        Write-IcingaConsoleWarning 'No path specified for Framework service. Service will not be installed';
        return;
    }

    $UpdateFile = [string]::Format('{0}.update', $Path);
    $IfWService = $Global:Icinga.Protected.Environment.'PowerShell Service';

    if ((Test-Path $UpdateFile)) {

        Write-IcingaConsoleNotice 'Updating Icinga PowerShell Service binary';

        if ($IfWService.Status -eq 'Running') {
            Write-IcingaConsoleNotice 'Stopping Icinga PowerShell service';
            Stop-IcingaWindowsService;
            Start-Sleep -Seconds 1;
        }

        if (Test-Path $Path) {
            Remove-ItemSecure -Path $Path -Force | Out-Null;
        }
        Copy-ItemSecure -Path $UpdateFile -Destination $Path -Force | Out-Null;
        Remove-ItemSecure -Path $UpdateFile -Force | Out-Null;
    }

    if ((Test-Path $Path) -eq $FALSE) {
        throw 'Please specify the path directly to the service binary';
    }

    $Path = [string]::Format(
        '\"{0}\" \"{1}\"',
        $Path,
        (Get-IcingaPowerShellModuleFile)
    );

    if ($IfWService.Present -eq $FALSE) {
        $ServiceCreation = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('create icingapowershell binPath= "{0}" DisplayName= "Icinga PowerShell Service" start= auto', $Path));
        $Global:Icinga.Protected.Environment.'PowerShell Service'.Present     = $TRUE;
        $Global:Icinga.Protected.Environment.'PowerShell Service'.User        = $User;
        $Global:Icinga.Protected.Environment.'PowerShell Service'.ServicePath = $Path;

        if ($ServiceCreation.ExitCode -ne 0) {
            throw ([string]::Format('Failed to install Icinga PowerShell Service: {0}{1}', $ServiceCreation.Message, $ServiceCreation.Error));
        }
    } else {
        $ServiceUpdate = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('config icingapowershell binPath= "{0}"', $Path));

        if ($ServiceUpdate.ExitCode -ne 0) {
            throw ([string]::Format('Failed to update config for Icinga PowerShell Service: {0}{1}', $ServiceUpdate.Message, $ServiceUpdate.Error));
        }

        $Global:Icinga.Protected.Environment.'PowerShell Service'.ServicePath = $Path;
    }

    # This is just a hotfix to ensure we setup the service properly before assigning it to
    # a proper user, like 'NT Authority\NetworkService'. For some reason the NetworkService
    # will not start without this workaround.
    # Todo: Figure out the reason and fix it properly
    Set-IcingaServiceUser -User 'LocalSystem' -Service 'icingapowershell' | Out-Null;
    Restart-IcingaForWindows;
    Start-Sleep -Seconds 1;
    Stop-IcingaWindowsService;
    Start-Sleep -Seconds 1;

    if ($IfWService.Status -eq 'Running') {
        Write-IcingaConsoleNotice 'Starting Icinga PowerShell service';
        Start-IcingaService 'icingapowershell';
        Start-Sleep -Seconds 1;
    }

    return (Set-IcingaServiceUser -User $User -Password $Password -Service 'icingapowershell');
}

Set-Alias -Name 'Install-IcingaFrameworkService' -Value 'Install-IcingaForWindowsService';
