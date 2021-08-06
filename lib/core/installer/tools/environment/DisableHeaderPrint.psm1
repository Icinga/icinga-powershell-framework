function Disable-IcingaForWindowsInstallationHeaderPrint()
{
    $global:Icinga.InstallWizard.HeaderPrint = $FALSE;
}
