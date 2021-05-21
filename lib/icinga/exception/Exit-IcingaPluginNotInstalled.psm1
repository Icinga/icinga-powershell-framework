<#
.SYNOPSIS
    Tests if a provided command is available on the system and exists
    the shell with an Unknown error and a message. Required to properly
    handle Icinga checks and possible error displaying inside Icinga Web 2
.DESCRIPTION
    Tests if a provided command is available on the system and exists
    the shell with an Unknown error and a message. Required to properly
    handle Icinga checks and possible error displaying inside Icinga Web 2
.FUNCTIONALITY
    Tests if a provided command is available on the system and exists
    the shell with an Unknown error and a message. Required to properly
    handle Icinga checks and possible error displaying inside Icinga Web 2
.EXAMPLE
    PS>Exit-IcingaPluginNotInstalled -Command 'Invoke-IcingaCheckCPU';
.PARAMETER Command
    The name of the check command to test for
.INPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Exit-IcingaPluginNotInstalled()
{
    param (
        [string]$Command
    );

    $PowerShellModule = Get-Module 'icinga-powershell-*' -ListAvailable |
        ForEach-Object {
            foreach ($cmd in $_.ExportedCommands.Values) {
                if ($Command.ToLower() -eq $cmd.Name.ToLower()) {
                    return $cmd.Source;
                }
            }
        }

    if ([string]::IsNullOrEmpty($PowerShellModule) -eq $FALSE) {
        try {
            Import-Module $PowerShellModule -ErrorAction Stop;
        } catch {
            $ExMsg = $_.Exception.Message;
            Exit-IcingaThrowException -CustomMessage 'Module not loaded' -ExceptionType 'Configuration' -ExceptionThrown $ExMsg -Force;
        }
    }

    if ([string]::IsNullOrEmpty($Command)) {
        Exit-IcingaThrowException -CustomMessage 'Null-Command' -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginNotAssigned -Force;
    }

    if ($null -eq (Get-Command $Command -ErrorAction SilentlyContinue)) {
        Exit-IcingaThrowException -CustomMessage $Command -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.PluginNotInstalled -Force;
    }
}
