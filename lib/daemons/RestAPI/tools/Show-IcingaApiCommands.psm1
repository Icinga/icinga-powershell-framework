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

function Show-IcingaRESTApiCommands()
{
    $Commands = Get-IcingaPowerShellConfig -Path 'RESTApi.Commands';

    foreach ($property in $Commands.PSObject.Properties) {
        $Whitelisted = 'None';
        $Blacklisted = 'None';

        if (Test-IcingaPowerShellConfigItem -ConfigObject $property.Value -ConfigKey 'Whitelist') {
            if ($property.Value.Whitelist.Count -ne 0) {
                $Whitelisted = [string]::Join(', ', ($property.Value.Whitelist));
            }
        }
        if (Test-IcingaPowerShellConfigItem -ConfigObject $property.Value -ConfigKey 'Blacklist') {
            if ($property.Value.Blacklist.Count -ne 0) {
                $Blacklisted = [string]::Join(', ', ($property.Value.Blacklist));
            }
        }
        Write-IcingaConsolePlain -Message 'API Endpoint "{0}"' -Objects $property.Name;
        Write-IcingaConsolePlain -Message '################';
        Write-IcingaConsolePlain -Message '';
        Write-IcingaConsolePlain -Message 'Whitelisted: {0}' -Objects $Whitelisted;
        Write-IcingaConsolePlain -Message '';
        Write-IcingaConsolePlain -Message 'Blacklisted: {0}' -Objects $Blacklisted;
        Write-IcingaConsolePlain -Message '';
    }
}
