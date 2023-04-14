function Install-IcingaSecurity()
{
    param (
        [string]$IcingaUser          = 'icinga',
        [switch]$RebuildFramework    = $FALSE,
        [switch]$AllowScriptBlocks   = $FALSE,
        [switch]$ConstrainedLanguage = $FALSE,
        [switch]$RunAsTask           = $FALSE
    );

    if ($PSVersionTable.PSVersion -lt (New-IcingaVersionObject -Version 5, 0)) {
        Write-IcingaConsoleError 'You cannot use JEA profiles on your system, as your installed PowerShell version "{0}" is lower than minimum required version "5.0"' -Objects $PSVersionTable.PSVersion;
        return;
    }

    if ((Test-AdministrativeShell) -eq $FALSE) {
        Write-IcingaConsoleError -Message 'This command can only be executed from an administrative shell';
        return;
    }

    $IcingaUserInfo = Split-IcingaUserDomain -User $IcingaUser;

    # Max length for the user name
    if ($IcingaUserInfo.User.Length -gt 20) {
        Write-IcingaConsoleError 'The specified user name "{0}" is too long. The maximum character limit is 20 digits.' -Objects $IcingaUserInfo.User;

        return;
    }

    Install-IcingaServiceUser -IcingaUser $IcingaUser;

    if ($RunAsTask) {
        Invoke-IcingaWindowsScheduledTask -JobType InstallJEA -Timeout 600 | Out-Null;
    } else {
        Install-IcingaJEAProfile -IcingaUser $IcingaUser -RebuildFramework:$RebuildFramework -AllowScriptBlocks:$AllowScriptBlocks -ConstrainedLanguage:$ConstrainedLanguage;
    }

    Restart-IcingaForWindows;
}
