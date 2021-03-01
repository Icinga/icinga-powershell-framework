function Show-IcingaForWindowsInstallerMenuNewConfiguration()
{
    $global:Icinga.InstallWizard.Config = @{ };
    Show-IcingaForWindowsInstallerMenuSelectConnection;
}
