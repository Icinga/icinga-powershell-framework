<#
.SYNOPSIS
   Reads the entire configuration and returns it as custom object
.DESCRIPTION
   Reads the entire configuration and returns it as custom object
.FUNCTIONALITY
   Reads the entire configuration and returns it as custom object
.EXAMPLE
   PS>Read-IcingaPowerShellConfig;
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Read-IcingaPowerShellConfig()
{
    $ConfigDir       = Get-IcingaPowerShellConfigDir;
    $ConfigFile      = Join-Path -Path $ConfigDir -ChildPath 'config.json';
    $ConfigObject    = (New-Object -TypeName PSObject);
    [string]$Content = Read-IcingaFileSecure -File $ConfigFile -ExitOnReadError;

    if ([string]::IsNullOrEmpty($Content) -eq $FALSE) {
        try {
            $ConfigObject = (ConvertFrom-Json -InputObject $Content -ErrorAction Stop);
        } catch {
            New-Item -ItemType Directory -Path (Join-Path -Path $ConfigDir -ChildPath 'corrupt') -ErrorAction SilentlyContinue;
            $NewConfigFile = Join-Path -Path $ConfigDir -ChildPath ([string]::Format('corrupt/config_broken_{0}.json', (Get-Date -Format "yyyy-MM-dd-HH-mm-ss-ffff")));
            Move-Item -Path $ConfigFile -Destination $NewConfigFile -ErrorAction SilentlyContinue;
            New-Item -ItemType File -Path $ConfigFile -ErrorAction SilentlyContinue;

            Write-IcingaEventMessage -EventId 1100 -Namespace 'Framework' -Objects $ConfigFile, $Content;
            Write-IcingaConsoleError -Message 'Your configuration file "{0}" was corrupt and could not be read. It was moved to "{1}" for review and a new plain file has been created' -Objects $ConfigFile, $NewConfigFile;

            $ConfigObject = (New-Object -TypeName PSObject);
        }
    }

    return $ConfigObject;
}
