<#
.SYNOPSIS
    Uninstalls the Icinga PowerShell Service as a Windows Service
.DESCRIPTION
    Uninstalls the Icinga PowerShell Service as a Windows Service. The service binary
    will be left on the system.
.FUNCTIONALITY
    Uninstalls the Icinga PowerShell Service as a Windows Service
.EXAMPLE
    PS>Uninstall-IcingaForWindowsService;
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Uninstall-IcingaForWindowsService()
{
    param (
        [switch]$RemoveFiles = $FALSE
    );

    Set-IcingaServiceEnvironment;

    $ServiceData = Get-IcingaForWindowsServiceData;

    Stop-IcingaForWindows;
    Start-Sleep -Seconds 1;

    $ServiceCreation = Start-IcingaProcess -Executable 'sc.exe' -Arguments 'delete icingapowershell';

    switch ($ServiceCreation.ExitCode) {
        0 {
            Write-IcingaConsoleNotice 'Icinga PowerShell Service was successfully removed';
            $Global:Icinga.Protected.Environment.'PowerShell Service'.Present = $FALSE;
        }
        1060 {
            Write-IcingaConsoleWarning 'The Icinga PowerShell Service is not installed';
        }
        Default {
            throw ([string]::Format('Failed to install Icinga PowerShell Service: {0}{1}', $ServiceCreation.Message, $ServiceCreation.Error));
        }
    }

    if ($RemoveFiles -eq $FALSE) {
        return $TRUE;
    }

    if ([string]::IsNullOrEmpty($ServiceData.Directory) -Or (Test-Path $ServiceData.Directory) -eq $FALSE) {
        return $TRUE;
    }

    $ServiceFolderContent = Get-ChildItem -Path $ServiceData.Directory;

    foreach ($entry in $ServiceFolderContent) {
        if ($entry.Name -eq 'icinga-service.exe' -Or $entry.Name -eq 'icinga-service.exe.md5' -Or $entry.Name -eq 'icinga-service.exe.sha256' -Or $entry.Name -eq 'icinga-service.exe.update') {
            Remove-Item $entry.FullName -Force;
            Write-IcingaConsoleNotice 'Removing file "{0}"' -Objects $entry.FullName;
        }
    }

    $ServiceFolderContent = Get-ChildItem -Path $ServiceData.Directory;

    if ($ServiceFolderContent.Count -eq 0) {
        Remove-Item $ServiceData.Directory;
        Write-IcingaConsoleNotice 'Removing directory "{0}"' -Objects $ServiceData.Directory;
    } else {
        Write-IcingaConsoleWarning 'Unable to remove folder "{0}", because there are still files inside.' -Objects $ServiceData.Directory;
    }

    return $TRUE;
}

Set-Alias -Name 'Uninstall-IcingaFrameworkService' -Value 'Uninstall-IcingaForWindowsService';
