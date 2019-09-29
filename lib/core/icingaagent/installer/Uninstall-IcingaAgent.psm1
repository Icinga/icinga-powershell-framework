function Uninstall-IcingaAgent()
{
    $IcingaData = Get-IcingaAgentInstallation;

    if ($IcingaData.Installed -eq $FALSE) {
        Write-Host 'Unable to uninstall the Icinga Agent. The Agent is not installed';
        return;
    }

    Write-Host 'Removing current installed Icinga Agent';

    $Uninstaller = Start-IcingaProcess -Executable 'MsiExec.exe' -Arguments ([string]::Format('{0} /q', $IcingaData.Uninstaller)) -FlushNewLine;

    if ($Uninstaller.ExitCode -ne 0) {
        Write-Host ([string]::Format('Failed to remove Icinga 2 Agent: {0}{1}', $Uninstaller.Message, $Uninstaller.Error));
        return $FALSE;
    }
    
    Write-Host 'Icinga Agent was successfully removed';
    return $TRUE;
}
