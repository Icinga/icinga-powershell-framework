function Show-Icinga()
{
    $IcingaInstallation      = Get-IcingaInstallation -Release;
    [array]$Output           = @( 'Icinga for Windows environment' );
    [int]$MaxComponentLength = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Keys;
    [int]$MaxVersionLength   = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Values.CurrentVersion;
    [string]$ComponentHeader = Add-IcingaWhiteSpaceToString -Text 'Component' -Length $MaxComponentLength;
    [string]$ComponentLine   = Add-IcingaWhiteSpaceToString -Text '---' -Length $MaxComponentLength;
    $Output                 += '-----------';
    $Output                 += '';
    $Output                 += 'Installed components on this system';
    $Output                 += '';
    $Output                 += [string]::Format('{0}   {1}   Available', $ComponentHeader, ((Add-IcingaWhiteSpaceToString -Text 'Version' -Length $MaxVersionLength)));
    $Output                 += [string]::Format('{0}   {1}    ---', $ComponentLine, ((Add-IcingaWhiteSpaceToString -Text '---' -Length $MaxVersionLength)));

    foreach ($component in $IcingaInstallation.Keys) {
        $Data           = $IcingaInstallation[$component];
        $LatestVersion  = $Data.LatestVersion;
        $CurrentVersion = $Data.CurrentVersion;

        if ([string]::IsNullOrEmpty($Data.LockedVersion) -eq $FALSE) {
            if ($Data.LockedVersion -eq $Data.CurrentVersion) {
                $CurrentVersion = [string]::Format('{0}*', $CurrentVersion);
            } else {
                $LatestVersion = [string]::Format('{0}*', $Data.LockedVersion);
            }
        }

        [string]$ComponentName = Add-IcingaWhiteSpaceToString -Text $component -Length $MaxComponentLength;
        $Output               += [string]::Format('{0}   {1}    {2}', $ComponentName, (Add-IcingaWhiteSpaceToString -Text $CurrentVersion -Length $MaxVersionLength), $LatestVersion);
    }

    $Output                 += '';
    $Output                 += 'Available versions flagged with "*" mean that this component is locked to this version';

    $IcingaForWindowsService = Get-IcingaForWindowsServiceData;
    $IcingaAgentService      = Get-IcingaAgentInstallation;
    $WindowsInformation      = Get-IcingaWindowsInformation Win32_OperatingSystem | Select-Object Version, BuildNumber, Caption;

    $Output += '';
    $Output += 'Environment configuration';
    $Output += '';
    $Output += ([string]::Format('PowerShell Root                 => {0}', (Get-IcingaForWindowsRootPath)));
    $Output += ([string]::Format('Icinga for Windows Service Path => {0}', $IcingaForWindowsService.Directory));
    $Output += ([string]::Format('Icinga for Windows Service User => {0}', $IcingaForWindowsService.User));
    $Output += ([string]::Format('Icinga Agent Path               => {0}', $IcingaAgentService.RootDir));
    $Output += ([string]::Format('Icinga Agent User               => {0}', $IcingaAgentService.User));
    $Output += ([string]::Format('PowerShell Version              => {0}', $PSVersionTable.PSVersion.ToString()));
    $Output += ([string]::Format('Operating System                => {0}', $WindowsInformation.Caption));
    $Output += ([string]::Format('Operating System Version        => {0}', $WindowsInformation.Version));

    $Output += '';
    $Output += (Show-IcingaRepository);

    Write-Output $Output;
}
