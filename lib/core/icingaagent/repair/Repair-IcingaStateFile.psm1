function Repair-IcingaStateFile()
{
    param (
        [switch]$Force
    );

    [string]$StateFilePath = Join-Path -Path $ENV:ProgramData -ChildPath 'icinga2\var\lib\icinga2\icinga2.state*';

    if ((Test-IcingaStateFile) -And $Force -eq $FALSE) {
        Write-IcingaConsoleNotice -Message 'The Icinga Agent state file seems to be okay';
        return;
    }

    $Success = Remove-ItemSecure -Path $StateFilePath -Force -Retries 5;

    if ($Success) {
        Write-IcingaConsoleNotice -Message 'The corrupted Icinga Agent State files have been removed';
    } else {
        Write-IcingaConsoleError -Message 'Failed to remove the corrupted Icinga Agent state files';
    }
}
