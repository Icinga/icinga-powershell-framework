function Add-IcingaForWindowsInstallerDisabledEntry()
{
    param (
        [string]$Name   = '',
        [string]$Reason = ''
    );

    if ([string]::IsNullOrEmpty($Reason)) {
        $Reason = 'Generic disable message';
    }

    if ($Global:Icinga.InstallWizard.DisabledEntries.ContainsKey($Name)) {
        $Global:Icinga.InstallWizard.DisabledEntries[$Name] = $Reason;
        return;
    }

    $Global:Icinga.InstallWizard.DisabledEntries.Add($Name, $Reason);
}
