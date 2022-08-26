function Test-IcingaForWindowsManagementConsoleUpdating()
{
    $UpdateFile = Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'framework.update';

    return (Test-Path -Path $UpdateFile);
}
