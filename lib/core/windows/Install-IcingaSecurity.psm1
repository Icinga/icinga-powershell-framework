function Install-IcingaSecurity()
{
    param (
        [string]$IcingaUser          = 'icinga',
        [switch]$RebuildFramework    = $FALSE,
        [switch]$AllowScriptBlocks   = $FALSE,
        [switch]$ConstrainedLanguage = $FALSE
    );

    if ($PSVersionTable.PSVersion -lt (New-IcingaVersionObject -Version 5, 0)) {
        Write-IcingaConsoleError 'You cannot use JEA profiles on your system, as your installed PowerShell version "{0}" is lower than minimum required version "5.0"' -Objects $PSVersionTable.PSVersion;
        return;
    }

    # Max length for the user name
    if ($IcingaUser.Length -gt 20) {
        Write-IcingaConsoleError 'The specified user name "{0}" is too long. The maximum character limit is 20 digits.' -Objects $IcingaUser;

        return;
    }

    Install-IcingaServiceUser -IcingaUser $IcingaUser;
    Install-IcingaJEAProfile -IcingaUser $IcingaUser -RebuildFramework:$RebuildFramework -AllowScriptBlocks:$AllowScriptBlocks -ConstrainedLanguage:$ConstrainedLanguage;

    Restart-IcingaWindowsService;
}
