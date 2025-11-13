function Install-IcingaJEAProfile()
{
    param (
        [string]$IcingaUser          = (Get-IcingaServiceUser),
        [switch]$ConstrainedLanguage = $FALSE,
        [switch]$TestEnv             = $FALSE,
        [switch]$RebuildFramework    = $FALSE,
        [switch]$AllowScriptBlocks   = $FALSE
    );

    if ($PSVersionTable.PSVersion -lt '5.0.0.0') {
        Write-IcingaConsoleError 'You cannot use JEA profiles on your system, as your installed PowerShell version "{0}" is lower than minimum required version "5.0"' -Objects $PSVersionTable.PSVersion;
        return;
    }

    $IcingaUserInfo = Split-IcingaUserDomain -User $IcingaUser;

    # Max length for the user name
    if ($IcingaUserInfo.User.Length -gt 20) {
        Write-IcingaConsoleError 'The specified user name "{0}" is too long. The maximum character limit is 20 digits.' -Objects $IcingaUserInfo.User;

        return;
    }

    Write-IcingaConsoleNotice 'Writing Icinga for Windows environment information as JEA profile';
    # Always rebuild the framework to ensure we have the latest configuration
    Write-IcingaJEAProfile -RebuildFramework -AllowScriptBlocks:$AllowScriptBlocks;
    Write-IcingaConsoleNotice 'Registering Icinga for Windows JEA profile';
    Register-IcingaJEAProfile -IcingaUser $IcingaUser -TestEnv:$TestEnv -ConstrainedLanguage:$ConstrainedLanguage;
    # We need to run the task renewal with our scheduled task to fix errors while using WinRM / SSH
    Start-IcingaWindowsScheduledTaskRenewCertificate;
}

Set-Alias -Name 'Update-IcingaJEAProfile' -Value 'Install-IcingaJEAProfile';
