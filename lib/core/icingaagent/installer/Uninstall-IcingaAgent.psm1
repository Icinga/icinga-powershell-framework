function Uninstall-IcingaAgent()
{
    param (
        [switch]$RemoveDataFolder = $FALSE
    );

    $IcingaData = Get-IcingaAgentInstallation;

    if ($IcingaData.Installed -eq $FALSE) {
        Write-IcingaConsoleError 'Unable to uninstall the Icinga Agent. The Agent is not installed';
        return;
    }

    Write-IcingaConsoleNotice 'Removing current installed Icinga Agent';

    Stop-IcingaService 'icinga2';

    $Uninstaller = Start-IcingaProcess -Executable 'MsiExec.exe' -Arguments ([string]::Format('{0} /q', $IcingaData.Uninstaller)) -FlushNewLine;

    if ($Uninstaller.ExitCode -ne 0) {
        Write-IcingaConsoleError ([string]::Format('Failed to remove Icinga 2 Agent: {0}{1}', $Uninstaller.Message, $Uninstaller.Error));
        return $FALSE;
    }

    if ($RemoveDataFolder) {
        [string]$IcingaProgramData = Join-Path -Path $Env:ProgramData -ChildPath 'icinga2';
        Write-IcingaConsoleNotice -Message 'Removing Icinga 2 directoy from ProgramData: "{0}"' -Objects $IcingaProgramData;
        if ((Remove-ItemSecure -Path $IcingaProgramData -Recurse -Force) -eq $FALSE) {
            return $FALSE;
        }
    }

    Write-IcingaConsoleNotice 'Icinga Agent was successfully removed';
    return $TRUE;
}
