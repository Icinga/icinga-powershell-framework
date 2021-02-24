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
   PS>Add-IcingaFrameworkApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'checker';
.EXAMPLE
   PS>Add-IcingaFrameworkApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'checker' -Blacklist;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Add-IcingaFrameworkApiCommand()
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
    $ConfigPath    = ([string]::Format('Framework.RESTApiCommands.{0}.Whitelist', $Endpoint));
    [array]$Values = @();

    if ($Blacklist) {
        $ConfigPath = ([string]::Format('Framework.RESTApiCommands.{0}.Blacklist', $Endpoint));
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
