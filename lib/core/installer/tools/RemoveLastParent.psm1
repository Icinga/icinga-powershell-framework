function Remove-IcingaForWindowsInstallerLastParent()
{
    if ($global:Icinga.InstallWizard.LastParent.Count -ne 0) {
        $global:Icinga.InstallWizard.LastParent.RemoveAt($global:Icinga.InstallWizard.LastParent.Count - 1);
    }
}
