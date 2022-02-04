function Export-IcingaForWindowsManagementConsoleInstallationAnswerFile()
{
    $FilePath = '';
    $Value    = $global:Icinga.InstallWizard.LastValues;

    if ($null -ne $Value -And $Value.Count -ne 0) {
        $FilePath = $Value[0]
    }

    if (Test-Path ($FilePath)) {
        Write-IcingaFileSecure -File (Join-Path -Path $FilePath -ChildPath 'IfW_answer.json') -Value (Get-IcingaForWindowsManagementConsoleConfigurationString);
        $global:Icinga.InstallWizard.NextCommand = 'Install-Icinga';
        $global:Icinga.InstallWizard.LastNotice  = ([string]::Format('Answer file "IfW_answer.json" successfully exported into "{0}"', $FilePath));
        Clear-IcingaForWindowsManagementConsolePaginationCache;
    } else {
        $global:Icinga.InstallWizard.LastError   += ([string]::Format('The provided path to store the answer file is invalid: "{0}"', $FilePath));
        $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsManagementConsoleInstallationFileExport';
    }
}
