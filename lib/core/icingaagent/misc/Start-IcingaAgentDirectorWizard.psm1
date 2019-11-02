function Start-IcingaAgentDirectorWizard()
{
    param(
        [string]$DirectorUrl,
        [string]$SelfServiceAPIKey,
        $OverrideDirectorVars      = $null,
        $InstallFrameworkService   = $null,
        $ServiceDirectory          = $null,
        $ServiceBin                = $null,
        [bool]$RunInstaller        = $FALSE
    );

    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        $DirectorUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the Url pointing to your Icinga Director' -Default 'v').answer;
    }

    [bool]$HostKnown      = $FALSE;
    [string]$TemplateKey = $SelfServiceAPIKey;

    if ($null -eq $OverrideDirectorVars) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to manually override arguments provided by the Director API?' -Default 'n').result -eq 0) {
            $OverrideDirectorVars = $TRUE;
        } else{
            $OverrideDirectorVars = $FALSE;
        }
    }

    $SelfServiceAPIKey = Get-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey';
    if ([string]::IsNullOrEmpty($SelfServiceAPIKey)) {
        $LegacyTokenPath = Join-Path -Path Get-IcingaAgentConfigDirectory -ChildPath 'icingadirector.token';
        if (Test-Path $LegacyTokenPath) {
            $SelfServiceAPIKey =  Get-Content -Path $LegacyTokenPath;
            Set-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey' -Value $SelfServiceAPIKey;
        }
    }

    if ([string]::IsNullOrEmpty($SelfServiceAPIKey)) {
        $SelfServiceAPIKey = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter your Self-Service API key' -Default 'v').answer;
    } else {
        $HostKnown = $TRUE;
    }

    $Arguments = Get-IcingaDirectorSelfServiceConfig -DirectorUrl $DirectorUrl -ApiKey $SelfServiceAPIKey;
    $Arguments = Convert-IcingaDirectorSelfServiceArguments -JsonInput $Arguments;

    if ($OverrideDirectorVars -eq $TRUE) {
        $NewArguments = Start-IcingaDirectorAPIArgumentOverride -Arguments $Arguments;
        $Arguments = $NewArguments;
    }

    if ($HostKnown -eq $FALSE) {
        Write-Host $SelfServiceAPIKey;
        Write-Host (Get-IcingaHostname @Arguments);
        Write-Host $DirectorUrl;
        $SelfServiceAPIKey = Register-IcingaDirectorSelfServiceHost -DirectorUrl $DirectorUrl -ApiKey $SelfServiceAPIKey -Hostname (Get-IcingaHostname @Arguments);

        # Host is already registered
        if ($null -eq $SelfServiceAPIKey) {
            Write-Host 'The wizard is unable to complete as this host is already registered but the local API key is not stored within the config'
            return;
        }

        $Arguments = Get-IcingaDirectorSelfServiceConfig -DirectorUrl $DirectorUrl -ApiKey $SelfServiceAPIKey;
        $Arguments = Convert-IcingaDirectorSelfServiceArguments -JsonInput $Arguments;
        if ($OverrideDirectorVars -eq $TRUE) {
            $NewArguments = Start-IcingaDirectorAPIArgumentOverride -Arguments $Arguments;
            $Arguments = $NewArguments;
        }
    }

    $Arguments.Add(
        'UseDirectorSelfService', $TRUE
    );
    $Arguments.Add(
        'OverrideDirectorVars', $FALSE
    );
    $Arguments.Add(
        'DirectorUrl', $DirectorUrl
    );
    $Arguments.Add(
        'SelfServiceAPIKey', $TemplateKey
    );
    $Arguments.Add(
        'SkipDirectorQuestion', $TRUE
    );
    $Arguments.Add(
        'InstallFrameworkService', $InstallFrameworkService
    );
    $Arguments.Add(
        'ServiceDirectory', $ServiceDirectory
    );
    $Arguments.Add(
        'ServiceBin', $ServiceBin
    );
    $Arguments.Add(
        'ProvidedArgs', $Arguments
    );

    if ($RunInstaller) {
        Start-IcingaAgentInstallWizard @Arguments;
        return;
    }

    if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'The Director wizard is complete. Do you want to start the installation now?' -Default 'y').result -eq 1) {
        Start-IcingaAgentInstallWizard @Arguments;
    }
}

function Start-IcingaDirectorAPIArgumentOverride()
{
    param(
        $Arguments
    );

    $NewArguments = @{};
    Write-Host 'Please follow the wizard and manually override all entries you intend to';
    Write-Host '====';

    foreach ($entry in $Arguments.Keys) {
        $value = (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Please enter the new value for the argument "{0}"', $entry)) -Default 'v' -DefaultInput $Arguments[$entry]).answer;
        $NewArguments.Add($entry, $value);
    }

    return $NewArguments;
}

Export-ModuleMember -Function @( 'Start-IcingaAgentDirectorWizard' );
