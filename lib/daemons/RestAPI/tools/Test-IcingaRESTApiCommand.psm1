<#
.SYNOPSIS
   Tests if a Cmdlet for a given endpoint is configured as whitelist or blacklist.
   This function will return True if the command is whitelisted and False if it is
   blacklisted. If the Cmdlet is not added anywhere, the function will return False as well.
.DESCRIPTION
   Tests if a Cmdlet for a given endpoint is configured as whitelist or blacklist.
   This function will return True if the command is whitelisted and False if it is
   blacklisted. If the Cmdlet is not added anywhere, the function will return False as well.
.FUNCTIONALITY
   Tests if a Cmdlet is allowed to be executed over the REST-Api
.EXAMPLE
   PS>Test-IcingaRESTApiCommand -Command 'Invoke-IcingaCheckCPU' -Endpoint 'checker';
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaRESTApiCommand()
{
    param (
        [string]$Command  = '',
        [string]$Endpoint = ''
    );

    if ([string]::IsNullOrEmpty($Command) -Or [string]::IsNullOrEmpty($Endpoint)) {
        return $FALSE;
    }

    $WhiteList = Get-IcingaPowerShellConfig -Path ([string]::Format('RESTApi.Commands.{0}.Whitelist', $Endpoint));
    $Blacklist = Get-IcingaPowerShellConfig -Path ([string]::Format('RESTApi.Commands.{0}.Blacklist', $Endpoint));

    foreach ($entry in $Blacklist) {
        if ($Command.ToLower() -like $entry.ToLower()) {
            return $FALSE;
        }
    }

    foreach ($entry in $WhiteList) {
        if ($Command.ToLower() -like $entry.ToLower()) {
            return $TRUE;
        }
    }

    # If the command is not configured, always return false
    return $FALSE;
}
