function Invoke-IcingaForWindowsMenuStartIcingaShell()
{
    Clear-Host;
    $global:Icinga.InstallWizard.Closing = $TRUE;
    Invoke-IcingaCommand -Shell;
}
