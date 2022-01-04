function Install-IcingaJEAProfile()
{
    param (
        [string]$IcingaUser          = ((Get-IcingaServices).icinga2.configuration.ServiceUser),
        [switch]$ConstrainedLanguage = $FALSE,
        [switch]$TestEnv             = $FALSE,
        [switch]$RebuildFramework    = $FALSE,
        [switch]$AllowScriptBlocks   = $FALSE
    );

    if ($PSVersionTable.PSVersion -lt '5.0.0.0') {
        Write-IcingaConsoleError 'You cannot use JEA profiles on your system, as your installed PowerShell version "{0}" is lower than minimum required version "5.0"' -Objects $PSVersionTable.PSVersion;
        return;
    }

    # Max length for the user name
    if ($IcingaUser.Length -gt 20) {
        Write-IcingaConsoleError 'The specified user name "{0}" is too long. The maximum character limit is 20 digits.' -Objects $IcingaUser;

        return;
    }

    Write-IcingaConsoleNotice 'Writing Icinga for Windows environment information as JEA profile'
    Write-IcingaJEAProfile -RebuildFramework:$RebuildFramework -AllowScriptBlocks:$AllowScriptBlocks;
    Write-IcingaConsoleNotice 'Registering Icinga for Windows JEA profile'
    Register-IcingaJEAProfile -IcingaUser $IcingaUser -TestEnv:$TestEnv -ConstrainedLanguage:$ConstrainedLanguage;
}

Set-Alias -Name 'Update-IcingaJEAProfile' -Value 'Install-IcingaJEAProfile';
