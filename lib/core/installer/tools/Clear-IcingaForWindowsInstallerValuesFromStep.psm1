function Clear-IcingaForWindowsInstallerValuesFromStep()
{
    $Step = Get-IcingaForWindowsManagementConsoleMenu;

    if ($global:Icinga.InstallWizard.Config.ContainsKey($Step) -eq $FALSE) {
        return;
    }

    if ($null -eq $global:Icinga.InstallWizard.Config[$Step].Values) {
        return;
    }

    $global:Icinga.InstallWizard.Config[$Step].Values = @();
}
