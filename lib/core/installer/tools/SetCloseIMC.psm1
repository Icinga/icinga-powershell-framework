function Set-IcingaForWindowsManagementConsoleClosing()
{
    param (
        [switch]$Completed = $FALSE
    );

    if ($null -eq $Global:Icinga) {
        return;
    }

    if ($Global:Icinga.ContainsKey('InstallWizard') -eq $FALSE) {
        return;
    }

    if ($Global:Icinga.InstallWizard.ContainsKey('Closing') -eq $FALSE) {
        return;
    }

    $global:Icinga.InstallWizard.Closing = (-Not ([bool]$Completed));
}
