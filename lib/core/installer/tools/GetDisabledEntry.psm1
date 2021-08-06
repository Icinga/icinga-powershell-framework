function Get-IcingaForWindowsInstallerDisabledEntry()
{
    param (
        [string]$Name   = ''
    );

    if ($Global:Icinga.InstallWizard.DisabledEntries.ContainsKey($Name)) {
        return ($Global:Icinga.InstallWizard.DisabledEntries[$Name]);
    }

    return '';
}
