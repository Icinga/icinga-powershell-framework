function Get-IcingaForWindowsInstallerLastParent()
{
    if ($global:Icinga.InstallWizard.LastParent.Count -ne 0) {
        $Parent   = $global:Icinga.InstallWizard.LastParent[-1];
        return $Parent;
    }

    return $null;
}
