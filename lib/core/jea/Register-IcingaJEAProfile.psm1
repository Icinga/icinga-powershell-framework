function Register-IcingaJEAProfile()
{
    param (
        [string]$IcingaUser          = ((Get-IcingaServices).icinga2.configuration.ServiceUser),
        [switch]$ConstrainedLanguage = $FALSE,
        [switch]$TestEnv             = $FALSE
    );

    $JeaTemplate = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'templates\IcingaForWindows.pssc.template';
    $JeaProfile  = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'IcingaForWindows.pssc';
    $JeaContent  = Get-Content -Path $JeaTemplate -Raw;
    $JeaName     = 'IcingaForWindows';

    if ($TestEnv) {
        $IcingaUser = $ENV:USERNAME;
        $JeaProfile = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'IcingaForWindowsTest.pssc';
        $JeaName    = 'IcingaForWindowsTest';
    }

    if ([string]::IsNullOrEmpty($IcingaUser)) {
        Write-IcingaConsoleError 'No user found to set the JEA profile to. By default the Icinga Agent user is used for this';
        return;
    }

    $LanguageMode = 'FullLanguage';

    if ($ConstrainedLanguage) {
        $LanguageMode = 'ConstrainedLanguage';
    }

    $UserSID    = Get-IcingaUserSID -User $IcingaUser;
    $IcingaUser = Get-IcingaUsernameFromSID -SID $UserSID;
    $JeaContent = $JeaContent.Replace('$ICINGAFORWINDOWSJEAUSER$', $IcingaUser);
    $JeaContent = $JeaContent.Replace('$POWERSHELLLANGUAGEMODE$', $LanguageMode);

    Set-Content -Path $JeaProfile -Value $JeaContent;

    $Result = Register-PSSessionConfiguration -Name $JeaName -Path $JeaProfile -Force;

    if ($TestEnv -eq $FALSE) {
        Set-IcingaPowerShellConfig -Path 'Framework.JEAProfile' -Value 'IcingaForWindows';
    }

    if ($null -ne $Result) {
        Write-IcingaConsoleNotice 'JEA Profile "{0}" was successfully installed' -Objects $Result.Name;
    } else {
        Write-IcingaConsoleNotice 'Failed to install JEA profile';
    }
}
