<#
.SYNOPSIS
   Removes a Cmdlet from an REST-Api endpoints whitelist or blacklist.
.DESCRIPTION
   Removes a Cmdlet from an REST-Api endpoints whitelist or blacklist.
.FUNCTIONALITY
   Removes Cmdlets for REST-Api endpoints
.EXAMPLE
   PS>Remove-IcingaFrameworkApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'checker';
.EXAMPLE
   PS>Add-IcingaFrameworkApiCommand -Command 'Invoke-IcingaCheck*' -Endpoint 'checker' -Blacklist;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Remove-IcingaFrameworkApiCommand()
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

    if ($null -eq $Commands) {
        return;
    }

    foreach ($element in $Commands) {
        if ($element.ToLower() -ne $Command.ToLower()) {
            $Values += $element;
        }
    }

    Set-IcingaPowerShellConfig -Path $ConfigPath -Value $Values;
}
