function Start-IcingaAgentDirectorWizard()
{
    param(
        [string]$DirectorUrl,
        [string]$SelfServiceAPIKey = $null,
        $OverrideDirectorVars      = $null,
        [bool]$RunInstaller        = $FALSE
    );

    [hashtable]$DirectorOverrideArgs        = @{}
    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        $DirectorUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the Url pointing to your Icinga Director' -Default 'v').answer;
    }

    [bool]$HostKnown     = $FALSE;
    [string]$TemplateKey = $SelfServiceAPIKey;

    if ($null -eq $OverrideDirectorVars -And $RunInstaller -eq $FALSE) {
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

    if ($OverrideDirectorVars -eq $TRUE -And -Not $RunInstaller) {
        $DirectorOverrideArgs = Start-IcingaDirectorAPIArgumentOverride -Arguments $Arguments;
        foreach ($entry in $DirectorOverrideArgs.Keys) {
            if ($Arguments.ContainsKey($entry)) {
                $Arguments[$entry] = $DirectorOverrideArgs[$entry];
            }
        }
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
        if ($OverrideDirectorVars -eq $TRUE -And -Not $RunInstaller) {
            $DirectorOverrideArgs = Start-IcingaDirectorAPIArgumentOverride -Arguments $Arguments;
            foreach ($entry in $DirectorOverrideArgs.Keys) {
                if ($Arguments.ContainsKey($entry)) {
                    $Arguments[$entry] = $DirectorOverrideArgs[$entry];
                }
            }
        }
    }

    $DirectorOverrideArgs.Add(
        'DirectorUrl', $DirectorUrl
    );
    if ([string]::IsNullOrEmpty($TemplateKey) -eq $FALSE) {
        $DirectorOverrideArgs.Add(
            'SelfServiceAPIKey', $TemplateKey
        );
    }

    return @{
        'Arguments' = $Arguments;
        'Overrides' = $DirectorOverrideArgs;
    };
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
        if ($Arguments[$entry] -is [array]) {
            if ([string]::IsNullOrEmpty($value) -eq $FALSE) { 
                [array]$tmpArray = $value.Split(',');
                if ($null -ne (Compare-Object -ReferenceObject $Arguments[$entry] -DifferenceObject $tmpArray)) {
                    $NewArguments.Add(
                        $entry,
                        ([string]::Join(',', $tmpArray))
                    );
                }
            }
            continue;
        } elseif ($Arguments[$entry] -is [bool]) {
            if ($value -eq 'true' -or $value -eq 'y' -or $value -eq '1' -or $value -eq 'yes' -or $value -eq 1) {
                $value = 1;
            } else {
                $value = 0;
            }
        }

        if ($Arguments[$entry] -ne $value) {
            $NewArguments.Add($entry, $value);
        }
    }

    return $NewArguments;
}

Export-ModuleMember -Function @( 'Start-IcingaAgentDirectorWizard' );
