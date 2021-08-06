function Clear-IcingaForWindowsManagementConsolePaginationCache()
{
    $global:Icinga.InstallWizard.LastParent.Clear();
}
