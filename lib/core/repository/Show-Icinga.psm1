function Show-Icinga()
{
    param (
        [switch]$SkipHeader = $FALSE
    );

    $IcingaInstallation      = Get-IcingaInstallation -Release;
    [array]$Output           = @( 'Icinga for Windows environment:' );
    [array]$VersionList      = @();
    [int]$MaxComponentLength = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Keys;

    foreach ($entry in $IcingaInstallation.Keys) {
        $LockVersion = Get-IcingaComponentLock -Name $entry;

        if ($null -eq $LockVersion) {
            $VersionList += [string]$IcingaInstallation[$entry].CurrentVersion;
            continue;
        }

        $VersionList += ([string]::Format('{0}*', $IcingaInstallation[$entry].CurrentVersion));
    }

    [int]$MaxVersionLength   = Get-IcingaMaxTextLength -TextArray $VersionList;
    [string]$ComponentHeader = Add-IcingaWhiteSpaceToString -Text 'Component' -Length $MaxComponentLength;
    [string]$ComponentLine   = Add-IcingaWhiteSpaceToString -Text '---' -Length $MaxComponentLength;
    $Output                 += '-----------';
    $Output                 += '';

    if ($SkipHeader) {
        [array]$Output = @();
    }

    $IcingaForWindowsService = Get-IcingaForWindowsServiceData;
    $IcingaAgentService      = Get-IcingaAgentInstallation;
    $WindowsInformation      = Get-IcingaWindowsInformation Win32_OperatingSystem | Select-Object Version, BuildNumber, Caption;
    $DefinedServiceUser      = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser';
    $JEAContext              = Get-IcingaJEAContext;
    $JEASessionFile          = Get-IcingaJEASessionFile;
    $IcingaForWindowsCert    = Get-IcingaForWindowsCertificate;
    $ServicePid              = Get-IcingaForWindowsServicePid;
    $JEAServicePid           = Get-IcingaJEAServicePid;

    if ([string]::IsNullOrEmpty($DefinedServiceUser)) {
        $DefinedServiceUser = '';
    }
    if ([string]::IsNullOrEmpty($JEAContext)) {
        $JEAContext = '';
    }
    if ([string]::IsNullOrEmpty($JEASessionFile)) {
        $JEASessionFile = '';
    }
    if ([string]::IsNullOrEmpty($ServicePid)) {
        $ServicePid = '';
    }
    if ([string]::IsNullOrEmpty($JEAServicePid)) {
        $JEAServicePid = '';
    }

    $Output += '';
    $Output += 'Environment configuration:';
    $Output += '';
    $Output += ([string]::Format('PowerShell Root                 => {0}', (Get-IcingaForWindowsRootPath)));
    $Output += ([string]::Format('Icinga for Windows Service Path => {0}', $IcingaForWindowsService.Directory));
    $Output += ([string]::Format('Icinga for Windows Service User => {0}', $IcingaForWindowsService.User));
    $Output += ([string]::Format('Icinga for Windows Service Pid  => {0}', $ServicePid));
    $Output += ([string]::Format('Icinga for Windows JEA Pid      => {0}', $JEAServicePid));
    $Output += ([string]::Format('Icinga Agent Path               => {0}', $IcingaAgentService.RootDir));
    $Output += ([string]::Format('Icinga Agent User               => {0}', $IcingaAgentService.User));
    $Output += ([string]::Format('Defined Default User            => {0}', $DefinedServiceUser));
    $Output += ([string]::Format('Icinga Managed User             => {0}', (Test-IcingaManagedUser -IcingaUser (Get-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser'))));
    $Output += ([string]::Format('PowerShell Version              => {0}', $PSVersionTable.PSVersion.ToString()));
    $Output += ([string]::Format('Operating System                => {0}', $WindowsInformation.Caption));
    $Output += ([string]::Format('Operating System Version        => {0}', $WindowsInformation.Version));
    $Output += ([string]::Format('JEA Context                     => {0}', $JEAContext));
    $Output += ([string]::Format('JEA Session File                => {0}', $JEASessionFile));
    $Output += ([string]::Format('Api Check Forwarder             => {0}', (Get-IcingaFrameworkApiChecks)));
    $Output += ([string]::Format('Debug Mode                      => {0}', (Get-IcingaFrameworkDebugMode)));
    $Output += '';
    $Output += 'Icinga for Windows Certificate:';
    $Output += '';
    if ($null -eq $IcingaForWindowsCert -Or [string]::IsNullOrEmpty($IcingaForWindowsCert)) {
        $Output += 'Not installed';
    } else {
        $Output += ([string]::Format('Issuer  => {0}', ($IcingaForWindowsCert.Issuer)));
        $Output += ([string]::Format('Subject => {0}', ($IcingaForWindowsCert.Subject)));
    }

    $Output += '';

    $Output += (Show-IcingaRegisteredBackgroundDaemons);
    $Output += (Show-IcingaRegisteredServiceChecks);
    $Output += (Show-IcingaRepository);

    $Output += 'Installed components on this system:';
    $Output += '';
    $Output += [string]::Format('{0}   {1}   Available', $ComponentHeader, ((Add-IcingaWhiteSpaceToString -Text 'Version' -Length $MaxVersionLength)));
    $Output += [string]::Format('{0}   {1}   ---', $ComponentLine, ((Add-IcingaWhiteSpaceToString -Text '---' -Length $MaxVersionLength)));

    $IcingaInstallation = $IcingaInstallation.GetEnumerator() | Sort-Object -Property Name;

    foreach ($component in $IcingaInstallation) {
        $Data           = $component.Value;
        $LatestVersion  = $Data.LatestVersion;
        $CurrentVersion = $Data.CurrentVersion;

        if ([string]::IsNullOrEmpty($Data.LockedVersion) -eq $FALSE) {
            if ($Data.LockedVersion -eq $Data.CurrentVersion) {
                $CurrentVersion = [string]::Format('{0}*', $CurrentVersion);
            } else {
                $LatestVersion = [string]::Format('{0}*', $Data.LockedVersion);
            }
        }

        [string]$ComponentName = Add-IcingaWhiteSpaceToString -Text $component.Name -Length $MaxComponentLength;
        $Output               += [string]::Format('{0}   {1}   {2}', $ComponentName, (Add-IcingaWhiteSpaceToString -Text $CurrentVersion -Length $MaxVersionLength), $LatestVersion);
    }

    $Output += '';
    $Output += 'Available versions flagged with "*" mean that this component is locked to this version';

    Write-Output $Output;
}
