function Set-IcingaForWindowsInstallationHeaderSelection()
{
    param (
        [string]$Selection = $null
    );

    $global:Icinga.InstallWizard.HeaderSelection = $Selection;
}
