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

    Install-IcingaServiceUser -IcingaUser $IcingaUser;
    Install-IcingaJEAProfile -IcingaUser $IcingaUser -RebuildFramework:$RebuildFramework -AllowScriptBlocks:$AllowScriptBlocks -ConstrainedLanguage:$ConstrainedLanguage;

    Restart-IcingaWindowsService;
}
