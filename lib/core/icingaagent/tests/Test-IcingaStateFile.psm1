function Test-IcingaStateFile()
{
    param (
        [switch]$WriteOutput = $FALSE
    );

    $IcingaAgentData = Get-IcingaAgentInstallation;
    [string]$StateFilePath = Join-Path -Path $ENV:ProgramData -ChildPath 'icinga2\var\lib\icinga2\icinga2.state';

    if ((Test-Path $StateFilePath) -eq $FALSE) {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'The Icinga Agent state file does not exist' -DropMessage:(-Not $WriteOutput);
        return $TRUE;
    }

    $Success = Read-IcingaStateFile;

    if ($Success) {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'The Icinga Agent state file is healthy' -DropMessage:(-Not $WriteOutput);
        return $TRUE;
    } else {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'The Icinga Agent state file is corrupt. Use the "Repair-IcingaStateFile" command to repair the file or "Read-IcingaStateFile -WriteOutput" for further details' -DropMessage:(-Not $WriteOutput);
    }

    return $FALSE;
}
