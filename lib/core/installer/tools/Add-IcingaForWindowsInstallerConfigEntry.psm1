function Add-IcingaForWindowsInstallerConfigEntry()
{
    param (
        [string]$Selection       = $null,
        [array]$Values           = @(),
        [switch]$Hidden          = $FALSE,
        [switch]$PasswordInput   = $FALSE,
        [switch]$OverwriteValues = $FALSE,
        [string]$OverwriteMenu   = '',
        [string]$OverwriteParent = '',
        [switch]$Advanced        = $FALSE
    );

    if ([string]::IsNullOrEmpty($OverwriteMenu) -eq $FALSE) {
        $Step = $OverwriteMenu;
    } else {
        $Step = Get-IcingaForWindowsManagementConsoleMenu;
    }
    if ([string]::IsNullOrEmpty($OverwriteParent) -eq $FALSE) {
        $Parent = $OverwriteParent;
    } else {
        $Parent = $global:Icinga.InstallWizard.ParentConfig;
    }

    $ConfigIndex  = $global:Icinga.InstallWizard.Config.Count;
    $ParentEntry  = $null;

    $Parent = Get-IcingaForWindowsManagementConsoleAlias -Command $Parent;
    $Step   = Get-IcingaForWindowsManagementConsoleAlias -Command $Step;

    if ([string]::IsNullOrEmpty($Parent) -eq $FALSE) {
        $ParentEntry = $Parent.Split(':')[1];
        $Parent = $Parent.Split(':')[0];
        $Step = [string]::Format('{0}:{1}', $Step, $ParentEntry);
    }

    if ($global:Icinga.InstallWizard.Config.ContainsKey($Step) -eq $FALSE) {
        $global:Icinga.InstallWizard.Config.Add(
            $Step,
            @{
                'Selection'   = $Selection;
                'Values'      = $Values
                'Index'       = $ConfigIndex;
                'Parent'      = $Parent;
                'ParentEntry' = $ParentEntry;
                'Hidden'      = [bool]$Hidden;
                'Password'    = [bool]$PasswordInput;
                'Advanced'    = [bool]$Advanced;
                'Modified'    = ($Advanced -eq $FALSE);
            }
        );
    } else {
        $global:Icinga.InstallWizard.Config[$Step].Selection = $Selection;
        $global:Icinga.InstallWizard.Config[$Step].Values    = $Values;
        $global:Icinga.InstallWizard.Config[$Step].Modified  = $TRUE;
    }

    Write-IcingaforWindowsManagementConsoleConfigSwap -Config $global:Icinga.InstallWizard.Config;
}
