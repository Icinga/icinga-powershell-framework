function Reset-IcingaForWindowsManagementConsoleInstallationDirectorConfigModifyState()
{
    foreach ($entry in $Global:Icinga.InstallWizard.Config.Keys) {

        if ($entry -eq 'IfW-DirectorUrl' -Or $entry -eq 'IfW-DirectorSelfServiceKey') {
            continue;
        }

        $Global:Icinga.InstallWizard.Config[$entry].Modified = $FALSE;
    }
}
