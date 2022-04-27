function Uninstall-IcingaAgent()
{
    param (
        [switch]$RemoveDataFolder = $FALSE
    );

    $IcingaData                = Get-IcingaAgentInstallation;
    [string]$IcingaProgramData = Join-Path -Path $Env:ProgramData -ChildPath 'icinga2';

    if ($IcingaData.Installed -eq $FALSE) {
        Write-IcingaConsoleNotice 'Unable to uninstall the Icinga Agent. The Agent is not installed';
        if ($RemoveDataFolder) {
            if (Test-Path $IcingaProgramData) {
                Write-IcingaConsoleNotice -Message 'Removing Icinga Agent directory: "{0}"' -Objects $IcingaProgramData;
                return ((Remove-ItemSecure -Path $IcingaProgramData -Recurse -Force) -eq $FALSE);
            } else {
                Write-IcingaConsoleNotice -Message 'Icinga Agent directory "{0}" does not exist' -Objects $IcingaProgramData;
            }
        }
        return $FALSE;
    }

    Stop-IcingaService -Service 'icinga2';

    $Uninstaller = & powershell.exe -Command {
        $IcingaData  = $args[0];
        $Uninstaller = Start-IcingaProcess -Executable 'MsiExec.exe' -Arguments ([string]::Format('{0} /q', $IcingaData.Uninstaller)) -FlushNewLine;

        Start-Sleep -Seconds 2;
        Optimize-IcingaForWindowsMemory;

        return $Uninstaller;
    } -Args $IcingaData;

    if ($Uninstaller.ExitCode -ne 0) {
        Write-IcingaConsoleError ([string]::Format('Failed to remove Icinga Agent: {0}{1}', $Uninstaller.Message, $Uninstaller.Error));
        return $FALSE;
    }

    if ($RemoveDataFolder) {
        Write-IcingaConsoleNotice -Message 'Removing Icinga Agent directory: "{0}"' -Objects $IcingaProgramData;
        if ((Remove-ItemSecure -Path $IcingaProgramData -Recurse -Force) -eq $FALSE) {
            return $FALSE;
        }
    }

    Write-IcingaConsoleNotice 'Icinga Agent was successfully removed';
    return $TRUE;
}
