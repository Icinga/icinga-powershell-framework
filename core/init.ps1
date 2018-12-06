# This script will initialse the entire module configuration for easier usage
param (
    [string]$RootDirectory = '',
    [string]$ModuleName    = ''
);

# Create an internal 'namespace' for our environment
Set-Variable -Name Icinga2 -Option Constant -Value @{
    Function = @(
        'Get-Icinga-Lib',
        'Get-Icinga-Object',
        'Get-Icinga-Service',
        'Start-Icinga-Service',
        'Stop-Icinga-Service',
        'Restart-Icinga-Service',
        'Install-Icinga-Service',
        'Uninstall-Icinga-Service',
        'Install-Icinga',
        'Get-Icinga-Setup',
        'Start-Icinga-Daemon',
        'Stop-Icinga-Daemon',
        'Start-Icinga-Checker',
        'Stop-Icinga-Checker',
        'Get-Icinga-Command',
        'New-Icinga-Monitoring',
        'Get-Icinga-Counter',
        'Get-Icinga-Config',
        'Set-Icinga-Config',
        'Remove-Icinga-Config',
        'New-Icinga-Config'
    );
}

# Define temporary variables to store the main current root and module name
# Note: Never use this variables within the module besides inside '\core\includes\'
$_InternalTempVariables = @{
    RootPath   = $RootDirectory;
    ModuleName = $ModuleName;
}
# End definition of temporary variables

# Load all PowerShell scripts within our '\core\include\' directory and add the content with the name
# of the script into our namespace
Get-ChildItem (Join-Path -Path $PSScriptRoot -ChildPath '\include\') -Filter *.ps1 |
    Foreach-Object {
        $path = $_.FullName;
        $name = $_.Name.Replace('.ps1', '');

        # Add variables to a global namespace. Should only be used within the
        # same PowerShell instance
        try {
            $include = (& $path);
        } catch {
            Write-Host (
                [string]::Format(
                    'Failed to execute core module "{0}". Exception: {1}',
                    $name,
                    $_.Exception.Message
                )
            );
        }

        if ([bool]($include.PSobject.Properties.Name -eq 'static') -eq $FALSE -Or $include.static -eq $TRUE) {
            $Icinga2.Add($name, $include);
        }
    }

# Flush the internal temp variable cache
$_InternalTempVariables = $null;

# Load our System.Web helper class
[Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null;

$Icinga2.Add(
    'Cache',
    @{
        # This will allow us to dynamicly initialise Performance Counters during
        # startup to speed up actual checks later on. Of course counters will be
        # cached anyway once they are executed, but will speed up first check
        # executions for CPU Performance Counters for example
        PerformanceCounter = @{ };
        # Pre-Load the Server SSL Certificate
        Certificates       = @{ Server = $Icinga2.Utils.SSL.LoadServerCertificate() };
        # Create a instance for storing TCP Sockets (in case we later want to listen in multi-sockets)
        Sockets            = @{ };
        # Store our checker configuration we receive from the remote endpoint
        Checker            = @{ };
        # This cache can be used for storing informations of modules to compare send informations
        # as well as required data for a later execution of the same module again
        Modules            = @{ };
    }
);

return $Icinga2;