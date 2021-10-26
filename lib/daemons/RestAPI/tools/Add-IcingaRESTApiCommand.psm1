<#
.SYNOPSIS
   Adds a Cmdlet to an REST-Api endpoint which is either whitelisted or blacklisted.
   Whitelisted Cmdlets can be executed over API endpoints, blacklisted not.
   Use '*' for wildcard matches
.DESCRIPTION
   Adds a Cmdlet to an REST-Api endpoint which is either whitelisted or blacklisted.
   Whitelisted Cmdlets can be executed over API endpoints, blacklisted not.
   Use '*' for wildcard matches
.FUNCTIONALITY
   Enables or disables Cmdlets for REST-Api endpoints
.EXAMPLE
   PS>Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'checker';
.EXAMPLE
   PS>Add-IcingaRESTApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'checker' -Blacklist;
.LINK
   https://github.com/Icinga/icinga-powershell-restapi
#>

function Add-IcingaRESTApiCommand()
{
    param (
        [string]$Command   = '',
        [string]$Endpoint  = '',
        [switch]$Blacklist = $FALSE
    );

    if ([string]::IsNullOrEmpty($Command) -Or [string]::IsNullOrEmpty($Endpoint)) {
        return;
    }

    $Commands      = $null;
    $ConfigPath    = ([string]::Format('RESTApi.Commands.{0}.Whitelist', $Endpoint));
    [array]$Values = @();

    if ($Blacklist) {
        $ConfigPath = ([string]::Format('RESTApi.Commands.{0}.Blacklist', $Endpoint));
    }

    $Commands = Get-IcingaPowerShellConfig -Path $ConfigPath;

    if ((Test-IcingaPowerShellConfigItem -ConfigObject $Commands -ConfigKey $Command)) {
        return;
    }

    if ($null -ne $Commands) {
        $Values = $Commands;
    }

    $Values += $Command;

    Set-IcingaPowerShellConfig -Path $ConfigPath -Value $Values;
}
