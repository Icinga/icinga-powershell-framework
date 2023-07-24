function Set-IcingaForWindowsInstallerValuesFromStep()
{
    param (
        [string]$InstallerStep,
        [string]$Parent,
        [array]$Values         = @()
    );

    $Step = Get-IcingaForWindowsManagementConsoleMenu;

    if ([string]::IsNullOrEmpty($InstallerStep) -eq $FALSE) {
        $Step = Get-IcingaForWindowsManagementConsoleAlias -Command $InstallerStep;

        if ([string]::IsNullOrEmpty($Parent) -eq $FALSE) {
            $Step = [string]::Format('{0}:{1}', $Step, $Parent);
        }
    }

    $global:Icinga.InstallWizard.Config[$Step].Values = $Values;
}
