function Invoke-IcingaForWindowsMenuStartIcingaShell()
{
    Clear-CLIConsole;
    $global:Icinga.InstallWizard.Closing = $TRUE;
    Invoke-IcingaCommand -Shell;
}
