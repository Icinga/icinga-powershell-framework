function Set-IcingaForWindowsManagementConsoleUpdating()
{
    param (
        [switch]$Completed = $FALSE
    );

    Set-IcingaForWindowsManagementConsoleClosing;

    $UpdateFile = Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'framework.update';
    if ($Completed) {
        Remove-ItemSecure -Path $UpdateFile -Force -Retries 5 | Out-Null;
    } else {
        New-Item -Path $UpdateFile -ItemType File -Force | Out-Null;
    }
}
