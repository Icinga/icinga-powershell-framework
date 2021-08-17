<#
.SYNOPSIS
   Will fetch the current host configuration or general configuration depending
   if a host or template key is specified from the Icinga Director Self-Service API
.DESCRIPTION
   Use the Self-Service API of the Icinga Director to connect to it and fetch the
   configuration to apply for this host. The configuration itself is differentiated
   if a template or the specific host key is used
.FUNCTIONALITY
   Fetches host or general configuration form the Icinga Director Self-Service API
.EXAMPLE
   PS>Get-IcingaDirectorSelfServiceConfig -DirectorUrl 'https://example.com/icingaweb2/director -ApiKey 457g6b98054v76vb5490ß276bv0457v6054b76;
.PARAMETER DirectorUrl
   The URL pointing directly to the Icinga Web 2 Director module
.PARAMETER ApiKey
   Either the template or host key to authenticate against the Self-Service API
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaDirectorSelfServiceConfig()
{
    param(
        $DirectorUrl,
        $ApiKey      = $null
    );

    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        throw 'Please enter a valid Url to your Icinga Director';
    }

    if ([string]::IsNullOrEmpty($ApiKey)) {
        throw 'Please enter either a template or your host key. If this message persists, ensure your host is not having a template key assigned already. If so, you can try dropping it within the Icinga Director.';
    }

    Set-IcingaTLSVersion;
    $ProgressPreference = "SilentlyContinue";

    $EndpointUrl = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/powershell-parameters?key={0}', $ApiKey));

    $response = Invoke-IcingaWebRequest -Uri $EndpointUrl -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST';

    if ($response.StatusCode -ne 200) {
        throw $response.Content;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    if (Test-PSCustomObjectMember -PSObject $JsonContent -Name 'error') {
        throw 'Icinga Director Self-Service has thrown an error: ' + $JsonContent.error;
    }

    $JsonContent = Add-PSCustomObjectMember -Object $JsonContent -Key 'IcingaMaster' -Value $response.BaseResponse.ResponseUri.Host;

    return $JsonContent;
}

<#
.SYNOPSIS
    Will fetch the ticket for certificate signing by using the Icinga Director
    Self-Service API
.DESCRIPTION
    Use the Self-Service API of the Icinga Director to connect to it and fetch the
    ticket to sign Icinga 2 certificate requests
.FUNCTIONALITY
    Fetches the ticket for certificate signing form the Icinga Director Self-Service API
.EXAMPLE
    PS>Get-IcingaDirectorSelfServiceTicket -DirectorUrl 'https://example.com/icingaweb2/director -ApiKey 457g6b98054v76vb5490ß276bv0457v6054b76;
.PARAMETER DirectorUrl
    The URL pointing directly to the Icinga Web 2 Director module
.PARAMETER ApiKey
    The host key to authenticate against the Self-Service API
.INPUTS
    System.String
.OUTPUTS
    System.Object
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaDirectorSelfServiceTicket()
{
    param (
        $DirectorUrl,
        $ApiKey      = $null
    );

    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        Write-IcingaConsoleError 'Unable to fetch host ticket. No Director url has been specified';
        return;
    }

    if ([string]::IsNullOrEmpty($ApiKey)) {
        Write-IcingaConsoleError 'Unable to fetch host ticket. No API key has been specified';
        return;
    }

    Set-IcingaTLSVersion;

    [string]$url = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/ticket?key={0}', $ApiKey));

    $response = Invoke-IcingaWebRequest -Uri $url -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST';

    if ($response.StatusCode -ne 200) {
        throw $response.Content;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    return $JsonContent;
}

<#
.SYNOPSIS
   Register the current host wihtin the Icinga Director by using the
   Self-Service API and return the host key
.DESCRIPTION
   This function will register the current host within the Icinga Director in case
   it is not already registered and returns the host key for storing it on disk
   to allow the host to fetch detailed configurations like zones and endppoints
.FUNCTIONALITY
   Register a host within the Icinga Director by using the Self-Service API
.EXAMPLE
   PS>Register-IcingaDirectorSelfServiceHost -DirectorUrl 'https://example.com/icingaweb2/director -Hostname 'examplehost' -ApiKey 457g6b98054v76vb5490ß276bv0457v6054b76 -Endpoint 'icinga.example.com';
.PARAMETER DirectorUrl
   The URL pointing directly to the Icinga Web 2 Director module
.PARAMETER Hostname
   The name of the current host to register within the Icinga Director
.PARAMETER ApiKey
   The template key to authenticate against the Self-Service API
.PARAMETER Endpoint
   The IP or FQDN to one of the parent Icinga 2 nodes this Agent will connect to
   for determining which network interface shall be used by Icinga for connecting
   and to apply hostalive/ping checks to
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Register-IcingaDirectorSelfServiceHost()
{
    param(
        $DirectorUrl,
        $Hostname,
        $ApiKey           = $null,
        [string]$Endpoint = $null
    );

    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        throw 'Please enter a valid Url to your Icinga Director';
    }

    if ([string]::IsNullOrEmpty($Hostname)) {
        throw 'Please enter the hostname to use';
    }

    if ([string]::IsNullOrEmpty($ApiKey)) {
        throw 'Please enter the API key of the template you wish to use';
    }

    Set-IcingaTLSVersion;
    $ProgressPreference = "SilentlyContinue";
    $DirectorConfigJson = $null;

    if ([string]::IsNullOrEmpty($Endpoint)) {
        if ($DirectorUrl.Contains('https://') -Or $DirectorUrl.Contains('http://')) {
            $Endpoint = $DirectorUrl.Split('/')[2];
        } else {
            $Endpoint = $DirectorUrl.Split('/')[0];
        }
    }

    $Interface          = Get-IcingaNetworkInterface $Endpoint;
    $DirectorConfigJson = [string]::Format('{0} "address":"{2}" {1}', '{', '}', $Interface);

    $EndpointUrl = Join-WebPath -Path $DirectorUrl -ChildPath ([string]::Format('/self-service/register-host?name={0}&key={1}', $Hostname, $ApiKey));

    $response = Invoke-IcingaWebRequest -Uri $EndpointUrl -UseBasicParsing -Headers @{ 'accept' = 'application/json'; 'X-Director-Accept' = 'application/json' } -Method 'POST' -Body $DirectorConfigJson;

    if ($response.StatusCode -ne 200) {
        throw $response.Content;
    }

    $JsonContent = ConvertFrom-Json -InputObject $response.Content;

    if (Test-PSCustomObjectMember -PSObject $JsonContent -Name 'error') {
        if ($JsonContent.error -like '*already been registered*') {
            return $null;
        }

        throw 'Icinga Director Self-Service has thrown an error: ' + $JsonContent.error;
    }

    Set-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey' -Value $JsonContent;

    Write-IcingaConsoleNotice 'Host was successfully registered within Icinga Director';

    return $JsonContent;
}

<#
.SYNOPSIS
   Returns the amount of items for a config item
.DESCRIPTION
   Returns the amount of items for a config item
.FUNCTIONALITY
   Returns the amount of items for a config item
.EXAMPLE
   PS>Get-IcingaConfigTreeCount -Path 'framework.daemons';
.PARAMETER Path
   The path to the config item to check for
.INPUTS
   System.String
.OUTPUTS
   System.Integer
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaConfigTreeCount()
{
    param(
        $Path = ''
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Count   = 0;

    foreach ($entry in $PathArray) {
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            continue;
        }

        $ConfigObject = $ConfigObject.$entry;
    }

    foreach ($config in $ConfigObject.PSObject.Properties) {
        $Count += 1;
    }

    return $Count;
}

<#
.SYNOPSIS
   Returns the configuration for a provided config path
.DESCRIPTION
   Returns the configuration for a provided config path
.FUNCTIONALITY
   Returns the configuration for a provided config path
.EXAMPLE
   PS>Get-IcingaPowerShellConfig -Path 'framework.daemons';
.PARAMETER Path
   The path to the config item to check for
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaPowerShellConfig()
{
    param(
        $Path = ''
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;

    foreach ($entry in $PathArray) {
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            return $null;
        }

        $ConfigObject = $ConfigObject.$entry;
    }

    return $ConfigObject;
}

<#
.SYNOPSIS
   Creates a new config entry with given arguments
.DESCRIPTION
   Creates a new config entry with given arguments
.FUNCTIONALITY
   Creates a new config entry with given arguments
.EXAMPLE
   PS>New-IcingaPowerShellConfigItem -ConfigObject $PSObject -ConfigKey 'keyname' -ConfigValue 'keyvalue';
.PARAMETER ConfigObject
   The custom config object to modify
.PARAMETER ConfigKey
   The key which is added to the config object
.PARAMETER ConfigValue
   The value written for the ConfigKey
.INPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPowerShellConfigItem()
{
    param(
        $ConfigObject,
        [string]$ConfigKey,
        $ConfigValue       = $null
    );

    if ($null -eq $ConfigValue) {
        $ConfigValue = (New-Object -TypeName PSOBject);
    }

    $ConfigObject | Add-Member -MemberType NoteProperty -Name $ConfigKey -Value $ConfigValue;
}

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
    $ConfigDir  = Get-IcingaPowerShellConfigDir;
    $ConfigFile = Join-Path -Path $ConfigDir -ChildPath 'config.json';

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon) {
        if ($global:IcingaDaemonData.ContainsKey('Config')) {
            return $global:IcingaDaemonData.Config;
        }
    }

    if (-Not (Test-Path $ConfigFile)) {
        return (New-Object -TypeName PSObject);
    }

    [string]$Content = Read-IcingaFileContent -File $ConfigFile;

    if ([string]::IsNullOrEmpty($Content)) {
        return (New-Object -TypeName PSObject);
    }

    return (ConvertFrom-Json -InputObject $Content);
}

<#
.SYNOPSIS
   Removes a config entry from a given path
.DESCRIPTION
   Removes a config entry from a given path
.FUNCTIONALITY
   Removes a config entry from a given path
.EXAMPLE
   PS>Remove-IcingaPowerShellConfig -Path 'framework.daemons';
.PARAMETER Path
   The path to the config item to remove
.INPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Remove-IcingaPowerShellConfig()
{
    param(
        $Path  = ''
    );

    if ([string]::IsNullOrEmpty($Path)) {
        throw 'Please specify a valid path to an object';
    }

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Index   = $PathArray.Count;

    foreach ($entry in $PathArray) {

        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            return $null;
        }

        if ($index -eq  1) {
            $ConfigObject.PSObject.Properties.Remove($entry);
            break;
        }

        $ConfigObject = $ConfigObject.$entry;
        $Index        -= 1;
    }

    Write-IcingaPowerShellConfig $Config;
}

<#
.SYNOPSIS
   Sets a config entry for a given path to a certain value
.DESCRIPTION
   Sets a config entry for a given path to a certain value
.FUNCTIONALITY
   Sets a config entry for a given path to a certain value
.EXAMPLE
   PS>Set-IcingaPowerShellConfig -Path 'framework.daemons.servicecheck' -Value $DaemonConfig;
.PARAMETER Path
   The path to the config item to be set
.PARAMETER Value
   The value to be set for a specific config path
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Set-IcingaPowerShellConfig()
{
    param(
        $Path  = '',
        $Value = $null
    );

    $Config       = Read-IcingaPowerShellConfig;
    $PathArray    = $Path.Split('.');
    $ConfigObject = $Config;
    [int]$Index   = $PathArray.Count;
    $InputValue   = $null;
    foreach ($entry in $PathArray) {
        if ($index -eq  1) {
            $InputValue = $Value;
        }
        if (-Not (Test-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry)) {
            New-IcingaPowerShellConfigItem -ConfigObject $ConfigObject -ConfigKey $entry -ConfigValue $InputValue;
        }

        if ($index -eq  1) {
            $ConfigObject.$entry = $Value;
            break;
        }

        $ConfigObject = $ConfigObject.$entry;
        $index -= 1;
    }

    Write-IcingaPowerShellConfig $Config;
}

<#
.SYNOPSIS
   Test if a config entry on an object is already present
.DESCRIPTION
   Test if a config entry on an object is already present
.FUNCTIONALITY
   Test if a config entry on an object is already present
.EXAMPLE
   PS>Test-IcingaPowerShellConfigItem -ConfigObject $PSObject -ConfigKey 'keyname';
.PARAMETER ConfigObject
   The custom config object to check for
.PARAMETER ConfigKey
   The key which is checked
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaPowerShellConfigItem()
{
    param(
        $ConfigObject,
        $ConfigKey
    );

    return ([bool]($ConfigObject.PSobject.Properties.Name -eq $ConfigKey) -eq $TRUE);
}

<#
.SYNOPSIS
   Writes a given config object to disk
.DESCRIPTION
   Writes a given config object to disk
.FUNCTIONALITY
   Writes a given config object to disk
.EXAMPLE
   PS>Write-IcingaPowerShellConfig -Config $PSObject;
.PARAMETER Config
   A PSObject containing the entire configuration to write
.INPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaPowerShellConfig()
{
    param(
        $Config
    );

    $ConfigDir  = Get-IcingaPowerShellConfigDir;
    $ConfigFile = Join-Path -Path $ConfigDir -ChildPath 'config.json';

    if (-Not (Test-Path $ConfigDir)) {
        New-Item -Path $ConfigDir -ItemType Directory | Out-Null;
    }

    $Content = ConvertTo-Json -InputObject $Config -Depth 100;

    Set-Content -Path $ConfigFile -Value $Content;

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon) {
        if ($global:IcingaDaemonData.ContainsKey('Config')) {
            $global:IcingaDaemonData.Config = $Config;
        }
    }
}

<#
.SYNOPSIS
    Reads data from a cache file of the Framework and returns its content
.DESCRIPTION
    Allows a developer to read data from certain cache files to either speed up
    loading procedures, to store content to not lose data on restarts of a daemon
    or to build data tables over time
.FUNCTIONALITY
    Returns cached data for specific content
.EXAMPLE
    PS>Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName 'Invoke-IcingaCheckCPU';
.PARAMETER Space
    The individual space to read from. This is targeted to a folder the cache data is written to under icinga-powershell-framework/cache/
.PARAMETER CacheStore
    This is targeted to a sub-folder under icinga-powershell-framework/cache/<space>/
.PARAMETER KeyName
    This is the actual cache file located under icinga-powershell-framework/cache/<space>/<CacheStore>/<KeyName>.json
    Please note to only provide the name without the '.json' apendix. This is done by the module itself
.INPUTS
    System.String
.OUTPUTS
    System.Object
.LINK
    https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>
function Get-IcingaCacheData()
{
    param(
        [string]$Space,
        [string]$CacheStore,
        [string]$KeyName
    );

    $CacheFile       = Join-Path -Path (Join-Path -Path (Join-Path -Path (Get-IcingaCacheDir) -ChildPath $Space) -ChildPath $CacheStore) -ChildPath ([string]::Format('{0}.json', $KeyName));
    [string]$Content = '';
    $cacheData       = @{ };

    if ((Test-Path $CacheFile) -eq $FALSE) {
        return $null;
    }

    $Content = Read-IcingaFileContent -File $CacheFile;

    if ([string]::IsNullOrEmpty($Content)) {
        return $null;
    }

    $cacheData = ConvertFrom-Json -InputObject ([string]$Content);

    if ([string]::IsNullOrEmpty($KeyName)) {
        return $cacheData;
    } else {
        return $cacheData.$KeyName;
    }
}

<#
.SYNOPSIS
    Writes data to a cache file for the Framework
.DESCRIPTION
    Allows a developer to write data to certain cache files to either speed up
    loading procedures, to store content to not lose data on restarts of a daemon
    or to build data tables over time
.FUNCTIONALITY
    Writes  data for specific value to a cache file
.EXAMPLE
    PS>Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName 'Invoke-IcingaCheckCPU' -Value @{ 'CachedData' = 'MyValue' };
.PARAMETER Space
    The individual space to write to. This is targeted to a folder the cache data is written to under icinga-powershell-framework/cache/
.PARAMETER CacheStore
    This is targeted to a sub-folder under icinga-powershell-framework/cache/<space>/
.PARAMETER KeyName
    This is the actual cache file located under icinga-powershell-framework/cache/<space>/<CacheStore>/<KeyName>.json
    Please note to only provide the name without the '.json' apendix. This is done by the module itself
.PARAMETER Value
    The actual value to store within the cache file. This can be any kind of value, as long as it is convertable to JSON
.INPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Set-IcingaCacheData()
{
    param (
        [string]$Space,
        [string]$CacheStore,
        [string]$KeyName,
        $Value
    );

    $CacheFile = Join-Path -Path (Join-Path -Path (Join-Path -Path (Get-IcingaCacheDir) -ChildPath $Space) -ChildPath $CacheStore) -ChildPath ([string]::Format('{0}.json', $KeyName));
    $cacheData = @{ };

    if ((Test-Path $CacheFile)) {
        $cacheData = Get-IcingaCacheData -Space $Space -CacheStore $CacheStore;
    } else {
        try {
            New-Item -ItemType File -Path $CacheFile -Force -ErrorAction Stop | Out-Null;
        } catch {
            Exit-IcingaThrowException -InputString $_.Exception -CustomMessage (Get-IcingaCacheDir) -StringPattern 'NewItemUnauthorizedAccessError' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.CacheFolder;
            Exit-IcingaThrowException -CustomMessage $_.Exception -ExceptionType 'Unhandled' -Force;
        }
    }

    if ($null -eq $cacheData -or $cacheData.Count -eq 0) {
        $cacheData = @{
            $KeyName = $Value
        };
    } else {
        if ($cacheData.PSobject.Properties.Name -ne $KeyName) {
            $cacheData | Add-Member -MemberType NoteProperty -Name $KeyName -Value $Value -Force;
        } else {
            $cacheData.$KeyName = $Value;
        }
    }

    try {
        Set-Content -Path $CacheFile -Value (ConvertTo-Json -InputObject $cacheData -Depth 100) | Out-Null;
    } catch {
        Exit-IcingaThrowException -InputString $_.Exception -CustomMessage (Get-IcingaCacheDir) -StringPattern 'System.UnauthorizedAccessException' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.CacheFolder;
        Exit-IcingaThrowException -CustomMessage $_.Exception -ExceptionType 'Unhandled' -Force;
    }
}
<#
.SYNOPSIS
   Clear all cached values for all check commands executed by this thread.
   This is mandatory as we might run into a memory leak otherwise!
.DESCRIPTION
   Clear all cached values for all check commands executed by this thread.
   This is mandatory as we might run into a memory leak otherwise!
.FUNCTIONALITY
   Clear all cached values for all check commands executed by this thread.
   This is mandatory as we might run into a memory leak otherwise!
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Clear-IcingaCheckSchedulerCheckData()
{
    if ($null -eq $global:Icinga) {
        return;
    }

    if ($global:Icinga.ContainsKey('CheckData') -eq $FALSE) {
        return;
    }

    $global:Icinga.CheckData.Clear();
}

<#
.SYNOPSIS
   Clears the entire check scheduler cache environment and frees memory as
   well as cleaning the stack
.DESCRIPTION
   Clears the entire check scheduler cache environment and frees memory as
   well as cleaning the stack
.FUNCTIONALITY
   Clears the entire check scheduler cache environment and frees memory as
   well as cleaning the stack
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Clear-IcingaCheckSchedulerEnvironment()
{
    if ($null -eq $global:Icinga) {
        return;
    }

    Get-IcingaCheckSchedulerPluginOutput | Out-Null;
    Get-IcingaCheckSchedulerPerfData | Out-Null;
    Clear-IcingaCheckSchedulerCheckData;
}

<#
.SYNOPSIS
   A more secure way to copy items from one location to another including error handling
.DESCRIPTION
   Wrapper for the Copy-Item Cmdlet to more securely copy items with error
   handling to prevent interuptions during actions
.FUNCTIONALITY
   Copies items from a source to a destination location
.EXAMPLE
   PS>Copy-ItemSecure -Path 'C:\users\public\test.txt' -Destination 'C:\users\public\text2.txt';
.EXAMPLE
   PS>Copy-ItemSecure -Path 'C:\users\public\testfolder\' -Destination 'C:\users\public\testfolder2\' -Recurse;
.PARAMETER Path
   The location you wish to copy from. Can either be a file or a directory
.PARAMETER Destination
   The target destination to copy to. Can either be a file or a directory
.PARAMETER Recurse
   Include possible sub-folders
.PARAMETER Force
   Overwrite already existing files/folders
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Copy-ItemSecure()
{
    param(
        [string]$Path,
        [string]$Destination,
        [switch]$Recurse,
        [switch]$Force
    );

    if ((Test-Path $Path) -eq $FALSE) {
        return $FALSE;
    }

    try {
        if ($Recurse -And $Force) {
            Copy-Item -Path $Path -Destination $Destination -Recurse -Force;
        } elseif ($Recurse -And -Not $Force) {
            Copy-Item -Path $Path -Destination $Destination -Recurse;
        } elseif (-Not $Recurse -And $Force) {
            Copy-Item -Path $Path -Destination $Destination -Force;
        } else {
            Copy-Item -Path $Path -Destination $Destination;
        }
        return $TRUE;
    } catch {
        Write-IcingaConsoleError -Message 'Failed to copy items from path "{0}" to "{1}": {2}' -Objects $Path, $Destination, $_.Exception;
    }
    return $FALSE;
}

<#
.SYNOPSIS
   Disables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.DESCRIPTION
   Disables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.FUNCTIONALITY
   Disables the Icinga for Windows Api checks forwarded
.EXAMPLE
   PS>Disable-IcingaFrameworkApiChecks;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaFrameworkApiChecks()
{
    Set-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks' -Value $FALSE;
}

<#
.SYNOPSIS
   Allows to disable any console output for this PowerShell session
.DESCRIPTION
   Allows to disable any console output for this PowerShell session
.FUNCTIONALITY
   Allows to disable any console output for this PowerShell session
.EXAMPLE
   PS>Disable-IcingaFrameworkConsoleOutput;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaFrameworkConsoleOutput()
{
    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    if ($global:Icinga.ContainsKey('DisableConsoleOutput') -eq $FALSE) {
        $global:Icinga.Add('DisableConsoleOutput', $TRUE);
    } else {
        $global:Icinga.DisableConsoleOutput = $TRUE;
    }
}

<#
.SYNOPSIS
   Disables the debug mode of the Framework
.DESCRIPTION
   Disables the debug mode of the Framework
.FUNCTIONALITY
   Disables the Icinga for Windows Debug-Log
.EXAMPLE
   PS>Disable-IcingaFrameworkDebugMode;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaFrameworkDebugMode()
{
    $global:IcingaDaemonData.DebugMode = $FALSE;
    Set-IcingaPowerShellConfig -Path 'Framework.DebugMode' -Value $FALSE;
}

<#
.SYNOPSIS
   Enables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.DESCRIPTION
   Enables the feature to forward all executed checks to an internal
   installed API to run them within a daemon
.FUNCTIONALITY
   Enables the Icinga for Windows Api checks forwarded
.EXAMPLE
   PS>Enable-IcingaFrameworkApiChecks;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaFrameworkApiChecks()
{
    Set-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks' -Value $TRUE;

    Write-IcingaConsoleWarning 'Experimental Feature: Please ensure to install the packages "icinga-powershell-restapi" and "icinga-powershell-apichecks", install the Icinga for Windows background service and also register the daemon with "Register-IcingaBackgroundDaemon -Command {0}". Afterwards all services will be executed by the background daemon in case it is running.' -Objects "'Start-IcingaWindowsRESTApi'";
}

<#
.SYNOPSIS
   Allows to enable any console output for this PowerShell session
.DESCRIPTION
   Allows to enable any console output for this PowerShell session
.FUNCTIONALITY
   Allows to enable any console output for this PowerShell session
.EXAMPLE
   PS>Enable-IcingaFrameworkConsoleOutput;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaFrameworkConsoleOutput()
{
    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    if ($global:Icinga.ContainsKey('DisableConsoleOutput') -eq $FALSE) {
        $global:Icinga.Add('DisableConsoleOutput', $FALSE);
    } else {
        $global:Icinga.DisableConsoleOutput = $FALSE;
    }
}

<#
.SYNOPSIS
   Enables the debug mode of the Framework to print additional details into
   the Windows Event Log with Id 1000
.DESCRIPTION
   Enables the debug mode of the Framework to print additional details into
   the Windows Event Log with Id 1000
.FUNCTIONALITY
   Enables the Icinga for Windows Debug-Log
.EXAMPLE
   PS>Enable-IcingaFrameworkDebugMode;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Enable-IcingaFrameworkDebugMode()
{
    $global:IcingaDaemonData.DebugMode = $TRUE;
    Set-IcingaPowerShellConfig -Path 'Framework.DebugMode' -Value $TRUE;
}

<#
.SYNOPSIS
   Extracts a ZIP-Archive to a certain location
.DESCRIPTION
   Unzips a ZIP-Archive on to a certain location
.FUNCTIONALITY
   Unzips a ZIP-Archive on to a certain location
.EXAMPLE
   PS>Expand-IcingaZipArchive -Path 'C:\users\public\test.zip' -Destination 'C:\users\public\';
.PARAMETER Path
   The location of your ZIP-Archive
.PARAMETER Destination
   The target destination to extract the ZIP-Archive to
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Expand-IcingaZipArchive()
{
    param(
        $Path,
        $Destination
    );

    if ((Test-Path $Path) -eq $FALSE -Or (Test-Path $Destination) -eq $FALSE) {
        Write-IcingaConsoleError 'The path to the zip archive or the destination path do not exist';
        return $FALSE;
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem;

    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($Path, $Destination);
        return $TRUE;
    } catch {
        throw $_.Exception;
    }

    return $FALSE;
}

<#
.SYNOPSIS
   Fetch the raw output values for a check command for each single object
   processed by New-IcingaCheck
.DESCRIPTION
   Fetch the raw output values for a check command for each single object
   processed by New-IcingaCheck
.FUNCTIONALITY
   Fetch the raw output values for a check command for each single object
   processed by New-IcingaCheck
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaCheckSchedulerCheckData()
{
    if ($null -eq $global:Icinga) {
        return $null;
    }

    if ($global:Icinga.ContainsKey('CheckData') -eq $FALSE) {
        return @{ };
    }

    return $global:Icinga.CheckData;
}

<#
.SYNOPSIS
   Function to fetch the last executed plugin peformance data
   from an internal memory cache in case the Framework is running as daemon.
.DESCRIPTION
   While running the Framework as daemon, checkresults for plugins are not
   printed into the console but written into an internal memory cache. Once
   a plugin was executed, use this function to fetch the plugin performance data
.FUNCTIONALITY
   Returns the last performance data output for executed plugins while the
   Framework is running as daemon
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaCheckSchedulerPerfData()
{
    if ($null -eq $global:Icinga) {
        return $null;
    }

    $PerfData               = $global:Icinga.PerfData;
    $global:Icinga.PerfData = @();

    return $PerfData;
}

<#
.SYNOPSIS
   Function to fetch the last executed plugin output from an internal memory
   cache in case the Framework is running as daemon.
.DESCRIPTION
   While running the Framework as daemon, checkresults for plugins are not
   printed into the console but written into an internal memory cache. Once
   a plugin was executed, use this function to fetch the plugin output
.FUNCTIONALITY
   Returns the last checkresult output for executed plugins while the
   Framework is running as daemon
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaCheckSchedulerPluginOutput()
{
    if ($null -eq $global:Icinga) {
        return $null;
    }

    $CheckResult = [string]::Join("`r`n", $global:Icinga.CheckResults);
    $global:Icinga.CheckResults = @();

    return $CheckResult;
}

<#
.SYNOPSIS
   Fetches the current enable/disable state of the feature
   for executing checks of the internal REST-Api
.DESCRIPTION
   Fetches the current enable/disable state of the feature
   for executing checks of the internal REST-Api
.FUNCTIONALITY
   Get the current API check execution configuration of the
   Icinga PowerShell Framework
.EXAMPLE
   PS>Get-IcingaFrameworkApiChecks;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.OUTPUTS
   System.Boolean
#>

function Get-IcingaFrameworkApiChecks()
{
    $CodeCaching = Get-IcingaPowerShellConfig -Path 'Framework.Experimental.UseApiChecks';

    if ($null -eq $CodeCaching) {
        return $FALSE;
    }

    return $CodeCaching;
}

<#
.SYNOPSIS
   Get the current debug mode configuration of the Framework
.DESCRIPTION
   Get the current debug mode configuration of the Framework
.FUNCTIONALITY
   Get the current debug mode configuration of the Framework
.EXAMPLE
   PS>Get-IcingaFrameworkDebugMode;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.OUTPUTS
   System.Boolean
#>

function Get-IcingaFrameworkDebugMode()
{
    $DebugMode = Get-IcingaPowerShellConfig -Path 'Framework.DebugMode';

    if ($null -eq $DebugMode) {
        return $FALSE;
    }

    return $DebugMode;
}

<#
.SYNOPSIS
   Downloads a ZIP-Archive for the Icinga for Windows Service Binary
   and installs it into a specified directory
.DESCRIPTION
   Wizard function to download the Icinga for Windows Service binary from
   a public ressource or from a local webstore / webshare and extract
   the ZIP-Archive into a target destination
.FUNCTIONALITY
   Downloads and unzips the Icinga for Windows service binary ZIP-Archive
.EXAMPLE
   PS>Get-IcingaFrameworkServiceBinary -FrameworkServiceUrl 'https://github.com/Icinga/icinga-powershell-service/releases/download/v1.0.0/icinga-service-v1.0.0.zip' -ServiceDirectory 'C:\Program Files\icinga-framework-service';
.EXAMPLE
   PS>Get-IcingaFrameworkServiceBinary -FrameworkServiceUrl 'C:/users/public/icinga-service-v1.0.0.zip' -ServiceDirectory 'C:\Program Files\icinga-framework-service';
.PARAMETER FrameworkServiceUrl
   The URL / Source for downloading the ZIP-Archive from.
.PARAMETER Destination
   The target destination to extract the ZIP-Archive to and to place the service binary
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaFrameworkServiceBinary()
{
    param(
        [string]$FrameworkServiceUrl,
        [string]$ServiceDirectory,
        [switch]$Release             = $FALSE
    );

    Set-IcingaTLSVersion;
    $ProgressPreference = "SilentlyContinue";

    if ([string]::IsNullOrEmpty($FrameworkServiceUrl) -Or $Release) {
        if ($Release -Or (Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you provide a custom source of the service binary?' -Default 'n').result -eq 1) {
            $LatestRelease       = (Invoke-IcingaWebRequest -Uri 'https://github.com/Icinga/icinga-powershell-service/releases/latest' -UseBasicParsing).BaseResponse.ResponseUri.AbsoluteUri;
            $FrameworkServiceUrl = $LatestRelease.Replace('/tag/', '/download/');
            $Tag                 = $FrameworkServiceUrl.Split('/')[-1];
            $FrameworkServiceUrl = [string]::Format('{0}/icinga-service-{1}.zip', $FrameworkServiceUrl, $Tag);
        } else {
            $FrameworkServiceUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the full path to your service binary repository' -Default 'v').answer;
        }
    }

    if ([string]::IsNullOrEmpty($FrameworkServiceUrl)) {
        Write-IcingaConsoleError 'No Url to download the Icinga Service Binary from has been specified. Please try again.';
        return Get-IcingaFrameworkServiceBinary;
    }

    if ([string]::IsNullOrEmpty($ServiceDirectory)) {
        $ServiceDirectory = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the path you wish to install the service to' -Default 'v' -DefaultInput 'C:\Program Files\icinga-framework-service\').answer;
    }

    if ((Test-Path $ServiceDirectory) -eq $FALSE) {
        New-Item -Path $ServiceDirectory -Force -ItemType Directory | Out-Null;
    }

    $TmpDirectory  = New-IcingaTemporaryDirectory;
    if (Test-Path $FrameworkServiceUrl) {
        $ZipArchive = Join-Path -Path $TmpDirectory -ChildPath ($FrameworkServiceUrl.Replace('/', '\').Split('\')[-1]);
    } else {
        $ZipArchive = Join-Path -Path $TmpDirectory -ChildPath ($FrameworkServiceUrl.Split('/')[-1]);
    }

    $TmpServiceBin = Join-Path -Path $TmpDirectory -ChildPath 'icinga-service.exe';
    $UpdateBin     = Join-Path -Path $ServiceDirectory -ChildPath 'icinga-service.exe.update';
    $ServiceBin    = Join-Path -Path $ServiceDirectory -ChildPath 'icinga-service.exe';

    if ((Invoke-IcingaWebRequest -Uri $FrameworkServiceUrl -UseBasicParsing -OutFile $ZipArchive).HasErrors) {
        Write-IcingaConsoleError -Message 'Failed to download the Icinga Service Binary from "{0}". Please try again.' -Objects $FrameworkServiceUrl;
        return Get-IcingaFrameworkServiceBinary;
    }

    if ((Expand-IcingaZipArchive -Path $ZipArchive -Destination $TmpDirectory) -eq $FALSE) {
        throw 'Failed to expand the downloaded ZIP archive';
    }

    if ((Test-IcingaZipBinaryChecksum -Path $TmpServiceBin) -eq $FALSE) {
        throw 'The checksum of the downloaded file and the required MD5 hash are not matching';
    }

    Copy-ItemSecure -Path $TmpServiceBin -Destination $UpdateBin -Force | Out-Null;
    Start-Sleep -Seconds 1;
    Remove-ItemSecure -Path $TmpDirectory -Recurse -Force | Out-Null;

    return @{
        'FrameworkServiceUrl' = $FrameworkServiceUrl;
        'ServiceDirectory'    = $ServiceDirectory;
        'ServiceBin'          = $ServiceBin;
    };
}

<#
.SYNOPSIS
   Download a PowerShell Module from a custom source or from GitHub
   by providing a repository and the user space
.DESCRIPTION
   Download a PowerShell Module from a custom source or from GitHub
   by providing a repository and the user space
.FUNCTIONALITY
   Download and install a PowerShell module from a custom or GitHub source
.EXAMPLE
   PS>Get-IcingaPowerShellModuleArchive -ModuleName 'Plugins' -Repository 'icinga-powershell-plugins' -Release 1;
.EXAMPLE
   PS>Get-IcingaPowerShellModuleArchive -ModuleName 'Plugins' -Repository 'icinga-powershell-plugins' -Release 1 -DryRun 1;
.PARAMETER DownloadUrl
   The Url to a ZIP-Archive to download from (skips the wizard)
.PARAMETER ModuleName
   The name which is used inside output messages
.PARAMETER Repository
   The repository to download the ZIP-Archive from
.PARAMETER GitHubUser
   The user from which a repository is downloaded from
.PARAMETER Release
   Download the latest release
.PARAMETER Snapshot
   Download the latest package from the master branch
.PARAMETER DryRun
   Only return the finished build Url including the version to install but
   do not modify the system in any way
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaPowerShellModuleArchive()
{
    param(
        [string]$DownloadUrl = '',
        [string]$ModuleName  = '',
        [string]$Repository  = '',
        [string]$GitHubUser  = 'Icinga',
        [bool]$Release       = $FALSE,
        [bool]$Snapshot      = $FALSE,
        [bool]$DryRun        = $FALSE
    );

    Set-IcingaTLSVersion;
    $ProgressPreference = "SilentlyContinue";
    $Tag                = 'master';
    [bool]$SkipRepo     = $FALSE;

    if ($Release -Or $Snapshot) {
        $SkipRepo = $TRUE;
    }

    # Fix TLS errors while connecting to GitHub with old PowerShell versions
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";

    if ([string]::IsNullOrEmpty($DownloadUrl)) {
        if ($SkipRepo -Or (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you provide a custom repository for "{0}"?', $ModuleName)) -Default 'n').result -eq 1) {
            if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
                $branch = (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Which version of the "{0}" do you want to install? (release/snapshot)', $ModuleName)) -Default 'v' -DefaultInput 'release').answer;
            } elseif ($Release) {
                $branch = 'release';
            } else {
                $branch = 'snapshot'
            }
            if ($branch.ToLower() -eq 'snapshot') {
                $DownloadUrl   = [string]::Format('https://github.com/{0}/{1}/archive/master.zip', $GitHubUser, $Repository);
            } else {
                $WebResponse = Invoke-IcingaWebRequest -Uri 'https://github.com/{0}/{1}/releases/latest' -Objects $GitHubUser, $Repository -UseBasicParsing;

                if ($null -eq $WebResponse.HasErrors -Or $WebResponse.HasErrors -eq $FALSE) {
                    $LatestRelease = $WebResponse.BaseResponse.ResponseUri.AbsoluteUri;
                    $DownloadUrl   = $LatestRelease.Replace('/releases/tag/', '/archive/');
                    $Tag           = $DownloadUrl.Split('/')[-1];
                } else {
                    Write-IcingaConsoleError -Message 'Failed to fetch latest release for "{0}" from GitHub. Either the module or the GitHub account do not exist' -Objects $ModuleName;
                }

                $DownloadUrl   = [string]::Format('{0}/{1}.zip', $DownloadUrl, $Tag);

                $CurrentVersion = Get-IcingaPowerShellModuleVersion $Repository;

                if ($null -ne $CurrentVersion -And $CurrentVersion -eq $Tag) {
                    Write-IcingaConsoleNotice -Message 'Your "{0}" is already up-to-date' -Objects $ModuleName;
                    return @{
                        'DownloadUrl' = $DownloadUrl;
                        'Version'     = $Tag;
                        'Directory'   = '';
                        'Archive'     = '';
                        'ModuleRoot'  = (Get-IcingaForWindowsRootPath);
                        'Installed'   = $FALSE;
                    };
                }
            }
        } else {
            $DownloadUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Please enter the full path of the custom repository for the "{0}" (location of zip file)', $ModuleName)) -Default 'v').answer;
        }
    }

    if ($DryRun) {
        return @{
            'DownloadUrl' = $DownloadUrl;
            'Version'     = $Tag;
            'Directory'   = '';
            'Archive'     = '';
            'ModuleRoot'  = (Get-IcingaForWindowsRootPath);
            'Installed'   = $FALSE;
        };
    }

    $DownloadDirectory   = New-IcingaTemporaryDirectory;
    $DownloadDestination = (Join-Path -Path $DownloadDirectory -ChildPath ([string]::Format('{0}.zip', $Repository)));
    Write-IcingaConsoleNotice ([string]::Format('Downloading "{0}" into "{1}"', $ModuleName, $DownloadDirectory));

    if ((Invoke-IcingaWebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $DownloadDestination).HasErrors) {
        Write-IcingaConsoleError ([string]::Format('Failed to download "{0}" into "{1}". Starting cleanup process', $ModuleName, $DownloadDirectory));
        Start-Sleep -Seconds 2;
        Remove-Item -Path $DownloadDirectory -Recurse -Force;

        Write-IcingaConsoleNotice 'Starting to re-run the download wizard';

        return Get-IcingaPowerShellModuleArchive -ModuleName $ModuleName -Repository $Repository;
    }

    return @{
        'DownloadUrl' = $DownloadUrl;
        'Version'     = $Tag;
        'Directory'   = $DownloadDirectory;
        'Archive'     = $DownloadDestination;
        'ModuleRoot'  = (Get-IcingaForWindowsRootPath);
        'Installed'   = $TRUE;
    };
}

<#
.SYNOPSIS
   Get the version of an installed PowerShell Module
.DESCRIPTION
   Get the version of an installed PowerShell Module
.FUNCTIONALITY
   Get the version of an installed PowerShell Module
.EXAMPLE
   PS>Get-IcingaPowerShellModuleVersion -ModuleName 'icinga-powershell-framework';
.EXAMPLE
   PS>Get-IcingaPowerShellModuleVersion -ModuleName 'icinga-powershell-plugins';
.PARAMETER ModuleName
   The PowerShell module to fetch the installed version from
.INPUTS
   System.String
.OUTPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaPowerShellModuleVersion()
{
    param(
        $ModuleName
    );

    $ModuleDetails = Get-Module -ListAvailable $ModuleName;

    if ($null -eq $ModuleDetails) {
        return $null;
    }

    return $ModuleDetails.PrivateData.Version;
}

<#
.SYNOPSIS
   Fetches a Stopwatch system object by a given name if initialised with Start-IcingaTimer
.DESCRIPTION
   Fetches a Stopwatch system object by a given name if initialised with Start-IcingaTimer
.FUNCTIONALITY
   Fetches a Stopwatch system object by a given name if initialised with Start-IcingaTimer
.EXAMPLE
   PS>Get-IcingaTimer;
.EXAMPLE
   PS>Get-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.OUTPUTS
   System.Diagnostics.Stopwatch
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    $TimerData = Get-IcingaHashtableItem -Key $Name -Hashtable $global:IcingaDaemonData.IcingaTimers;

    if ($null -eq $TimerData) {
        return $null;
    }

    return $TimerData.Timer;
}

<#
.SYNOPSIS
    Installs the Icinga PowerShell Services as a Windows service
.DESCRIPTION
    Uses the Icinga Service binary which is already installed on the system to register
    it as a Windows service and sets the proper user for it
.FUNCTIONALITY
    Installs the Icinga PowerShell Services as a Windows service
.EXAMPLE
    PS>Install-IcingaForWindowsService -Path C:\Program Files\icinga-service\icinga-service.exe;
.EXAMPLE
    PS>Install-IcingaForWindowsService -Path C:\Program Files\icinga-service\icinga-service.exe -User 'NT Authority\NetworkService';
.PARAMETER Path
    The location on where the service binary executable is found
.PARAMETER User
    The service user the service is running with
.PARAMETER Password
    If the specified service user is requiring a password for registering you can provide it here as secure string
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Install-IcingaForWindowsService()
{
    param(
        $Path,
        $User,
        [SecureString]$Password
    );

    if ([string]::IsNullOrEmpty($Path)) {
        Write-IcingaConsoleWarning 'No path specified for Framework service. Service will not be installed';
        return;
    }

    $UpdateFile = [string]::Format('{0}.update', $Path);

    $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;

    if ((Test-Path $UpdateFile)) {

        Write-IcingaConsoleNotice 'Updating Icinga PowerShell Service binary';

        if ($ServiceStatus -eq 'Running') {
            Write-IcingaConsoleNotice 'Stopping Icinga PowerShell service';
            Stop-IcingaService 'icingapowershell';
            Start-Sleep -Seconds 1;
        }

        Remove-ItemSecure -Path $Path -Force | Out-Null;
        Copy-ItemSecure -Path $UpdateFile -Destination $Path -Force | Out-Null;
        Remove-ItemSecure -Path $UpdateFile -Force | Out-Null;
    }

    if ((Test-Path $Path) -eq $FALSE) {
        throw 'Please specify the path directly to the service binary';
    }

    $Path = [string]::Format(
        '\"{0}\" \"{1}\"',
        $Path,
        (Get-IcingaPowerShellModuleFile)
    );

    if ($null -eq $ServiceStatus) {
        $ServiceCreation = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('create icingapowershell binPath= "{0}" DisplayName= "Icinga PowerShell Service" start= auto', $Path));

        if ($ServiceCreation.ExitCode -ne 0) {
            throw ([string]::Format('Failed to install Icinga PowerShell Service: {0}{1}', $ServiceCreation.Message, $ServiceCreation.Error));
        }
    } else {
        Write-IcingaConsoleWarning 'The Icinga PowerShell Service is already installed';
    }

    # This is just a hotfix to ensure we setup the service properly before assigning it to
    # a proper user, like 'NT Authority\NetworkService'. For some reason the NetworkService
    # will not start without this workaround.
    # Todo: Figure out the reason and fix it properly
    Set-IcingaAgentServiceUser -User 'LocalSystem' -Service 'icingapowershell' | Out-Null;
    Restart-IcingaService 'icingapowershell';
    Start-Sleep -Seconds 1;
    Stop-IcingaService 'icingapowershell';

    if ($ServiceStatus -eq 'Running') {
        Write-IcingaConsoleNotice 'Starting Icinga PowerShell service';
        Start-IcingaService 'icingapowershell';
        Start-Sleep -Seconds 1;
    }

    return (Set-IcingaAgentServiceUser -User $User -Password $Password -Service 'icingapowershell');
}

Set-Alias -Name 'Install-IcingaFrameworkService' -Value 'Install-IcingaForWindowsService';

<#
.SYNOPSIS
   Installs a PowerShell Module within the 'icinga-powershell-' namespace
   from GitHub or custom locations and installs it into the module directory
   the Framework itself is installed to
.DESCRIPTION
   Installs a PowerShell Module within the 'icinga-powershell-' namespace
   from GitHub or custom locations and installs it into the module directory
   the Framework itself is installed to
.FUNCTIONALITY
   Download and install a PowerShell module from the 'icinga-powershell-' namespace
.EXAMPLE
   PS>Install-IcingaFrameworkComponent -Name 'plugins' -Release;
.EXAMPLE
   PS>Install-IcingaFrameworkComponent -Name 'plugins' -Release -DryRun;
.PARAMETER Name
   The name of the module to install. The namespace 'icinga-powershell-' is added
   by the function automatically
.PARAMETER GitHubUser
   Overwrite the default GitHub user for a different one to download modules from
.PARAMETER Url
   Specify a direct Url to a ZIP-Archive for external or local web ressources or
   local network shares
.PARAMETER Release
   Download the latest Release version from a GitHub source
.PARAMETER Snapshot
   Download the latest master branch from a GitHub source
.PARAMETER DryRun
   Only fetch possible Urls and return the result. No download or installation
   will be done
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Install-IcingaFrameworkComponent()
{
    param(
        [string]$Name,
        [string]$GitHubUser = 'Icinga',
        [string]$Url,
        [switch]$Release    = $FALSE,
        [switch]$Snapshot   = $FALSE,
        [switch]$DryRun     = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        throw 'Please specify a component name to install from a GitHub/Local space';
    }

    Set-IcingaTLSVersion;

    $TextInfo       = (Get-Culture).TextInfo;
    $ComponentName  = $TextInfo.ToTitleCase($Name);
    $RepositoryName = [string]::Format('icinga-powershell-{0}', $Name);
    $Archive        = Get-IcingaPowerShellModuleArchive `
        -DownloadUrl $Url `
        -GitHubUser $GitHubUser `
        -ModuleName (
            [string]::Format(
                'Icinga {0}', $ComponentName
            )
        ) `
        -Repository $RepositoryName `
        -Release $Release `
        -Snapshot $Snapshot `
        -DryRun $DryRun;

    if ($Archive.Installed -eq $FALSE -Or $DryRun) {
        return @{
            'RepoUrl' = $Archive.DownloadUrl
        };
    }

    Write-IcingaConsoleNotice ([string]::Format('Installing module into "{0}"', ($Archive.Directory)));
    Expand-IcingaZipArchive -Path $Archive.Archive -Destination $Archive.Directory | Out-Null;

    $FolderContent = Get-ChildItem -Path $Archive.Directory;
    $ModuleContent = $Archive.Directory;

    foreach ($entry in $FolderContent) {
        if ($entry -like ([string]::Format('{0}*', $RepositoryName))) {
            $ModuleContent = Join-Path -Path $ModuleContent -ChildPath $entry;
            break;
        }
    }

    Write-IcingaConsoleNotice ([string]::Format('Using content of folder "{0}" for updates', $ModuleContent));

    $PluginDirectory = (Join-Path -Path $Archive.ModuleRoot -ChildPath $RepositoryName);

    if ((Test-Path $PluginDirectory) -eq $FALSE) {
        Write-IcingaConsoleNotice ([string]::Format('{0} Module Directory "{1}" is not present. Creating Directory', $ComponentName, $PluginDirectory));
        New-Item -Path $PluginDirectory -ItemType Directory | Out-Null;
    }

    Write-IcingaConsoleNotice ([string]::Format('Copying files to {0}', $ComponentName));
    Copy-ItemSecure -Path (Join-Path -Path $ModuleContent -ChildPath '/*') -Destination $PluginDirectory -Recurse -Force | Out-Null;

    Write-IcingaConsoleNotice 'Cleaning temporary content';
    Start-Sleep -Seconds 1;
    Remove-ItemSecure -Path $Archive.Directory -Recurse -Force | Out-Null;

    Unblock-IcingaPowerShellFiles -Path $PluginDirectory;

    # In case the plugins are not installed before, load the framework again to
    # include the plugins
    Use-Icinga;

    # Unload the module if it was loaded before
    Remove-Module $PluginDirectory -Force -ErrorAction SilentlyContinue;
    # Now import the module
    Import-Module $PluginDirectory;

    Write-IcingaConsoleNotice ([string]::Format('Icinga {0} update has been completed. Please start a new PowerShell to apply it', $ComponentName));

    return @{
        'RepoUrl' = $Archive.DownloadUrl
    };
}

<#
.SYNOPSIS
   Installs the Icinga Plugins PowerShell module from a remote or local source
.DESCRIPTION
   Installs the Icinga PowerShell Plugins from a remote or local source into the
   PowerShell module folder and makes them available for usage with Icinga 2 or
   other components.
.FUNCTIONALITY
   Installs the Icinga Plugins PowerShell module from a remote or local source
.EXAMPLE
   PS>Install-IcingaFrameworkPlugins;
.EXAMPLE
   PS>Install-IcingaFrameworkPlugins -PluginsUrl 'C:/icinga/icinga-plugins.zip';
.EXAMPLE
   PS>Install-IcingaFrameworkPlugins -PluginsUrl 'https://github.com/Icinga/icinga-powershell-plugins/archive/v1.0.0.zip';
.PARAMETER PluginsUrl
   The URL pointing either to a local or remote ressource to download the plugins from. This requires to be the
   full path to the .zip file to download.
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Install-IcingaFrameworkPlugins()
{
    param(
        [string]$PluginsUrl
    );

    [Hashtable]$Result = Install-IcingaFrameworkComponent `
        -Name 'plugins' `
        -GitHubUser 'Icinga' `
        -Url $PluginsUrl;

    return @{
        'PluginUrl' = $Result.RepoUrl;
    };
}

<#
.SYNOPSIS
    Update the current version of the PowerShell Framework with a newer or older one
.DESCRIPTION
    Allows you to specify a download url or being asked by a wizard on where a update for
    the PowerShell framework can be fetched from and applies the up- or downgrade
.FUNCTIONALITY
    Update the current version of the PowerShell Framework with a newer or older one
.EXAMPLE
    PS>Install-IcingaFrameworkUpdate;
.EXAMPLE
    PS>Install-IcingaFrameworkUpdate -FrameworkUrl 'C:/icinga/framework.zip';
.EXAMPLE
    PS>Install-IcingaFrameworkUpdate -FrameworkUrl 'https://github.com/Icinga/icinga-powershell-framework/archive/v1.0.2.zip';
.PARAMETER FrameworkUrl
    The url to a remote or local ressource pointing directly to a .zip file containing the required files for updating
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Install-IcingaFrameworkUpdate()
{
    param(
        [string]$FrameworkUrl
    );

    $RepositoryName = 'icinga-powershell-framework';
    $Archive        = Get-IcingaPowerShellModuleArchive -DownloadUrl $FrameworkUrl -ModuleName 'Icinga Framework' -Repository $RepositoryName;

    if ($Archive.Installed -eq $FALSE) {
        return @{
            'PluginUrl' = $Archive.DownloadUrl
        };
    }

    Write-IcingaConsoleNotice ([string]::Format('Installing module into "{0}"', ($Archive.Directory)));
    Expand-IcingaZipArchive -Path $Archive.Archive -Destination $Archive.Directory | Out-Null;

    $FolderContent = Get-ChildItem -Path $Archive.Directory;
    $ModuleContent = $Archive.Directory;

    foreach ($entry in $FolderContent) {
        if ($entry -like ([string]::Format('{0}*', $RepositoryName))) {
            $ModuleContent = Join-Path -Path $ModuleContent -ChildPath $entry;
            break;
        }
    }

    Write-IcingaConsoleNotice ([string]::Format('Using content of folder "{0}" for updates', $ModuleContent));

    $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;
    $AgentStatus   = (Get-Service 'icinga2' -ErrorAction SilentlyContinue).Status;

    if ($ServiceStatus -eq 'Running') {
        Write-IcingaConsoleNotice 'Stopping Icinga PowerShell service';
        Stop-IcingaService 'icingapowershell';
        Start-Sleep -Seconds 1;
    }
    if ($AgentStatus -eq 'Running') {
        Write-IcingaConsoleNotice 'Stopping Icinga Agent service';
        Stop-IcingaService 'icinga2';
        Start-Sleep -Seconds 1;
    }

    $ModuleDirectory = (Join-Path -Path $Archive.ModuleRoot -ChildPath $RepositoryName);

    if ((Test-Path $ModuleDirectory) -eq $FALSE) {
        Write-IcingaConsoleError 'Failed to update the component. Module Root-Directory was not found';
        return;
    }

    $Files = Get-ChildItem $ModuleDirectory -File '*';

    Write-IcingaConsoleNotice 'Removing files from framework';

    foreach ($ModuleFile in $Files) {
        Remove-ItemSecure -Path $ModuleFile -Force | Out-Null;
    }

    Remove-ItemSecure -Path (Join-Path $ModuleDirectory -ChildPath 'doc') -Recurse -Force | Out-Null;
    Remove-ItemSecure -Path (Join-Path $ModuleDirectory -ChildPath 'lib') -Recurse -Force | Out-Null;
    Remove-ItemSecure -Path (Join-Path $ModuleDirectory -ChildPath 'manifests') -Recurse -Force | Out-Null;

    Write-IcingaConsoleNotice 'Copying new files to framework';
    Copy-ItemSecure -Path (Join-Path $ModuleContent -ChildPath 'doc') -Destination $ModuleDirectory -Recurse -Force | Out-Null;
    Copy-ItemSecure -Path (Join-Path $ModuleContent -ChildPath 'lib') -Destination $ModuleDirectory -Recurse -Force | Out-Null;
    Copy-ItemSecure -Path (Join-Path $ModuleContent -ChildPath 'manifests') -Destination $ModuleDirectory -Recurse -Force | Out-Null;
    Copy-ItemSecure -Path (Join-Path -Path $ModuleContent -ChildPath '/*') -Destination $ModuleDirectory -Recurse -Force | Out-Null;

    Unblock-IcingaPowerShellFiles -Path $ModuleDirectory;

    Write-IcingaConsoleNotice 'Cleaning temporary content';
    Start-Sleep -Seconds 1;
    Remove-ItemSecure -Path $Archive.Directory -Recurse -Force | Out-Null;

    Write-IcingaConsoleNotice 'Updating Framework cache file';
    if (Test-IcingaFunction 'Write-IcingaFrameworkCodeCache') {
        Write-IcingaFrameworkCodeCache;
    }

    Write-IcingaConsoleNotice 'Framework update has been completed. Please start a new PowerShell instance now to complete the update';

    Test-IcingaAgent;

    if ($ServiceStatus -eq 'Running') {
        Write-IcingaConsoleNotice 'Starting Icinga PowerShell service';
        Start-IcingaService 'icingapowershell';
    }
    if ($AgentStatus -eq 'Running') {
        Write-IcingaConsoleNotice 'Starting Icinga Agent service';
        Start-IcingaService 'icinga2';
    }
}

function Invoke-IcingaInternalServiceCall()
{
    param (
        [string]$Command  = '',
        [array]$Arguments = @()
    );

    # If our Framework is running as daemon, never call our api
    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon) {
        return;
    }

    # If the API forward feature is disabled, do nothing
    if ((Get-IcingaFrameworkApiChecks) -eq $FALSE) {
        return;
    }

    # Test our Icinga for Windows service. If the service is not installed or not running, execute the plugin locally
    $IcingaForWindowsService = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue);

    if ($null -eq $IcingaForWindowsService -Or $IcingaForWindowsService.Status -ne 'Running') {
        return;
    }

    # In case the REST-Api module ist not configured, do nothing
    $BackgroundDaemons = Get-IcingaBackgroundDaemons;

    if ($null -eq $BackgroundDaemons -Or $BackgroundDaemons.ContainsKey('Start-IcingaWindowsRESTApi') -eq $FALSE) {
        return;
    }

    # If neither 'icinga-powershell-restapi' or 'icinga-powershell-apichecks' is installed, execute the plugin locally
    if ((Test-IcingaFunction 'Invoke-IcingaApiChecksRESTCall') -eq $FALSE -Or (Test-IcingaFunction 'Start-IcingaWindowsRESTApi') -eq $FALSE) {
        return;
    }

    $RestApiPort  = 5668;
    [int]$Timeout = 30;
    $Daemon       = $BackgroundDaemons['Start-IcingaWindowsRESTApi'];

    # Fetch our deamon configuration
    if ($Daemon.ContainsKey('-Port')) {
        $RestApiPort = $Daemon['-Port'];
    } elseif ($Daemon.ContainsKey('Port')) {
        $RestApiPort = $Daemon['Port'];
    }
    if ($Daemon.ContainsKey('-Timeout')) {
        $Timeout = $Daemon['-Timeout'];
    } elseif ($Daemon.ContainsKey('Timeout')) {
        $Timeout = $Daemon['Timeout'];
    }

    Set-IcingaTLSVersion;
    Enable-IcingaUntrustedCertificateValidation -SuppressMessages;

    [hashtable]$CommandArguments = @{ };
    [int]$ArgumentIndex          = 0;

    # Resolve our array arguments provided by $args and build proper check arguments
    while ($ArgumentIndex -lt $Arguments.Count) {
        $Value                 = $Arguments[$ArgumentIndex];
        [string]$Argument      = [string]$Value;
        $ArgumentValue         = $null;

        if ($Value[0] -eq '-') {
            if (($ArgumentIndex + 1) -lt $Arguments.Count) {
                [string]$NextValue = $Arguments[$ArgumentIndex + 1];
                if ($NextValue[0] -eq '-') {
                    $ArgumentValue = $TRUE;
                } else {
                    $ArgumentValue = $Arguments[$ArgumentIndex + 1];
                }
            } else {
                $ArgumentValue = $TRUE;
            }
        } else {
            $ArgumentIndex += 1;
            continue;
        }

        $Argument = $Argument.Replace('-', '');

        $CommandArguments.Add($Argument, $ArgumentValue);
        $ArgumentIndex += 1;
    }

    # Now queue the check inside our REST-Api
    try {
        $ApiResult = Invoke-WebRequest -Method POST -UseBasicParsing -Uri ([string]::Format('https://localhost:{0}/v1/checker?command={1}', $RestApiPort, $Command)) -Body (ConvertTo-JsonUTF8Bytes -InputObject $CommandArguments -Depth 100 -Compress) -ContentType 'application/json' -TimeoutSec $Timeout;
    } catch {
        # Something went wrong -> fallback to local execution
        $ExMsg = $_.Exception.message;
        # Fallback to execute plugin locally
        Write-IcingaEventMessage -Namespace 'Framework' -EventId 1553 -Objects $ExMsg, $Command, $CommandArguments;
        return;
    }

    # Resolve our result from the API
    $IcingaResult = ConvertFrom-JsonUTF8 -InputObject $ApiResult.Content;
    $IcingaCR     = '';

    # In case we didn't receive a check result, fallback to local execution
    if ([string]::IsNullOrEmpty($IcingaResult.$Command.checkresult)) {
        Write-IcingaEventMessage -Namespace 'Framework' -EventId 1553 -Objects 'The check result for the executed command was empty', $Command, $CommandArguments;
        return;
    }

    if ([string]::IsNullOrEmpty($IcingaResult.$Command.exitcode)) {
        Write-IcingaEventMessage -Namespace 'Framework' -EventId 1553 -Objects 'The check result for the executed command was empty', $Command, $CommandArguments;
        return;
    }

    $IcingaCR = ($IcingaResult.$Command.checkresult.Replace("`r`n", "`n"));

    if ($IcingaResult.$Command.perfdata.Count -ne 0) {
        $IcingaCR += ' | ';
        foreach ($perfdata in $IcingaResult.$Command.perfdata) {
            $IcingaCR += $perfdata;
        }
    }

    # Print our response and exit with the provide exit code
    Write-IcingaConsolePlain $IcingaCR;
    exit $IcingaResult.$Command.exitcode;
}

function Invoke-IcingaNamespaceCmdlets()
{
    param (
        [string]$Command
    );

    [Hashtable]$CommandConfig = @{};

    if ($Command.Contains('*') -eq $FALSE) {
        $Command = [string]::Format('{0}*', $Command);
    }

    $CommandList = Get-Command $Command;

    foreach ($Cmdlet in $CommandList) {
        try {
            $CommandName = $Cmdlet.Name;
            Import-Module $Cmdlet.Module.Path -WarningAction SilentlyContinue -ErrorAction Stop;

            $Content = (& $CommandName);
            Add-IcingaHashtableItem `
                -Hashtable $CommandConfig `
                -Key $Cmdlet.Name `
                -Value $Content | Out-Null;
        } catch {
            # TODO: Add event log logging on exceptions
        }
    }

    return $CommandConfig;
}

<#
.SYNOPSIS
   Create a new environment in which we can store check results, performance data
   and values over time or executed plugins.

   Usage:

   Access the string plugin output by calling `Get-IcingaCheckSchedulerPluginOutput`
   Access possible performance data with `Get-IcingaCheckSchedulerPerfData`

   If you execute check plugins, ensure you read both of these functions to fetch the
   result of the plugin call and to clear the stack and memory of the check data.

   If you do not require the output, you can write them to Null

   Get-IcingaCheckSchedulerPluginOutput | Out-Null;
   Get-IcingaCheckSchedulerPerfData | Out-Null;

   IMPORTANT:
   In addition each value for each object created with `New-IcingaCheck` is stored
   with a timestamp for the check command inside a hashtable. If you do not require
   these data, you MUST call `Clear-IcingaCheckSchedulerCheckData` to free memory
   and clear data from the stack!

   If you are finished with all data processing and do not require anything within
   memory anyway, you can safely call `Clear-IcingaCheckSchedulerEnvironment` to
   do the same thing in one call.
.DESCRIPTION
   Fetch the raw output values for a check command for each single object
   processed by New-IcingaCheck
.FUNCTIONALITY
   Fetch the raw output values for a check command for each single object
   processed by New-IcingaCheck
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaCheckSchedulerEnvironment()
{
    # Legacy code
    if ($IcingaDaemonData.IcingaThreadContent.ContainsKey('Scheduler') -eq $FALSE) {
        $IcingaDaemonData.IcingaThreadContent.Add('Scheduler', @{ });
    }

    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    if ($global:Icinga.ContainsKey('CheckResults') -eq $FALSE) {
        $global:Icinga.Add('CheckResults', @());
    }
    if ($global:Icinga.ContainsKey('PerfData') -eq $FALSE) {
        $global:Icinga.Add('PerfData', @());
    }
    if ($global:Icinga.ContainsKey('CheckData') -eq $FALSE) {
        $global:Icinga.Add('CheckData', @{ });
    }
}

<#
.SYNOPSIS
   Fetches plugins within the namespace `Invoke-IcingaCheck*` for a given
   component name or the direct path and creates Icinga Director as well as
   Icinga 2 configuration files.

   The configuration files are printed within a `config` folder of the
   specific module and splitted into `director` and `icinga`
.DESCRIPTION
   etches plugins within the namespace `Invoke-IcingaCheck*` for a given
   component name or the direct path and creates Icinga Director as well as
   Icinga 2 configuration files.

   The configuration files are printed within a `config` folder of the
   specific module and splitted into `director` and `icinga`
.FUNCTIONALITY
   Creates Icinga 2 and Icinga Director configuration files for plugins
.EXAMPLE
   PS>Publish-IcingaPluginConfiguration -ComponentName 'plugins';
.EXAMPLE
   PS>Publish-IcingaPluginConfiguration -ComponentPath 'C:\Program Files\WindowsPowerShell\modules\icinga-powershell-plugins';
.PARAMETER ComponentName
   The name of the component to lookup for plugins and write configuration for.
   The leading icinga-powershell- is not required and you should simply use the name,
   like 'plugins' or 'mssql'
.PARAMETER ComponentPath
   The path to the root directory of a PowerShell Plugin repository, like
   'C:\Program Files\WindowsPowerShell\modules\icinga-powershell-plugins'
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Publish-IcingaPluginConfiguration()
{
    param (
        [string]$ComponentName,
        [string]$ComponentPath
    );

    if ([string]::IsNullOrEmpty($ComponentName) -And [string]::IsNullOrEmpty($ComponentPath)) {
        Write-IcingaConsoleError 'Please specify either a component name like "plugins" or set the component path to the root folder if a component, like "C:\Program Files\WindowsPowerShell\modules\icinga-powershell\plugins".';
        return;
    }

    if ([string]::IsNullOrEmpty($ComponentPath)) {
        $ComponentPath = Join-Path -Path (Get-IcingaForWindowsRootPath) -ChildPath ([string]::Format('icinga-powershell-{0}', $ComponentName));
    }

    if ((Test-Path $ComponentPath) -eq $FALSE) {
        Write-IcingaConsoleError 'The path "{0}" for the Icinga for Windows component is not valid' -Objects $ComponentPath;
        return;
    }

    try {
        Import-Module $ComponentPath -Global -Force -ErrorAction Stop;
    } catch {
        [string]$Message = $_.Exception.Message;
        Write-IcingaConsoleError 'Failed to import the module on path "{0}". Please verify that this is a valid PowerShell module root folder. Exception: {1}{2}' -Objects $ComponentPath, (New-IcingaNewLine), $Message;
        return;
    }

    $CheckCommands = Get-Command -ListImported -Name 'Invoke-IcingaCheck*' -ErrorAction SilentlyContinue;

    if ($null -eq $CheckCommands) {
        Write-IcingaConsoleError 'No Icinga CheckCommands were configured for module "{0}". Please verify that this is a valid PowerShell module root folder. Exception: {1}{2}' -Objects $ComponentPath, (New-IcingaNewLine), $Message;
        return;
    }

    [array]$CheckList = @();

    [string]$BasketConfigDir = Join-Path -Path $ComponentPath -ChildPath 'config\director';
    [string]$IcingaConfigDir = Join-Path -Path $ComponentPath -ChildPath 'config\icinga';

    if ((Test-Path $BasketConfigDir)) {
        Remove-Item -Path $BasketConfigDir -Recurse -Force | Out-Null;
    }
    if ((Test-Path $IcingaConfigDir)) {
        Remove-Item -Path $IcingaConfigDir -Recurse -Force | Out-Null;
    }

    if ((Test-Path $BasketConfigDir) -eq $FALSE) {
        New-Item -Path $BasketConfigDir -ItemType Directory | Out-Null;
    }
    if ((Test-Path $IcingaConfigDir) -eq $FALSE) {
        New-Item -Path $IcingaConfigDir -ItemType Directory | Out-Null;
    }

    foreach ($check in $CheckCommands) {
        [string]$CheckPath = $check.Module.ModuleBase;

        if ($CheckPath.Contains($ComponentPath) -eq $FALSE) {
            continue;
        }

        $CheckList += [string]$check;
        Get-IcingaCheckCommandConfig -CheckName $check -OutDirectory $BasketConfigDir -FileName $check;
        Get-IcingaCheckCommandConfig -CheckName $check -OutDirectory $IcingaConfigDir -FileName $check -IcingaConfig;
    }

    Get-IcingaCheckCommandConfig -CheckName $CheckList -OutDirectory $BasketConfigDir -FileName ([string]::Format('{0}_Bundle', (Get-Culture).TextInfo.ToTitleCase($ComponentName)));
    Get-IcingaCheckCommandConfig -CheckName $CheckList -OutDirectory $IcingaConfigDir -FileName ([string]::Format('{0}_Bundle', (Get-Culture).TextInfo.ToTitleCase($ComponentName))) -IcingaConfig;
}

<#
.SYNOPSIS
    Wrapper for Remove-Item to secuerly remove items allowing better handling for errors
.DESCRIPTION
    Removes files and folders from disk and catches possible exceptions with proper return
    values to handle errors better
.FUNCTIONALITY
    Wrapper for Remove-Item to secuerly remove items allowing better handling for errors
.EXAMPLE
    PS>Remove-ItemSecure -Path C:\icinga;
.EXAMPLE
    PS>Remove-ItemSecure -Path C:\icinga -Recurse;
.EXAMPLE
    PS>Remove-ItemSecure -Path C:\icinga -Recurse -Force;
.PARAMETER Path
    The path to a file or folder you wish you delete
.PARAMETER Recurse
    Removes sub-folders and sub-files for a given location
.PARAMETER Force
    Tries to forefully removes a files and folders if they are either being used or a folder is
    still containing items
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Remove-ItemSecure()
{
    param(
        [string]$Path,
        [switch]$Recurse,
        [switch]$Force
    )

    if ((Test-Path $Path) -eq $FALSE) {
        return $FALSE;
    }

    try {
        if ($Recurse -And $Force) {
            Remove-Item -Path $Path -Recurse -Force;
        } elseif ($Recurse -And -Not $Force) {
            Remove-Item -Path $Path -Recurse;
        } elseif (-Not $Recurse -And $Force) {
            Remove-Item -Path $Path -Force;
        } else {
            Remove-Item -Path $Path;
        }
        return $TRUE;
    } catch {
        Write-IcingaConsoleError ([string]::Format('Failed to remove items from path "{0}": {1}', $Path, $_.Exception));
    }
    return $FALSE;
}

<#
.SYNOPSIS
    Wrapper for Restart-Service which catches errors and prints proper output messages
.DESCRIPTION
    Restarts a service if it is installed and prints console messages if a restart
    was triggered or the service is not installed
.FUNCTIONALITY
    Wrapper for restart service which catches errors and prints proper output messages
.EXAMPLE
    PS>Restart-IcingaService -Service 'icinga2';
.PARAMETER Service
    The name of the service to be restarted
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Restart-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service "$Service" -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice ([string]::Format('Restarting service "{0}"', $Service));
        powershell.exe -Command {
            $Service = $args[0]

            Restart-Service "$Service";
        } -Args $Service;
    } else {
        Write-IcingaConsoleWarning -Message 'The service "{0}" is not installed' -Objects $Service;
    }
}

<#
.SYNOPSIS
   Returns the spent time since Start-IcingaTimer was executed in seconds for
   a specific timer name
.DESCRIPTION
   Returns the spent time since Start-IcingaTimer was executed in seconds for
   a specific timer name
.FUNCTIONALITY
   Returns the spent time since Start-IcingaTimer was executed in seconds for
   a specific timer name
.EXAMPLE
   PS>Show-IcingaTimer;
.EXAMPLE
   PS>Show-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.OUTPUTS
   Single
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Show-IcingaTimer()
{
    param (
        [string]$Name    = 'DefaultTimer',
        [switch]$ShowAll = $FALSE
    );

    $TimerObject = Get-IcingaTimer -Name $Name;

    if (-Not $ShowAll) {
         if ($null -eq $TimerObject) {
             Write-IcingaConsoleNotice 'A timer with the name "{0}" does not exist' -Objects $Name;
            return;
        }

        $TimerOutput = New-Object -TypeName PSObject;
        $TimerOutput | Add-Member -MemberType NoteProperty -Name 'Timer Name' -Value $Name;
        $TimerOutput | Add-Member -MemberType NoteProperty -Name 'Elapsed Seconds' -Value $TimerObject.Elapsed.TotalSeconds;

        $TimerOutput | Format-Table -AutoSize;
    } else {
        $TimerObjects = Get-IcingaHashtableItem -Key 'IcingaTimers' -Hashtable $global:IcingaDaemonData;

        [array]$MultiOutput = @();

        foreach ($TimerName in $TimerObjects.Keys) {
           $TimerObject = $TimerObjects[$TimerName].Timer;

           $TimerOutput = New-Object -TypeName PSObject;
           $TimerOutput | Add-Member -MemberType NoteProperty -Name 'Timer Name' -Value $TimerName;
           $TimerOutput | Add-Member -MemberType NoteProperty -Name 'Elapsed Seconds' -Value $TimerObject.Elapsed.TotalSeconds;
           $MultiOutput += $TimerOutput;
        }

        $MultiOutput | Format-Table -AutoSize;
    }
}

<#
.SYNOPSIS
    Wrapper for Start-Service which catches errors and prints proper output messages
.DESCRIPTION
    Starts a service if it is installed and prints console messages if a start
    was triggered or the service is not installed
.FUNCTIONALITY
    Wrapper for Start-Service which catches errors and prints proper output messages
.EXAMPLE
    PS>Start-IcingaService -Service 'icinga2';
.PARAMETER Service
    The name of the service to be started
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Start-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service $Service -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice -Message 'Starting service "{0}"' -Objects $Service;
        powershell.exe -Command {
            $Service = $args[0]

            Start-Service "$Service";
        } -Args $Service;
    } else {
        Write-IcingaConsoleWarning -Message 'The service "{0}" is not installed' -Objects $Service;
    }
}

<#
.SYNOPSIS
   Start a new timer for a given name and stores it within the $globals section
   of the Icinga PowerShell Framework
.DESCRIPTION
   Start a new timer for a given name and stores it within the $globals section
   of the Icinga PowerShell Framework
.FUNCTIONALITY
   Start a new timer for a given name and stores it within the $globals section
   of the Icinga PowerShell Framework
.EXAMPLE
   PS>Start-IcingaTimer;
.EXAMPLE
   PS>Start-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Start-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    if ((Test-IcingaTimer -Name $Name)) {
        Write-IcingaConsoleNotice 'The timer with the name "{0}" is already active' -Objects $Name;
        return;
    }

    # Load the library first
    [System.Reflection.Assembly]::LoadWithPartialName("System.Diagnostics") | Out-Null;
    $TimerObject = New-Object System.Diagnostics.Stopwatch;
    $TimerObject.Start();

    Add-IcingaHashtableItem -Key $Name -Value (
        [hashtable]::Synchronized(
            @{
                'Active' = $TRUE;
                'Timer'  = $TimerObject;
            }
        )
    ) -Hashtable $global:IcingaDaemonData.IcingaTimers -Override | Out-Null;
}

<#
.SYNOPSIS
    Wrapper for Stop-Service which catches errors and prints proper output messages
.DESCRIPTION
    Stops a service if it is installed and prints console messages if a stop
    was triggered or the service is not installed
.FUNCTIONALITY
    Wrapper for Stop-Service which catches errors and prints proper output messages
.EXAMPLE
    PS>Stop-IcingaService -Service 'icinga2';
.PARAMETER Service
    The name of the service to be stopped
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Stop-IcingaService()
{
    param(
        $Service
    );

    if (Get-Service $Service -ErrorAction SilentlyContinue) {
        Write-IcingaConsoleNotice -Message 'Stopping service "{0}"' -Objects $Service;
        powershell.exe -Command {
            $Service = $args[0]

            Stop-Service "$Service";
        } -Args $Service;
    } else {
        Write-IcingaConsoleWarning -Message 'The service "{0}" is not installed' -Objects $Service;
    }
}

<#
.SYNOPSIS
   Stops a timer object started with Start-IcingaTimer for a specific
   named timer
.DESCRIPTION
   Stops a timer object started with Start-IcingaTimer for a specific
   named timer
.FUNCTIONALITY
   Stops a timer object started with Start-IcingaTimer for a specific
   named timer
.EXAMPLE
   PS>Stop-IcingaTimer;
.EXAMPLE
   PS>Stop-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Stop-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    $TimerObject = Get-IcingaTimer -Name $Name;

    if ($null -eq $TimerObject) {
        return;
    }

    if ($TimerObject.IsRunning) {
        $TimerObject.Stop();
    }
    Add-IcingaHashtableItem -Key $Name -Value (
        [hashtable]::Synchronized(
            @{
                'Active' = $FALSE;
                'Timer'  = $TimerObject;
            }
        )
    ) -Hashtable $global:IcingaDaemonData.IcingaTimers -Override | Out-Null;
}

<#
.SYNOPSIS
   Allows to test if console output can be written or not for this PowerShell session
.DESCRIPTION
   Allows to test if console output can be written or not for this PowerShell session
.FUNCTIONALITY
   Allows to test if console output can be written or not for this PowerShell session
.EXAMPLE
   PS>Enable-IcingaFrameworkConsoleOutput;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaFrameworkConsoleOutput()
{
    if ($null -eq $global:Icinga) {
        return $TRUE;
    }

    if ($global:Icinga.ContainsKey('DisableConsoleOutput') -eq $FALSE) {
        return $TRUE;
    }

    return (-Not ($global:Icinga.DisableConsoleOutput));
}

<#
.SYNOPSIS
   Tests if a specific timer object is already present and started with Start-IcingaTimer
.DESCRIPTION
   Tests if a specific timer object is already present and started with Start-IcingaTimer
.FUNCTIONALITY
   Tests if a specific timer object is already present and started with Start-IcingaTimer
.EXAMPLE
   PS>Test-IcingaTimer;
.EXAMPLE
   PS>Test-IcingaTimer -Name 'My Test Timer';
.PARAMETER Name
   The name of a custom identifier to run mutliple timers at once
.INPUTS
   System.String
.OUTPUTS
   Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaTimer()
{
    param (
        [string]$Name = 'DefaultTimer'
    );

    $TimerData = Get-IcingaHashtableItem -Key $Name -Hashtable $global:IcingaDaemonData.IcingaTimers;

    if ($null -eq $TimerData) {
        return $FALSE;
    }

    return $TimerData.Active;
}

<#
.SYNOPSIS
    Compares a binary within a .zip file to a included .md5 to ensure
    the checksum is matching
.DESCRIPTION
    Compares a possible included .md5 checksum file with the provided binary
    to ensure they are identical
.FUNCTIONALITY
    Compares a binary within a .zip file to a included .md5 to ensure
    the checksum is matching.
.EXAMPLE
    PS>Test-IcingaZipBinaryChecksum -Path 'C:\Program Files\icinga-service\icinga-service.exe';
.PARAMETER Path
    Path to the binary to be checked for. A Corresponding .md5 file with the
    extension added on the file is required, like icinga-service.exe.md5
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaZipBinaryChecksum()
{
    param(
        $Path
    );

    $MD5Path = [string]::Format('{0}.md5', $Path);

    if ((Test-Path $MD5Path) -eq $FALSE) {
        return $TRUE;
    }

    [string]$MD5Checksum = Get-Content $MD5Path;
    $MD5Checksum         = ($MD5Checksum.Split(' ')[0]).ToLower();

    $FileHash = ((Get-FileHash $Path -Algorithm MD5).Hash).ToLower();

    if ($MD5Checksum -ne $FileHash) {
        return $FALSE;
    }

    return $TRUE;
}

<#
.SYNOPSIS
    Unblocks a folder with PowerShell module/script files to make them usable
    on certain environments
.DESCRIPTION
    Wrapper command to unblock recursively a certain folder for PowerShell script
    and module files
.FUNCTIONALITY
    Unblocks a folder with PowerShell module/script files to make them usable
    on certain environments
.EXAMPLE
    PS>Unblock-IcingaPowerShellFiles -Path 'C:\Program Files\WindowsPowerShell\Modules\my-module';
.PARAMETER Path
    The path to a PowerShell module folder or script file to unblock it
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Unblock-IcingaPowerShellFiles()
{
    param(
        $Path
    );

    if ([string]::IsNullOrEmpty($Path)) {
        Write-IcingaConsoleError 'The specified directory was not found';
        return;
    }

    Write-IcingaConsoleNotice 'Unblocking Icinga PowerShell Files';
    Get-ChildItem -Path $Path -Recurse | Unblock-File;
}

<#
.SYNOPSIS
    Uninstalls every PowerShell module within the icinga-powershell-* namespace
    including the Icinga Agent with all components (like certificates) as well as
    the Icinga for Windows service and the Icinga PowerShell Framework.
.DESCRIPTION
    Uninstalls every PowerShell module within the icinga-powershell-* namespace
    including the Icinga Agent with all components (like certificates) as well as
    the Icinga for Windows service and the Icinga PowerShell Framework.
.FUNCTIONALITY
    Uninstalls every PowerShell module within the icinga-powershell-* namespace
    including the Icinga Agent with all components (like certificates) as well as
    the Icinga for Windows service and the Icinga PowerShell Framework.
.PARAMETER Force
    Suppress the question if you are sure to uninstall everything
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Uninstall-IcingaForWindows()
{
    param (
        [switch]$Force = $FALSE
    );

    $ModuleList      = Get-Module 'icinga-powershell-*' -ListAvailable;
    [string]$Modules = [string]::Join(', ', $ModuleList.Name);

    if ($Force -eq $FALSE) {
        Write-IcingaConsoleWarning -Message 'You are about to uninstall the Icinga Agent with all components (including certificates) and all Icinga for Windows Components: {0}{1}Are you sure you want to proceed? (y/N)' -Objects $Modules, (New-IcingaNewLine);
        $Input = Read-Host 'Confirm uninstall';
        if ($input -ne 'y') {
            return;
        }
    }

    $CurrentLocation = Get-Location;

    if ($CurrentLocation -eq (Get-IcingaFrameworkRootPath)) {
        Set-Location -Path (Get-IcingaForWindowsRootPath);
    }

    Write-IcingaConsoleNotice 'Uninstalling Icinga for Windows from this host';
    Write-IcingaConsoleNotice 'Uninstalling Icinga Agent';
    Uninstall-IcingaAgent -RemoveDataFolder | Out-Null;
    Write-IcingaConsoleNotice 'Uninstalling Icinga for Windows service';
    Uninstall-IcingaForWindowsService | Out-Null;

    $HasErrors = $FALSE;

    foreach ($module in $ModuleList.Name) {
        [string]$ModuleName = $module.Replace('icinga-powershell-', '');

        if ((Uninstall-IcingaFrameworkComponent -Name $ModuleName)) {
            continue;
        }

        $HasErrors = $TRUE;
    }

    Remove-Module 'icinga-powershell-framework' -Force -ErrorAction SilentlyContinue;

    if ($HasErrors) {
        Write-IcingaConsoleWarning 'Not all components could be removed. Please ensure no other PowerShell/Application is currently open and accessing Icinga for Windows files';
    } else {
        Write-IcingaConsoleNotice 'Icinga for Windows was removed from this host.';
    }
}

<#
.SYNOPSIS
    Uninstalls the Icinga PowerShell Service as a Windows Service
.DESCRIPTION
    Uninstalls the Icinga PowerShell Service as a Windows Service. The service binary
    will be left on the system.
.FUNCTIONALITY
    Uninstalls the Icinga PowerShell Service as a Windows Service
.EXAMPLE
    PS>Uninstall-IcingaForWindowsService;
.INPUTS
   System.String
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Uninstall-IcingaForWindowsService()
{
    param (
        [switch]$RemoveFiles = $FALSE
    );

    $ServiceData = Get-IcingaForWindowsServiceData;

    Stop-IcingaService 'icingapowershell';
    Start-Sleep -Seconds 1;

    $ServiceCreation = Start-IcingaProcess -Executable 'sc.exe' -Arguments 'delete icingapowershell';

    switch ($ServiceCreation.ExitCode) {
        0 {
            Write-IcingaConsoleNotice 'Icinga PowerShell Service was successfully removed';
        }
        1060 {
            Write-IcingaConsoleWarning 'The Icinga PowerShell Service is not installed';
        }
        Default {
            throw ([string]::Format('Failed to install Icinga PowerShell Service: {0}{1}', $ServiceCreation.Message, $ServiceCreation.Error));
        }
    }

    if ($RemoveFiles -eq $FALSE) {
        return $TRUE;
    }

    if ([string]::IsNullOrEmpty($ServiceData.Directory) -Or (Test-Path $ServiceData.Directory) -eq $FALSE) {
        return $TRUE;
    }

    $ServiceFolderContent = Get-ChildItem -Path $ServiceData.Directory;

    foreach ($entry in $ServiceFolderContent) {
        if ($entry.Name -eq 'icinga-service.exe' -Or $entry.Name -eq 'icinga-service.exe.md5' -Or $entry.Name -eq 'icinga-service.exe.update') {
            Remove-Item $entry.FullName -Force;
            Write-IcingaConsoleNotice 'Removing file "{0}"' -Objects $entry.FullName;
        }
    }

    $ServiceFolderContent = Get-ChildItem -Path $ServiceData.Directory;

    if ($ServiceFolderContent.Count -eq 0) {
        Remove-Item $ServiceData.Directory;
        Write-IcingaConsoleNotice 'Removing directory "{0}"' -Objects $ServiceData.Directory;
    } else {
        Write-IcingaConsoleWarning 'Unable to remove folder "{0}", because there are still files inside.' -Objects $ServiceData.Directory;
    }

    return $TRUE;
}

Set-Alias -Name 'Uninstall-IcingaFrameworkService' -Value 'Uninstall-IcingaForWindowsService';

<#
.SYNOPSIS
    Uninstalls a specific module within the icinga-powershell-* namespace
    inside your PowerShell module folder
.DESCRIPTION
    Uninstalls a specific module within the icinga-powershell-* namespace
    inside your PowerShell module folder
.FUNCTIONALITY
    Uninstalls a specific module within the icinga-powershell-* namespace
    inside your PowerShell module folder
.PARAMETER Name
    The component you want to uninstall, like 'plugins' or 'mssql'
.INPUTS
   System.String
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Uninstall-IcingaFrameworkComponent()
{
    param (
        [string]$Name = ''
    );

    $ModuleBase         = Get-IcingaForWindowsRootPath;
    $UninstallComponent = [string]::Format('icinga-powershell-{0}', $Name);
    $UninstallPath      = Join-Path -Path $ModuleBase -ChildPath $UninstallComponent;

    if ((Test-Path $UninstallPath) -eq $FALSE) {
        Write-IcingaConsoleNotice -Message 'The Icinga for Windows component "{0}" at "{1}" could not ne found.' -Objects $UninstallComponent, $UninstallPath;
        return $FALSE;
    }

    Write-IcingaConsoleNotice -Message 'Uninstalling Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
    if (Remove-ItemSecure -Path $UninstallPath -Recurse -Force) {
        Write-IcingaConsoleNotice -Message 'Successfully removed Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
        if ($UninstallComponent -ne 'icinga-powershell-framework') {
            Remove-Module $UninstallComponent -Force -ErrorAction SilentlyContinue;
        }
        return $TRUE;
    } else {
        Write-IcingaConsoleError -Message 'Unable to uninstall Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
    }

    return $FALSE;
}

function Find-IcingaAgentObjects()
{
    param(
        $Find    = @(),
        $OutFile = $null
    );

    if ($Find.Length -eq 0) {
        throw 'Please specify content you want to look for';
    }

    [array]$ObjectList = (Get-IcingaAgentObjectList).Split("`r`n");
    [int]$lineIndex    = 0;
    [array]$Result     = @();

    foreach ($line in $ObjectList) {
        if ([string]::IsNullOrEmpty($line)) {
            continue;
        }

        foreach ($entry in $Find) {
            if ($line -like $entry) {
                [string]$ResultLine = [string]::Format(
                    'Line #{0} => "{1}"',
                    $lineIndex,
                    $line
                );
                $Result += $ResultLine;
            }
        }

        $lineIndex += 1;
    }

    if ([string]::IsNullOrEmpty($OutFile)) {
        Write-Output $Result;
    } else {
        Set-Content -Path $OutFile -Value $Result;
    }
}

function Disable-IcingaFirewall()
{
    param(
        [switch]$LegacyOnly
    );

    $FirewallConfig = Get-IcingaFirewallConfig -NoOutput;

    if ($FirewallConfig.LegacyFirewall) {
        $Firewall = Start-IcingaProcess -Executable 'netsh' -Arguments 'advfirewall firewall delete rule name="Icinga 2 Agent Inbound by PS-Module"';
        if ($Firewall.ExitCode -ne 0) {
            Write-IcingaConsoleError ([string]::Format('Failed to remove legacy firewall: {0}{1}', $Firewall.Message, $Firewall.Error));
        } else {
            Write-IcingaConsoleNotice 'Successfully removed legacy firewall rule';
        }
    }

    if ($LegacyOnly) {
        return;
    }

    if ($FirewallConfig.IcingaFirewall) {
        $Firewall = Start-IcingaProcess -Executable 'netsh' -Arguments 'advfirewall firewall delete rule name="Icinga Agent Inbound"';
        if ($Firewall.ExitCode -ne 0) {
            Write-IcingaConsoleError ([string]::Format('Failed to remove Icinga firewall: {0}{1}', $Firewall.Message, $Firewall.Error));
        } else {
            Write-IcingaConsoleNotice 'Successfully removed Icinga firewall rule';
        }
    }
}

function Enable-IcingaFirewall()
{
    param(
        [int]$IcingaPort = 5665,
        [switch]$Force
    );

    $FirewallConfig = Get-IcingaFirewallConfig -NoOutput;

    if ($FirewallConfig.IcingaFirewall -And $Force -eq $FALSE) {
        Write-IcingaConsoleNotice 'Icinga Firewall is already enabled'
        return;
    }

    if ($Force) {
        Disable-IcingaFirewall;
    }

    $IcingaBinary         = Get-IcingaAgentBinary;
    [string]$FirewallRule = [string]::Format(
        'advfirewall firewall add rule dir=in action=allow program="{0}" name="{1}" description="{2}" enable=yes remoteip=any localip=any localport={3} protocol=tcp',
        $IcingaBinary,
        'Icinga Agent Inbound',
        'Inbound Firewall Rule to allow Icinga 2 masters / satellites to connect to the Icinga 2 Agent installed on this system.',
        $IcingaPort
    );

    $FirewallResult = Start-IcingaProcess -Executable 'netsh' -Arguments $FirewallRule;

    if ($FirewallResult.ExitCode -ne 0) {
        Write-IcingaConsoleError ([string]::Format('Failed to open Icinga firewall for port "{0}": {1}[2}', $IcingaPort, $FirewallResult.Message, $FirewallResult.Error));
    } else {
        Write-IcingaConsoleNotice ([string]::Format('Successfully enabled firewall for port "{0}"', $IcingaPort));
    }
}

function Get-IcingaFirewallConfig()
{
    param(
        [switch]$NoOutput
    );

    [bool]$LegacyFirewallPresent = $FALSE;
    [bool]$IcingaFirewallPresent = $FALSE;

    $LegacyFirewall = Start-IcingaProcess -Executable 'netsh' -Arguments 'advfirewall firewall show rule name="Icinga 2 Agent Inbound by PS-Module"';

    if ($LegacyFirewall.ExitCode -eq 0) {
        if ($NoOutput -eq $FALSE) {
            Write-IcingaConsoleWarning 'Legacy firewall configuration has been detected.';
        }
        $LegacyFirewallPresent = $TRUE;
    }

    $IcingaFirewall = Start-IcingaProcess -Executable 'netsh' -Arguments 'advfirewall firewall show rule name="Icinga Agent Inbound"';

    if ($IcingaFirewall.ExitCode -eq 0) {
        if ($NoOutput -eq $FALSE) {
            Write-IcingaConsoleNotice 'Icinga firewall is present.';
        }
        $IcingaFirewallPresent = $TRUE;
    } else {
        if ($NoOutput -eq $FALSE) {
            Write-IcingaConsoleError 'Icinga firewall is not present';
        }
    }

    return @{
        'LegacyFirewall' = $LegacyFirewallPresent;
        'IcingaFirewall' = $IcingaFirewallPresent;
    }
}

function Get-IcingaAgentArchitecture()
{
    $IcingaAgent = Get-IcingaAgentInstallation;

    return $IcingaAgent.Architecture;
}

function Get-IcingaAgentBinary()
{
    $IcingaRootDir = Get-IcingaAgentRootDirectory;
    if ([string]::IsNullOrEmpty($IcingaRootDir)) {
        throw 'The Icinga Agent seems not to be installed';
    }

    $IcingaBinary = (Join-Path -Path $IcingaRootDir -ChildPath '\sbin\icinga2.exe');

    if ((Test-Path $IcingaBinary) -eq $FALSE) {
        throw 'Icinga Agent binary could not be found';
    }

    return $IcingaBinary;
}

function Get-IcingaAgentConfigDirectory()
{
    return (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\etc\icinga2\')
}

function Get-IcingaAgentFeatures()
{
    $Binary       = Get-IcingaAgentBinary;
    $ConfigResult = Start-IcingaProcess -Executable $Binary -Arguments 'feature list';

    if ($ConfigResult.ExitCode -ne 0) {
        return @{
            'Enabled'  = @();
            'Disabled' = @();
        }
    }

    $DisabledFeatures = (
        $ConfigResult.Message.SubString(
            0,
            $ConfigResult.Message.IndexOf('Enabled features')
        )
    ).Replace('Disabled features: ', '').Replace("`r`n", '').Replace("`r", '').Replace("`n", '');

    $EnabledFeatures  = (
        $ConfigResult.Message.SubString(
            $ConfigResult.Message.IndexOf('Enabled features'),
            $ConfigResult.Message.Length - $ConfigResult.Message.IndexOf('Enabled features')
        )
    ).Replace('Enabled features: ', '').Replace("`r`n", '').Replace("`r", '').Replace("`n", '');

    return @{
        'Enabled'  = ($EnabledFeatures.Split(' '));
        'Disabled' = ($DisabledFeatures.Split(' '));
    }
}

function Get-IcingaAgentHostCertificate()
{
    # Default for Icinga 2.8.0 and above
    [string]$CertDirectory = (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\certs\*');
    $FolderContent         = Get-ChildItem -Path $CertDirectory -Filter '*.crt' -Exclude 'ca.crt';
    $Hostname              = Get-IcingaHostname -LowerCase $TRUE;
    $CertPath              = $null;

    foreach ($certFile in $FolderContent) {
        if ($certFile.Name -like ([string]::Format('{0}.crt', $Hostname))) {
            $CertPath = $certFile.FullName;
            break;
        }
    }

    if ([string]::IsNullOrEmpty($CertPath)) {
        return $null;
    }

    $Certificate = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $CertPath;

    return @{
        'CertFile'   = $CertPath;
        'Subject'    = $Certificate.Subject;
        'Thumbprint' = $Certificate.Thumbprint;
    };
}

function Get-IcingaAgentInstallation()
{
    [string]$architecture = '';
    if ([IntPtr]::Size -eq 4) {
        $architecture = "x86";
        $regPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*';
    } else {
        $architecture = "x86_64";
        $regPath = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*', 'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*');
    }

    $RegistryData = Get-ItemProperty $regPath;
    $IcingaData   = $null;
    foreach ($entry in $RegistryData) {
        if ($entry.DisplayName -eq 'Icinga 2') {
            $IcingaData = $entry;
            break;
        }
    }

    $IcingaService = Get-IcingaServices -Service 'icinga2';
    $ServiceUser   = 'NT AUTHORITY\NetworkService';

    if ($null -ne $IcingaService) {
        $ServiceUser = $IcingaService.icinga2.configuration.ServiceUser;
    }

    if ($null -eq $IcingaData) {
        return @{
            'Installed'    = $FALSE;
            'RootDir'      = '';
            'Version'      = (Split-IcingaVersion);
            'Architecture' = $architecture;
            'Uninstaller'  = '';
            'InstallDate'  = '';
            'User'         = $ServiceUser;
        };
    }

    return @{
        'Installed'    = $TRUE;
        'RootDir'      = $IcingaData.InstallLocation;
        'Version'      = (Split-IcingaVersion $IcingaData.DisplayVersion);
        'Architecture' = $architecture;
        'Uninstaller'  = $IcingaData.UninstallString.Replace("MsiExec.exe ", "");
        'InstallDate'  = $IcingaData.InstallDate;
        'User'         = $ServiceUser;
    };
}

function Get-IcingaAgentInstallerAnswerInput()
{
    param(
        $Prompt,
        [ValidateSet("y", "n", "v")]
        $Default,
        $DefaultInput   = '',
        [switch]$Secure
    );

    $DefaultAnswer = '';

    if ($Default -eq 'y') {
        $DefaultAnswer = ' (Y/n)';
    } elseif ($Default -eq 'n') {
        $DefaultAnswer = ' (y/N)';
    } elseif ($Default -eq 'v') {
        if ([string]::IsNullOrEmpty($DefaultInput) -eq $FALSE) {
            $DefaultAnswer = [string]::Format(' (Defaults: "{0}")', $DefaultInput);
        }
    }

    if (-Not $Secure) {
        $answer = Read-Host -Prompt ([string]::Format('{0}{1}', $Prompt, $DefaultAnswer));
    } else {
        $answer = Read-Host -Prompt ([string]::Format('{0}{1}', $Prompt, $DefaultAnswer)) -AsSecureString;
    }

    if ($Default -ne 'v') {
        $answer = $answer.ToLower();

        $returnValue = 0;
        if ([string]::IsNullOrEmpty($answer) -Or $answer -eq $Default) {
            $returnValue = 1;
        } else {
            $returnValue = 0;
        }

        return @{
            'result' = $returnValue;
            'answer' = '';
        }
    }

    if ([string]::IsNullOrEmpty($answer)) {
        $answer = $DefaultInput;
    }

    return @{
        'result' = 2;
        'answer' = $answer;
    }
}

function Get-IcingaAgentLogDirectory()
{
    return (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\log\icinga2\')
}

function Get-IcingaAgentMSIPackage()
{
    param(
        [string]$Source,
        [string]$Version,
        [switch]$SkipDownload
    );

    if ([string]::IsNullOrEmpty($Version)) {
        throw 'Please specify a valid version: "release", "snapshot" or a specific version like "2.11.0"';
    }

    if ([string]::IsNullOrEmpty($Source)) {
        throw 'Please specify a valid download URL, like "https://packages.icinga.com/windows/"';
    }

    Set-IcingaTLSVersion;
    # Disable the progress bar for the WebRequest
    $ProgressPreference = "SilentlyContinue";
    $Architecture = Get-IcingaAgentArchitecture;
    $LastUpdate   = $null;
    $Version      = $Version.ToLower();

    if ($Version -eq 'snapshot' -Or $Version -eq 'release') {
        if (Test-Path $Source) {
            $Content = Get-ChildItem -Path $Source;

            foreach ($entry in $Content) {
                # Only check for MSI packages
                if ($entry.Extension.ToLower() -ne '.msi') {
                    continue;
                }

                $PackageVersion = '';

                if ($entry.Name.ToLower().Contains('-')) {
                    $PackageVersion = ($entry.Name.Split('-')[1]).Replace('v', '');
                }

                if ($Version -eq 'snapshot') {
                    if ($PackageVersion -eq 'snapshot')  {
                        $UseVersion = 'snapshot';
                        break;
                    }
                    continue;
                }

                if ($PackageVersion -eq 'snapshot') {
                    continue;
                }

                try {
                    if ($null -eq $UseVersion -Or [version]$PackageVersion -ge [version]$UseVersion) {
                        $UseVersion = $PackageVersion;
                    }
                } catch {
                    # Nothing to catch specifically   
                }
            }
        } else {
            $Content    = (Invoke-IcingaWebRequest -Uri $Source -UseBasicParsing).RawContent.Split("`r`n");
            $UsePackage = $null;
            $UseVersion = $null;

            foreach ($line in $Content) {
                if ($line -like '*.msi*' -And $line -like "*$Architecture.msi*") {
                    $MSIPackage = $line.SubString(
                        $line.IndexOf('Icinga2-'),
                        $line.IndexOf('.msi') - $line.IndexOf('Icinga2-')
                    );
                    $LastUpdate = $line.SubString(
                        $line.IndexOf('indexcollastmod">') + 17,
                        $line.Length - $line.IndexOf('indexcollastmod">') - 17
                    );
                    $LastUpdate     = $LastUpdate.SubString(0, $LastUpdate.IndexOf(' '));
                    $LastUpdate     = $LastUpdate.Replace('-', '');
                    $MSIPackage     = [string]::Format('{0}.msi', $MSIPackage);
                    $PackageVersion = ($MSIPackage.Split('-')[1]).Replace('v', '');

                    if ($Version -eq 'snapshot') {
                        if ($PackageVersion -eq 'snapshot') {
                            $UseVersion = 'snapshot';
                            break;
                        }
                    } elseif ($Version -eq 'release') {
                        if ($line -like '*snapshot*' -Or $line -like '*-rc*') {
                            continue;
                        }

                        if ($null -eq $UseVersion -Or [version]$PackageVersion -ge [version]$UseVersion) {
                            $UseVersion = $PackageVersion;
                        }
                    }
                }
            }
        }
        if ($Version -eq 'snapshot') {
            $UsePackage = [string]::Format('Icinga2-{0}-{1}.msi', $UseVersion, $Architecture);
        } else {
            $UsePackage = [string]::Format('Icinga2-v{0}-{1}.msi', $UseVersion, $Architecture);
        }
    } else {
        $UsePackage = [string]::Format('Icinga2-v{0}-{1}.msi', $Version, $Architecture);
    }

    if ($null -eq $UsePackage) {
        throw 'No Icinga installation MSI package for your architecture could be found for the provided version and source';
    }

    if ($SkipDownload -eq $FALSE) {
        $DownloadPath = Join-Path $Env:TEMP -ChildPath $UsePackage;
        Write-IcingaConsoleNotice ([string]::Format('Downloading Icinga 2 Agent installer "{0}" into temp directory "{1}"', $UsePackage, $DownloadPath));
        Invoke-IcingaWebRequest -Uri (Join-WebPath -Path $Source -ChildPath $UsePackage) -OutFile $DownloadPath;
    }

    return @{
        'InstallerPath' = $DownloadPath;
        'Version'       = ($UsePackage).Replace('Icinga2-v', '').Replace('Icinga2-', '').Replace([string]::Format('-{0}.msi', $Architecture), '')
        'LastUpdate'    = $LastUpdate;
    }
}

function Get-IcingaAgentObjectList()
{
    $Binary     = Get-IcingaAgentBinary;
    $ObjectList = Start-IcingaProcess -Executable $Binary -Arguments 'object list';

    return $ObjectList.Message;
}

function Get-IcingaAgentRootDirectory()
{
    $IcingaAgent = Get-IcingaAgentInstallation;
    if ($IcingaAgent.Installed -eq $FALSE) {
        return '';
    }

    return $IcingaAgent.RootDir;
}

function Get-IcingaAgentServicePermission()
{
    $SystemPermissions = New-IcingaTemporaryFile;
    $SystemOutput      = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/export /cfg "{0}.inf"', $SystemPermissions));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to fetch system permission information: {0}', $SystemOutput.Message));
        return $null;
    }

    $SystemContent = Get-Content "$SystemPermissions.inf";

    Remove-Item $SystemPermissions*;

    return $SystemContent;
}

function Get-IcingaAgentVersion()
{
    $IcingaAgent = Get-IcingaAgentInstallation;

    return $IcingaAgent.Version;
}

function Get-IcingaHostname()
{
    param(
        [string]$Hostname,
        [bool]$AutoUseFQDN     = $FALSE,
        [bool]$AutoUseHostname = $FALSE,
        [bool]$UpperCase       = $FALSE,
        [bool]$LowerCase       = $FALSE
    );

    [string]$UseHostname = '';
    if ([string]::IsNullOrEmpty($Hostname) -eq $FALSE) {
        $UseHostname = $Hostname;
    } elseif ($AutoUseFQDN) {
        $UseHostname = [System.Net.Dns]::GetHostEntry("localhost").HostName;
    } else {
        $UseHostname = [System.Net.Dns]::GetHostName();
    }

    if ($UpperCase) {
        $UseHostname = $UseHostname.ToUpper();
    } elseif ($LowerCase) {
        $UseHostname = $UseHostname.ToLower();
    }

    return $UseHostname;
}

function Get-IcingaNetbiosName()
{
    $ComputerData = Get-IcingaWindowsInformation Win32_ComputerSystem;

    return $ComputerData.Name;
}

function Get-IcingaServiceUser()
{
    $Services = Get-IcingaServices -Service 'icinga2';
    if ($null -eq $Services) {
        throw 'Icinga Service not installed';
    }

    $Services    = $Services.GetEnumerator() | Select-Object -First 1;
    $ServiceUser = ($Services.Value.configuration.ServiceUser).Replace('.\', '');

    if ($ServiceUser -eq 'LocalSystem') {
        $ServiceUser = 'NT Authority\SYSTEM';
    }

    return $ServiceUser;
}

function Install-IcingaAgent()
{
    param(
        [string]$Version,
        [string]$Source     = 'https://packages.icinga.com/windows/',
        [string]$InstallDir = '',
        [bool]$AllowUpdates = $FALSE
    );

    if ([string]::IsNullOrEmpty($Version)) {
        Write-IcingaConsoleError 'No Icinga Agent version specified. Skipping installation.';
        return $FALSE;
    }

    if ($IcingaData.Installed -eq $TRUE -and $AllowUpdates -eq $FALSE) {
        Write-IcingaConsoleWarning 'The Icinga Agent is already installed on this system. To perform updates or downgrades, please add the "-AllowUpdates" argument';
        return $FALSE;
    }

    $IcingaData       = Get-IcingaAgentInstallation;
    $InstalledVersion = Get-IcingaAgentVersion;
    $IcingaInstaller  = Get-IcingaAgentMSIPackage -Source $Source -Version $Version -SkipDownload;
    $InstallTarget    = $IcingaData.RootDir;

    if ($Version -eq 'snapshot') {
        if ($IcingaData.InstallDate -ge $IcingaInstaller.LastUpdate -And [string]::IsNullOrEmpty($InstalledVersion.Snapshot) -eq $FALSE) {
            Write-IcingaConsoleNotice 'There is no new snapshot package available which requires to be installed.'
            return $FALSE;
        }
        $IcingaInstaller.Version = 'snapshot';
    } elseif ($IcingaInstaller.Version -eq $InstalledVersion.Full) {
        Write-IcingaConsoleNotice (
            [string]::Format(
                'No installation required. Your installed version [{0}] is matching the online version [{1}]',
                $InstalledVersion.Full,
                $IcingaInstaller.Version
            )
        );
        return $FALSE;
    }

    $IcingaInstaller = Get-IcingaAgentMSIPackage -Source $Source -Version $IcingaInstaller.Version;

    if ((Test-Path $IcingaInstaller.InstallerPath) -eq $FALSE) {
        throw 'Failed to locate Icinga Agent installer file';
    }

    if ([string]::IsNullOrEmpty($InstallDir) -eq $FALSE) {
        if ((Test-Path $InstallDir) -eq $FALSE) {
            New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null;
        }
        $InstallTarget = $InstallDir;
    }

    [string]$InstallFolderMsg = $InstallTarget;

    if ([string]::IsNullOrEmpty($InstallTarget) -eq $FALSE) {
        $InstallTarget = [string]::Format(' INSTALL_ROOT="{0}"', $InstallTarget);
    } else {
        $InstallTarget = '';
        if ($IcingaData.Architecture -eq 'x86') {
            $InstallFolderMsg = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'ICINGA2';
        } else {
            $InstallFolderMsg = Join-Path -Path $env:ProgramFiles -ChildPath 'ICINGA2';
        }
    }

    Write-IcingaConsoleNotice ([string]::Format('Installing new Icinga Agent version into "{0}"', $InstallFolderMsg));

    if ($IcingaData.Installed) {
        if ((Uninstall-IcingaAgent) -eq $FALSE) {
            return $FALSE;
        }
    }

    $InstallProcess = powershell.exe -Command {
        $IcingaInstaller = $args[0];
        $InstallTarget   = $args[1];
        Use-Icinga;

        $InstallProcess = Start-IcingaProcess -Executable 'MsiExec.exe' -Arguments ([string]::Format('/quiet /i "{0}" {1}', $IcingaInstaller.InstallerPath, $InstallTarget)) -FlushNewLines;

        return $InstallProcess;
    } -Args $IcingaInstaller, $InstallTarget;

    if ($InstallProcess.ExitCode -ne 0) {
        Write-IcingaConsoleError -Message 'Failed to install Icinga 2 Agent: {0}{1}' -Objects $InstallProcess.Message, $InstallProcess.Error;
        return $FALSE;
    }

    Write-IcingaConsoleNotice 'Icinga Agent was successfully installed';
    return $TRUE;
}

function Install-IcingaAgentBaseFeatures()
{
    Disable-IcingaAgentFeature -Feature 'checker';
    Disable-IcingaAgentFeature -Feature 'notification';
    Enable-IcingaAgentFeature -Feature 'api';
}

<#
.SYNOPSIS
    Installs the required certificates for the Icinga Agent including the entire
    signing process either by using the CA-Proxy, the CA-Server directly or
    by manually signing the request on the CA master
.DESCRIPTION
    Installs the required certificates for the Icinga Agent including the entire
    signing process either by using the CA-Proxy, the CA-Server directly or
   by manually signing the request on the CA master
.FUNCTIONALITY
    Creates, installs and signs required certificates for the Icinga Agent
.EXAMPLE
    # Connect to the CA server with a ticket to fully complete the request
    PS>Install-IcingaAgentCertificates -Hostname 'windows.example.com' -Endpoint 'icinga2.example.com' -Ticket 'my_secret_ticket';
.EXAMPLE
    # Connect to the CA server without a ticket, to create the sign request on the master
    PS>Install-IcingaAgentCertificates -Hostname 'windows.example.com' -Endpoint 'icinga2.example.com';
.EXAMPLE
    # Uses the Icinga ca.crt from a local filesystem and prepares the Icinga Agent for receiving connections from the Master/Satellite for signing
    PS>Install-IcingaAgentCertificates -Hostname 'windows.example.com' -CACert 'C:\users\public\icinga2\ca.crt';
.EXAMPLE
    # Uses the Icinga ca.crt from a web resource and prepares the Icinga Agent for receiving connections from the Master/Satellite for signing
    PS>Install-IcingaAgentCertificates -Hostname 'windows.example.com' -CACert 'https://example.com/icinga2/ca.crt';
.PARAMETER Hostname
    The hostname of the local system. Has to match the object name within the Icinga configuration
.PARAMETER Endpoint
    The address of either the Icinga CA master or a parent node of the Agent to transmit the request to the CA master
.PARAMETER Port
    The port used for Icinga communication. Uses 5665 as default
.PARAMETER CACert
    Allows to specify the path to the ca.crt from the Icinga CA master on a local, network or web share to allow certificate generation
    in case the Icinga Agent is not able to connect to it's parent hosts
.PARAMETER Ticket
    The ticket number for the signing request which is either generated by Icinga 2 or the Icinga Director
.PARAMETER Force
    Ignores existing certificates and will force the creation, overriding existing certificates
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Install-IcingaAgentCertificates()
{
    param(
        [string]$Hostname,
        [string]$Endpoint,
        [int]$Port        = 5665,
        [string]$CACert,
        [string]$Ticket,
        [switch]$Force    = $FALSE
    );

    if ([string]::IsNullOrEmpty($Hostname)) {
        Write-IcingaConsoleError 'Failed to install Icinga Agent certificates. Please provide a hostname';
        return $FALSE;
    }

    # Default for Icinga 2.8.0 and above
    [string]$NewCertificateDirectory = (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\certs\');
    [string]$OldCertificateDirectory = (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\etc\icinga2\pki\');
    [string]$CertificateDirectory    = $NewCertificateDirectory;
    if ((Compare-IcingaVersions -RequiredVersion '2.8.0') -eq $FALSE) {
        # Certificate path for versions older than 2.8.0
        $CertificateDirectory = $OldCertificateDirectory;
        Move-IcingaAgentCertificates -Source $NewCertificateDirectory -Destination $OldCertificateDirectory;
    } else {
        Move-IcingaAgentCertificates -Source $OldCertificateDirectory -Destination $NewCertificateDirectory;
    }

    if (-Not (Test-IcingaAgentCertificates -CertDirectory $CertificateDirectory -Hostname $Hostname -Force $Force)) {
        Write-IcingaConsoleNotice ([string]::Format('Generating host certificates for host "{0}"', $Hostname));

        $arguments = [string]::Format('pki new-cert --cn {0} --key {1}{0}.key --cert {1}{0}.crt',
            $Hostname,
            $CertificateDirectory
        );

        if ((Start-IcingaAgentCertificateProcess -Arguments $arguments) -eq $FALSE) {
            Write-IcingaConsoleError 'Failed to generate host certificate';
            return $FALSE;
        }

        # Once we generated new host certificates, we always require to sign them if possible
        $Force = $TRUE;
    }

    if ([string]::IsNullOrEmpty($Endpoint) -And [string]::IsNullOrEmpty($CACert)) {
        Write-IcingaConsoleWarning 'Your host certificates have been generated successfully. Please either specify an endpoint to connect to or provide the path to a valid ca.crt';
        return $FALSE;
    }

    if (-Not [string]::IsNullOrEmpty($Endpoint)) {
        if (-Not (Test-IcingaAgentCertificates -CertDirectory $CertificateDirectory -Hostname $Hostname -TestTrustedParent -Force $Force)) {

            Write-IcingaConsoleNotice ([string]::Format('Fetching trusted master certificate from "{0}"', $Endpoint));

            # Argument --key for save-cert is deprecated starting with Icinga 2.12.0
            if (Compare-IcingaVersions -RequiredVersion '2.12.0') {
                $arguments = [string]::Format('pki save-cert --trustedcert {0}trusted-parent.crt --host {1} --port {2}',
                    $CertificateDirectory,
                    $Endpoint,
                    $Port
                );
            } else {
                $arguments = [string]::Format('pki save-cert --key {0}{1}.key --trustedcert {0}trusted-parent.crt --host {2} --port {3}',
                    $CertificateDirectory,
                    $Hostname,
                    $Endpoint,
                    $Port
                );
            }

            if ((Start-IcingaAgentCertificateProcess -Arguments $arguments) -eq $FALSE) {
                Write-IcingaConsoleError 'Unable to connect to your provided Icinga CA. Please verify the entered configuration is correct.' `
                    'If you are not able to connect to your Icinga CA from this machine, you will have to provide the path' `
                    'to your Icinga ca.crt and use the CA-Proxy certificate handling.';
                return $FALSE;
            }
        }

        if (-Not (Test-IcingaAgentCertificates -CertDirectory $CertificateDirectory -Hostname $Hostname -TestCACert -Force $Force)) {
            [string]$PKIRequest = 'pki request --host {0} --port {1} --ticket {4} --key {2}{3}.key --cert {2}{3}.crt --trustedcert {2}trusted-parent.crt --ca {2}ca.crt';

            if ([string]::IsNullOrEmpty($Ticket)) {
                $PKIRequest = 'pki request --host {0} --port {1} --key {2}{3}.key --cert {2}{3}.crt --trustedcert {2}trusted-parent.crt --ca {2}ca.crt';
            }

            $arguments = [string]::Format($PKIRequest,
                $Endpoint,
                $Port,
                $CertificateDirectory,
                $Hostname,
                $Ticket
            );

            if ((Start-IcingaAgentCertificateProcess -Arguments $arguments) -eq $FALSE) {
                Write-IcingaConsoleError 'Failed to sign Icinga certificate';
                return $FALSE;
            }

            if ([string]::IsNullOrEmpty($Ticket)) {
                Write-IcingaConsoleNotice 'Your certificates were generated successfully. Please sign the certificate now on your Icinga CA master. You can lookup open requests with "icinga2 ca list"';
            } else {
                Write-IcingaConsoleNotice 'Icinga certificates successfully installed';
            }
        }

        return $TRUE;
    } elseif (-Not [string]::IsNullOrEmpty($CACert)) {
        if (-Not (Copy-IcingaAgentCACertificate -CAPath $CACert -Desination $CertificateDirectory)) {
            return $FALSE;
        }
        Write-IcingaConsoleNotice 'Host-Certificates and ca.crt are present. Please start your Icinga Agent now and manually sign your certificate request on your CA master. You can lookup open requests with "icinga2 ca list"';
    }

    return $TRUE;
}

function Start-IcingaAgentCertificateProcess()
{
    param(
        $Arguments
    );

    $Binary  = Get-IcingaAgentBinary;
    $Process = Start-IcingaProcess -Executable $Binary -Arguments $Arguments;

    if ($Process.ExitCode -ne 0) {
        Write-IcingaConsoleError ([string]::Format('Failed to create certificate.{0}Arguments: {1}{0}Error:{2} {3}', "`r`n", $Arguments, $Process.Message, $Process.Error));
        return $FALSE;
    }

    Write-IcingaConsoleNotice $Process.Message;
    return $TRUE;
}

function Move-IcingaAgentCertificates()
{
    param(
        [string]$Source,
        [string]$Destination
    );

    $SourceDir = Join-Path -Path $Source -ChildPath '\*';
    $TargetDir = Join-Path -Path $Destination -ChildPath '\';

    Move-Item -Path $SourceDir -Destination $TargetDir;
}

function Test-IcingaAgentCertificates()
{
    param(
        [string]$CertDirectory,
        [string]$Hostname,
        [switch]$TestCACert,
        [switch]$TestTrustedParent,
        [bool]$Force
    );

    if ($Force) {
        return $FALSE;
    }

    if ($TestCACert) {
        if (Test-Path (Join-Path -Path $CertDirectory -ChildPath 'ca.crt')) {
            Write-IcingaConsoleNotice 'Your ca.crt is present. No generation or fetching required';
            return $TRUE;
        } else {
            Write-IcingaConsoleWarning 'Your ca.crt is not present. Manuall copy or fetching from your Icinga CA is required.';
            return $FALSE;
        }
    }

    if ($TestTrustedParent) {
        if (Test-Path (Join-Path -Path $CertDirectory -ChildPath 'trusted-parent.crt')) {
            Write-IcingaConsoleNotice 'Your trusted-parent.crt is present. No fetching or generation required';
            return $TRUE;
        } else {
            Write-IcingaConsoleWarning 'Your trusted master certificate is not present. Fetching from your CA server is required';
            return $FALSE;
        }
    }

    if ((-Not (Test-Path ((Join-Path -Path $CertDirectory -ChildPath $Hostname) + '.key'))) `
            -Or -Not (Test-Path ((Join-Path -Path $CertDirectory -ChildPath $Hostname) + '.crt'))) {
        return $FALSE;
    }

    [string]$hostCRT       = [string]::Format('{0}.crt', $Hostname);
    [string]$hostKEY       = [string]::Format('{0}.key', $Hostname);
    [bool]$CertNameInvalid = $FALSE;

    $certificates = Get-ChildItem -Path $CertDirectory;
    # Now loop each file and match their name with our hostname
    foreach ($cert in $certificates) {
        if ($cert.Name.toLower() -eq $hostCRT.toLower() -Or $cert.Name.toLower() -eq $hostKEY.toLower()) {
            $file = $cert.Name.Replace('.key', '').Replace('.crt', '');
            if (-Not ($file -clike $Hostname)) {
                Write-IcingaConsoleWarning ([string]::Format('Certificate file {0} is not matching the hostname {1}. Certificate generation is required.', $cert.Name, $Hostname));
                $CertNameInvalid = $TRUE;
                break;
            }
        }
    }

    if ($CertNameInvalid) {
        Remove-Item -Path (Join-Path -Path $CertDirectory -ChildPath $hostCRT) -Force;
        Remove-Item -Path (Join-Path -Path $CertDirectory -ChildPath $hostKEY) -Force;
        return $FALSE;
    }

    Write-IcingaConsoleNotice 'Icinga host certificates are present and valid. No generation required';

    return $TRUE;
}

function Copy-IcingaAgentCACertificate()
{
    param(
        [string]$CAPath,
        [string]$Desination
    );

    # Copy ca.crt from local path or network share to certificate path
    if ((Test-Path $CAPath)) {
        Copy-Item -Path $CAPath -Destination (Join-Path -Path $Desination -ChildPath 'ca.crt') | Out-Null;
        Write-IcingaConsoleNotice ([string]::Format('Copied ca.crt from "{0}" to "{1}', $CAPath, $Desination));
    } else {
        Set-IcingaTLSVersion;
        # It could also be a web ressource
        try {
            $response   = Invoke-IcingaWebRequest $CAPath -UseBasicParsing;
            [int]$Index = $response.RawContent.IndexOf("`r`n`r`n") + 4;

            [string]$CAContent = $response.RawContent.SubString(
                $Index,
                $response.RawContent.Length - $Index
            );
            Set-Content -Path (Join-Path $Desination -ChildPath 'ca.crt') -Value $CAContent;
            Write-IcingaConsoleNotice ([string]::Format('Downloaded ca.crt from "{0}" to "{1}', $CAPath, $Desination))
        } catch {
            Write-IcingaConsoleError 'Failed to load any provided ca.crt ressource';
            return $FALSE;
        }
    }

    return $TRUE;
}

Export-ModuleMember -Function @('Install-IcingaAgentCertificates');

function Uninstall-IcingaAgent()
{
    param (
        [switch]$RemoveDataFolder = $FALSE
    );

    $IcingaData                = Get-IcingaAgentInstallation;
    [string]$IcingaProgramData = Join-Path -Path $Env:ProgramData -ChildPath 'icinga2';

    if ($IcingaData.Installed -eq $FALSE) {
        Write-IcingaConsoleNotice 'Unable to uninstall the Icinga Agent. The Agent is not installed';
        if ($RemoveDataFolder) {
            if (Test-Path $IcingaProgramData) {
                Write-IcingaConsoleNotice -Message 'Removing Icinga Agent directory: "{0}"' -Objects $IcingaProgramData;
                return ((Remove-ItemSecure -Path $IcingaProgramData -Recurse -Force) -eq $FALSE);
            } else {
                Write-IcingaConsoleNotice -Message 'Icinga Agent directory "{0}" does not exist' -Objects $IcingaProgramData;
            }
        }
        return $FALSE;
    }

    $Uninstaller = powershell.exe -Command {
        $IcingaData = $args[0]
        Use-Icinga;

        Stop-Service 'icinga2' -ErrorAction SilentlyContinue | Out-Null;

        $Uninstaller = Start-IcingaProcess -Executable 'MsiExec.exe' -Arguments ([string]::Format('{0} /q', $IcingaData.Uninstaller)) -FlushNewLine;

        return $Uninstaller;
    } -Args $IcingaData;

    if ($Uninstaller.ExitCode -ne 0) {
        Write-IcingaConsoleError ([string]::Format('Failed to remove Icinga Agent: {0}{1}', $Uninstaller.Message, $Uninstaller.Error));
        return $FALSE;
    }

    if ($RemoveDataFolder) {
        Write-IcingaConsoleNotice -Message 'Removing Icinga Agent directory: "{0}"' -Objects $IcingaProgramData;
        if ((Remove-ItemSecure -Path $IcingaProgramData -Recurse -Force) -eq $FALSE) {
            return $FALSE;
        }
    }

    Write-IcingaConsoleNotice 'Icinga Agent was successfully removed';
    return $TRUE;
}

<#
.SYNOPSIS
   Clears the entire content of the Icinga Agent API directory located
   at Program Data\icinga2\var\lib\icinga2\api\
.DESCRIPTION
   Clears the entire content of the Icinga Agent API directory located
   at Program Data\icinga2\var\lib\icinga2\api\
.FUNCTIONALITY
   Clears the entire content of the Icinga Agent API directory located
   at Program Data\icinga2\var\lib\icinga2\api\
.EXAMPLE
   PS>Clear-IcingaAgentApiDirectory;
.EXAMPLE
   PS>Clear-IcingaAgentApiDirectory -Force;
.PARAMETER Force
   In case the Icinga Agent service is running while executing the command,
   the force argument will ensure the service is stopped before the API
   directory is flushed and restarted afterwards
.INPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Clear-IcingaAgentApiDirectory()
{
    param (
        [switch]$Force = $FALSE
    );

    $IcingaService = (Get-IcingaServices -Service icinga2).icinga2;
    $ApiDirectory  = (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\api\');

    if ((Test-Path $ApiDirectory) -eq $FALSE) {
        Write-IcingaConsoleError 'The Icinga Agent API directory is not present on this system. Please check if the Icinga Agent is installed';
        return;
    }

    if ($IcingaService.configuration.Status.raw -eq 4 -And $Force -eq $FALSE) {
        Write-IcingaConsoleError 'The API directory can not be deleted while the Icinga Agent is running. Use the "-Force" argument to stop the service, flush the directory and restart the service again.';
        return;
    }

    if ($IcingaService.configuration.Status.raw -eq 4) {
        Stop-IcingaService icinga2;
        Start-Sleep -Seconds 1;
    }

    Write-IcingaConsoleNotice 'Flushing Icinga Agent API directory';
    Remove-ItemSecure -Path (Join-Path -Path $ApiDirectory -ChildPath '*') -Recurse -Force | Out-Null;
    Start-Sleep -Seconds 1;

    if ($IcingaService.configuration.Status.raw -eq 4) {
        Start-IcingaService icinga2;
    }
}

function Compare-IcingaVersions()
{
    param(
        $CurrentVersion,
        $RequiredVersion
    );

    if ([string]::IsNullOrEmpty($RequiredVersion)) {
        return $FALSE;
    }

    $RequiredVersion = Split-IcingaVersion -Version $RequiredVersion;

    if ([string]::IsNullOrEmpty($CurrentVersion) -eq $FALSE) {
        $CurrentVersion = Split-IcingaVersion -Version $CurrentVersion;
    } else {
        $CurrentVersion = Get-IcingaAgentVersion;
    }

    if ($requiredVersion.Mayor -gt $currentVersion.Mayor) {
        return $FALSE;
    }

    if ($requiredVersion.Minor -gt $currentVersion.Minor) {
        return $FALSE;
    }

    if ($requiredVersion.Minor -ge $currentVersion.Minor -And $requiredVersion.Fixes -gt $currentVersion.Fixes) {
        return $FALSE;
    }

    return $TRUE;
}

function Convert-IcingaDirectorSelfServiceArguments()
{
    param(
        $JsonInput
    );

    if ($null -eq $JsonInput) {
        return @{};
    }

    [hashtable]$DirectorArguments = @{
        PackageSource           = $JsonInput.download_url;
        AgentVersion            = $JsonInput.agent_version;
        CAPort                  = $JsonInput.agent_listen_port;
        AllowVersionChanges     = $JsonInput.allow_updates;
        GlobalZones             = $JsonInput.global_zones;
        ParentZone              = $JsonInput.parent_zone;
        #CAEndpoint             = $JsonInput.ca_server;
        Endpoints               = $JsonInput.parent_endpoints;
        AddFirewallRule         = $JsonInput.agent_add_firewall_rule;
        AcceptConnections       = $JsonInput.agent_add_firewall_rule;
        ServiceUser             = $JsonInput.icinga_service_user;
        IcingaMaster            = $JsonInput.IcingaMaster;
        InstallFrameworkService = $JsonInput.install_framework_service;
        ServiceDirectory        = $JsonInput.framework_service_directory;
        FrameworkServiceUrl     = $JsonInput.framework_service_url;
        InstallFrameworkPlugins = $JsonInput.install_framework_plugins;
        PluginsUrl              = $JsonInput.framework_plugins_url;
        ConvertEndpointIPConfig = $JsonInput.resolve_parent_host;
        UpdateAgent             = $TRUE;
        AddDirectorGlobal       = $FALSE;
        AddGlobalTemplates      = $FALSE;
        RunInstaller            = $TRUE;
    };

    # Use NetworkService as default if nothing was transmitted by Director
    if ([string]::IsNullOrEmpty($DirectorArguments['ServiceUser'])) {
        $DirectorArguments['ServiceUser'] = 'NT Authority\NetworkService';
    }

    if ($JsonInput.transform_hostname -eq 1) {
        $DirectorArguments.Add(
            'LowerCase', $TRUE
        );
    }

    if ($JsonInput.transform_hostname -eq 2) {
        $DirectorArguments.Add(
            'UpperCase', $TRUE
        );
    }

    if ($JsonInput.fetch_agent_fqdn) {
        $DirectorArguments.Add(
            'AutoUseFQDN', $TRUE
        );
    } elseif ($JsonInput.fetch_agent_name) {
        $DirectorArguments.Add(
            'AutoUseHostname', $TRUE
        );
    }

    $NetworkDefault = '';
    foreach ($Endpoint in $JsonInput.parent_endpoints) {
        $NetworkDefault += [string]::Format('[{0}]:{1},', $Endpoint, $JsonInput.agent_listen_port);
    }
    if ([string]::IsNullOrEmpty($NetworkDefault) -eq $FALSE) {
        $NetworkDefault = $NetworkDefault.Substring(0, $NetworkDefault.Length - 1).Split(',');
        $DirectorArguments.Add(
            'EndpointConnections', $NetworkDefault
        );

        $EndpointConnections = $NetworkDefault;
        $DirectorArguments.Add(
            'CAEndpoint', (Get-IPConfigFromString $EndpointConnections[0]).address
        );
    }

    return $DirectorArguments;
}

function Disable-IcingaAgentFeature()
{
    param(
        [string]$Feature
    );

    if ([string]::IsNullOrEmpty($Feature)) {
        throw 'Please specify a valid feature';
    }

    if ((Test-IcingaAgentFeatureEnabled -Feature $Feature) -eq $FALSE) {
        Write-IcingaConsoleNotice ([string]::Format('This feature is already disabled [{0}]', $Feature));
        return;
    }

    $Binary  = Get-IcingaAGentBinary;
    $Process = Start-IcingaProcess -Executable $Binary -Arguments ([string]::Format('feature disable {0}', $Feature));

    if ($Process.ExitCode -ne 0) {
        throw ([string]::Format('Failed to disable Icinga Feature: {0}', $Process.Message));
    }

    Write-IcingaConsoleNotice ([string]::Format('Feature "{0}" was successfully disabled', $Feature));
}

function Enable-IcingaAgentFeature()
{
    param(
        [string]$Feature
    );

    if ([string]::IsNullOrEmpty($Feature)) {
        throw 'Please specify a valid feature';
    }

    if ((Test-IcingaAgentFeatureEnabled -Feature $Feature)) {
        Write-IcingaConsoleNotice ([string]::Format('This feature is already enabled [{0}]', $Feature));
        return;
    }

    $Binary  = Get-IcingaAgentBinary;
    $Process = Start-IcingaProcess -Executable $Binary -Arguments ([string]::Format('feature enable {0}', $Feature));

    if ($Process.ExitCode -ne 0) {
        throw ([string]::Format('Failed to enable Icinga Feature: {0}', $Process.Message));
    }

    Write-IcingaConsoleNotice ([string]::Format('Feature "{0}" was successfully enabled', $Feature));
}

function Move-IcingaAgentDefaultConfig()
{
    $ConfigDir  = Get-IcingaAgentConfigDirectory;
    $BackupFile = Join-Path -Path $ConfigDir -ChildPath 'ps_backup\backup_executed.key';

    if ((Test-Path $BackupFile)) {
        Write-IcingaConsoleNotice 'A backup of your default configuration is not required. A backup was already made';
        return;
    }

    New-Item (Join-Path -Path $ConfigDir -ChildPath 'ps_backup') -ItemType Directory | Out-Null;

    Move-Item -Path (Join-Path -Path $ConfigDir -ChildPath 'conf.d') -Destination (Join-Path -Path $ConfigDir -ChildPath 'ps_backup\conf.d');
    Move-Item -Path (Join-Path -Path $ConfigDir -ChildPath 'zones.conf') -Destination (Join-Path -Path $ConfigDir -ChildPath 'ps_backup\zones.conf');
    Copy-Item -Path (Join-Path -Path $ConfigDir -ChildPath 'constants.conf') -Destination (Join-Path -Path $ConfigDir -ChildPath 'ps_backup\constants.conf');
    Copy-Item -Path (Join-Path -Path $ConfigDir -ChildPath 'features-available') -Destination (Join-Path -Path $ConfigDir -ChildPath 'ps_backup\features-available');

    New-Item (Join-Path -Path $ConfigDir -ChildPath 'conf.d') -ItemType Directory | Out-Null;
    New-Item (Join-Path -Path $ConfigDir -ChildPath 'zones.conf') -ItemType File | Out-Null;
    New-Item -Path $BackupFile -ItemType File | Out-Null;

    Write-IcingaConsoleNotice 'Successfully backed up Icinga 2 Agent default config';
}

<#
.SYNOPSIS
   Checks for old configurations provided by the old PowerShell module
   and restores the original configuration file
.DESCRIPTION
   Restores the original Icinga 2 configuration by replacing the existing
   configuration created by the old PowerShell module with the plain one
   from the Icinga 2 backup file
.FUNCTIONALITY
   Restores original Icinga 2 configuration icinga2.conf
.EXAMPLE
   PS>Reset-IcingaAgentConfigFile;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Reset-IcingaAgentConfigFile()
{
    $ConfigDir       = Get-IcingaAgentConfigDirectory;
    $OldConfig       = Join-Path -Path $ConfigDir -ChildPath 'icinga2.conf';
    $OldConfigBackup = Join-Path -Path $ConfigDir -ChildPath 'icinga2.conf.old.module';
    $OriginalConfig  = Join-Path -Path $ConfigDir -ChildPath 'icinga2.confdirector.bak';

    if ((Test-Path $OriginalConfig)) {
        Write-IcingaConsoleWarning 'Found icinga2.conf backup file created by old PowerShell module. Restoring original configuration';

        Move-Item -Path $OldConfig      -Destination $OldConfigBackup;
        Move-Item -Path $OriginalConfig -Destination $OldConfig;
    }
}

function Show-IcingaAgentObjects()
{
    $Binary = Get-IcingaAgentBinary;
    $Output = Start-IcingaProcess -Executable $Binary -Arguments 'object list';

    if ($Output.ExitCode -ne 0) {
        Write-IcingaConsoleError ([string]::Format('Failed to fetch Icinga Agent objects list: {0}{1}', $Output.Message, $Output.Error));
        return $null;
    }

    return $Output.Message;
}

function Split-IcingaVersion()
{
    param(
        [string]$Version
    );

    if ([string]::IsNullOrEmpty($Version)) {
        return @{
            'Full'     = '';
            'Mayor'    = $null;
            'Minor'    = $null;
            'Fixes'    = $null;
            'Snapshot' = $null;
        }
    }

    [array]$IcingaVersion = $Version.Split('.');
    $Snapshot             = $null;

    if ([string]::IsNullOrEmpty($IcingaVersion[3]) -eq $FALSE) {
        $Snapshot = [int]$IcingaVersion[3];
    }

    return @{
        'Full'     = $Version;
        'Mayor'    = [int]$IcingaVersion[0];
        'Minor'    = [int]$IcingaVersion[1];
        'Fixes'    = [int]$IcingaVersion[2];
        'Snapshot' = $Snapshot;
    }
}

function Start-IcingaAgentDirectorWizard()
{
    param(
        [string]$DirectorUrl,
        [string]$SelfServiceAPIKey = $null,
        $OverrideDirectorVars      = $null,
        [bool]$RunInstaller        = $FALSE,
        [switch]$ForceTemplateKey  = $FALSE
    );

    [hashtable]$DirectorOverrideArgs        = @{ }
    if ([string]::IsNullOrEmpty($DirectorUrl)) {
        $DirectorUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the Url pointing to your Icinga Director (Example: "https://example.com/icingaweb2/director")' -Default 'v').answer;
    }

    [bool]$HostKnown     = $FALSE;
    [string]$TemplateKey = $SelfServiceAPIKey;

    if ($null -eq $OverrideDirectorVars -And $RunInstaller -eq $FALSE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to manually override arguments provided by the Director API?' -Default 'n').result -eq 0) {
            $OverrideDirectorVars = $TRUE;
        } else {
            $OverrideDirectorVars = $FALSE;
        }
    }

    $LocalAPIKey = Get-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey';

    if ($ForceTemplateKey) {
        if ($SelfServiceAPIKey -eq $LocalAPIKey) {
            $ForceTemplateKey = $FALSE;
        }
    }

    if ($ForceTemplateKey -eq $FALSE) {
        if ([string]::IsNullOrEmpty($LocalAPIKey)) {
            $LegacyTokenPath = Join-Path -Path Get-IcingaAgentConfigDirectory -ChildPath 'icingadirector.token';
            if (Test-Path $LegacyTokenPath) {
                $SelfServiceAPIKey =  Get-Content -Path $LegacyTokenPath;
                Set-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey' -Value $SelfServiceAPIKey;
            } else {
                $ForceTemplateKey = $TRUE;
            }
        } else {
            $SelfServiceAPIKey = $LocalAPIKey;
        }
    }

    if ([string]::IsNullOrEmpty($SelfServiceAPIKey)) {
        $SelfServiceAPIKey = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter your Self-Service API key' -Default 'v').answer;
    } else {
        if ($ForceTemplateKey -eq $FALSE) {
            $HostKnown = $TRUE;
        }
    }

    if ([string]::IsNullOrEmpty($LocalAPIKey) -eq $FALSE -And $LocalAPIKey -ne $TemplateKey -And $ForceTemplateKey -eq $FALSE) {
        try {
            $Arguments = Get-IcingaDirectorSelfServiceConfig -DirectorUrl $DirectorUrl -ApiKey $LocalAPIKey;
        } catch {
            Write-IcingaConsoleError 'Your local stored host key is no longer valid. Using provided template key';

            return Start-IcingaAgentDirectorWizard `
                -DirectorUrl $DirectorUrl `
                -SelfServiceAPIKey $TemplateKey `
                -OverrideDirectorVars $OverrideDirectorVars `
                -ForceTemplateKey;
        }
    } else {
        try {
            $Arguments = Get-IcingaDirectorSelfServiceConfig -DirectorUrl $DirectorUrl -ApiKey $SelfServiceAPIKey;
        } catch {
            Write-IcingaConsoleError ([string]::Format('Failed to connect to your Icinga Director at "{0}". Please try again', $DirectorUrl));

            return Start-IcingaAgentDirectorWizard `
                -SelfServiceAPIKey ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Please re-enter your SelfService API Key for the Host-Template in case the key is no longer assigned to your host' -Default 'v' -DefaultInput $SelfServiceAPIKey).answer) `
                -OverrideDirectorVars $OverrideDirectorVars;
        }
    }

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
        while ($TRUE) {
            try {
                $SelfServiceAPIKey = Register-IcingaDirectorSelfServiceHost -DirectorUrl $DirectorUrl -ApiKey $SelfServiceAPIKey -Hostname (Get-IcingaHostname @Arguments) -Endpoint $Arguments.IcingaMaster;
                break;
            } catch {
                $SelfServiceAPIKey = (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Failed to register host within Icinga Director. Full error: "{0}". Please re-enter your SelfService API Key. If this prompt continues ensure you are using an Agent template or drop your host key at "Hosts -> {1} -> Agent"', $_.Exception.Message, (Get-IcingaHostname @Arguments))) -Default 'v' -DefaultInput $SelfServiceAPIKey).answer;
            }
        }

        # Host is already registered
        if ($null -eq $SelfServiceAPIKey) {
            Write-IcingaConsoleError 'The wizard is unable to complete as this host is already registered but the local API key is not stored within the config'
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

    $IcingaTicket = Get-IcingaDirectorSelfServiceTicket -DirectorUrl $DirectorUrl -ApiKey $SelfServiceAPIKey;

    $DirectorOverrideArgs.Add(
        'DirectorUrl', $DirectorUrl
    );
    $DirectorOverrideArgs.Add(
        'Ticket', $IcingaTicket
    );
    $DirectorOverrideArgs.Add(
        'OverrideDirectorVars', 0
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
    Write-IcingaConsoleNotice 'Please follow the wizard and manually override all entries you intend to';
    Write-IcingaConsoleNotice '====';

    foreach ($entry in $Arguments.Keys) {
        $value = (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Please enter the new value for the argument "{0}"', $entry)) -Default 'v' -DefaultInput $Arguments[$entry]).answer;
        if ($Arguments[$entry] -is [array] -Or ($value -is [string] -And $value.Contains(','))) {
            if ([string]::IsNullOrEmpty($value) -eq $FALSE) {
                while ($value.Contains(', ')) {
                    $value = $value.Replace(', ', ',');
                }
                [array]$tmpArray = $value.Split(',');
                if ($null -ne (Compare-Object -ReferenceObject $Arguments[$entry] -DifferenceObject $tmpArray)) {
                    $NewArguments.Add(
                        $entry,
                        $tmpArray
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

<#
.SYNOPSIS
   A installation wizard that will guide you through the entire installation and
   configuration of Icinga for Windows including the Icinga Agent
.DESCRIPTION
   A installation wizard that will guide you through the entire installation and
   configuration of Icinga for Windows including the Icinga Agent
.FUNCTIONALITY
   Makes initial installation and first configuration of Icinga for Windows and
   the Icinga Agent very easy
.PARAMETER Hostname
   Set a specific hostname to the system and do not lookup anything automatically
.PARAMETER AutoUseFQDN
   Tells the wizard if you want to use the FQDN for the Icinga Agent or not.
   Set it to 1 to use FQDN and 0 to do not use it. Leave it empty to be prompted the wizard question.
   Ignores `AutoUseHostname`
.PARAMETER AutoUseHostname
   Tells the wizard if you want to use the hostname for the Icinga Agent or not.
   Set it to 1 to use hostname only 0 to not use it. Leave it empty to be prompted the wizard question.
   Overwritten by `AutoUseFQDN`
.PARAMETER LowerCase
   Tells the wizard if the provided hostname should be converted to lower case characters.
   Set it to 1 to lower case the name and 0 to do nothing. Leave it empty to be prompted the wizard question
.PARAMETER UpperCase
   Tells the wizard if the provided hostname should be converted to upper case characters.
   Set it to 1 to upper case the name and 0 to do nothing. Leave it empty to be prompted the wizard question
.PARAMETER AddDirectorGlobal
   Tells the wizard to add the `director-global` zone to your Icinga Agent configuration.
   Set it to 1 to add it and 0 to not add it. Leave it empty to be prompted the wizard question
.PARAMETER AddGlobalTemplates
   Tells the wizard to add the `global-templates` zone to your Icinga Agent configuration.
   Set it to 1 to add it and 0 to not add it. Leave it empty to be prompted the wizard question
.PARAMETER PackageSource
   Tells the wizard from which source we can download the Icinga Agent from. Use https://packages.icinga.com/windows/ if you can reach the internet
   Set the source to either web, local or network share. Leave it empty to be prompted the wizard question
.PARAMETER AgentVersion
   Tells the wizard which Icinga Agent version to install. You can provide latest, snapshot or a specific version like 2.11.6
   Set the value to one mentioned above. Leave it empty to be prompted the wizard question
.PARAMETER InstallDir
   Tells the wizard which directory the Icinga Agent will beinstalled into. Default is `C:\Program Files\ICINGA2`
   Set the value to one mentioned above.
.PARAMETER AllowVersionChanges
   Tells the wizard if the Icinga Agent should be updated/downgraded in case the current/target version are not matching
   Should be equal to `UpdateAgent`
   Set it to 1 to allow updates/downgrades 0 to not allow it. Leave it empty to be prompted the wizard question
.PARAMETER UpdateAgent
   Tells the wizard if the Icinga Agent should be updated/downgraded in case the current/target version are not matching
   Should be equal to `AllowVersionChanges`
   Set it to 1 to allow updates/downgrades 0 to not allow it. Leave it empty to be prompted the wizard question
.PARAMETER AddFirewallRule
   Tells the wizard if the used Icinga Agent port should be opened for incoming traffic on the Windows Firewall
   Set it to 1 to set the firewall rule 0 to do nothing. Leave it empty to be prompted the wizard question
.PARAMETER AcceptConnections
   Tells the wizard if the Icinga Agent is accepting incoming connections.
   Might require `AddFirewallRule` being enabled in case this value is set to 1
   Set it to 1 to accept connections 0 to not accept them. Leave it empty to be prompted the wizard question
.PARAMETER Endpoints
   Tells the wizard which endpoints this Icinga Agent has as parent. Example: master-icinga1, master-icinga2
   Set all parent endpoint names in a comma separated list. Leave it empty to be prompted the wizard question
.PARAMETER EndpointConnections
   Tells the wizard the connection configuration for provided endpoints. The order of this argument has to match
   the endpoint configuration on the `Endpoints` argument. Example: [master-icinga1.example.com]:5665, 192.168.0.5
   Set all parent endpoint connections as comma separated list. Leave it empty to be prompted the wizard question
.PARAMETER ConvertEndpointIPConfig
   Tells the wizard if FQDN for parent connections should be looked up and resolved to IP addresses. Example: example.com => 93.184.216.34
   Set it to 1 to lookup the up and 0 to do nothing. Leave it empty to be prompted the wizard question
.PARAMETER ParentZone
   Tells the wizard which parent zone name to use for Icinga Agent configuration.
   Set it to the name of the parent zone. Leave it empty to be prompted the wizard question
.PARAMETER GlobalZones
   Tells the wizard to add additional global zones to your configuration. You can provide a comma separated list for this
   Add additional global zones as comma separated list, use @() to not add anything. Leave it empty to be prompted the wizard question
.PARAMETER CAEndpoint
   Tells the wizard which address/fqdn to use for Icinga Agent certificate signing.
   Set the IP/FQDN of your CA Server/Icinga parent node or leave it empty if no connection is possible
.PARAMETER CAPort
   Tells the wizard which port to use for Icinga Agent certificate signing.
   Set the port of your CA Server/Icinga parent node or leave it empty if no connection is possible
.PARAMETER Ticket
   Tells the wizard which ticket to use for Icinga Agent certificate signing.
   Set the ticket of your certificate request for this host or leave it empty if no ticket is available.
   If you leave this argument empty, you will have to set `-EmptyTicket` to 1 and otherwise to 0
.PARAMETER EmptyTicket
   Tells the wizard to use a provided `-Ticket` or skip it. If `-Ticket` is empty you do not want to use it,
   set this argument to 1. If you set `-Ticket` with a ticket to use, set this argument to 0
   Leave it empty to be prompted the wizard question
.PARAMETER CAFile
   Tells the wizard if the Icinga CA Server ca.crt shall be used for signing certificate request.
   You can specify a web, local or network share as source to lookup the `ca.crt`.
   If this argument is set to be empty, ensure to also set `-EmptyCA` to 1
.PARAMETER EmptyCA
   Tells the wizard if the argument `-CAFile` is set or not. Set this argument to 1 if `-CAFile` is
   set and to 0 if `-CAFile` is not used
.PARAMETER RunInstaller
   Tells the wizard to skip the question if the configuration is correct and skips the question if you
   want to execute the wizard.
.PARAMETER Reconfigure
   Tells the wizard to execute all arguments again and configure certificates any thing else even if no
   change to the Icinga Agent was made. This is mostly required if you run the wizard again with the same
   Icinga Agent version being installed and available
.PARAMETER ServiceUser
   Tells the wizard which service user should be used for the Icinga Agent and PowerShell Service.
   Add 'NT Authority\NetworkService' to use the default one or specify a custom user
   Leave it empty to be prompted the wizard question.
.PARAMETER ServicePass
   Tells the wizard to use a special password for service users in case you are running a custom user
   instead of local service accounts.
.PARAMETER InstallFrameworkService
   Tells the wizard if you want to install the Icinga PowerShell service
   Set it to 1 to install it and 0 to not install it. Leave it empty to be prompted the wizard question
.PARAMETER FrameworkServiceUrl
   Tells the wizard where to download the Icinga PowerShell Service binary from. Example: https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip
   This argument is only required if `-InstallFrameworkService` is set to 1
.PARAMETER ServiceDirectory
   Tells the wizard where to install the Icinga PowerShell Service binary into. Use `C:\Program Files\icinga-framework-service` as default
   This argument is only required if `-InstallFrameworkService` is set to 1
.PARAMETER ServiceBin
   Tells the wizard the exact path of the service binary. Must match the path of `-ServiceDirectory` and add the binary at the end. Use `C:\Program Files\icinga-framework-service\icinga-service.exe` as default
   This argument is only required if `-InstallFrameworkService` is set to 1
.PARAMETER UseDirectorSelfService
   Tells the wizard to use the Icinga Director Self-Service API.
   Set it to 1 to use the SelfService and 0 to not use it. Leave it empty to prompt the wizard question
.PARAMETER SkipDirectorQuestion
   Tells the wizard to skip all related Icinga Director questions.
   Set it to 1 to skip possible questions and 0 if you continue with Icinga Director. Leave it empty to prompt the wizard question
.PARAMETER DirectorUrl
   Tells the wizard which URL to use for the Icinga Director. Only required if `-UseDirectorSelfService` is set to 1
   Specify the URL targeting your Icinga Director. Leave it empty to prompt the wizard question
.PARAMETER SelfServiceAPIKey
   Tells the wizard which SelfService API key to use for registering this host. In case wizard already run once,
   this argument is always overwritten by the local stored argument. Only required if `-UseDirectorSelfService` is set to 1
   Specify the SelfService API key being used for configuration. Leave it empty to prompt the wizard question in case the registration was not yet done for this host
.PARAMETER OverrideDirectorVars
   Tells the wizard of variables shipped by the Icinga Director SelfService should be overwritten. Only required if `-UseDirectorSelfService` is set to 1
   Set it to 1 to override arguments and 0 to do nothing. Leave it empty to prompt the wizard question
.PARAMETER InstallFrameworkPlugins
   Tells the wizard if you want to install the Icinga PowerShell Plugins
   Set it to 1 to install them and 0 to not install them. Leave it empty to be prompted the wizard question
.PARAMETER PluginsUrl
   Tells the wizard where to download the Icinga PowerShell Plugins from. Example: https://github.com/Icinga/icinga-powershell-plugins/archive/v1.2.0.zip
   This argument is only required if `-InstallFrameworkPlugins` is set to 1
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Start-IcingaAgentInstallWizard()
{
    param(
        [string]$Hostname,
        $AutoUseFQDN,
        $AutoUseHostname,
        $LowerCase,
        $UpperCase,
        $AddDirectorGlobal           = $null,
        $AddGlobalTemplates          = $null,
        [string]$PackageSource,
        [string]$AgentVersion,
        [string]$InstallDir,
        $AllowVersionChanges,
        $UpdateAgent                 = $null,
        $AddFirewallRule             = $null,
        $AcceptConnections           = $null,
        [array]$Endpoints            = @(),
        [array]$EndpointConnections  = @(),
        $ConvertEndpointIPConfig     = $null,
        [string]$ParentZone,
        [array]$GlobalZones          = $null,
        [string]$CAEndpoint,
        $CAPort                      = $null,
        [string]$Ticket,
        $EmptyTicket,
        [string]$CAFile              = $null,
        $EmptyCA                     = $null,
        [switch]$RunInstaller,
        [switch]$Reconfigure,
        [string]$ServiceUser,
        [securestring]$ServicePass   = $null,
        $InstallFrameworkService     = $null,
        $FrameworkServiceUrl         = $null,
        $ServiceDirectory            = $null,
        $ServiceBin                  = $null,
        $UseDirectorSelfService      = $null,
        [bool]$SkipDirectorQuestion  = $FALSE,
        [string]$DirectorUrl,
        [string]$SelfServiceAPIKey   = $null,
        $OverrideDirectorVars        = $null,
        $InstallFrameworkPlugins     = $null,
        $PluginsUrl                  = $null
    );

    [array]$InstallerArguments = @();
    [array]$GlobalZoneConfig   = @();

    if ($SkipDirectorQuestion -eq $FALSE) {
        if ($null -eq $UseDirectorSelfService) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to use the Icinga Director Self-Service API?' -Default 'y').result -eq 1) {
                $UseDirectorSelfService = $TRUE;
            } else {
                $UseDirectorSelfService = $FALSE;
                $InstallerArguments += '-UseDirectorSelfService 0';
            }
        }
        if ($UseDirectorSelfService) {

            $InstallerArguments += '-UseDirectorSelfService 1';
            $DirectorArgs = Start-IcingaAgentDirectorWizard `
                -DirectorUrl $DirectorUrl `
                -SelfServiceAPIKey $SelfServiceAPIKey `
                -OverrideDirectorVars $OverrideDirectorVars `
                -RunInstaller $RunInstaller;

            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'DirectorUrl' -Value $DirectorUrl -InstallerArguments $InstallerArguments;
            $DirectorUrl         = $Result.Value;
            $InstallerArguments  = $Result.Args;
            $Result              = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'SelfServiceAPIKey' -Value $SelfServiceAPIKey -InstallerArguments $InstallerArguments -Default $null;

            if ([string]::IsNullOrEmpty($Result.Value) -eq $FALSE) {
                $SelfServiceAPIKey   = $Result.Value;
                $InstallerArguments  = $Result.Args;
            }

            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'Ticket' -Value $Ticket -InstallerArguments $InstallerArguments;
            $Ticket                  = $Result.Value;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'PackageSource' -Value $PackageSource -InstallerArguments $InstallerArguments;
            $PackageSource           = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AgentVersion' -Value $AgentVersion -InstallerArguments $InstallerArguments;
            $AgentVersion            = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'InstallDir' -Value $InstallDir -InstallerArguments $InstallerArguments;
            $InstallDir              = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'CAPort' -Value $CAPort -InstallerArguments $InstallerArguments;
            $CAPort                  = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AllowVersionChanges' -Value $AllowVersionChanges -InstallerArguments $InstallerArguments;
            $AllowVersionChanges     = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'GlobalZones' -Value $GlobalZones -InstallerArguments $InstallerArguments;
            $GlobalZones             = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ParentZone' -Value $ParentZone -InstallerArguments $InstallerArguments;
            $ParentZone              = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'CAEndpoint' -Value $CAEndpoint -InstallerArguments $InstallerArguments;
            $CAEndpoint              = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'Endpoints' -Value $Endpoints -InstallerArguments $InstallerArguments;
            $Endpoints               = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddFirewallRule' -Value $AddFirewallRule -InstallerArguments $InstallerArguments;
            $AddFirewallRule         = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AcceptConnections' -Value $AcceptConnections -InstallerArguments $InstallerArguments;
            $AcceptConnections       = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ServiceUser' -Value $ServiceUser -InstallerArguments $InstallerArguments;
            $ServiceUser             = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'UpdateAgent' -Value $UpdateAgent -InstallerArguments $InstallerArguments;
            $UpdateAgent             = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddDirectorGlobal' -Value $AddDirectorGlobal -InstallerArguments $InstallerArguments;
            $AddDirectorGlobal       = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AddGlobalTemplates' -Value $AddGlobalTemplates -InstallerArguments $InstallerArguments;
            $AddGlobalTemplates      = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'LowerCase' -Value $LowerCase -Default $FALSE -InstallerArguments $InstallerArguments;
            $LowerCase               = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'UpperCase' -Value $UpperCase -Default $FALSE -InstallerArguments $InstallerArguments;
            $UpperCase               = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AutoUseFQDN' -Value $AutoUseFQDN -Default $FALSE -InstallerArguments $InstallerArguments;
            $AutoUseFQDN             = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'AutoUseHostname' -Value $AutoUseHostname -Default $FALSE -InstallerArguments $InstallerArguments;
            $AutoUseHostname         = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'EndpointConnections' -Value $EndpointConnections -InstallerArguments $InstallerArguments;
            $EndpointConnections     = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'OverrideDirectorVars' -Value $OverrideDirectorVars -InstallerArguments $InstallerArguments;
            $OverrideDirectorVars    = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'InstallFrameworkService' -Value $InstallFrameworkService -InstallerArguments $InstallerArguments;
            $InstallFrameworkService = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ServiceDirectory' -Value $ServiceDirectory -InstallerArguments $InstallerArguments;
            $ServiceDirectory        = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'FrameworkServiceUrl' -Value $FrameworkServiceUrl -InstallerArguments $InstallerArguments;
            $FrameworkServiceUrl     = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'InstallFrameworkPlugins' -Value $InstallFrameworkPlugins -InstallerArguments $InstallerArguments;
            $InstallFrameworkPlugins = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'PluginsUrl' -Value $PluginsUrl -InstallerArguments $InstallerArguments;
            $PluginsUrl              = $Result.Value;
            $InstallerArguments      = $Result.Args;
            $Result                  = Set-IcingaWizardArgument -DirectorArgs $DirectorArgs -WizardArg 'ConvertEndpointIPConfig' -Value $ConvertEndpointIPConfig -InstallerArguments $InstallerArguments;
            $ConvertEndpointIPConfig = $Result.Value;
            $InstallerArguments      = $Result.Args;
        }
    }

    # 'latest' is deprecated starting with 1.1.0
    if ($AgentVersion -eq 'latest') {
        $AgentVersion = 'release';
        Write-IcingaConsoleWarning -Message 'The value "latest" for the argmument "AgentVersion" is deprecated. Please use the value "release" in the future!';
    }

    if ([string]::IsNullOrEmpty($Hostname) -And $null -eq $AutoUseFQDN -And $null -eq $AutoUseHostname) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to specify the hostname manually?' -Default 'n').result -eq 1) {
            $HostFQDN     = Get-IcingaHostname -AutoUseFQDN 1 -AutoUseHostname 0 -LowerCase 1 -UpperCase 0;
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to automatically fetch the hostname as FQDN? (Result: "{0}")', $HostFQDN)) -Default 'y').result -eq 1) {
                $InstallerArguments += '-AutoUseFQDN 1';
                $InstallerArguments += '-AutoUseHostname 0';
                $AutoUseFQDN         = $TRUE;
                $AutoUseHostname     = $FALSE;
            } else {
                $InstallerArguments += '-AutoUseFQDN 0';
                $InstallerArguments += '-AutoUseHostname 1';
                $AutoUseFQDN         = $FALSE;
                $AutoUseHostname     = $TRUE;
            }
            $Hostname = Get-IcingaHostname -AutoUseFQDN $AutoUseFQDN -AutoUseHostname $AutoUseHostname -LowerCase 1 -UpperCase 0;
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to convert the hostname into lower case characters? (Result: "{0}")', $Hostname)) -Default 'y').result -eq 1) {
                $InstallerArguments += '-LowerCase 1';
                $InstallerArguments += '-UpperCase 0';
                $LowerCase = $TRUE;
                $UpperCase = $FALSE;
            } else {
                $Hostname = Get-IcingaHostname -AutoUseFQDN $AutoUseFQDN -AutoUseHostname $AutoUseHostname -LowerCase 0 -UpperCase 1;
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to convert the hostname into upper case characters? (Result: "{0}")', $Hostname)) -Default 'y').result -eq 1) {
                    $InstallerArguments += '-LowerCase 0';
                    $InstallerArguments += '-UpperCase 1';
                    $LowerCase = $FALSE;
                    $UpperCase = $TRUE;
                } else {
                    $InstallerArguments += '-LowerCase 0';
                    $InstallerArguments += '-UpperCase 0';
                    $LowerCase = $FALSE;
                    $UpperCase = $FALSE;
                }
            }
            $Hostname = Get-IcingaHostname -AutoUseFQDN $AutoUseFQDN -AutoUseHostname $AutoUseHostname -LowerCase $LowerCase -UpperCase $UpperCase;
        } else {
            $Hostname = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the hostname to use' -Default 'v').answer;
        }
    } else {
        if ($AutoUseFQDN -Or $AutoUseHostname) {
            $Hostname = Get-IcingaHostname -AutoUseFQDN $AutoUseFQDN -AutoUseHostname $AutoUseHostname -LowerCase $LowerCase -UpperCase $UpperCase;
        }
    }

    Write-IcingaConsoleNotice ([string]::Format('Using hostname "{0}" for the Icinga Agent configuration', $Hostname));

    $IcingaAgent = Get-IcingaAgentInstallation;
    if ($IcingaAgent.Installed -eq $FALSE) {
        if ([string]::IsNullOrEmpty($PackageSource)) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the Icinga Agent now?' -Default 'y').result -eq 1) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to use a different package source? (Defaults: "https://packages.icinga.com/windows/")' -Default 'n').result -eq 0) {
                    $PackageSource = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your package source' -Default 'v').answer;
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                } else {
                    $PackageSource = 'https://packages.icinga.com/windows/'
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                }

                Write-IcingaConsoleNotice ([string]::Format('Using package source "{0}" for the Icinga Agent package', $PackageSource));
                $AllowVersionChanges = $TRUE;
                $InstallerArguments += '-AllowVersionChanges 1';

                if ([string]::IsNullOrEmpty($AgentVersion)) {
                    $AgentVersion = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the version you want to install ("release", "snapshot" or a specific version like "2.11.3")' -Default 'v' -DefaultInput 'release').answer;
                    $InstallerArguments += "-AgentVersion '$AgentVersion'";

                    Write-IcingaConsoleNotice ([string]::Format('Installing Icinga version: "{0}"', $AgentVersion));
                }
            } else {
                $AllowVersionChanges = $FALSE;
                $InstallerArguments += '-AllowVersionChanges 0';
                $InstallerArguments += "-AgentVersion '$AgentVersion'";
                $AgentVersion        = '';
            }
        }
    } else {
        if ($null -eq $UpdateAgent) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'The Icinga Agent is already installed. Would you like to update it?' -Default 'y').result -eq 1) {
                $UpdateAgent = 1;
                $AllowVersionChanges = $TRUE;
                $InstallerArguments += '-AllowVersionChanges 1';
            } else {
                $UpdateAgent = 0;
                $AllowVersionChanges = $FALSE;
                $InstallerArguments += '-AllowVersionChanges 0';
            }
            $InstallerArguments += "-UpdateAgent $UpdateAgent";
        }

        if ($UpdateAgent -eq 1) {
            if ([string]::IsNullOrEmpty($AgentVersion)) {
                $AgentVersion = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the version you want to install ("release", "snapshot" or a specific version like "2.11.3")' -Default 'v' -DefaultInput 'release').answer;
                $InstallerArguments += "-AgentVersion '$AgentVersion'";

                Write-IcingaConsoleNotice ([string]::Format('Updating/Downgrading Icinga 2 Agent to version: "{0}"', $AgentVersion));
            }

            if ([string]::IsNullOrEmpty($PackageSource)) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to use a different package source then "https://packages.icinga.com/windows/" ?' -Default 'n').result -eq 0) {
                    $PackageSource = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your package source' -Default 'v').answer;
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                } else {
                    $PackageSource = 'https://packages.icinga.com/windows/'
                    $InstallerArguments += "-PackageSource '$PackageSource'";
                }
            }
        }
    }

    if ($Endpoints.Count -eq 0) {
        $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the parent node(s) separated by "," (Examples: "master1, master2" or "master1.example.com, master2.example.com")' -Default 'v').answer;
        $Endpoints = ($ArrayString.Replace(' ', '')).Split(',');
        $InstallerArguments += ("-Endpoints " + ([string]::Join(',', $Endpoints)));
    }

    if ($null -eq $CAPort) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Are you using another port than 5665 for Icinga communication?' -Default 'n').result -eq 0) {
            $CAPort = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the port for Icinga communication' -Default 'v' -DefaultInput '5665').answer;
            $InstallerArguments += "-CAPort $CAPort";
        } else {
            $InstallerArguments += "-CAPort 5665";
            $CAPort = 5665;
        }
    }

    [bool]$CanConnectToParent = $FALSE;

    if ($null -eq $AcceptConnections) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt "Is this Agent able to connect to its parent node(s)?" -Default 'y').result -eq 1) {
            $CanConnectToParent = $TRUE;
            $AcceptConnections = 0;
            $InstallerArguments += ("-AcceptConnections 0");
        } else {
            $AcceptConnections = 1;
            $InstallerArguments += ("-AcceptConnections 1");
        }
    } else {
        if ((Test-IcingaWizardArgument -Argument 'AcceptConnections') -eq $FALSE) {
            $InstallerArguments += ([string]::Format('-AcceptConnections {0}', [int]$AcceptConnections));
        }

        if ($AcceptConnections -eq $FALSE) {
            $CanConnectToParent = $TRUE;
        }
    }

    if ($null -eq $AddFirewallRule -And $CanConnectToParent -eq $FALSE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to open the Windows Firewall for incoming traffic on Port "{0}"?', $CAPort)) -Default 'y').result -eq 1) {
            $InstallerArguments += "-AddFirewallRule 1";
            $AddFirewallRule = $TRUE;
        } else {
            $InstallerArguments += "-AddFirewallRule 0";
            $AddFirewallRule = $FALSE;
        }
    } else {
        if ($CanConnectToParent -eq $TRUE) {
            $InstallerArguments += "-AddFirewallRule 0";
            $AddFirewallRule = $FALSE;
        }
    }

    if ($null -eq $ConvertEndpointIPConfig -And $CanConnectToParent -eq $TRUE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to convert parent node(s) connection data to IP adresses?' -Default 'y').result -eq 1) {
            $InstallerArguments     += "-ConvertEndpointIPConfig 1";
            $ConvertEndpointIPConfig = $TRUE;
            if ($EndpointConnections.Count -eq 0) {
                $EndpointsConversion = Convert-IcingaEndpointsToIPv4 -NetworkConfig $Endpoints.Split(',');
            } else {
                $EndpointsConversion = Convert-IcingaEndpointsToIPv4 -NetworkConfig $EndpointConnections;
            }
            if ($EndpointsConversion.HasErrors) {
                Write-IcingaConsoleWarning -Message 'Not all of your endpoint connection data could be resolved. These endpoints were dropped: {0}' -Objects ([string]::Join(', ', $EndpointsConversion.Unresolved));
            }
            $EndpointConnections     = $EndpointsConversion.Network;
        } else {
            $InstallerArguments     += "-ConvertEndpointIPConfig 0";
            $ConvertEndpointIPConfig = $FALSE;
        }
    }

    if ($EndpointConnections.Count -eq 0 -And $AcceptConnections -eq 0) {
        $NetworkDefault = '';
        foreach ($Endpoint in $Endpoints) {
            $NetworkDefault += [string]::Format('[{0}]:{1},', $Endpoint, $CAPort);
        }
        if ([string]::IsNullOrEmpty($NetworkDefault) -eq $FALSE) {
            $NetworkDefault = $NetworkDefault.Substring(0, $NetworkDefault.Length - 1);
        }
        $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the network destinations this Agent will connect to separated by "," (Examples: 192.168.0.1, [192.168.0.2]:5665, [icinga2.example.com]:5665)' -Default 'v' -DefaultInput $NetworkDefault).answer;
        $EndpointConnections = ($ArrayString.Replace(' ', '')).Split(',');

        if ($ConvertEndpointIPConfig) {
            $EndpointsConversion = Convert-IcingaEndpointsToIPv4 -NetworkConfig $EndpointConnections.Split(',');
            if ($EndpointsConversion.HasErrors -eq $FALSE) {
                $EndpointConnections = $EndpointsConversion.Network;
            }
        }
        $InstallerArguments += ("-EndpointConnections " + ([string]::Join(',', $EndpointConnections)));
    } elseif ($EndpointConnections.Count -ne 0 -And $AcceptConnections -eq 0 -And $ConvertEndpointIPConfig) {
        $EndpointsConversion = Convert-IcingaEndpointsToIPv4 -NetworkConfig $EndpointConnections;
        if ($EndpointsConversion.HasErrors) {
            Write-IcingaConsoleWarning -Message 'Not all of your endpoint connection data could be resolved. These endpoints were dropped: {0}' -Objects ([string]::Join(', ', $EndpointsConversion.Unresolved));
        }
        $EndpointConnections = $EndpointsConversion.Network;
    }

    if ([string]::IsNullOrEmpty($ParentZone)) {
        $ParentZone = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify the parent zone this Agent will connect to' -Default 'v' -DefaultInput 'master').answer;
        $InstallerArguments += "-ParentZone $ParentZone";
    }

    if ($null -eq $AddDirectorGlobal) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to add the global zone "director-global"?' -Default 'y').result -eq 1) {
            $AddDirectorGlobal = $TRUE;
            $InstallerArguments += ("-AddDirectorGlobal 1");
        } else {
            $AddDirectorGlobal = $FALSE;
            $InstallerArguments += ("-AddDirectorGlobal 0");
        }
    }

    if ($AddDirectorGlobal) {
        $GlobalZoneConfig += 'director-global';
    }

    if ($null -eq $AddGlobalTemplates) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to add the global zone "global-templates"?' -Default 'y').result -eq 1) {
            $AddGlobalTemplates = $TRUE;
            $InstallerArguments += ("-AddGlobalTemplates 1");
        } else {
            $AddGlobalTemplates = $FALSE;
            $InstallerArguments += ("-AddGlobalTemplates 0");
        }
    }

    if ($AddGlobalTemplates) {
        $GlobalZoneConfig += 'global-templates';
    }

    if ($null -eq $GlobalZones) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to add custom global zones?' -Default 'n').result -eq 0) {
            $ArrayString = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please specify your additional zones seperated by "," (Example: "global-zone1, global-zone2")' -Default 'v').answer;
            if ([string]::IsNullOrEmpty($ArrayString) -eq $FALSE) {
                $GlobalZones = ($ArrayString.Replace(' ', '')).Split(',')
                $GlobalZoneConfig += $GlobalZones;
                $InstallerArguments += ("-GlobalZones " + ([string]::Join(',', $GlobalZones)));
            } else {
                $GlobalZones = @();
                $InstallerArguments += ("-GlobalZones @()");
            }
        } else {
            $GlobalZones = @();
            $InstallerArguments += ("-GlobalZones @()");
        }
    } else {
        $GlobalZoneConfig += $GlobalZones;
    }

    if ($CanConnectToParent) {
        if ([string]::IsNullOrEmpty($CAEndpoint)) {
            $CAEndpoint = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the connection data of the parent node that handles certificate requests' -Default 'v' -DefaultInput (Get-IPConfigFromString $EndpointConnections[0]).address).answer;
            $InstallerArguments += "-CAEndpoint $CAEndpoint";
        }
        if ([string]::IsNullOrEmpty($Ticket) -And $null -eq $EmptyTicket) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you have a PKI Ticket to sign your certificate request?' -Default 'y').result -eq 1) {
                $Ticket = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter your PKI Ticket' -Default 'v').answer;
                if ([string]::IsNullOrEmpty($Ticket)) {
                    $InstallerArguments += "-EmptyTicket 1"
                } else {
                    $InstallerArguments += "-EmptyTicket 0"
                }
                $InstallerArguments += "-Ticket '$Ticket'";
            } else {
                $InstallerArguments += "-Ticket ''";
                $InstallerArguments += "-EmptyTicket 1"
            }
        } else {
            if ([string]::IsNullOrEmpty($Ticket)) {
                $InstallerArguments += "-Ticket ''";
            } else {
                $InstallerArguments += "-Ticket '$Ticket'";
            }
            if ($null -eq $EmptyTicket) {
                $InstallerArguments += "-EmptyTicket 1"
            } else {
                $InstallerArguments += "-EmptyTicket $EmptyTicket"
            }
        }
    } else {
        if ([string]::IsNullOrEmpty($CAFile) -And $null -eq $EmptyCA) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is your public Icinga 2 CA (ca.crt) available on a local, network or web share?' -Default 'y').result -eq 1) {
                $CAFile = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please provide the full path to your ca.crt file (Examples: "C:\icinga2\ca.crt", "https://icinga.example.com/ca.crt"' -Default 'v').answer;
                if ([string]::IsNullOrEmpty($CAFile)) {
                    $InstallerArguments += "-EmptyCA 1"
                } else {
                    $InstallerArguments += "-EmptyCA 0"
                }
                $InstallerArguments += "-CAFile '$CAFile'";
            } else {
                $InstallerArguments += "-CAFile ''";
                $InstallerArguments += "-EmptyCA 1";
                $EmptyCA             = $TRUE;
            }
        } else {
            if ([string]::IsNullOrEmpty($CAFile)) {
                $InstallerArguments += "-CAFile ''";
            } else {
                $InstallerArguments += "-CAFile '$CAFile'";
            }
            if ($null -eq $EmptyCA) {
                $InstallerArguments += "-EmptyCA 1"
            } else {
                $InstallerArguments += "-EmptyCA $EmptyCA"
            }
        }
    }

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to change the user of the Icinga Agent service? (Defaults: "NT Authority\NetworkService")' -Default 'n').result -eq 0) {
            $ServiceUser = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter a custom user for the Icinga Agent service' -Default 'v' -DefaultInput 'NT Authority\NetworkService').answer;
            $InstallerArguments += "-ServiceUser $ServiceUser";
            if ($null -eq $ServicePass) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Does your Icinga Agent service user require a password to login? (Not required for System users)' -Default 'y').result -eq 1) {
                    $ServicePass = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the password for your service user' -Secure -Default 'v').answer;
                    $InstallerArguments += "-ServicePass $ServicePass";
                } else {
                    $ServicePass         = $null
                    $InstallerArguments += '-ServicePass $null';
                }
            }
        } else {
            $InstallerArguments += "-ServiceUser 'NT Authority\NetworkService'";
            $ServiceUser = 'NT Authority\NetworkService';
        }
    }

    if ($null -eq $InstallFrameworkPlugins) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the Icinga PowerShell Plugins?' -Default 'y').result -eq 1) {
            $result = Install-IcingaFrameworkPlugins -PluginsUrl $PluginsUrl;
            $PluginsUrl = $result.PluginUrl;
            $InstallerArguments += "-InstallFrameworkPlugins 1";
            $InstallerArguments += "-PluginsUrl '$PluginsUrl'";
        } else {
            $InstallerArguments += "-InstallFrameworkPlugins 0";
        }
    } elseif ($InstallFrameworkPlugins -eq 1) {
        $result = Install-IcingaFrameworkPlugins -PluginsUrl $PluginsUrl;
        $InstallerArguments += "-InstallFrameworkPlugins 1";
        $InstallerArguments += "-PluginsUrl '$PluginsUrl'";
    } else {
        if ((Test-IcingaWizardArgument -Argument 'InstallFrameworkPlugins') -eq $FALSE) {
            $InstallerArguments += "-InstallFrameworkPlugins 0";
        }
    }

    if ($null -eq $InstallFrameworkService) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to install the Icinga PowerShell Framework as a service?' -Default 'y').result -eq 1) {
            $result = Get-IcingaFrameworkServiceBinary;
            $InstallerArguments += "-InstallFrameworkService 1";
            $InstallerArguments += [string]::Format("-FrameworkServiceUrl '{0}'", $result.FrameworkServiceUrl);
            $InstallerArguments += [string]::Format("-ServiceDirectory '{0}'", $result.ServiceDirectory);
            $InstallerArguments += [string]::Format("-ServiceBin '{0}'", $result.ServiceBin);
            $ServiceBin = $result.ServiceBin;
        } else {
            $InstallerArguments += "-InstallFrameworkService 0";
        }
    } elseif ($InstallFrameworkService -eq $TRUE) {
        $result     = Get-IcingaFrameworkServiceBinary -FrameworkServiceUrl $FrameworkServiceUrl -ServiceDirectory $ServiceDirectory;
        $ServiceBin = $result.ServiceBin;
    } else {
        $InstallerArguments += "-InstallFrameworkService 0";
    }

    if ($InstallerArguments.Count -ne 0) {
        $InstallerArguments += "-RunInstaller";
        Write-IcingaConsoleNotice 'The wizard is complete. These are the configured settings:';

        Write-IcingaConsolePlain '========';
        Write-IcingaConsolePlain ($InstallerArguments | Out-String);
        Write-IcingaConsolePlain '========';

        if (-Not $RunInstaller) {
            if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Is this configuration correct?' -Default 'y').result -eq 1) {
                if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you want to run the installer now? (Otherwise only the configuration command will be printed)' -Default 'y').result -eq 1) {
                    Write-IcingaConsoleNotice 'To execute your Icinga Agent installation based on your answers again on this or another machine, simply run this command:';

                    $RunInstaller = $TRUE;
                } else {
                    Write-IcingaConsoleNotice 'To execute your Icinga Agent installation based on your answers, simply run this command:';
                }
            } else {
                Write-IcingaConsoleNotice 'Please run the wizard again to modify your answers or modify the command below:';
            }
        }
        Get-IcingaAgentInstallCommand -InstallerArguments $InstallerArguments -PrintConsole;
    }

    if ($RunInstaller) {
        if ((Test-IcingaAgentNETFrameworkDependency) -eq $FALSE) {
            Write-IcingaConsoleError -Message 'You cannot install the Icinga Agent on this system as the required .NET Framework version is not installed. Please install .NET Framework 4.6.0 or later and use the above provided install arguments to try again.'
            return;
        }

        if ((Install-IcingaAgent -Version $AgentVersion -Source $PackageSource -AllowUpdates $AllowVersionChanges -InstallDir $InstallDir) -Or $Reconfigure) {
            Reset-IcingaAgentConfigFile;
            Move-IcingaAgentDefaultConfig;
            Set-IcingaAgentNodeName -Hostname $Hostname;
            Set-IcingaAgentServiceUser -User $ServiceUser -Password $ServicePass -SetPermission | Out-Null;
            if ($InstallFrameworkService) {
                Install-IcingaForWindowsService -Path $ServiceBin -User $ServiceUser -Password $ServicePass | Out-Null;
            }
            Register-IcingaBackgroundDaemon -Command 'Start-IcingaServiceCheckDaemon';
            Install-IcingaAgentBaseFeatures;
            $CertsInstalled = Install-IcingaAgentCertificates -Hostname $Hostname -Endpoint $CAEndpoint -Port $CAPort -CACert $CAFile -Ticket $Ticket;
            Write-IcingaAgentApiConfig -Port $CAPort;
            if ($EmptyCA -eq $TRUE -And $CertsInstalled -eq $FALSE) {
                Disable-IcingaAgentFeature 'api';
                Write-IcingaConsoleWarning `
                    -Message '{0}{1}{2}{3}{4}' `
                    -Objects (
                        'Your Icinga Agent API feature has been disabled. Please provide either your ca.crt ',
                        'or connect to a parent node for certificate requests. You can run "Install-IcingaAgentCertificates" ',
                        'with your configuration to properly create the host certificate and a valid certificate request. ',
                        'After this you can enable the API feature by using "Enable-IcingaAgentFeature api" and restart the ',
                        'Icinga Agent service "Restart-IcingaService icinga2"'
                    );
            }
            Write-IcingaAgentZonesConfig -Endpoints $Endpoints -EndpointConnections $EndpointConnections -ParentZone $ParentZone -GlobalZones $GlobalZoneConfig -Hostname $Hostname;
            if ($AddFirewallRule) {
                # First cleanup the system by removing all old Firewalls
                Enable-IcingaFirewall -IcingaPort $CAPort -Force;
            }
            Test-IcingaAgent;
            if ($InstallFrameworkService) {
                Restart-IcingaService 'icingapowershell';
            }
            Restart-IcingaService 'icinga2';
        }
    }
}

function Add-InstallerArgument()
{
    param(
        $InstallerArguments,
        [string]$Key,
        $Value,
        [switch]$ReturnValue
    );

    [bool]$IsArray = $Value -is [array];

    # Check for arrays
    if ($IsArray) {
        [array]$NewArray = @();
        foreach ($entry in $Value) {
            $NewArray += Add-InstallerArgument -Value $entry -ReturnValue;
        }

        if ($ReturnValue) {
            return ([string]::Join(',', $NewArray));
        }

        $InstallerArguments += [string]::Format(
            '-{0} {1}',
            $Key,
            [string]::Join(',', $NewArray)
        );

        return $InstallerArguments;
    }

    # Check for integers
    if (Test-Numeric $Value) {
        if ($ReturnValue) {
            return $Value;
        }

        $InstallerArguments += [string]::Format(
            '-{0} {1}',
            $Key,
            $Value
        );

        return $InstallerArguments;
    }

    # Check for integer conversion
    $IntValue = ConvertTo-Integer -Value $Value;
    if ([string]$Value -ne [string]$IntValue) {
        if ($ReturnValue) {
            return $IntValue;
        }

        $InstallerArguments += [string]::Format(
            '-{0} {1}',
            $Key,
            $IntValue
        );

        return $InstallerArguments;
    }

    $Type     = $Value.GetType().Name;
    $NewValue = $null;

    if ($Type -eq 'String') {
        $NewValue = [string]::Format(
            "'{0}'",
            $Value
        );

        if ($ReturnValue) {
            return $NewValue;
        }

        $InstallerArguments += [string]::Format(
            '-{0} {1}',
            $Key,
            $NewValue
        );

        return $InstallerArguments;
    }
}

function Test-IcingaWizardArgument()
{
    param(
        [string]$Argument
    );

    foreach ($entry in $InstallerArguments) {
        if ($entry -like [string]::Format('-{0} *', $Argument)) {
            return $TRUE;
        }
    }

    return $FALSE;
}

function Set-IcingaWizardArgument()
{
    param(
        [hashtable]$DirectorArgs,
        [string]$WizardArg,
        $Value,
        $Default                 = $null,
        $InstallerArguments
    );

    if ($DirectorArgs.Overrides.ContainsKey($WizardArg)) {

        $InstallerArguments = Add-InstallerArgument `
            -InstallerArguments $InstallerArguments `
            -Key $WizardArg `
            -Value $DirectorArgs.Overrides[$WizardArg];

        return @{
            'Value' = $DirectorArgs.Overrides[$WizardArg];
            'Args'  = $InstallerArguments;
        };
    }

    $RetValue = $null;

    if ($DirectorArgs.Arguments.ContainsKey($WizardArg)) {
        $RetValue = $DirectorArgs.Arguments[$WizardArg];
    } else {

        if ($null -ne $Value -And [string]::IsNullOrEmpty($Value) -eq $FALSE) {
            $InstallerArguments = Add-InstallerArgument `
                -InstallerArguments $InstallerArguments `
                -Key $WizardArg `
                -Value $Value;

            return @{
                'Value' = $Value;
                'Args'  = $InstallerArguments;
            };
        } else {
            return @{
                'Value' = $Default;
                'Args'  = $InstallerArguments;
            };
        }
    }

    if ([string]::IsNullOrEmpty($Value) -eq $FALSE) {

        $InstallerArguments = Add-InstallerArgument `
            -InstallerArguments $InstallerArguments `
            -Key $WizardArg `
            -Value $Value;

        return @{
            'Value' = $Value;
            'Args'  = $InstallerArguments;
        };
    }

    return @{
        'Value' = $RetValue;
        'Args'  = $InstallerArguments;
    };
}
function Get-IcingaAgentInstallCommand()
{
    param(
        $InstallerArguments,
        [switch]$PrintConsole
    );

    [string]$Installer = (
        [string]::Format(
            'Start-IcingaAgentInstallWizard {0}',
            ([string]::Join(' ', $InstallerArguments))
        )
    );

    if ($PrintConsole) {
        Write-IcingaConsolePlain '===='
        Write-IcingaConsolePlain $Installer;
        Write-IcingaConsolePlain '===='
    } else {
        return $Installer;
    }
}

function Read-IcingaAgentDebugLogFile()
{
    $Logfile = Join-Path -Path (Get-IcingaAgentLogDirectory) -ChildPath 'debug.log';
    if ((Test-Path $Logfile) -eq $FALSE) {
        Write-IcingaConsoleError 'Icinga 2 debug logfile not present. Unable to load it';
        return;
    }

    Get-Content -Path $Logfile -Tail 20 -Wait;
}

function Read-IcingaAgentLogFile()
{
    $Logfile = Join-Path -Path (Get-IcingaAgentLogDirectory) -ChildPath 'icinga2.log';
    if ((Test-Path $Logfile) -eq $FALSE) {
        Write-IcingaConsoleError 'Icinga 2 logfile not present. Unable to load it';
        return;
    }

    Get-Content -Path $Logfile -Tail 20 -Wait;
}

function Set-IcingaAcl()
{
    param(
        [string]$Directory
    );

    if (-Not (Test-Path $Directory)) {
        throw 'Failed to set Acl for directory. Directory does not exist';
        return;
    }

    $DirectoryAcl        = (Get-Item -Path $Directory).GetAccessControl('Access');
    $DirectoryAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        (Get-IcingaServiceUser),
        'Modify',
        'ContainerInherit,ObjectInherit',
        'None',
        'Allow'
    );

    $DirectoryAcl.SetAccessRule($DirectoryAccessRule);
    Set-Acl -Path $Directory -AclObject $DirectoryAcl;
    Test-IcingaAcl -Directory $Directory -WriteOutput | Out-Null;
}

function Set-IcingaAgentNodeName()
{
    param(
        $Hostname
    );

    if ([string]::IsNullOrEmpty($Hostname)) {
        throw 'You have to specify a hostname in order to change the Icinga Agent NodeName';
    }

    $ConfigDir     = Get-IcingaAgentConfigDirectory;
    $ConstantsConf = Join-Path -Path $ConfigDir -ChildPath 'constants.conf';

    $ConfigContent = Get-Content -Path $ConstantsConf;

    if ($ConfigContent.Contains('//const NodeName = "localhost"')) {
        $ConfigContent = $ConfigContent.Replace(
            '//const NodeName = "localhost"',
            [string]::Format('const NodeName = "{0}"', $Hostname)
        );
    } else {
        [string]$NewConfigContent = '';
        foreach ($line in $ConfigContent) {
            if ($line.Contains('const NodeName =')) {
                $line = [string]::Format('const NodeName = "{0}"', $Hostname);
            }
            $NewConfigContent = [string]::Format('{0}{1}{2}', $NewConfigContent, $line, "`r`n");
        }
        $ConfigContent = $NewConfigContent;
    }

    Set-Content -Path $ConstantsConf -Value $ConfigContent;

    Write-IcingaConsoleNotice ([string]::Format('Your hostname was successfully changed to "{0}"', $Hostname));
}

function Set-IcingaAgentServicePermission()
{
    if (Test-IcingaAgentServicePermission -Silent) {
        Write-IcingaConsoleNotice 'The Icinga Service User already has permission to run as service';
        return;
    }

    $SystemPermissions = New-IcingaTemporaryFile;
    $ServiceUser       = Get-IcingaServiceUser;
    $ServiceUserSID    = Get-IcingaUserSID $ServiceUser;
    $SystemContent     = Get-IcingaAgentServicePermission;
    $NewSystemContent  = @();

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'There is no user assigned to the Icinga 2 service or the service is not yet installed';
        return $FALSE;
    }

    foreach ($line in $SystemContent) {
        if ($line -like '*SeServiceLogonRight*') {
            $line = [string]::Format('{0},*{1}', $line, $ServiceUserSID);
        }

        $NewSystemContent += $line;
    }

    Set-Content -Path "$SystemPermissions.inf" -Value $NewSystemContent;

    $SystemOutput = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/import /cfg "{0}.inf" /db "{0}.sdb"', $SystemPermissions));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to import system permission information: {0}', $SystemOutput.Message));
        return $null;
    }

    $SystemOutput = Start-IcingaProcess -Executable 'secedit.exe' -Arguments ([string]::Format('/configure /cfg "{0}.inf" /db "{0}.sdb"', $SystemPermissions));

    if ($SystemOutput.ExitCode -ne 0) {
        throw ([string]::Format('Unable to configure system permission information: {0}', $SystemOutput.Message));
        return $null;
    }

    Remove-Item $SystemPermissions*;

    Test-IcingaAgentServicePermission | Out-Null;
}

function Set-IcingaAgentServiceUser()
{
    param (
        [string]$User,
        [securestring]$Password,
        [string]$Service        = 'icinga2',
        [switch]$SetPermission
    );

    if ([string]::IsNullOrEmpty($User)) {
        throw 'Please specify a username to modify the service user';
        return $FALSE;
    }

    if ($User.Contains('\') -eq $FALSE) {
        $User = [string]::Format('.\{0}', $User);
    }

    $ArgString = 'config {0} obj= "{1}" password= "{2}"';
    if ($null -eq $Password) {
        $ArgString = 'config {0} obj= "{1}"{2}';
    }

    $Output = Start-IcingaProcess `
        -Executable 'sc.exe' `
        -Arguments ([string]::Format($ArgString, $Service, $User, (ConvertFrom-IcingaSecureString $Password))) `
        -FlushNewLines $TRUE;

    if ($Output.ExitCode -eq 0) {

        if ($SetPermission) {
            Set-IcingaUserPermissions;
        }

        Write-IcingaConsoleNotice 'Service User successfully updated'
        return $TRUE;
    } else {
        Write-IcingaConsoleError ([string]::Format('Failed to update the service user: {0}', $Output.Message));
        return $FALSE;
    }
}

function Set-IcingaUserPermissions()
{
    Set-IcingaAgentServicePermission | Out-Null;
    Set-IcingaAcl "$Env:ProgramData\icinga2\etc";
    Set-IcingaAcl "$Env:ProgramData\icinga2\var";
    Set-IcingaAcl (Get-IcingaCacheDir);
}

function Test-IcingaAcl()
{
    param(
        [string]$Directory,
        [switch]$WriteOutput
    );

    if ([string]::IsNullOrEmpty($Directory) -Or -Not (Test-Path $Directory)) {
        throw 'The specified directory was not found';
    }

    $FolderACL      = Get-Acl $Directory;
    $ServiceUser    = Get-IcingaServiceUser;
    $UserFound      = $FALSE;
    $HasAccess      = $FALSE;
    $ServiceUserSID = Get-IcingaUserSID $ServiceUser;

    foreach ($user in $FolderACL.Access) {
        # Not only check here for the exact name but also for included strings like NT AU or NT-AU or even further later on
        # As the Get-Acl Cmdlet will translate usernames into the own language, resultng in 'NT AUTHORITY\NetworkService' being translated
        # to 'NT-AUTORITÄT\Netzwerkdienst' for example
        $UserSID = $null;
        try {
            $UserSID = Get-IcingaUserSID $user.IdentityReference;
        } catch {
            $UserSID = $null;
        }

        if ($ServiceUserSID -eq $UserSID) {
            $UserFound = $TRUE;
            if (($user.FileSystemRights -Like '*Modify*' -And $user.FileSystemRights -Like '*Synchronize*') -Or $user.FileSystemRights -like '*FullControl*') {
                $HasAccess = $TRUE;
            }
        }
    }

    if ($WriteOutput) {
        [string]$messageFormat = 'Directory "{0}" {1} by the Icinga Service User "{2}"';
        if ($UserFound) {
            if ($HasAccess) {
                Write-IcingaTestOutput -Severity 'Passed' -Message ([string]::Format($messageFormat, $Directory, 'is accessible and writeable', $ServiceUser));
            } else {
                Write-IcingaTestOutput -Severity 'Failed' -Message ([string]::Format($messageFormat, $Directory, 'is accessible but NOT writeable', $ServiceUser));
                Write-IcingaConsolePlain "\_ Please run the following command to fix this issue: Set-IcingaAcl -Directory '$Directory'";
            }
        } else {
            Write-IcingaTestOutput -Severity 'Failed' -Message ([string]::Format($messageFormat, $Directory, 'is not accessible', $ServiceUser));
            Write-IcingaConsolePlain "\_ Please run the following command to fix this issue: Set-IcingaAcl -Directory '$Directory'";
        }
    }

    return $UserFound;
}

function Test-IcingaAgent()
{
    if (Get-Service 'icinga2' -ErrorAction SilentlyContinue) {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent service is installed';
        Test-IcingaAgentServicePermission | Out-Null;
        Test-IcingaAcl "$Env:ProgramData\icinga2\etc" -WriteOutput | Out-Null;
        Test-IcingaAcl "$Env:ProgramData\icinga2\var" -WriteOutput | Out-Null;
        Test-IcingaAcl (Get-IcingaCacheDir) -WriteOutput | Out-Null;
        Test-IcingaAgentConfig | Out-Null;
        if (Test-IcingaAgentFeatureEnabled -Feature 'debuglog') {
            Write-IcingaTestOutput -Severity 'Warning' -Message 'The debug log of the Icinga Agent is enabled. Please keep in mind to disable it once testing is done, as a huge amount of data is generated'
        } else {
            Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent debug log is disabled'
        }
    } else {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'Icinga Agent service is not installed';
    }
}

function Test-IcingaAgentConfig()
{
    param (
        [switch]$WriteStackTrace
    );

    $Binary       = Get-IcingaAgentBinary;
    $ConfigResult = Start-IcingaProcess -Executable $Binary -Arguments 'daemon -C';

    if ($ConfigResult.ExitCode -eq 0) {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'Icinga Agent configuration is valid';
        return $TRUE;
    } else {
        Write-IcingaTestOutput -Severity 'Failed' -Message 'Icinga Agent configuration contains errors. Run this command for getting a detailed error report: "Test-IcingaAgentConfig -WriteStackTrace | Out-Null"';
        if ($WriteStackTrace) {
            Write-IcingaConsolePlain $ConfigResult.Message;
        }
        return $FALSE;
    }
}

function Test-IcingaAgentFeatureEnabled()
{
    param(
        [string]$Feature
    );

    $Features = Get-IcingaAgentFeatures;

    if ($Features.Enabled -Contains $Feature) {
        return $TRUE;
    }

    return $FALSE;
}

<#
.SYNOPSIS
   Test if .NET Framework 4.6.0 or above is installed which is required by
   the Icinga Agent. Returns either true or false - depending on if the
   .NET Framework 4.6.0 or above is installed or not
.DESCRIPTION
   Test if .NET Framework 4.6.0 or above is installed which is required by
   the Icinga Agent. Returns either true or false - depending on if the
   .NET Framework 4.6.0 or above is installed or not
.FUNCTIONALITY
   Test if .NET Framework 4.6.0 or above is installed
.EXAMPLE
   PS>Test-IcingaAgentNETFrameworkDependency;
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
   https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
#>

function Test-IcingaAgentNETFrameworkDependency()
{
    $RegistryContent = Get-ItemProperty -Path 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -ErrorAction SilentlyContinue;

    # We require at least .NET Framework 4.6.0 to be installed on the system
    # Version on Windows 10: 393295
    # Version on any other system: 393297
    # We do only require to check for the Windows 10 version, as the other Windows verions
    # do not cause an issue there then because of how the next versions are iterated

    if ($null -eq $RegistryContent -Or $RegistryContent.Release -lt 393295) {
        if ($null -eq $RegistryContent) {
            $RegistryContent = @{
                'Version' = 'Unknown'
            };
        }
        Write-IcingaConsoleError `
            -Message 'To install the Icinga Agent you will require .NET Framework 4.6.0 or later to be installed on the system. Current installed version: {0}' `
            -Objects $RegistryContent.Version;

        return $FALSE;
    }

    Write-IcingaConsoleNotice `
        -Message 'Found installed .NET Framework version {0}' `
        -Objects $RegistryContent.Version;

    return $TRUE;
}

function Test-IcingaAgentServicePermission()
{
    param(
        [switch]$Silent = $FALSE
    );

    $ServiceUser       = Get-IcingaServiceUser;
    $ServiceUserSID    = Get-IcingaUserSID $ServiceUser;
    $SystemContent     = Get-IcingaAgentServicePermission;
    [bool]$FoundSID    = $FALSE;

    if ($ServiceUser -eq 'NT Authority\SYSTEM') {
        return $TRUE;
    }

    if ([string]::IsNullOrEmpty($ServiceUser)) {
        if (-Not $Silent) {
            Write-IcingaTestOutput -Severity 'Failed' -Message 'There is no user assigned to the Icinga 2 service or the service is not yet installed';
        }
        return $FALSE;
    }

    foreach ($line in $SystemContent) {
        if ($line -like '*SeServiceLogonRight*') {
            $Index           = $line.IndexOf('= ') + 2;
            [string]$SIDs    = $line.Substring($Index, $line.Length - $Index);
            [array]$SIDArray = $SIDs.Split(',');

            foreach ($sid in $SIDArray) {
                if ($sid -like "*$ServiceUserSID" -Or $sid -eq $ServiceUser) {
                    $FoundSID = $TRUE;
                    break;
                }
            }
        }
        if ($FoundSID) {
            break;
        }
    }

    if (-Not $Silent) {
        if ($FoundSID) {
            Write-IcingaTestOutput -Severity 'Passed' -Message ([string]::Format('The specified user "{0}" is allowed to run as service', $ServiceUser));
        } else {
            Write-IcingaTestOutput -Severity 'Failed' -Message ([string]::Format('The specified user "{0}" is not allowed to run as service', $ServiceUser));
        }
    }

    return $FoundSID;
}

function Write-IcingaAgentApiConfig()
{
    param(
        [int]$Port = 5665
    );

    [string]$ApiConf = '';

    $ApiConf = [string]::Format('{0}object ApiListener "api" {1}{2}', $ApiConf, '{', "`r`n");
    $ApiConf = [string]::Format('{0}    accept_commands = true;{1}', $ApiConf, "`r`n");
    $ApiConf = [string]::Format('{0}    accept_config = true;{1}', $ApiConf, "`r`n");
    $ApiConf = [string]::Format('{0}    bind_host = "::";{1}', $ApiConf, "`r`n");
    $ApiConf = [string]::Format('{0}    bind_port = {1};{2}', $ApiConf, $Port, "`r`n");
    $ApiConf = [string]::Format('{0}{1}{2}{2}', $ApiConf, '}', "`r`n");

    $ApiConf = $ApiConf.Substring(0, $ApiConf.Length - 4);

    Set-Content -Path (Join-Path -Path (Get-IcingaAgentConfigDirectory) -ChildPath 'features-available\api.conf') -Value $ApiConf;
    Write-IcingaConsoleNotice 'Api configuration has been written successfully';
}

function Write-IcingaAgentObjectList()
{
    param(
        [string]$Path
    );

    if ([string]::IsNullOrEmpty($Path)) {
        throw 'Please specify a path to write the Icinga objects to';
    }

    $ObjectList = Get-IcingaAgentObjectList;

    Set-Content -Path $Path -Value $ObjectList;
}

function Write-IcingaAgentZonesConfig()
{
    param(
        [array]$Endpoints           = @(),
        [array]$EndpointConnections = @(),
        [string]$ParentZone         = '',
        [array]$GlobalZones         = @(),
        [string]$Hostname           = ''
    );

    if ($Endpoints.Count -eq 0) {
        throw 'Please properly specify your endpoint names';
    }

    if ([string]::IsNullOrEmpty($ParentZone)) {
        throw 'Please specify a parent zone this agent shall connect to / receives connections from';
    }

    if ([string]::IsNullOrEmpty($Hostname)) {
        throw 'Please specify hostname for this agent configuration';
    }

    [int]$Index        = 0;
    [string]$ZonesConf = '';

    $ZonesConf = [string]::Format('{0}object Endpoint "{1}" {2}{3}', $ZonesConf, $Hostname, '{', "`r`n");
    $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");

    foreach ($endpoint in $Endpoints) {
        $ZonesConf = [string]::Format('{0}object Endpoint "{1}" {2}{3}', $ZonesConf, $endpoint, '{', "`r`n");
        if ($EndpointConnections.Count -ne 0) {
            $ConnectionConfig = Get-IPConfigFromString -IPConfig ($EndpointConnections[$Index]);
            $ZonesConf = [string]::Format('{0}    host = "{1}";{2}', $ZonesConf, $ConnectionConfig.address, "`r`n");
            if ([string]::IsNullOrEmpty($ConnectionConfig.port) -eq $FALSE) {
                $ZonesConf = [string]::Format('{0}    port = "{1}";{2}', $ZonesConf, $ConnectionConfig.port, "`r`n");
            }
        }
        $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");
        $Index += 1;
    }

    [string]$EndpointString = '';
    foreach ($endpoint in $Endpoints) {
        $EndpointString = [string]::Format(
            '{0}"{1}", ',
            $EndpointString,
            $endpoint
        );
    }
    $EndpointString = $EndpointString.Substring(0, $EndpointString.Length - 2);

    $ZonesConf = [string]::Format('{0}object Zone "{1}" {2}{3}', $ZonesConf, $ParentZone, '{', "`r`n");
    $ZonesConf = [string]::Format('{0}    endpoints = [ {1} ];{2}', $ZonesConf, $EndpointString, "`r`n");
    $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");

    $ZonesConf = [string]::Format('{0}object Zone "{1}" {2}{3}', $ZonesConf, $Hostname, '{', "`r`n");
    $ZonesConf = [string]::Format('{0}    parent = "{1}";{2}', $ZonesConf, $ParentZone, "`r`n");
    $ZonesConf = [string]::Format('{0}    endpoints = [ "{1}" ];{2}', $ZonesConf, $Hostname, "`r`n");
    $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");

    foreach ($zone in $GlobalZones) {
        $ZonesConf = [string]::Format('{0}object Zone "{1}" {2}{3}', $ZonesConf, $zone, '{', "`r`n");
        $ZonesConf = [string]::Format('{0}    global = true;{1}', $ZonesConf, "`r`n");
        $ZonesConf = [string]::Format('{0}{1}{2}{2}', $ZonesConf, '}', "`r`n");
    }

    $ZonesConf = $ZonesConf.Substring(0, $ZonesConf.Length - 4);

    Set-Content -Path (Join-Path -Path (Get-IcingaAgentConfigDirectory) -ChildPath 'zones.conf') -Value $ZonesConf;
    Write-IcingaConsoleNotice 'Icinga Agent zones.conf has been written successfully';
}

function Write-IcingaTestOutput()
{
    param(
        [ValidateSet('Passed', 'Warning', 'Failed')]
        $Severity,
        $Message
    );

    $Color = 'Green';

    Switch ($Severity) {
        'Passed' {
            $Color = 'Green';
            break;
        };
        'Warning' {
            $Color = 'Yellow';
            break;
        };
        'Failed' {
            $Color = 'Red';
            break;
        };
    }

    Write-Host '[' -NoNewline;
    Write-Host $Severity -ForegroundColor $Color -NoNewline;
    Write-Host ']:' $Message;
}

function Install-Icinga()
{
    param (
        [string]$InstallCommand = $null,
        [string]$InstallFile    = ''
    );

    if ($null -eq $global:Icinga) {
        $global:Icinga = @{ };
    }

    if ($global:Icinga.ContainsKey('InstallWizard') -eq $FALSE) {
        $global:Icinga.Add(
            'InstallWizard', @{
                'AdminShell'      = (Test-AdministrativeShell);
                'LastInput'       = '';
                'LastNotice'      = '';
                'LastError'       = '';
                'HeaderPreview'   = '';
                'LastParent'      = [System.Collections.ArrayList]@();
                'LastValues'      = @();
                'Config'          = @{ };
                'ConfigSwap'      = @{ };
                'ParentConfig'    = $null;
                'Menu'            = 'Install-Icinga';
                'NextCommand'     = '';
                'NextArguments'   = $null;
                'HeaderSelection' = $null;
                'DisplayAdvanced' = $FALSE;
                'ShowAdvanced'    = $FALSE;
                'ShowHelp'        = $FALSE;
                'DeleteValues'    = $FALSE;
                'HeaderPrint'     = $FALSE;
                'JumpToSummary'   = $FALSE;
                'Closing'         = $FALSE;
            }
        );
    }

    if ([string]::IsNullOrEmpty($InstallFile) -eq $FALSE) {
        $InstallCommand = Read-IcingaFileContent -File $InstallFile;
    }

    # Use our install command to configure everything
    if ([string]::IsNullOrEmpty($InstallCommand) -eq $FALSE) {

        Disable-IcingaFrameworkConsoleOutput;

        # Add our "old" swap internally
        $OldConfigSwap = Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap';

        [hashtable]$IcingaConfiguration = Convert-IcingaForwindowsManagementConsoleJSONConfig -Config (ConvertFrom-Json -InputObject $InstallCommand);

        # First run our configuration values
        Invoke-IcingaForWindowsManagementConsoleCustomConfig -IcingaConfiguration $IcingaConfiguration;

        # In case we use the director, we require to first fetch all basic values from the Self-Service API then
        # require to register the host to fet the remaining content
        if ($IcingaConfiguration.ContainsKey('IfW-DirectorSelfServiceKey') -And $IcingaConfiguration.ContainsKey('IfW-DirectorUrl')) {
            Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate;
            Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate -Register;
            Disable-IcingaFrameworkConsoleOutput;
        } else {
            # Now load all remaining values we haven't set and define the defaults
            Add-IcingaForWindowsInstallationAdvancedEntries;
        }

        # Now apply our configuration again to ensure the defaults are overwritten again
        # Suite a mess, but we can improve this later
        Invoke-IcingaForWindowsManagementConsoleCustomConfig -IcingaConfiguration $IcingaConfiguration;

        Enable-IcingaFrameworkConsoleOutput;

        Start-IcingaForWindowsInstallation -Automated;

        # Set our "old" swap live again. By doing so, we can still continue our old
        # configuration
        Set-IcingaPowerShellConfig -Path 'Framework.Config.Swap' -Value $OldConfigSwap;

        return;
    }

    while ($TRUE) {

        # Do nothing else anymore in case we are closing the management console
        if ($global:Icinga.InstallWizard.Closing) {
            break;
        }

        $FrameworkInstalled = Get-IcingaPowerShellConfig -Path 'Framework.Installed';

        if ($null -eq $FrameworkInstalled) {
            $FrameworkInstalled = $FALSE;
        }

        if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.NextCommand) -Or $global:Icinga.InstallWizard.NextCommand -eq 'Install-Icinga') {
            Show-IcingaForWindowsInstallerMenu `
                -Header 'What do you want to do?' `
                -Entries @(
                    @{
                        'Caption' = 'Installation';
                        'Command' = 'Show-IcingaForWindowsInstallerMenuInstallWindows';
                        'Help'    = 'Allows you to install Icinga for Windows with all required components and options.'
                    },
                    @{
                        'Caption' = 'Install Components';
                        'Command' = 'Show-IcingaForWindowsMenuInstallComponents';
                        'Help'    = 'Allows you to install new components for Icinga for Windows from your repositories.';
                    },
                    @{
                        'Caption' = 'Update environment';
                        'Command' = 'Show-IcingaForWindowsMenuUpdateComponents';
                        'Help'    = 'Allows you to modify your current Icinga for Windows installation.';
                    },
                    @{
                        'Caption' = 'Manage environment';
                        'Command' = 'Show-IcingaForWindowsMenuManage';
                        'Help'    = 'Allows you to modify your current Icinga for Windows installation.';
                    },
                    @{
                        'Caption'  = 'Remove components';
                        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
                        'Help'     = 'Allows you to modify your current Icinga for Windows installation.';
                        'Disabled' = (-Not ($global:Icinga.InstallWizard.AdminShell));
                    }
                ) `
                -DefaultIndex 0;
        } else {
            $NextArguments = $global:Icinga.InstallWizard.NextArguments;

            if ($global:Icinga.InstallWizard.NextCommand.Contains(':')) {
                $NextArguments = @{
                    'Value' = ($global:Icinga.InstallWizard.NextCommand.Split(':')[1]);
                };
                $global:Icinga.InstallWizard.NextCommand = $global:Icinga.InstallWizard.NextCommand.Split(':')[0];
            }

            try {
                if ($null -ne $NextArguments -And $NextArguments.Count -ne 0) {
                    & $global:Icinga.InstallWizard.NextCommand @NextArguments;
                } else {
                    & $global:Icinga.InstallWizard.NextCommand;
                }
            } catch {
                $ErrMsg = $_.Exception.Message;

                $global:Icinga.InstallWizard.LastError     = [string]::Format('Failed to enter menu "{0}". Error "{1}', $global:Icinga.InstallWizard.NextCommand, $ErrMsg);
                $global:Icinga.InstallWizard.NextCommand   = 'Install-Icinga';
                $global:Icinga.InstallWizard.NextArguments = @{ };
            }
        }
    }
}

function Start-IcingaForWindowsInstallation()
{
    param (
        [switch]$Automated
    );

    if ((Get-IcingaFrameworkDebugMode) -eq $FALSE) {
        Clear-Host;
    }

    Write-IcingaConsoleNotice 'Starting Icinga for Windows installation';

    $ConnectionType        = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectConnection';
    $HostnameType          = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectHostname';
    $FirewallType          = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall';

    # Certificate handler
    $CertificateType       = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectCertificate';
    $CertificateTicket     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
    $CertificateCAFile     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';

    # Icinga Agent
    $AgentVersion          = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentVersion';
    $InstallIcingaAgent    = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaAgent';
    $AgentInstallDir       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory';
    $ServiceUser           = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser';
    $ServicePassword       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';

    # Icinga for Windows Service
    $InstallPSService      = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService';
    $WindowsServiceDir     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory';

    # Icinga for Windows Plugins
    $InstallPluginChoice   = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins';

    # Global Zones
    $GlobalZonesType       = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectGlobalZones';
    $GlobalZonesCustom     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones';

    # Icinga Endpoint Configuration
    $IcingaZone            = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
    $IcingaEndpoints       = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';
    $IcingaPort            = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuEnterIcingaPort';

    # Repository
    $IcingaStableRepo      = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallationMenuStableRepository';

    # JEA Profile
    $InstallJEAProfile     = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectInstallJEAProfile';

    $Hostname              = '';
    $GlobalZones           = @();
    $IcingaParentAddresses = @();
    $ServicePackageSource  = ''
    $ServiceSourceGitHub   = $FALSE;
    $InstallAgent          = $TRUE;
    $InstallService        = $TRUE;
    $InstallPlugins        = $TRUE;
    $PluginPackageRelease  = $FALSE;
    $PluginPackageSnapshot = $FALSE;

    if ([string]::IsNullOrEmpty($IcingaStableRepo) -eq $FALSE) {
        Add-IcingaRepository -Name 'Icinga Stable' -RemotePath $IcingaStableRepo;
    }

    foreach ($endpoint in $IcingaEndpoints) {
        $EndpointAddress = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $endpoint;

        $IcingaParentAddresses += $EndpointAddress;
    }

    switch ($HostnameType) {
        '0' {
            $Hostname = (Get-IcingaHostname -AutoUseFQDN 1);
            break;
        };
        '1' {
            $Hostname = (Get-IcingaHostname -AutoUseFQDN 1 -LowerCase 1);
            break;
        };
        '2' {
            $Hostname = (Get-IcingaHostname -AutoUseFQDN 1 -UpperCase 1);
            break;
        };
        '3' {
            $Hostname = (Get-IcingaHostname -AutoUseHostname 1);
            break;
        };
        '4' {
            $Hostname = (Get-IcingaHostname -AutoUseHostname 1 -LowerCase 1);
            break;
        };
        '5' {
            $Hostname = (Get-IcingaHostname -AutoUseHostname 1 -UpperCase 1);
            break;
        };
    }

    switch ($GlobalZonesType) {
        '0' {
            $GlobalZones += 'director-global';
            $GlobalZones += 'global-templates';
            break;
        };
        '1' {
            $GlobalZones += 'director-global';
            break;
        }
        '2' {
            $GlobalZones += 'global-templates';
            break;
        }
    }

    foreach ($zone in $GlobalZonesCustom) {
        if ([string]::IsNullOrEmpty($zone) -eq $FALSE) {
            if ($GlobalZones -Contains $zone) {
                continue;
            }

            $GlobalZones += $zone;
        }
    }

    switch ($InstallIcingaAgent) {
        '0' {
            # Install Icinga Agent from packages.icinga.com
            $InstallAgent = $TRUE;
            break;
        };
        '1' {
            # Do not install Icinga Agent
            $InstallAgent = $FALSE;
            break;
        }
    }

    switch ($InstallPSService) {
        '0' {
            # Install Icinga for Windows Service
            $InstallService = $TRUE;
            break;
        };
        '1' {
            # Do not install Icinga for Windows service
            $InstallService = $FALSE;
            break;
        }
    }

    switch ($InstallPluginChoice) {
        '0' {
            # Download stable release
            $PluginPackageRelease = $TRUE;
            break;
        };
        '1' {
            # Do not install plugins
            $InstallPlugins = $FALSE;
            break;
        }
    }

    if ($InstallAgent) {
        Set-IcingaPowerShellConfig -Path 'Framework.Icinga.AgentLocation' -Value $AgentInstallDir;
        Install-IcingaComponent -Name 'agent' -Version $AgentVersion -Confirm -Release;
        Reset-IcingaAgentConfigFile;
        Move-IcingaAgentDefaultConfig;
        Set-IcingaAgentNodeName -Hostname $Hostname;
        Set-IcingaAgentServiceUser -User $ServiceUser -Password (ConvertTo-IcingaSecureString $ServicePassword) -SetPermission | Out-Null;
        Install-IcingaAgentBaseFeatures;
        Write-IcingaAgentApiConfig -Port $IcingaPort;
    }

    if ((Install-IcingaAgentCertificates -Hostname $Hostname -Endpoint $IcingaParentAddresses[0] -Port $IcingaPort -CACert $CertificateCAFile -Ticket $CertificateTicket) -eq $FALSE) {
        Disable-IcingaAgentFeature 'api';
        Write-IcingaConsoleWarning `
            -Message '{0}{1}{2}{3}{4}' `
            -Objects (
                'Your Icinga Agent API feature has been disabled. Please provide either your ca.crt ',
                'or connect to a parent node for certificate requests. You can run "Install-IcingaAgentCertificates" ',
                'with your configuration to properly create the host certificate and a valid certificate request. ',
                'After this you can enable the API feature by using "Enable-IcingaAgentFeature api" and restart the ',
                'Icinga Agent service "Restart-IcingaService icinga2"'
            );
    }

    Write-IcingaAgentZonesConfig -Endpoints $IcingaEndpoints -EndpointConnections $IcingaParentAddresses -ParentZone $IcingaZone -GlobalZones $GlobalZones -Hostname $Hostname;

    if ($InstallService) {
        Set-IcingaPowerShellConfig -Path 'Framework.Icinga.IcingaForWindowsService' -Value $WindowsServiceDir;
        Set-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser' -User $ServiceUser;
        Set-IcingaInternalPowerShellServicePassword -Password (ConvertTo-IcingaSecureString $ServicePassword);

        Install-IcingaComponent -Name 'service' -Release -Confirm;
        Register-IcingaBackgroundDaemon -Command 'Start-IcingaServiceCheckDaemon';
    }

    if ($InstallPlugins) {
        Install-IcingaComponent -Name 'plugins' -Release:$PluginPackageRelease -Snapshot:$PluginPackageSnapshot -Confirm;
    }

    switch ($FirewallType) {
        '0' {
            # Open Windows Firewall
            Enable-IcingaFirewall -IcingaPort $IcingaPort -Force;
            break;
        };
        '1' {
            # Close Windows Firewall
            Disable-IcingaFirewall;
            break;
        }
    }

    Write-IcingaFrameworkCodeCache;
    Test-IcingaAgent;

    if ($InstallAgent) {
        Restart-IcingaService 'icinga2';
    }

    if ($InstallService) {
        Restart-IcingaService 'icingapowershell';
    }

    switch ($InstallJEAProfile) {
        '0' {
            Install-IcingaJEAProfile;
            break;
        };
        '1' {
            Install-IcingaSecurity;
            break;
        };
        '2' {
            # Do not install JEA profile
        }
    }

    # Update configuration and clear swap
    $ConfigSwap = Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap';
    Set-IcingaPowerShellConfig -Path 'Framework.Config.Swap' -Value $null;
    Set-IcingaPowerShellConfig -Path 'Framework.Config.Live' -Value $ConfigSwap;
    $global:Icinga.InstallWizard.Config = @{ };
    Set-IcingaPowerShellConfig -Path 'Framework.Installed' -Value $TRUE;

    if ($Automated -eq $FALSE) {
        Write-IcingaConsoleNotice 'Icinga for Windows is installed. Returning to main menu in 5 seconds'
        Start-Sleep -Seconds 5;
    }

    $global:Icinga.InstallWizard.NextCommand   = 'Install-Icinga';
    $global:Icinga.InstallWizard.NextArguments = @{ };
}

function Add-IcingaForWindowsInstallationAdvancedEntries()
{
    $ConnectionConfiguration = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectConnection';

    $OpenFirewall = '1'; # Do not open firewall
    if ($ConnectionConfiguration -ne '0') {
        $OpenFirewall = '0';
    }

    Disable-IcingaFrameworkConsoleOutput;

    Show-IcingaForWindowsInstallationMenuEnterIcingaPort -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall -DefaultInput $OpenFirewall -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectCertificate -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectGlobalZones -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaAgentVersion -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaAgent -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory -Automated -Advanced;
    Show-IcingaForWindowsInstallationMenuStableRepository -Automated -Advanced;
    Show-IcingaForWindowsInstallerMenuSelectInstallJEAProfile -Automated -Advanced;

    Enable-IcingaFrameworkConsoleOutput;

    $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
}

function Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory()
{
    param (
        [array]$Value          = @( (Join-Path -Path $Env:ProgramFiles -ChildPath 'ICINGA2') ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Enter the path where to install the Icinga Agent into:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to override the location on where the Icinga Agent will be installed into';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-AgentDirectory' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentDirectory';

function Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword()
{
    param (
        [array]$Value          = @( ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the password for your service. Not required for system users!' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to provide a password for a service user account. This is only required for custom users, like a local or domain user. The default user does not require a password and should be left empty in this case';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -PasswordInput `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-ServicePassword' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';

function Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser()
{
    param (
        [array]$Value          = @( 'NT Authority\NetworkService' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please define the user the Icinga Agent service should run with:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';
                'Help'    = 'Allows you to override the default user the Icinga Agent is running with as service. In case a password is required, you can add it in the next step';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # Remove a defined password in case we are running system services
    [string]$ServiceUser = Get-IcingaForWindowsInstallerValuesFromStep;

    if ([string]::IsNullOrEmpty($ServiceUser) -eq $FALSE) {
        $ServiceUser = $ServiceUser.ToLower();
    } else {
        $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser';
        return;
    }

    if ($ServiceUser -eq 'networkservice' -Or $ServiceUser -eq 'nt authority\networkservice' -Or $ServiceUser -eq 'localsystem' -Or $ServiceUser -eq 'nt authority\localservice' -Or $ServiceUser -eq 'localservice') {
        Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';
        $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallerConfigurationSummary';
        $global:Icinga.InstallWizard.NextArguments = @{ };
    } else {
        $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentServicePassword';
    }
}

Set-Alias -Name 'IfW-AgentUser' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentUser';

function Show-IcingaForWindowsInstallationMenuEnterIcingaAgentVersion()
{
    param (
        [array]$Value          = @( 'release' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please specify the version of the Icinga Agent you want to install:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to define which Icinga Agent version is installed on this system. The installer will search for the .MSI package for the specified version on the source location. You can either use "release" to install the highest version found, use "snapshot" to install snapshot packages or specify a direct version like "2.12.3"';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-AgentVersion' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaAgentVersion';

function Show-IcingaForWindowsInstallerMenuSelectInstallIcingaAgent()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select if the Icinga Agent should be installed' `
        -Entries @(
            @{
                'Caption' = 'Install Icinga Agent';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Downloads the Icinga Agent from the specified stable repository and installs it';
            },
            @{
                'Caption' = 'Do not install Icinga Agent';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Do not install the Icinga Agent on this system';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-InstallAgent' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaAgent';

function Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Advanced = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the path to your ca.crt file. This can be a local, network share or web address:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'To sign certificates locally you can copy the Icinga CA master "ca.crt" file (normally located at "/var/lib/icinga2/ca") to a location you can access from this host. Enter the full path on where you stored the "ca.crt" file. You can provide a local path "C:\users\public\ca.crt", a network share "\\share.example.com\icinga\ca.crt" or a web address "https://example.com/icinga/ca.crt"';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-CAFile' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';

function Show-IcingaForWindowsInstallerMenuEnterIcingaTicket()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Advanced = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your ticket for signing the Icinga certificate:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'The ticket required for signing your local Icinga certificate. You can get the ticket from the Icinga Director for this host or from your Icinga CA master by running "icinga2 pki ticket --cn <hostname as selected before>"';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-Ticket' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';

function Show-IcingaForWindowsInstallerMenuSelectCertificate()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'How do you want to create the Icinga certificate?' `
        -Entries @(
            @{
                'Caption' = 'Sign certificate manually on the Icinga CA master';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This option will not require you to provide additional details for certificate generation and only require a connection to/from this host. You will have to sign the certificate manually on the Icinga CA master with "icinga2 ca sign <request>"';
            },
            @{
                'Caption' = 'Sign certificate with a ticket';
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
                'Help'    = 'By selecting this option, this host will connect to a parent Icinga node and sign the certificate with a ticket you have to provide in the next step';
            },
            @{
                'Caption' = 'Sign certificate with local ca.crt';
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';
                'Help'    = 'This will allow you to sign the certificate for this host directly on this machine. For this you will have to store your Icinga ca.crt somewhere accessible to this system. In the next step you are asked to provide the path to the location of your ca.crt';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # Make sure we delete configuration no longer required
    switch (Get-IcingaForWindowsManagementConsoleLastInput) {
        '0' {
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';
            break;
        };
        '1' {
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaCAFile';
            break;
        };
        '2' {
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaTicket';
            break;
        };
    }
}

Set-Alias -Name 'IfW-Certificate' -Value 'Show-IcingaForWindowsInstallerMenuSelectCertificate';

function Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate()
{
    param (
        [switch]$Register = $FALSE
    );

    $DirectorUrl    = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl';
    $SelfServiceKey = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';

    # Once we run this menu, we require to reset everything to have a proper state
    if ($Register -eq $FALSE) {
        $global:Icinga.InstallWizard.Config = @{ };

        Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $DirectorUrl -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl';
        Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $SelfServiceKey -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';
    } else {
        $HostnameType = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectHostname';
        $Hostname     = '';

        switch ($HostnameType) {
            '0' {
                $Hostname = (Get-IcingaHostname -AutoUseFQDN 1);
                break;
            };
            '1' {
                $Hostname = (Get-IcingaHostname -AutoUseFQDN 1 -LowerCase 1);
                break;
            };
            '2' {
                $Hostname = (Get-IcingaHostname -AutoUseFQDN 1 -UpperCase 1);
                break;
            };
            '3' {
                $Hostname = (Get-IcingaHostname -AutoUseHostname 1);
                break;
            };
            '4' {
                $Hostname = (Get-IcingaHostname -AutoUseHostname 1 -LowerCase 1);
                break;
            };
            '5' {
                $Hostname = (Get-IcingaHostname -AutoUseHostname 1 -UpperCase 1);
                break;
            };
        }

        try {
            $SelfServiceKey = Register-IcingaDirectorSelfServiceHost -DirectorUrl $DirectorUrl -ApiKey $SelfServiceKey -Hostname $Hostname;
        } catch {
            Write-IcingaConsoleNotice 'Host seems already to be registered within Icinga Director. Trying local Api key if present'
            $SelfServiceKey = Get-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey';

            if ([string]::IsNullOrEmpty($SelfServiceKey)) {
                Write-IcingaConsoleNotice 'No local Api key was found and using your provided template key failed. Please ensure the host is not already registered and drop the set Self-Service key within the Icinga Director for this host.'
            }
        }
        Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $SelfServiceKey -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';
    }

    try {
        $DirectorConfig = Get-IcingaDirectorSelfServiceConfig -DirectorUrl $DirectorUrl -ApiKey $SelfServiceKey;
    } catch {
        Set-IcingaForWindowsManagementConsoleMenu 'Show-IcingaForWindowsInstallerConfigurationSummary';
        $global:Icinga.InstallWizard.LastError = 'Failed to fetch host configuration with the given Director Url and Self-Service key. Please ensure the template key is correct and in case a previous host key was used, that it matches the one configured within the Icinga Director. In case this form was loaded previously with a key, it might be that the host key is no longer valid and requires to be dropped. In addition please ensure that this host can connect to the Icinga Director and the SSL certificate is trusted. Otherwise run "Enable-IcingaUntrustedCertificateValidation" before starting the management console. Otherwise modify the "DirectorSelfServiceKey" configuration element above with the correct key and try again.';
        return;
    }

    # No we need to identify which host selection is matching our config
    $HostnameSelection        = -1;
    $InstallPluginsSelection  = -1;
    $InstallServiceSelection  = -1;
    $WindowsFirewallSelection = 1;

    $ServiceUserName          = $DirectorConfig.icinga_service_user;
    $AgentPackageSelection    = 1; #Always use custom source
    $AgentPackageSource       = $DirectorConfig.download_url;
    $AgentVersion             = $DirectorConfig.release;
    $IcingaPort               = $DirectorConfig.agent_listen_port;
    $GlobalZones              = @();
    $IcingaParents            = @();
    $IcingaParentAddresses    = New-Object PSCustomObject;
    $ParentZone               = '';
    $MasterAddress            = '';

    if ($DirectorUrl.ToLower().Contains('https://') -Or $DirectorUrl.ToLower().Contains('http://')) {
        $MasterAddress = $DirectorUrl.Split('/')[2];
    } else {
        $MasterAddress = $DirectorUrl.Split('/')[0];
    }

    if ($Register) {
        if ($null -ne $DirectorConfig.agent_add_firewall_rule -And $DirectorConfig.agent_add_firewall_rule) {
            # Open Windows Firewall
            $WindowsFirewallSelection = 0;
        }

        if ($null -ne $DirectorConfig.global_zones) {
            $GlobalZones = $DirectorConfig.global_zones;
        }

        if ($null -ne $DirectorConfig.parent_endpoints) {
            $IcingaParents = $DirectorConfig.parent_endpoints;
        }

        if ($null -ne $DirectorConfig.endpoints_config) {
            [int]$Index = 0;
            foreach ($entry in $DirectorConfig.endpoints_config) {
                $IcingaParentAddresses | Add-Member -MemberType NoteProperty -Name ($IcingaParents[$Index]) -Value (($entry.Split(';')[0]));
                $Index += 1;
            }
        }

        if ($null -ne $DirectorConfig.parent_zone) {
            $ParentZone = $DirectorConfig.parent_zone;
        }
    }

    if ($DirectorConfig.fetch_agent_fqdn) {
        switch ($DirectorConfig.transform_hostname) {
            '0' {
                # FQDN as it is
                $HostnameSelection = 0;
                break;
            };
            '1' {
                # FQDN to lowercase
                $HostnameSelection = 1;
                break;
            };
            '2' {
                # FQDN to uppercase
                $HostnameSelection = 2;
                break;
            }
        }
    } elseif ($DirectorConfig.fetch_agent_name) {
        switch ($DirectorConfig.transform_hostname) {
            '0' {
                # Hostname as it is
                $HostnameSelection = 3;
                break;
            };
            '1' {
                # Hostname to lowercase
                $HostnameSelection = 4;
                break;
            };
            '2' {
                # Hostname to uppercase
                $HostnameSelection = 5;
                break;
            }
        }
    }

    if ($DirectorConfig.install_framework_service -eq 0) {
        # Do not install
        $InstallServiceSelection = 1;
    } else {
        $InstallServiceSelection = 0;
    }

    if ($DirectorConfig.install_framework_plugins -eq 0) {
        # Do not install
        $InstallPluginsSelection = 1;
    } else {
        # TODO: This is currently not supported. We use the "default" config for installing from GitHub by now
        $InstallPluginsSelection = 0;
    }

    Disable-IcingaFrameworkConsoleOutput;
    Show-IcingaForWindowsInstallerMenuSelectHostname -DefaultInput $HostnameSelection -Automated;
    Add-IcingaForWindowsInstallationAdvancedEntries;
    Disable-IcingaFrameworkConsoleOutput;

    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins -DefaultInput $InstallPluginsSelection -Value @() -Automated;
    Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService -DefaultInput $InstallServiceSelection -Value @() -Automated;
    Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall -DefaultInput $WindowsFirewallSelection -Value @() -Automated;

    if ($Register) {
        Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones -Value $GlobalZones -Automated;
        Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes -Value $IcingaParents -Automated;
        Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses -Value $IcingaParentAddresses -Automated;
        Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone -Value $ParentZone -Automated;
    }

    Show-IcingaForWindowsManagementConsoleInstallationDirectorRegisterHost -Automated;

    Enable-IcingaFrameworkConsoleOutput;
    Reset-IcingaForWindowsManagementConsoleInstallationDirectorConfigModifyState;
}

function Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the URL pointing to your Icinga Director module:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';
                'Help'    = 'The Icinga Web 2 url pointing directly to the root of the Icinga Director module. Example: "https://example.com/icingaweb2/director" or "https://icinga.example.com/director"';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-DirectorUrl' -Value 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl';

function Show-IcingaForWindowsManagementConsoleInstallationDirectorRegisterHost()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Advanced = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Do you want to register the host right now inside the Icinga Director? This will show missing configurations.' `
        -Entries @(
            @{
                'Caption' = 'Do not register host inside Icinga Director';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'If you do not want to modify extended properties for this host and use default values from the Icinga Director, based on the Self-Service API configuration, use this option and complete the installation process afterwards.';
            },
            @{
                'Caption' = 'Register host inside Icinga Director';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'You can select this option to register the host within the Icinga Director right now, unlocking more advanced configurations for this host like "Parent Zone", "Parent Nodes" and "Parent Node Addresses"';
                'Action'  = @{
                    'Command'   = 'Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate';
                    'Arguments' = @{
                        '-Register' = $TRUE;
                    }
                }
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-DirectorRegisterHost' -Value 'Show-IcingaForWindowsManagementConsoleInstallationDirectorRegisterHost';

function Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($null -eq $Value -or $Value.Count -eq 0) {
        $LocalApiKey = Get-IcingaPowerShellConfig -Path 'IcingaDirector.SelfService.ApiKey';
        if ([string]::IsNullOrEmpty($LocalApiKey) -eq $FALSE) {
            $Value += $LocalApiKey;
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the Self-Service API key for the Host-Template to use:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This is the Self-Service API for the host template to use. To get this, you will have to set the host template to be an "Icinga 2 Agent" template inside the Icinga Director. Afterwards you see an "Agent" tab on the top right navigation, providing you with the key. In case you entered this menu for the first time and see a key already present, this means the installer already run once and therefor you will be presented with your host key. If a host is already present within the Icinga Director, you can also use the "Agent" tab to get the key of this host directly to enter here';
                'Action'  = @{
                    'Command'   = 'Resolve-IcingaForWindowsManagementConsoleInstallationDirectorTemplate';
                    'Arguments' = @{
                        '-Register' = $FALSE;
                    }
                }
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-DirectorSelfServiceKey' -Value 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorSelfServiceKey';

function Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '1',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select if your Windows Firewall should be opened for the Icinga port:' `
        -Entries @(
            @{
                'Caption' = 'Open Windows Firewall for incoming Icinga connections';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This will open the Windows Firewall for the configured Icinga Port, to allow incoming communication from Icinga parent node(s)';
            },
            @{
                'Caption' = 'Do not open Windows Firewall for incoming Icinga connections';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Do not open the Windows firewall for any incoming Icinga connections. Please note that in case your Icinga Agent is configured for "Connecting from parent system" you will not be able to establish a communication unless the connection type is changed or the port is opened';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-WindowsFirewall' -Value 'Show-IcingaForWindowsInstallerMenuSelectOpenWindowsFirewall';

function Show-IcingaForWindowsInstallationMenuStableRepository()
{
    param (
        [array]$Value          = @( 'https://packages.icinga.com/IcingaForWindows/stable' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the path or Url for your stable Icinga repository:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This is the stable repository from where all packages of Icinga for Windows are downloaded and intstalled from. Defaults to "https://packages.icinga.com/IcingaForWindows/stable"';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-StableRepository' -Value 'Show-IcingaForWindowsInstallationMenuStableRepository';

function Show-IcingaForWindowsInstallerMenuSelectInstallJEAProfile()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '2',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($PSVersionTable.PSVersion -lt '5.0.0.0') {
        return;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select if you want to install the JEA profile for the assigned service user or to create a managed user' `
        -Entries @(
            @{
                'Caption' = 'Install JEA Profile';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Installs the Icinga for Windows JEA profile for the specified service user';
            },
            @{
                'Caption' = 'Install JEA Profile with managed user "IcingaForWindows"';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Installs the Icinga for Windows JEA profile with a newly created, managed user "IcingaForWindows". This will override your service and service password configuration';
            },
            @{
                'Caption' = 'Do not install JEA Profile';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Do not install the Icinga for Windows JEA profile';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-InstallJEAProfile' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallJEAProfile';

function Show-IcingaForWindowsInstallerConfigurationSummary()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    [array]$Entries    = @();
    [int]$CurrentIndex = 0

    Enable-IcingaForWindowsInstallationHeaderPrint;

    while ($TRUE) {
        if ($CurrentIndex -gt $global:Icinga.InstallWizard.Config.Count) {
            break;
        }

        foreach ($entry in $global:Icinga.InstallWizard.Config.Keys) {
            $ConfigEntry = $global:Icinga.InstallWizard.Config[$entry];

            if ($ConfigEntry.Index -ne $CurrentIndex) {
                continue;
            }

            if ($ConfigEntry.Hidden) {
                continue;
            }

            if ($ConfigEntry.Advanced -And $global:Icinga.InstallWizard.ShowAdvanced -eq $FALSE) {
                continue;
            }

            $EntryValue = $ConfigEntry.Selection;
            if ($null -ne $ConfigEntry.Values -And $ConfigEntry.Count -ne 0) {
                if ($ConfigEntry.Password) {
                    $EntryValue = ConvertFrom-IcingaArrayToString -Array $ConfigEntry.Values -AddQuotes -SecureContent;
                } else {
                    $EntryValue = ConvertFrom-IcingaArrayToString -Array $ConfigEntry.Values -AddQuotes;
                }
            }

            [string]$Caption = ''
            $PrintName       = $entry;
            $RealCommand     = $entry;
            $ChildElement    = '';

            if ($RealCommand.Contains(':')) {
                $RealCommand  = $entry.Split(':')[0];
                $ChildElement = $entry.Split(':')[1];
            }

            if ($entry.Contains(':')) {
                $PrintName = [string]::Format('{0} for "{1}"', $RealCommand, $ChildElement);
            } else {
                $PrintName = $RealCommand;
            }

            $PrintName = $PrintName.Replace('IfW-', '');

            if (Test-Numeric ($ConfigEntry.Selection)) {
                Set-IcingaForWindowsInstallationHeaderSelection -Selection $ConfigEntry.Selection;

                &$RealCommand;

                $Caption = ([string]::Format('{0}: {1}', $PrintName, $global:Icinga.InstallWizard.HeaderPreview));
            } else {
                $Caption = ([string]::Format('{0}: {1}', $PrintName, $EntryValue));
            }

            $Entries += @{
                'Caption'   = $Caption;
                'Command'   = $entry;
                'Arguments' = @{ '-JumpToSummary' = $TRUE };
                'Help'      = ''
            }

            $global:Icinga.InstallWizard.HeaderPreview = '';
        }

        $CurrentIndex += 1;
    }

    Disable-IcingaForWindowsInstallationHeaderPrint;
    Enable-IcingaForWindowsInstallationJumpToSummary;

    $global:Icinga.InstallWizard.DisplayAdvanced = $TRUE;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please validate your configuration. Installation starts on continue:' `
        -Entries $Entries `
        -DefaultIndex 'c' `
        -ContinueFunction 'Show-IcingaForWindowsInstallerMenuFinishInstaller' `
        -ConfigElement `
        -Hidden;

    Disable-IcingaForWindowsInstallationJumpToSummary;
    $global:Icinga.InstallWizard.DisplayAdvanced = $FALSE;
}

Set-Alias -Name 'IfW-ConfigurationSummary' -Value 'Show-IcingaForWindowsInstallerConfigurationSummary';

function Show-IcingaForWindowsInstallerMenuContinueConfiguration()
{
    $SwapConfig                         = Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap';
    $global:Icinga.InstallWizard.Config = Convert-IcingaForwindowsManagementConsoleJSONConfig -Config $SwapConfig;
    [string]$Menu                       = Get-IcingaForWindowsInstallerLastParent;

    # We don't need the last entry, as this will be added anyways because we are
    # starting right from there and it will be added anyway
    Remove-IcingaForWindowsInstallerLastParent;

    if ($Menu.Contains(':')) {
        $Menu = Get-IcingaForWindowsInstallerLastParent;
    }

    $global:Icinga.InstallWizard.NextCommand = $Menu;
}

function Show-IcingaForWindowsInstallerMenuFinishInstaller()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'How you do want to proceed:' `
        -Entries @(
            @{
                'Caption'  = 'Start installation';
                'Command'  = 'Start-IcingaForWindowsInstallation';
                'Help'     = 'Apply the just configured configuration and install components as selected';
                'Disabled' = (-Not ($global:Icinga.InstallWizard.AdminShell));
                'Action'   = @{
                    'Command' = 'Clear-IcingaForWindowsManagementConsolePaginationCache';
                }
            },
            @{
                'Caption' = 'Export answer file';
                'Command' = 'Show-IcingaForWindowsManagementConsoleInstallationFileExport';
                'Help'    = 'Allows you to export a JSON file containing all settings configured during this step and use it on another system';
            },
            @{
                'Caption' = 'Print installation command';
                'Command' = 'Show-IcingaForWindowsManagementConsoleInstallationConfigString';
                'Help'    = 'Allows you to export a simple configuration command you can run on another system. Similar to the "Export answer file" option, but does not require to distribute files';
            },
            @{
                'Caption' = 'Save current configuration and go to main menu';
                'Command' = 'Install-Icinga';
                'Help'    = 'Keep the current configuration as "swap" and exit to the main menu';
                'Action'  = @{
                    'Command' = 'Clear-IcingaForWindowsManagementConsolePaginationCache';
                }
            }
        ) `
        -DefaultIndex 0 `
        -Hidden;
}

Set-Alias -Name 'IfW-FinishInstaller' -Value 'Show-IcingaForWindowsInstallerMenuFinishInstaller';

function Export-IcingaForWindowsManagementConsoleInstallationAnswerFile()
{
    $FilePath = '';
    $Value    = $global:Icinga.InstallWizard.LastValues;

    if ($null -ne $Value -And $Value.Count -ne 0) {
        $FilePath = $Value[0]
    }

    if (Test-Path ($FilePath)) {
        Set-Content -Path (Join-Path -Path $FilePath -ChildPath 'IfW_answer.json') -Value (Get-IcingaForWindowsManagementConsoleConfigurationString);
        $global:Icinga.InstallWizard.NextCommand = 'Install-Icinga';
        $global:Icinga.InstallWizard.LastNotice  = ([string]::Format('Answer file "IfW_answer.json" successfully exported into "{0}"', $FilePath));
        Clear-IcingaForWindowsManagementConsolePaginationCache;
    } else {
        $global:Icinga.InstallWizard.LastError   = ([string]::Format('The provided path to store the answer file is invalid: "{0}"', $FilePath));
        $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsManagementConsoleInstallationFileExport';
    }
}

function Show-IcingaForWindowsManagementConsoleInstallationConfigString()
{
    [string]$ConfigurationString = [string]::Format(
        "{0}Install-Icinga -InstallCommand '{1}'{0}",
        (New-IcingaNewLine),
        (Get-IcingaForWindowsManagementConsoleConfigurationString -Compress)
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Here is your configuration command for Icinga for Windows:' `
        -Entries @(
            @{
                'Caption' = '';
                'Command' = 'Install-Icinga';
                'Help'    = 'This command provides a list of settings you entered or modified during the process. In case values are not modified, they do not show up here and are left as default. You can run this entire command on a different Windows host to apply the same configuration';
                'Action'  = @{
                    'Command' = 'Clear-IcingaForWindowsManagementConsolePaginationCache';
                }
            }
        ) `
        -AddConfig `
        -DefaultValues @( $ConfigurationString ) `
        -ConfigLimit 1 `
        -DefaultIndex 'c' `
        -ReadOnly `
        -Hidden;
}

function Show-IcingaForWindowsManagementConsoleInstallationFileExport()
{
    $FilePath = $ENV:USERPROFILE;

    if ($null -ne $global:Icinga.InstallWizard.LastValues -And $global:Icinga.InstallWizard.LastValues.Count -ne 0) {
        $FilePath = $global:Icinga.InstallWizard.LastValues[0];
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Where do you want to export the answer file to? The filename "IfW_answer.json" is added automatically.' `
        -Entries @(
            @{
                'Caption' = '';
                'Command' = 'Export-IcingaForWindowsManagementConsoleInstallationAnswerFile';
                'Help'    = 'This will all you to export the answer file with the given configuration. You can install Icinga for Windows with this file by using the command "Install-Icinga -AnswerFile <path to the file>".';
            }
        ) `
        -AddConfig `
        -DefaultValues @( $FilePath ) `
        -ConfigLimit 1 `
        -DefaultIndex 'c' `
        -MandatoryValue `
        -Hidden;
}

function Show-IcingaForWindowsInstallerMenuInstallWindows()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($null -eq (Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap') -And $null -eq (Get-IcingaPowerShellConfig -Path 'Framework.Config.Live')) {
        Show-IcingaForWindowsInstallerMenuSelectConnection;
        return;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Choose the configuration type:' `
        -Entries @(
            @{
                'Caption' = 'New configuration';
                'Command' = 'Show-IcingaForWindowsInstallerMenuNewConfiguration';
                'Help'    = 'Start a new configuration and truncate all information stored on the current swap file. This will only modify your production if you hit "Start installation" at the end';
            },
            @{
                'Caption'  = 'Continue configuration';
                'Command'  = 'Show-IcingaForWindowsInstallerMenuContinueConfiguration';
                'Help'     = 'Continue with the previous configuration swap file.';
                'Disabled' = ([bool]($null -eq (Get-IcingaPowerShellConfig -Path 'Framework.Config.Swap')));
            },
            @{
                'Caption'  = 'Reconfigure Environment';
                'Command'  = 'Invoke-IcingaForWindowsManagementConsoleReconfigureAgent';
                'Help'     = 'Load the current configuration of Icinga for Windows to modify it.';
                'Disabled' = ([bool]($null -eq (Get-IcingaPowerShellConfig -Path 'Framework.Config.Live')));
            }
        ) `
        -DefaultIndex $DefaultInput `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

function Show-IcingaForWindowsInstallerMenuNewConfiguration()
{
    $global:Icinga.InstallWizard.Config = @{ };
    Show-IcingaForWindowsInstallerMenuSelectConnection;
}

function Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = $null,
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    if ($Value.Count -ne 0) {

        while ($TRUE) {
            # Use the installer file/command for automation
            if ($Value[0].GetType().Name.ToLower() -eq 'pscustomobject') {

                # This is just to handle automated installation by using a file or the install command
                # We use a hashtable here as well, but reduce complexity and remove network checks

                foreach ($endpoint in  $Value[0].PSObject.Properties) {
                    Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $endpoint.Value `
                        -OverwriteValues `
                        -OverwriteMenu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' `
                        -OverwriteParent ([string]::Format('Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes:{0}', $endpoint.Name));
                }

                return;

            } elseif ($Value[0].GetType().Name.ToLower() -eq 'hashtable') { # We will be forwarded this from Test-IcingaForWindowsInstallerParentEndpoints

                $NetworkMap        = $Value[0];
                [int]$AddressIndex = 0;

                foreach ($entry in $NetworkMap.Keys) {
                    $EndpointConfig = $NetworkMap[$entry];

                    if ($EndpointConfig.Error -eq $FALSE) {
                        $AddressIndex += 1;
                        continue;
                    }

                    $global:Icinga.InstallWizard.LastError = ([string]::Format('Failed to resolve the address for the following endpoint: {0}', $EndpointConfig.Endpoint));

                    $Address = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $EndpointConfig.Endpoint;

                    if ($null -eq $Address -Or $Address.Count -eq 0) {
                        $Address = @( $EndpointConfig.Address );
                    }

                    Show-IcingaForWindowsInstallerMenu `
                        -Header ([string]::Format('Please enter the connection data for endpoint: "{0}"', $EndpointConfig.Endpoint)) `
                        -Entries @(
                            @{
                                'Command' = 'break';
                                'Help'    = 'The address to communicate with your parent Icinga node. It is highly recommended to use an IP address instead of a FQDN';
                            }
                        ) `
                        -AddConfig `
                        -ConfigLimit 1 `
                        -DefaultValues $Address `
                        -MandatoryValue `
                        -ParentConfig ([string]::Format('Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes:{0}', $EndpointConfig.Endpoint)) `
                        -JumpToSummary:$JumpToSummary `
                        -ConfigElement `
                        -Automated:$Automated `
                        -Advanced:$Advanced;

                    $NewAddress = $Address;
                    $NewValue   = $Value;

                    if ((Test-IcingaForWindowsManagementConsoleContinue)) {
                        $ParentAddress = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $EndpointConfig.Endpoint;
                        $NetworkTest   = Convert-IcingaEndpointsToIPv4 -NetworkConfig $ParentAddress;
                        $NewAddress    = $ParentAddress;

                        if ($NetworkTest.HasErrors -eq $FALSE) {
                            Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values ($NetworkTest.Network[0]) -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';
                            $AddressIndex += 1;
                            $NewValue[0][$entry].Error = $FALSE;
                            continue;
                        }
                    }

                    Set-IcingaForWindowsManagementConsoleMenu -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';

                    $NewValue[0][$entry].Address = $NewAddress;

                    $global:Icinga.InstallWizard.NextArguments = @{
                        'Value'         = $NewValue;
                        'DefaultInput'  = $DefaultInput;
                        'JumpToSummary' = $JumpToSummary;
                        'Automated'     = $Automated;
                        'Advanced'      = $Advanced;
                    };

                    return;
                }

                $global:Icinga.InstallWizard.NextCommand = 'Add-IcingaForWindowsInstallationAdvancedEntries';
                return;
            } elseif ($Value[0].GetType().Name.ToLower() -eq 'string') {
                $Address = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $Value[0];

                Show-IcingaForWindowsInstallerMenu `
                    -Header ([string]::Format('Please enter the connection data for endpoint: "{0}"', $Value[0])) `
                    -Entries @(
                        @{
                            'Command' = 'break';
                            'Help'    = 'The address to communicate with your parent Icinga node. It is highly recommended to use an IP address instead of a FQDN';
                        }
                    ) `
                    -AddConfig `
                    -ConfigLimit 1 `
                    -DefaultValues $Address `
                    -MandatoryValue `
                    -ParentConfig ([string]::Format('Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes:{0}', $Value[0])) `
                    -JumpToSummary:$JumpToSummary `
                    -ConfigElement `
                    -Automated:$Automated `
                    -Advanced:$Advanced;

                if ((Test-IcingaForWindowsManagementConsoleContinue)) {
                    $ParentAddress = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $Value[0];
                    $NetworkTest   = Convert-IcingaEndpointsToIPv4 -NetworkConfig $ParentAddress;

                    if ($NetworkTest.HasErrors -eq $FALSE) {
                        Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values ($NetworkTest.Network[0]) -OverwriteValues -OverwriteMenu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';
                        $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                        return;
                    }
                }
            }

            if ((Test-IcingaForWindowsManagementConsoleExit) -Or (Test-IcingaForWindowsManagementConsoleMenu) -Or (Test-IcingaForWindowsManagementConsolePrevious)) {
                return;
            }

            if ((Test-IcingaForWindowsManagementConsoleDelete)) {
                continue;
            }
        }

        # Just to ensure we never are "trapped" in a endless loop
        if ($Automated) {
            break;
        }
    }

    $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
}

Set-Alias -Name 'IfW-ParentAddress' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';

function Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    $Endpoints = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your parent Icinga node name(s):' `
        -Entries @(
            @{
                'Command' = 'Test-IcingaForWindowsInstallerParentEndpoints';
                'Help'    = 'These are the object names for your parent Icinga endpoints as defined within the zones.conf. If you are running multiple Icinga instances within the same zone, you require to add both of them';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 2 `
        -DefaultValues $Value `
        -ContinueFirstValue `
        -MandatoryValue `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;

    # In case we delete our parent config, ensure we also delete our endpoint addresses
    if (Test-IcingaForWindowsManagementConsoleDelete) {
        foreach ($endpoint in $Endpoints) {
            Remove-IcingaForWindowsInstallerConfigEntry -Menu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $endpoint;
        }
    }
}

Set-Alias -Name 'IfW-ParentNodes' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';

function Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone()
{
    param (
        [array]$Value          = @( 'master' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your parent Icinga zone:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';
                'Help'    = 'The object name of the zone of the parent Icinga node(s) you want to communicate with, as defined within the zones.conf';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-ParentZone' -Value 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';

function Show-IcingaForWindowsInstallationMenuEnterIcingaPort()
{
    param (
        [array]$Value          = @( 5665 ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter your parent Icinga communication port:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'This is the port Icinga will use for communicating with all parent nodes and for which the firewall must be opened, depending on your communication configuration. Defaults to 5665';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-Port' -Value 'Show-IcingaForWindowsInstallationMenuEnterIcingaPort';

function Show-IcingaForWindowsInstallerMenuSelectConnection()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'How do you want to configure your local Icinga Agent?' `
        -Entries @(
            @{
                'Caption' = 'Connecting from this system';
                'Command' = 'Show-IcingaForWindowsInstallerMenuSelectHostname';
                'Help'    = 'Choose this option if your Icinga Agent should only connect to a parent Icinga node. This is the easiest configuration as certificate generation is done automatically.'
            },
            @{
                'Caption' = 'Connecting from parent system';
                'Command' = 'Show-IcingaForWindowsInstallerMenuSelectHostname';
                'Help'    = 'Choose this option if the Icinga Agent should not or cannot connect to a parent Icinga node and only connections from a Master/Satellite are possible. This will open the Windows firewall for the chosen Icinga protocol port (default 5665). Certificate generation might require additional steps.';
            },
            @{
                'Caption' = 'Connecting from both systems';
                'Command' = 'Show-IcingaForWindowsInstallerMenuSelectHostname';
                'Help'    = 'Choose this if connections from a parent Icinga node are possible and the Icinga Agent should connect to a parent node. This will open the Windows firewall for the chosen Icinga protocol port (default 5665).';
            },
            @{
                'Caption' = 'Icinga Director Self-Service API';
                'Command' = 'Show-IcingaForWindowsManagementConsoleInstallationEnterDirectorUrl';
                'Help'    = 'Choose this option if you can connect to the Icinga Director from this host. You will be asked for the Icinga Director Url and a Self-Service API key. The entire configuration for this host is then fetched from the Icinga Director.';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-Connection' -Value 'Show-IcingaForWindowsInstallerMenuSelectConnection';

function Show-IcingaForWindowsInstallerMenuSelectHostname()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '1',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'How is your host object named in Icinga?' `
        -Entries @(
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (current)', (Get-IcingaHostname -AutoUseFQDN 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and not modify the name at all';
            },
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (lowercase)', (Get-IcingaHostname -AutoUseFQDN 1 -LowerCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and modify all characters to lowercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": FQDN (uppercase)', (Get-IcingaHostname -AutoUseFQDN 1 -UpperCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the current FQDN of your host and modify all characters to uppercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (current)', (Get-IcingaHostname -AutoUseHostname 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension without modification';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (lowercase)', (Get-IcingaHostname -AutoUseHostname 1 -LowerCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension and modify all characters to lowercase';
            },
            @{
                'Caption' = ([string]::Format('"{0}": Hostname (uppercase)', (Get-IcingaHostname -AutoUseHostname 1 -UpperCase 1)));
                'Command' = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentZone';
                'Help'    = 'This will use the hostname only without FQDN extension and modify all characters to uppercase';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-Hostname' -Value 'Show-IcingaForWindowsInstallerMenuSelectHostname';

function Show-IcingaForWindowsInstallerMenuEnterWindowsServicePackageSource()
{
    param (
        [array]$Value          = @( ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the full path to the Icinga PowerShell Service .zip file:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to specify a full custom path on where your Icinga service package .zip file is located at. You can specify a local path "C:\icinga\service\icinga-service.zip", a network path "\\example.com\software\icinga\service\icinga-service.zip" or a web path "https://example.com/icinga/windows/service/icinga-service.zip". Please note that only the custom release .zip packages downloaded from "https://github.com/Icinga/icinga-powershell-service/releases" will work. You can get the packages from there and place them on your custom location';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -ContinueFirstValue `
        -MandatoryValue `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-WindowsServicePackageSource' -Value 'Show-IcingaForWindowsInstallerMenuEnterWindowsServicePackageSource';

function Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select of you want to install the Icinga for Windows service:' `
        -Entries @(
            @{
                'Caption' = 'Install Icinga for Windows Service';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Installs the Icinga for Windows service from the provided stable repository';
            },
            @{
                'Caption' = 'Do not install Icinga for Windows service';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Select this if you do not want to install the Icinga for Windows service';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-InstallPowerShellService' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaForWindowsService';

function Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory()
{
    param (
        [array]$Value          = @( (Join-Path -Path $Env:ProgramFiles -ChildPath 'icinga-framework-service') ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Enter the path where to install the Icinga for Windows service binary into:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'If you want to run a background PowerShell daemon, you will require a binary starting the shell as service. This is the permanent location for the binary, as the Icinga for Windows service is registered with this binary to run PowerShell as background daemon';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues @( $Value ) `
        -MandatoryValue `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-WindowsServiceDirectory' -Value 'Show-IcingaForWindowsInstallationMenuEnterWindowsServiceDirectory';

function Show-IcingaForWindowsInstallerMenuEnterPluginsPackageSource()
{
    param (
        [array]$Value          = @( ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please enter the full path to the Icinga PowerShell Plugins .zip file:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Allows you to specify a full custom path on where your Icinga plugins .zip file is located at. You can specify a local path "C:\icinga\plugins\icinga-powershell-plugins.zip", a network path "\\example.com\software\icinga\plugins\icinga-powershell-plugins.zip" or a web path "https://example.com/icinga/windows/plugins/icinga-powershell-plugins.zip". Please note that only .zip packages downloaded from "https://github.com/icinga/icinga-powershell-plugins/releases" will work. You can get the packages from there and place them on your custom location';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -ConfigLimit 1 `
        -DefaultValues $Value `
        -ContinueFirstValue `
        -MandatoryValue `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-PluginPackageSource' -Value 'Show-IcingaForWindowsInstallerMenuEnterPluginsPackageSource';

function Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please select where your Icinga plugins are downloaded from:' `
        -Entries @(
            @{
                'Caption' = 'Install plugins';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Installs the Icinga Plugins from the defined stable repository';
            },
            @{
                'Caption' = 'Do not install plugins';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Select this if you do not want to install the plugins for the moment';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$FALSE `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-InstallPlugins' -Value 'Show-IcingaForWindowsInstallerMenuSelectInstallIcingaPlugins';

function Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones()
{
    param (
        [array]$Value          = @( '' ),
        [string]$DefaultInput  = 'c',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Please add all your global zones you want to add:' `
        -Entries @(
            @{
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'If you have configured custom global zones you require on this Windows host, please add all of them in this list. Default zones like "director-global" and "global-templates" should not be configured here';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -AddConfig `
        -DefaultValues @( $Value ) `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-CustomZones' -Value 'Show-IcingaForWindowsInstallationMenuEnterCustomGlobalZones';

function Show-IcingaForWindowsInstallerMenuSelectGlobalZones()
{
    param (
        [array]$Value          = @(),
        [string]$DefaultInput  = '0',
        [switch]$JumpToSummary = $FALSE,
        [switch]$Automated     = $FALSE,
        [switch]$Advanced      = $FALSE
    );

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Which default Icinga global zones do you want to add?' `
        -Entries @(
            @{
                'Caption' = 'Add "director-global" and "global-templates" zones';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Adds both global zones, "director-global" and "global-templates" as the default installer would. Depending on your environment these might be mandatory.';
            },
            @{
                'Caption' = 'Add "director-global" zone';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Only add the global zone "director-global" to your configuration which might be required if you are using the Icinga Director, depending on your configuration.';
            },
            @{
                'Caption' = 'Add "global-templates" zone';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Only add the global zone "global-templates" to your configuration';
            },
            @{
                'Caption' = 'Add no default global zone';
                'Command' = 'Show-IcingaForWindowsInstallerConfigurationSummary';
                'Help'    = 'Do not add any default global zones to your configuration';
            }
        ) `
        -DefaultIndex $DefaultInput `
        -JumpToSummary:$JumpToSummary `
        -ConfigElement `
        -Automated:$Automated `
        -Advanced:$Advanced;
}

Set-Alias -Name 'IfW-GlobalZones' -Value 'Show-IcingaForWindowsInstallerMenuSelectGlobalZones';

function Show-IcingaForWindowsMenuManageIcingaAgent()
{
    $IcingaService = Get-Service 'icinga2' -ErrorAction SilentlyContinue;
    $AdminShell    = $global:Icinga.InstallWizard.AdminShell;
    $ServiceStatus = $null;

    if ($null -ne $IcingaService) {
        $ServiceStatus = $IcingaService.Status;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga Agent:' `
        -Entries @(
            @{
                'Caption'  = 'Manage Features';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgentFeatures';
                'Help'     = 'Allows you to install Icinga for Windows with all required components and options';
                'Disabled' = ($null -eq $IcingaService -Or (-Not $AdminShell));
            },
            @{
                'Caption'  = 'Read Icinga Agent Log File';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows to read the Icinga Agent log file in case the "mainlog" feature of the Icinga Agent is enabled';
                'Disabled' = ((-Not $AdminShell) -Or -Not (Test-IcingaAgentFeatureEnabled -Feature 'mainlog'));
                'Action'   = @{
                    'Command'   = 'Start-Process';
                    'Arguments' = @{ '-FilePath' = 'powershell.exe'; '-ArgumentList' = "-Command  `"&{ icinga { Read-IcingaAgentLogFile; }; }`"" };
                }
            },
            @{
                'Caption'  = 'Read Icinga Debug Log File';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows to read the Icinga Agent debug log file in case the "debuglog" feature of the Icinga Agent is enabled';
                'Disabled' = ((-Not $AdminShell) -Or -Not (Test-IcingaAgentFeatureEnabled -Feature 'debuglog'));
                'Action'   = @{
                    'Command'   = 'Start-Process';
                    'Arguments' = @{ '-FilePath' = 'powershell.exe'; '-ArgumentList' = "-Command  `"&{ icinga { Read-IcingaAgentDebugLogFile; }; }`"" };
                }
            },
            @{
                'Caption'  = 'Flush API directory (will restart Agent)';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to flush the Icinga Agent API directory for cleanup. This will restart the Icinga Agent';
                'Disabled' = ($null -eq $IcingaService -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Clear-IcingaAgentApiDirectory';
                    'Arguments' = @{ '-Force' = $TRUE };
                }
            },
            @{
                'Caption'  = 'Start Icinga Agent';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to start the Icinga Agent if the service is not running';
                'Disabled' = ($null -eq $IcingaService -Or $ServiceStatus -eq 'Running' -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Start-Service';
                    'Arguments' = @{ '-Name' = 'icinga2'; };
                }
            },
            @{
                'Caption'  = 'Stop Icinga Agent';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to stop the Icinga Agent if the service is not running';
                'Disabled' = ($null -eq $IcingaService -Or $ServiceStatus -ne 'Running' -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Stop-Service';
                    'Arguments' = @{ '-Name' = 'icinga2'; };
                }
            },
            @{
                'Caption'  = 'Restart Icinga Agent';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to restart the Icinga Agent if the service is installed';
                'Disabled' = ($null -eq $IcingaService -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Restart-Service';
                    'Arguments' = @{ '-Name' = 'icinga2'; };
                }
            }
        );
}

function Show-IcingaForWindowsMenuManageIcingaAgentFeatures()
{
    $Features = Get-IcingaAgentFeatures;

    [array]$FeatureList = @();

    foreach ($entry in $Features.Enabled) {

        if ([string]::IsNullOrEmpty($entry)) {
            continue;
        }

        [string]$Caption = [string]::Format('{0}: Enabled', $entry);

        $FeatureList += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgentFeatures';
            'Help'     = ([string]::Format('The feature "{0}" is currently enabled. Select this entry to disable it.', $entry));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Disable-IcingaAgentFeature';
                'Arguments' = @{
                    '-Feature' = $entry;
                }
            }
        }
    }

    foreach ($entry in $Features.Disabled) {

        if ([string]::IsNullOrEmpty($entry)) {
            continue;
        }

        [string]$Caption = [string]::Format('{0}: Disabled', $entry);

        $FeatureList += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgentFeatures';
            'Help'     = ([string]::Format('The feature "{0}" is currently disabled. Select this entry to enable it.', $entry));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Enable-IcingaAgentFeature';
                'Arguments' = @{
                    '-Feature' = $entry;
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga Agent Features. Select an entry and hit enter to Disable/Enable them:' `
        -Entries $FeatureList;
}

function Invoke-IcingaForWindowsManagementConsoleReconfigureAgent()
{
    $LiveConfig = Get-IcingaPowerShellConfig -Path 'Framework.Config.Live';

    if ($null -eq $LiveConfig) {
        $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsMenuManageIcingaAgent';
        $global:Icinga.InstallWizard.LastError   = 'Unable to load any previous live configuration. Reconfiguring not possible.';
        return;
    }

    $global:Icinga.InstallWizard.Config      = Convert-IcingaForwindowsManagementConsoleJSONConfig -Config $LiveConfig;
    $global:Icinga.InstallWizard.NextCommand = 'Show-IcingaForWindowsInstallerConfigurationSummary';
}

function Show-IcingaForWindowsManagementConsoleFrameworkExperimental()
{
    $ApiChecks = Get-IcingaFrameworkApiChecks;

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows experimental features. Not recommended for production!' `
        -Entries @(
            @{
                'Caption'  = ([string]::Format('Forward checks to Api: {0}', (& { if ($ApiChecks) { 'Enabled' } else { 'Disabled' } } )));
                'Command'  = 'Show-IcingaForWindowsManagementConsoleFrameworkExperimental';
                'Help'     = 'In case enabled, all check commands executed by "Exit-IcingaExecutePlugin" are forwarded to an internal REST-Api and executed from within the Icinga for Windows background daemon. Requires the Icinga for Windows background daemon and the modules "icinga-powershell-restapi" and "icinga-powershell-apichecks"';
                'Disabled' = $FALSE;
                'Action'   = @{
                    'Command'   = 'Invoke-IcingaForWindowsMangementConsoleToogleFrameworkApiChecks';
                    'Arguments' = @{ };
                }
            }
        );
}

function Show-IcingaForWindowsManagementConsoleManageFramework()
{
    $FrameworkDebug     = Get-IcingaFrameworkDebugMode;
    $IcingaService      = Get-Service 'icingapowershell' -ErrorAction SilentlyContinue;
    $AdminShell         = $global:Icinga.InstallWizard.AdminShell;
    $ServiceStatus      = $null;

    if ($null -ne $IcingaService) {
        $ServiceStatus = $IcingaService.Status;
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows:' `
        -Entries @(
            @{
                'Caption'  = 'Manage background daemons';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageBackgroundDaemons';
                'Help'     = 'Allows you to manage Icinga for Windows background daemons';
                'Disabled' = ($null -eq (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue));
            },
            @{
                'Caption'  = ([string]::Format('Framework Debug Mode: {0}', (& { if ($FrameworkDebug) { 'Enabled' } else { 'Disabled' } } )));
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Disable or enable the Icinga PowerShell Framework debug mode';
                'Disabled' = $FALSE;
                'Action'   = @{
                    'Command'   = 'Invoke-IcingaForWindowsMangementConsoleToogleFrameworkDebug';
                    'Arguments' = @{ };
                }
            },
            @{
                'Caption' = 'Update Framework Code Cache';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'    = 'Updates the Icinga PowerShell Framework Code Cache';
                'Action'  = @{
                    'Command'   = 'Write-IcingaFrameworkCodeCache';
                    'Arguments' = @{ };
                }
            },
            @{
                'Caption'  = 'Allow untrusted certificate communication (this session only)';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Enables the Icinga untrusted certificate validation, allowing you to communicate with web servers which ships with a self-signed certificate not installed on this system. This applies only to this PowerShell session and is not permanent. Might be helpful in case you want to connect to the Icinga Director and the SSL is not trusted by this host';
                'Disabled' = $FALSE
                'Action'   = @{
                    'Command'   = 'Enable-IcingaUntrustedCertificateValidation';
                    'Arguments' = @{ };
                }
            },
            @{
                'Caption'  = 'Configure experimental features';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleFrameworkExperimental';
                'Help'     = 'Allows you to manage experimental features for Icinga for Windows';
                'Disabled' = $FALSE
            },
            @{
                'Caption'  = 'Start Icinga for Windows Service';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Allows you to start the Icinga for Windows Service if the service is not running';
                'Disabled' = ($null -eq $IcingaService -Or $ServiceStatus -eq 'Running' -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Start-Service';
                    'Arguments' = @{ '-Name' = 'icingapowershell'; };
                }
            },
            @{
                'Caption'  = 'Stop Icinga for Windows Service';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Allows you to stop the Icinga for Windows Service if the service is not running';
                'Disabled' = ($null -eq $IcingaService -Or $ServiceStatus -ne 'Running' -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Stop-Service';
                    'Arguments' = @{ '-Name' = 'icingapowershell'; };
                }
            },
            @{
                'Caption'  = 'Restart Icinga for Windows Service';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'     = 'Allows you to restart the Icinga for Windows Service if the service is installed';
                'Disabled' = ($null -eq $IcingaService -Or (-Not $AdminShell));
                'Action'   = @{
                    'Command'   = 'Restart-Service';
                    'Arguments' = @{ '-Name' = 'icingapowershell'; };
                }
            }
        );
}

function Invoke-IcingaForWindowsMangementConsoleToogleFrameworkApiChecks()
{
    if (Get-IcingaFrameworkApiChecks) {
        Disable-IcingaFrameworkApiChecks;
    } else {
        Enable-IcingaFrameworkApiChecks;
    }
}

function Invoke-IcingaForWindowsMangementConsoleToogleFrameworkDebug()
{
    if (Get-IcingaFrameworkDebugMode) {
        Disable-IcingaFrameworkDebugMode;
    } else {
        Enable-IcingaFrameworkDebugMode;
    }
}

function Show-IcingaForWindowsManagementConsoleManageBackgroundDaemons()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage the Icinga for Windows background daemons:' `
        -Entries @(
            @{
                'Caption'  = 'Register background daemon';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleRegisterBackgroundDaemons';
                'Help'     = 'Allows you to register a new background daemon for Icinga for Windows';
                'Disabled' = $FALSE;
            },
            @{
                'Caption'  = 'Unregister background daemon';
                'Command'  = 'Show-IcingaForWindowsManagementConsoleUnregisterBackgroundDaemons';
                'Help'     = 'Remove registered Icinga for Windows background daemons';
                'Disabled' = $FALSE;
            }
        );
}

function Show-IcingaForWindowsManagementConsoleRegisterBackgroundDaemons()
{
    [array]$AvailableDaemons = @();
    $ModuleList              = Get-Module 'icinga-powershell-*' -ListAvailable;

    $AvailableDaemons += @{
        'Caption'  = 'Register background daemon "Start-IcingaServiceCheckDaemon"';
        'Command'  = 'Show-IcingaForWindowsManagementConsoleRegisterBackgroundDaemons';
        'Help'     = ((Get-Help 'Start-IcingaServiceCheckDaemon' -Full).Description.Text);
        'Disabled' = $FALSE;
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Register background daemon "Start-IcingaServiceCheckDaemon"';
                '-Command'      = 'Register-IcingaBackgroundDaemon';
                '-CmdArguments' = @{
                    '-Command' = 'Start-IcingaServiceCheckDaemon';
                }
            }
        }
    }

    foreach ($module in $ModuleList) {

        $ModuleInfo = $null;

        Import-LocalizedData -BaseDirectory (Join-Path -Path (Get-IcingaForWindowsRootPath) -ChildPath $module.Name) -FileName ([string]::Format('{0}.psd1', $module.Name)) -BindingVariable ModuleInfo -ErrorAction SilentlyContinue;

        if ($null -eq $ModuleInfo -Or $null -eq $ModuleInfo.PrivateData -Or $null -eq $ModuleInfo.PrivateData.Type -Or ([string]::IsNullOrEmpty($ModuleInfo.PrivateData.Type)) -Or $ModuleInfo.PrivateData.Type -ne 'daemon' -Or $null -eq $ModuleInfo.PrivateData.Function -Or ([string]::IsNullOrEmpty($ModuleInfo.PrivateData.Function))) {
            continue;
        }

        $HelpObject  = Get-Help ($ModuleInfo.PrivateData.Function) -Full -ErrorAction SilentlyContinue;
        $HelpText    = '';
        $Caption     = [string]::Format('Register background daemon "{0}"', ($ModuleInfo.PrivateData.Function));

        if ($null -ne $HelpObject) {
            $HelpText = $HelpObject.Description.Text;
        }

        $AvailableDaemons += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsManagementConsoleRegisterBackgroundDaemons';
            'Help'     = $HelpText;
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = $Caption;
                    '-Command'      = 'Register-IcingaBackgroundDaemon';
                    '-CmdArguments' = @{
                        '-Command' = $ModuleInfo.PrivateData.Function;
                    }
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Register Icinga for Windows background daemon:' `
        -Entries $AvailableDaemons;
}

function Show-IcingaForWindowsManagementConsoleUnregisterBackgroundDaemons()
{
    [array]$RegisteredDaemons = @();

    $BackgroundDaemons = Get-IcingaBackgroundDaemons;

    foreach ($daemon in $BackgroundDaemons.Keys) {
        $DaemonValue = $BackgroundDaemons[$daemon];
        $HelpObject  = Get-Help $daemon -Full -ErrorAction SilentlyContinue;
        $HelpText    = '';
        $Caption     = [string]::Format('Unregister background daemon "{0}"', $daemon);

        if ($null -ne $HelpObject) {
            $HelpText = $HelpObject.Description.Text;
        }

        $RegisteredDaemons += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsManagementConsoleUnregisterBackgroundDaemons';
            'Help'     = $HelpText;
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = $Caption;
                    '-Command'      = 'Unregister-IcingaBackgroundDaemon';
                    '-CmdArguments' = @{
                        '-BackgroundDaemon' = $daemon;
                    }
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Unregister Icinga for Windows background daemon:' `
        -Entries $RegisteredDaemons;
}

function Show-IcingaForWindowsMenuInstallComponents()
{
    $IcingaInstallation      = Get-IcingaComponentList;
    $CurrentComponents       = Get-IcingaInstallation -Release;
    [int]$MaxComponentLength = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Components.Keys;
    [array]$InstallList      = @();

    foreach ($entry in $IcingaInstallation.Components.Keys) {
        $LatestVersion = $IcingaInstallation.Components[$entry];
        $LockedVersion = Get-IcingaComponentLock -Name $entry;
        $VersionText   = $LatestVersion;

        # Only show not installed components
        if ($CurrentComponents.ContainsKey($entry)) {
            continue;
        }

        if ($null -ne $LockedVersion) {
            $VersionText   = [string]::Format('{0}*', $LockedVersion);
            $LatestVersion = $LockedVersion;
        }

        $InstallList += @{
            'Caption'  = ([string]::Format('{0} [{1}]', (Add-IcingaWhiteSpaceToString -Text $entry -Length $MaxComponentLength), $VersionText));
            'Command'  = 'Show-IcingaForWindowsMenuInstallComponents';
            'Help'     = ([string]::Format('This will install the component "{0}" with version "{1}"', $entry, $VersionText));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = ([string]::Format('Install component "{0}" with version "{1}"', $entry, $VersionText));
                    '-Command'      = 'Install-IcingaComponent';
                    '-CmdArguments' = @{
                        '-Name'    = $entry;
                        '-Version' = $LatestVersion;
                        '-Release' = $TRUE;
                        '-Confirm' = $TRUE;
                    }
                }
            }
        }
    }

    if ($InstallList.Count -ne 0) {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'Install Icinga for Windows components. Select an entry to continue:' `
            -Entries $InstallList;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no packages found for installation'
    }
}

function Show-IcingaForWindowsMenuManage()
{
    Show-IcingaForWindowsInstallerMenu `
        -Header 'Manage Icinga for Windows:' `
        -Entries @(
            @{
                'Caption'  = 'Icinga Agent';
                'Command'  = 'Show-IcingaForWindowsMenuManageIcingaAgent';
                'Help'     = 'Allows you to manage the installed Icinga Agent';
                'Disabled' = (-Not ([bool](Get-Service 'icinga2' -ErrorAction SilentlyContinue)));
            },
            @{
                'Caption' = 'Icinga PowerShell Framework';
                'Command' = 'Show-IcingaForWindowsManagementConsoleManageFramework';
                'Help'    = 'Allows you to modify certain settings for the Icinga PowerShell Framework and to register background daemons';
            }<#,
            @{
                'Caption' = 'Health Check';
                'Command' = '';
                'Help'    = 'Check the current health and status information of your installation';
            }#>
        );
}

function Show-IcingaForWindowsMenuRemoveComponents()
{

    [array]$UninstallFeatures   = @();
    $AgentInstalled             = Get-Service -Name 'icinga2' -ErrorAction SilentlyContinue;
    $PowerShellServiceInstalled = Get-Service -Name 'icingapowershell' -ErrorAction SilentlyContinue;
    $IcingaWindowsServiceData   = Get-IcingaForWindowsServiceData;
    $ModuleList                 = Get-Module 'icinga-powershell-*' -ListAvailable;

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga Agent';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'Will remove the Icinga Agent from this system. Please note that this option will leave content inside "ProgramData", like certificates, alone'
        'Disabled' = ($null -eq $AgentInstalled);
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga Agent';
                '-Command'      = 'Uninstall-IcingaComponent';
                '-CmdArguments' = @{
                    '-Name' = 'agent';
                }
            }
        }
    }

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga Agent (include ProgramData)';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'Will remove the Icinga Agent from this system. Please note that this option will leave content inside "ProgramData", like certificates, alone'
        'Disabled' = (-Not (Test-Path -Path (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2')));
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga Agent (include ProgramData)';
                '-Command'      = 'Uninstall-IcingaComponent';
                '-CmdArguments' = @{
                    '-Name'               = 'agent';
                    '-RemovePackageFiles' = $TRUE;
                }
            }
        }
    }

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga for Windows Service';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'This will remove the icingapowershell service for Icinga for Windows if installed'
        'Disabled' = ($null -eq $PowerShellServiceInstalled);
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga for Windows service';
                '-Command'      = 'Uninstall-IcingaComponent';
                '-CmdArguments' = @{
                    '-Name' = 'service';
                }
            }
        }
    }

    $UninstallFeatures += @{
        'Caption'  = 'Uninstall Icinga for Windows Service (include files)';
        'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
        'Help'     = 'This will remove the icingapowershell service for Icinga for Windows if installed and the service binary including the folder, if empty afterwards'
        'Disabled' = (-Not (Test-Path $IcingaWindowsServiceData.Directory));
        'Action'   = @{
            'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
            'Arguments' = @{
                '-Caption'      = 'Uninstall Icinga for Windows service (include files)';
                '-Command'      = 'Uninstall-IcingaComponent';
                '-CmdArguments' = @{
                    '-Name'               = 'service';
                    '-RemovePackageFiles' = $TRUE;
                }
            }
        }
    }

    foreach ($module in $ModuleList) {
        $ComponentName = $module.Name.Replace('icinga-powershell-', '');
        $Caption       = ([string]::Format('Uninstall component "{0}"', $ComponentName));

        if ($ComponentName -eq 'framework' -Or $ComponentName -eq 'service' -Or $ComponentName -eq 'agent') {
            continue;
        }

        $UninstallFeatures += @{
            'Caption'  = $Caption;
            'Command'  = 'Show-IcingaForWindowsMenuRemoveComponents';
            'Help'     = ([string]::Format('This will remove the Icinga for Windows component "{0}" from this host', $ComponentName));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = $Caption;
                    '-Command'      = 'Uninstall-IcingaComponent';
                    '-CmdArguments' = @{
                        '-Name' = $ComponentName;
                    }
                }
            }
        }
    }

    Show-IcingaForWindowsInstallerMenu `
        -Header 'Uninstall Icinga for Windows components. Select an entry to continue:' `
        -Entries $UninstallFeatures;
}

function Show-IcingaForWindowsMenuUpdateComponents()
{
    $IcingaInstallation      = Get-IcingaInstallation -Release;
    [int]$MaxComponentLength = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Keys;
    [array]$UpdateList       = @();

    foreach ($entry in $IcingaInstallation.Keys) {
        $Component = $IcingaInstallation[$entry];

        $LatestVersion = $Component.LatestVersion;
        if ([string]::IsNullOrEmpty($Component.LockedVersion) -eq $FALSE) {
            if ([Version]$Component.CurrentVersion -ge [Version]$Component.LockedVersion) {
                continue;
            }
            $LatestVersion = [string]::Format('{0}*', $Component.LockedVersion);
        }

        if ([string]::IsNullOrEmpty($LatestVersion)) {
            continue;
        }

        $UpdateList += @{
            'Caption'  = ([string]::Format('{0} [{1}] => [{2}]', (Add-IcingaWhiteSpaceToString -Text $entry -Length $MaxComponentLength), $Component.CurrentVersion, $LatestVersion));
            'Command'  = 'Show-IcingaForWindowsMenuUpdateComponents';
            'Help'     = ([string]::Format('This will update the component "{0}" from current version "{1}" to stable version "{2}"', $entry, $Component.CurrentVersion, $LatestVersion));
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = ([string]::Format('Update component "{0}" from version "{1}" to stable version "{2}"', $entry, $Component.CurrentVersion, $LatestVersion));
                    '-Command'      = 'Update-Icinga';
                    '-CmdArguments' = @{
                        '-Name'    = $entry;
                        '-Release' = $TRUE;
                        '-Confirm' = $TRUE;
                    }
                }
            }
        }
    }

    if ($UpdateList.Count -ne 0) {
        $UpdateList += @{
            'Caption'  = 'Update entire environment';
            'Command'  = 'Show-IcingaForWindowsMenuUpdateComponents';
            'Help'     = 'This will update all components listed above to the mentioned stable version'
            'Disabled' = $FALSE;
            'Action'   = @{
                'Command'   = 'Show-IcingaWindowsManagementConsoleYesNoDialog';
                'Arguments' = @{
                    '-Caption'      = 'Update entire Icinga for Windows environment';
                    '-Command'      = 'Update-Icinga';
                    '-CmdArguments' = @{
                        '-Release' = $TRUE;
                        '-Confirm' = $TRUE;
                    }
                }
            }
        }

        Show-IcingaForWindowsInstallerMenu `
            -Header 'Updates Icinga for Windows components. Select an entry to continue:' `
            -Entries $UpdateList;
    } else {
        Show-IcingaForWindowsInstallerMenu `
            -Header 'There are no updates pending for your environment'
    }
}

function Test-IcingaForWindowsInstallerParentEndpoints()
{
    $Selection = Get-IcingaForWindowsInstallerStepSelection -InstallerStep 'Show-IcingaForWindowsInstallerMenuSelectConnection';

    # Agents connects, therefor validate this setting. 1 only accepts connections from parent
    if ($Selection -ne 1) {
        $Values          = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes';
        $NetworkMap      = @{ };
        [bool]$HasErrors = $FALSE;

        foreach ($endpoint in $Values) {
            $Address     = Get-IcingaForWindowsInstallerValuesFromStep -InstallerStep 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' -Parent $endpoint;
            $TestAddress = $Address;
            if ($null -eq $Address -Or $Address.Count -eq 0) {
                $TestAddress = $endpoint;
            }

            $Resolved = Convert-IcingaEndpointsToIPv4 -NetworkConfig $TestAddress;

            if ($Resolved.HasErrors) {
                $Address   = $endpoint;
                $HasErrors = $TRUE;
            } else {
                $Address = $Resolved.Network[0];
            }

            $NetworkMap.Add(
                $endpoint,
                @{
                    'Endpoint' = $endpoint;
                    'Address'  = $Address;
                    'Error'    = $Resolved.HasErrors;
                }
            );

            Add-IcingaForWindowsInstallerConfigEntry -Selection 'c' -Values $Address -OverwriteValues `
                -OverwriteMenu 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses' `
                -OverwriteParent ([string]::Format('Show-IcingaForWindowsInstallerMenuEnterIcingaParentNodes:{0}', $endpoint));
        }

        if ($HasErrors) {
            $global:Icinga.InstallWizard.NextCommand   = 'Show-IcingaForWindowsInstallerMenuEnterIcingaParentAddresses';
            $global:Icinga.InstallWizard.NextArguments = @{ 'Value' = $NetworkMap };
            return;
        }
    }

    $global:Icinga.InstallWizard.NextCommand   = 'Add-IcingaForWindowsInstallationAdvancedEntries';
}

function Add-IcingaForWindowsInstallerConfigEntry()
{
    param (
        [string]$Selection       = $null,
        [array]$Values           = @(),
        [switch]$Hidden          = $FALSE,
        [switch]$PasswordInput   = $FALSE,
        [switch]$OverwriteValues = $FALSE,
        [string]$OverwriteMenu   = '',
        [string]$OverwriteParent = '',
        [switch]$Advanced        = $FALSE
    );

    if ([string]::IsNullOrEmpty($OverwriteMenu) -eq $FALSE) {
        $Step = $OverwriteMenu;
    } else {
        $Step = Get-IcingaForWindowsManagementConsoleMenu;
    }
    if ([string]::IsNullOrEmpty($OverwriteParent) -eq $FALSE) {
        $Parent = $OverwriteParent;
    } else {
        $Parent = $global:Icinga.InstallWizard.ParentConfig;
    }

    $ConfigIndex  = $global:Icinga.InstallWizard.Config.Count;
    $ParentEntry  = $null;

    $Parent = Get-IcingaForWindowsManagementConsoleAlias -Command $Parent;
    $Step   = Get-IcingaForWindowsManagementConsoleAlias -Command $Step;

    if ([string]::IsNullOrEmpty($Parent) -eq $FALSE) {
        $ParentEntry = $Parent.Split(':')[1];
        $Parent = $Parent.Split(':')[0];
        $Step = [string]::Format('{0}:{1}', $Step, $ParentEntry);
    }

    if ($global:Icinga.InstallWizard.Config.ContainsKey($Step) -eq $FALSE) {
        $global:Icinga.InstallWizard.Config.Add(
            $Step,
            @{
                'Selection'   = $Selection;
                'Values'      = $Values
                'Index'       = $ConfigIndex;
                'Parent'      = $Parent;
                'ParentEntry' = $ParentEntry;
                'Hidden'      = [bool]$Hidden;
                'Password'    = [bool]$PasswordInput;
                'Advanced'    = [bool]$Advanced;
                'Modified'    = ($Advanced -eq $FALSE);
            }
        );
    } else {
        $global:Icinga.InstallWizard.Config[$Step].Selection = $Selection;
        $global:Icinga.InstallWizard.Config[$Step].Values    = $Values;
        $global:Icinga.InstallWizard.Config[$Step].Modified  = $TRUE;
    }

    Write-IcingaforWindowsManagementConsoleConfigSwap -Config $global:Icinga.InstallWizard.Config;
}

function Get-IcingaForWindowsManagementConsoleAlias()
{
    param (
        [string]$Command
    );

    if ([string]::IsNullOrEmpty($Command)) {
        return '';
    }

    $ParentEntry = $null;

    if ($Command.Contains(':')) {
        $KeyValue    = $Command.Split(':');
        $Command     = $KeyValue[0];
        $ParentEntry = $KeyValue[1];
    }

    $CommandAlias = Get-Alias -Definition $Command -ErrorAction SilentlyContinue;

    if ($null -ne $CommandAlias) {
        $Command = $CommandAlias.Name;
    }

    if ([string]::IsNullOrEmpty($ParentEntry) -eq $FALSE) {
        $Command = [string]::Format('{0}:{1}', $Command, $ParentEntry);
    }

    return $Command;
}

function Clear-IcingaForWindowsInstallerValuesFromStep()
{
    $Step = Get-IcingaForWindowsManagementConsoleMenu;

    if ($global:Icinga.InstallWizard.Config.ContainsKey($Step) -eq $FALSE) {
        return;
    }

    if ($null -eq $global:Icinga.InstallWizard.Config[$Step].Values) {
        return;
    }

    $global:Icinga.InstallWizard.Config[$Step].Values = @();
}

function Remove-IcingaForWindowsInstallerConfigEntry()
{
    param (
        [string]$Menu,
        [string]$Parent
    );

    $Menu = Get-IcingaForWindowsManagementConsoleAlias -Command $Menu;

    if ([string]::IsNullOrEmpty($Parent) -eq $FALSE) {
        $Menu = [string]::Format('{0}:{1}', $Menu, $Parent);
    }

    if ($global:Icinga.InstallWizard.Config.ContainsKey($Menu)) {
        $global:Icinga.InstallWizard.Config.Remove($Menu);
    }

    Write-IcingaforWindowsManagementConsoleConfigSwap -Config $global:Icinga.InstallWizard.Config;
}

function Get-IcingaForWindowsManagementConsoleConfigurationString()
{
    param (
        [switch]$Compress = $FALSE
    );

    [hashtable]$Configuration = @{ };

    foreach ($entry in $Global:Icinga.InstallWizard.Config.Keys) {
        $Value = $Global:Icinga.InstallWizard.Config[$entry];

        # Only print arguments that contain changes
        if ($Value.Modified -eq $FALSE) {
            continue;
        }

        $Command = $entry;
        $Parent  = $null;

        # Handle configurations with parent dependencies
        if ($entry.Contains(':')) {
            $KeyValue = $entry.Split(':');
            $Command  = $KeyValue[0];
            $Parent   = $KeyValue[1];
        }

        if ($Configuration.ContainsKey($Command) -eq $FALSE) {
            $Configuration.Add($Command, @{ });
        }

        # No parent exist, just add the values
        if ([string]::IsNullOrEmpty($Parent)) {
            if ($null -ne $Value.Values -And $Value.Values.Count -ne 0) {
                [array]$ConfigValues = @();

                foreach ($element in $Value.Values) {
                    if ([string]::IsNullOrEmpty($element) -eq $FALSE) {
                        $ConfigValues += $element;
                    }
                }

                if ($ConfigValues.Count -ne 0) {
                    $Configuration[$Command].Add(
                        'Values', $ConfigValues
                    );
                }
            }
        } else {
            # Handle parent references
            [hashtable]$ParentConfig = @{ };

            if ($Configuration[$Command].ContainsKey('Values')) {
                $ParentConfig = $Configuration[$Command].Values;
            }

            $ParentConfig.Add(
                $Value.ParentEntry,
                $Value.Values
            );

            $Configuration[$Command].Values = $ParentConfig;
        }

        if ($Configuration[$Command].ContainsKey('Selection')) {
            continue;
        }

        if ([string]::IsNullOrEmpty($Value.Selection) -eq $FALSE -And $Value.Selection -ne 'c') {
            $Configuration[$Command].Add(
                'Selection', $Value.Selection
            );
        }

        if ($Configuration[$Command].Count -eq 0) {
            $Configuration.Remove($Command);
        }
    }

    return ($Configuration | ConvertTo-Json -Depth 100 -Compress:$Compress);
}

function Add-IcingaForWindowsManagementConsoleLastParent()
{
    $Menu = Get-IcingaForWindowsManagementConsoleAlias -Command (Get-IcingaForWindowsManagementConsoleMenu);

    if ($Menu -eq (Get-IcingaForWindowsInstallerLastParent)) {
        return;
    }

    # Do not add Yes/No Dialog to the list
    if ($Menu -eq 'Show-IcingaWindowsManagementConsoleYesNoDialog') {
        return;
    }

    $global:Icinga.InstallWizard.LastParent.Add($Menu) | Out-Null;
}

function Invoke-IcingaForWindowsManagementConsoleCustomConfig()
{
    param (
        [hashtable]$IcingaConfiguration = @{ }
    );

    foreach ($cmd in $IcingaConfiguration.Keys) {
        $cmdConfig = $IcingaConfiguration[$cmd];

        if ($cmd.Contains(':')) {
            continue; # skip for now, as more complicated
        }

        $cmdArguments = @{
            'Automated' = $TRUE;
        }

        if ($cmdConfig.ContainsKey('Values') -And $null -ne $cmdConfig.Values) {
            $cmdArguments.Add('Value', $cmdConfig.Values)
        }
        if ($cmdConfig.ContainsKey('Selection') -And $null -ne $cmdConfig.Selection) {
            $cmdArguments.Add('DefaultInput', $cmdConfig.Selection)
        }

        &$cmd @cmdArguments;
    }
}

function Reset-IcingaForWindowsManagementConsoleInstallationDirectorConfigModifyState()
{
    foreach ($entry in $Global:Icinga.InstallWizard.Config.Keys) {

        if ($entry -eq 'IfW-DirectorUrl' -Or $entry -eq 'IfW-DirectorSelfServiceKey') {
            continue;
        }

        $Global:Icinga.InstallWizard.Config[$entry].Modified = $FALSE;
    }
}

function Get-IcingaForWindowsInstallerLastParent()
{
    if ($global:Icinga.InstallWizard.LastParent.Count -ne 0) {
        $Parent   = $global:Icinga.InstallWizard.LastParent[-1];
        return $Parent;
    }

    return $null;
}

function Get-IcingaInternalPowerShellServicePassword()
{
    if ($null -eq $global:Icinga -Or $Global:Icinga.ContainsKey('InstallerServicePassword') -eq $FALSE) {
        return $null;
    }

    return $Global:Icinga.InstallerServicePassword;
}

function Convert-IcingaForwindowsManagementConsoleJSONConfig()
{
    param (
        $Config
    );

    [int]$Index                 = 0;
    $MaxIndex                   = $Config.PSObject.Properties.Count;
    [string]$Menu               = '';
    [hashtable]$ConvertedConfig = @{ };

    while ($Index -lt $MaxIndex.Count) {
        foreach ($entry in $Config.PSObject.Properties) {

            if ($index -eq [int]$entry.Value.Index) {
                $ConvertedConfig.Add(
                    $entry.Name,
                    @{
                        'Selection'   = $entry.Value.Selection;
                        'Values'      = $entry.Value.Values;
                        'Index'       = $index;
                        'Parent'      = $entry.Value.Parent;
                        'ParentEntry' = $entry.Value.ParentEntry;
                        'Hidden'      = $entry.Value.Hidden;
                        'Password'    = $entry.Value.Password;
                        'Advanced'    = $entry.Value.Advanced;
                        'Modified'    = $entry.Value.Modified;
                    }
                );

                if ($entry.Value.Advanced -eq $FALSE) {
                    $global:Icinga.InstallWizard.LastParent.Add($entry.Name) | Out-Null;
                }
            }
        }
        $Index += 1;
    }

    return $ConvertedConfig;
}

function Get-IcingaForWindowsManagementConsoleMenu()
{
    if ($null -eq $global:Icinga -Or $null -eq $global:Icinga.InstallWizard) {
        return '';
    }

    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.Menu) -Or $global:Icinga.InstallWizard.Menu -eq 'break') {
        return '';
    }

    return (Get-IcingaForWindowsManagementConsoleAlias -Command $global:Icinga.InstallWizard.Menu);
}

function Clear-IcingaForWindowsManagementConsolePaginationCache()
{
    $global:Icinga.InstallWizard.LastParent.Clear();
}

function Remove-IcingaForWindowsInstallerLastParent()
{
    if ($global:Icinga.InstallWizard.LastParent.Count -ne 0) {
        $global:Icinga.InstallWizard.LastParent.RemoveAt($global:Icinga.InstallWizard.LastParent.Count - 1);
    }
}

function Set-IcingaForWindowsManagementConsoleMenu()
{
    param (
        [string]$Menu
    );

    if ([string]::IsNullOrEmpty($Menu) -Or $Menu -eq 'break') {
        return;
    }

    $global:Icinga.InstallWizard.Menu = (Get-IcingaForWindowsManagementConsoleAlias -Command $Menu);
}

function Set-IcingaInternalPowerShellServicePassword()
{
    param (
        [SecureString]$Password = $null
    );

    if ($null -eq $global:Icinga) {
        $Global:Icinga = @{
            'InstallerServicePassword' = $Password;
        }

        return;
    }

    if ($Global:Icinga.ContainsKey('InstallerServicePassword') -eq $FALSE) {
        $Global:Icinga.Add(
            'InstallerServicePassword',
            $Password
        )

        return;
    }

    $Global:Icinga.InstallerServicePassword = $Password;
}

function Show-IcingaForWindowsInstallerMenu()
{
    param (
        [string]$Header,
        [array]$Entries,
        [array]$DefaultValues        = @(),
        [string]$DefaultIndex        = $null,
        [string]$ParentConfig        = $null,
        [switch]$AddConfig           = $FALSE,
        [switch]$PasswordInput       = $FALSE,
        [switch]$ContinueFirstValue  = $FALSE,
        [switch]$MandatoryValue      = $FALSE,
        [int]$ConfigLimit            = -1,
        [switch]$JumpToSummary       = $FALSE,
        [string]$ContinueFunction    = $null,
        [switch]$ConfigElement       = $FALSE,
        [switch]$HiddenConfigElement = $FALSE,
        [switch]$ReadOnly       = $FALSE,
        [switch]$Automated           = $FALSE,
        [switch]$Advanced            = $FALSE
    );

    if ((Test-IcingaForWindowsInstallationHeaderPrint) -eq $FALSE -And (Get-IcingaFrameworkDebugMode) -eq $FALSE) {
        Clear-Host;
    }

    $PSCallStack   = Get-PSCallStack;
    $LastArguments = $null;
    $LastCommand   = $null;

    if ($PSCallStack.Count -gt 1) {
        $LastCommand   = $PSCallStack[1].Command;
        $LastArguments = $PSCallStack[1].InvocationInfo.BoundParameters;

        # Only keep internal values as long as we are navigating within the same menu
        if ($global:Icinga.InstallWizard.Menu -ne $LastCommand) {
            $global:Icinga.InstallWizard.LastValues = @();
        }

        # Prevent from adding ourself because of stack calls.
        # This should always be the "real" last command
        if ($LastCommand -ne 'Show-IcingaForWindowsInstallerMenu') {
            $global:Icinga.InstallWizard.Menu = $LastCommand;
        } else {
            $LastCommand = Get-IcingaForWindowsManagementConsoleMenu;
        }
    }

    $SelectionForCurrentMenu                  = Get-IcingaForWindowsInstallerStepSelection -InstallerStep (Get-IcingaForWindowsManagementConsoleMenu);
    [bool]$EntryModified                      = $FALSE;
    [int]$EntryIndex                          = 0;
    [hashtable]$KnownIndexes                  = @{ };
    $LastParent                               = Get-IcingaForWindowsInstallerLastParent;
    [array]$StoredValues                      = (Get-IcingaForWindowsInstallerValuesFromStep);
    $global:Icinga.InstallWizard.ParentConfig = $ParentConfig;
    $global:Icinga.InstallWizard.LastInput    = $null;

    if ($LastParent -eq (Get-IcingaForWindowsManagementConsoleAlias -Command $LastCommand)) {
        Remove-IcingaForWindowsInstallerLastParent;
        $LastParent = Get-IcingaForWindowsInstallerLastParent;
    }

    if (Test-IcingaForWindowsInstallationJumpToSummary) {
        $SelectionForCurrentMenu = $null;
    }

    if ($StoredValues.Count -eq 0 -And $DefaultValues.Count -ne 0) {
        $StoredValues = $DefaultValues;
    }

    if ($global:Icinga.InstallWizard.DeleteValues) {
        $StoredValues = @();
        $global:Icinga.InstallWizard.DeleteValues = $FALSE;
    }

    if ((Test-IcingaForWindowsInstallationHeaderPrint) -eq $FALSE) {

        $ConsoleHeaderLines = @(
            'Icinga for Windows Management Console',
            'Copyright $Copyright',
            'User environment $UserDomain\$Username',
            'Icinga PowerShell Framework $FrameworkVersion'
        );

        if ($global:Icinga.InstallWizard.AdminShell -eq $FALSE) {
            $ConsoleHeaderLines += '[Warning]: Run this shell as Administrator to unlock all features'
        }

        $ConsoleHeaderLines += @(
            'This is an experimental feature and might contain bugs',
            'Please provide us with feedback, issues and input at',
            'https://github.com/Icinga/icinga-powershell-framework/issues'
        )

        Write-IcingaConsoleHeader -HeaderLines $ConsoleHeaderLines;

        Write-IcingaConsolePlain '';
        Write-IcingaConsolePlain $Header;
        Write-IcingaConsolePlain '';
    }

    foreach ($entry in $Entries) {
        if ([string]::IsNullOrEmpty($entry.Caption) -eq $FALSE) {
            $Header    = ([string]::Format('[{0}] {1}', $EntryIndex, $entry.Caption));
            $FontColor = 'Default';

            if ((Test-IcingaForWindowsInstallationHeaderPrint) -eq $FALSE) {
                # Highlight the default index in a different color
                if ($DefaultIndex -eq $EntryIndex) {
                    $FontColor = 'Cyan';
                }

                # In case a entry is disabled, highlight it differently
                if ($null -ne $entry.Disabled -And $entry.Disabled -eq $TRUE) {
                    $FontColor = 'DarkGray';
                }

                # Mark our previous selection in another color for better highlighting
                if ($null -ne $SelectionForCurrentMenu -And $SelectionForCurrentMenu -eq $EntryIndex) {
                    $FontColor = 'Green';
                }

                Write-IcingaConsolePlain $Header -ForeColor $FontColor;

                if ($global:Icinga.InstallWizard.ShowHelp -And ([string]::IsNullOrEmpty($entry.Help)) -eq $FALSE) {
                    Write-IcingaConsolePlain '';
                    Write-IcingaConsolePlain $entry.Help -ForeColor Magenta;
                    Write-IcingaConsolePlain '';
                }
            } else {
                if ((Get-IcingaForWindowsInstallationHeaderSelection) -eq $EntryIndex) {
                    $global:Icinga.InstallWizard.HeaderPreview = $entry.Caption;
                    return;
                }
            }
        }

        $KnownIndexes.Add([string]$EntryIndex, $TRUE);
        $EntryIndex += 1;
    }

    if ((Test-IcingaForWindowsInstallationHeaderPrint)) {
        return;
    }

    if ($StoredValues.Count -ne 0) {
        if ($PasswordInput -eq $FALSE) {
            Write-IcingaConsolePlain ([string]::Format(' {0}', (ConvertFrom-IcingaArrayToString -Array $StoredValues -AddQuotes))) -ForeColor Cyan;
        } else {
            Write-IcingaConsolePlain ([string]::Format(' {0}', (ConvertFrom-IcingaArrayToString -Array $StoredValues -AddQuotes -SecureContent))) -ForeColor Cyan;
        }
    }

    if ($AddConfig) {
        if ($global:Icinga.InstallWizard.ShowHelp -And ([string]::IsNullOrEmpty($Entries[0].Help)) -eq $FALSE) {
            Write-IcingaConsolePlain '';
            Write-IcingaConsolePlain $entry.Help -ForeColor Magenta;
        }
    }

    $MenuNavigation = '[x] Exit';

    Write-IcingaConsolePlain '';

    if ($global:Icinga.InstallWizard.DisplayAdvanced) {
        $MenuNavigation = [string]::Format('{0} [a] Advanced', $MenuNavigation)
    }

    $MenuNavigation = [string]::Format('{0} [c] Continue', $MenuNavigation)

    if ($AddConfig -And $ReadOnly -eq $FALSE) {
        $MenuNavigation = [string]::Format('{0} [d] Delete', $MenuNavigation)
    }

    $MenuNavigation = [string]::Format('{0} [h] Help [m] Main', $MenuNavigation)

    if ([string]::IsNullOrEmpty($LastParent) -eq $FALSE -Or $global:Icinga.InstallWizard.LastParent.Count -gt 1) {
        $MenuNavigation = [string]::Format('{0} [p] Previous', $MenuNavigation)
    }

    Write-IcingaConsolePlain $MenuNavigation;

    $Prompt      = 'Input';
    $CountPrompt = ([string]::Format('({0}/{1})', $StoredValues.Count, $ConfigLimit));
    if ($ConfigLimit -eq -1) {
        $CountPrompt = ([string]::Format('({0} values)', $StoredValues.Count));
    }

    if ($AddConfig) {
        $Prompt = ([string]::Format('Input {0}', $CountPrompt));
        # In case we reached the maximum entries, set c as default input for easier handling
        if (($ConfigLimit -le $StoredValues.Count) -Or ($ContinueFirstValue -eq $TRUE -And $StoredValues.Count -ge 1)) {
            $DefaultIndex = 'c';
        }
    }

    if ([string]::IsNullOrEmpty($DefaultIndex) -eq $FALSE) {
        if ((Test-Numeric $DefaultIndex)) {
            $Prompt = [string]::Format('Input (Default {0} and c)', $DefaultIndex);
        } else {
            $Prompt = [string]::Format('Input (Default {0})', $DefaultIndex);
        }
        if ($AddConfig) {
            $Prompt = [string]::Format('{0} {1}', $Prompt, $CountPrompt);
        }
    }

    Write-IcingaConsolePlain '';

    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastError) -eq $FALSE) {
        Write-IcingaConsoleError ($global:Icinga.InstallWizard.LastError);
        $global:Icinga.InstallWizard.LastError = '';
        Write-IcingaConsolePlain '';
    }

    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastNotice) -eq $FALSE) {
        Write-IcingaConsoleNotice ($global:Icinga.InstallWizard.LastNotice);
        $global:Icinga.InstallWizard.LastNotice = '';
        Write-IcingaConsolePlain '';
    }

    if ($Automated -eq $FALSE) {
        $Result = Read-Host -Prompt $Prompt -AsSecureString:$PasswordInput;

        # Translate the value back to check what we used for input. We are not going to share
        # the content however
        if ($PasswordInput) {
            $Result = ConvertFrom-IcingaSecureString -SecureString $Result;
        }

        if ([string]::IsNullOrEmpty($Result) -And [string]::IsNullOrEmpty($DefaultIndex) -eq $FALSE) {
            $Result = $DefaultIndex;
        }
    } else {
        if ([string]::IsNullOrEmpty($DefaultIndex) -eq $FALSE) {
            $Result = $DefaultIndex;
        }
    }

    $global:Icinga.InstallWizard.NextCommand   = $LastCommand;
    $global:Icinga.InstallWizard.NextArguments = $LastArguments;
    $global:Icinga.InstallWizard.LastInput     = $Result;

    switch ($Result) {
        'x' {
            Clear-Host;
            $global:Icinga.InstallWizard.Closing = $TRUE;
            return;
        };
        'a' {
            $global:Icinga.InstallWizard.ShowAdvanced = (-Not ($global:Icinga.InstallWizard.ShowAdvanced));
            return;
        };
        'h' {
            $global:Icinga.InstallWizard.ShowHelp = (-Not ($global:Icinga.InstallWizard.ShowHelp));

            return;
        };
        'm' {
            $global:Icinga.InstallWizard.NextCommand   = $null;
            $global:Icinga.InstallWizard.NextArguments = $null;

            return;
        }
        'p' {
            if ([string]::IsNullOrEmpty($LastParent) -eq $FALSE) {
                Remove-IcingaForWindowsInstallerLastParent;

                $global:Icinga.InstallWizard.NextCommand   = $LastParent;
                $global:Icinga.InstallWizard.NextArguments = $null;

                return;
            }

            $global:Icinga.InstallWizard.LastError = 'You cannot move to the previous menu from here.';
            if ($global:Icinga.InstallWizard.LastParent.Count -eq 0) {
                $global:Icinga.InstallWizard.NextCommand   = $null;
                $global:Icinga.InstallWizard.NextArguments = $null;

                return;
            }

            return;
        };
        'd' {
            if ($ReadOnly -eq $FALSE) {
                $StoredValues = @();
                Clear-IcingaForWindowsInstallerValuesFromStep
                $global:Icinga.InstallWizard.DeleteValues = $TRUE;
                $global:Icinga.InstallWizard.LastValues = @();
            }

            return;
        };
        'c' {
            if ($MandatoryValue -And $StoredValues.Count -eq 0) {
                $global:Icinga.InstallWizard.LastError = 'You need to add at least one value!';

                return;
            }

            if ($AddConfig -eq $FALSE) {
                $Result = $DefaultIndex;
                $global:Icinga.InstallWizard.LastInput = $Result;
            }

            $global:Icinga.InstallWizard.LastValues = $StoredValues;

            break;
        };
        default {
            if ($AddConfig) {

                if ($ConfigLimit -eq -1 -Or $ConfigLimit -gt $StoredValues.Count) {
                    if ([string]::IsNullOrEmpty($Result) -eq $FALSE) {

                        $StoredValues += $Result;
                        if ($ConfigElement) {
                            Add-IcingaForWindowsInstallerConfigEntry -Values $StoredValues -Hidden:$HiddenConfigElement -PasswordInput:$PasswordInput -Advanced:$Advanced;
                        }

                        $global:Icinga.InstallWizard.LastValues = $StoredValues;
                    } else {
                        if ($DefaultValues.Count -ne 0) {
                            $global:Icinga.InstallWizard.LastNotice = 'Empty values are not allowed! Resetting to default.';
                        } else {
                            $global:Icinga.InstallWizard.LastError = 'You cannot add an empty value!';
                        }
                    }
                } else {
                    $global:Icinga.InstallWizard.LastError = [string]::Format('You can only add {0} value(s)', $ConfigLimit);
                }

                return;
            }
            if ((Test-Numeric $Result) -eq $FALSE -Or $KnownIndexes.ContainsKey([string]$Result) -eq $FALSE) {
                $global:Icinga.InstallWizard.LastError = [string]::Format('Invalid selection has been made: {0}', $Result);

                return;
            }

            break;
        };
    }

    $DisabledMenu  = $FALSE;
    $NextMenu      = $null;
    $NextArguments = @{ };
    $ActionCmd     = $null;
    $ActionArgs    = $null;

    if ([string]::IsNullOrEmpty($Result) -eq $FALSE) {
        if ($Result -eq 'c') {
            if ([string]::IsNullOrEmpty($ContinueFunction) -eq $FALSE) {
                $NextMenu = $ContinueFunction;
            } else {
                $NextMenu = $Entries[0].Command;
                if ($null -ne $Entries[0].Disabled) {
                    $DisabledMenu = $Entries[0].Disabled;
                }
            }
            $ActionCmd  = $Entries[0].Action.Command;
            $ActionArgs = $Entries[0].Action.Arguments;
        } else {
            $NextMenu = $Entries[$Result].Command;
            if ($null -ne $Entries[$Result].Disabled) {
                $DisabledMenu = $Entries[$Result].Disabled;
            }
            if ($Entries[$Result].ContainsKey('Arguments')) {
                $NextArguments = $Entries[$Result].Arguments;
            }
            $ActionCmd  = $Entries[$Result].Action.Command;
            $ActionArgs = $Entries[$Result].Action.Arguments;
        }
    }

    if ($DisabledMenu) {
        $global:Icinga.InstallWizard.LastNotice = [string]::Format('This menu is not enabled: {0}', $Result);

        return;
    }

    if ([string]::IsNullOrEmpty($NextMenu)) {
        $global:Icinga.InstallWizard.LastNotice = [string]::Format('This menu is not yet implemented: {0}', $Result);

        return;
    }

    if ($Advanced -eq $FALSE) {
        Add-IcingaForWindowsManagementConsoleLastParent;
    }

    if ($JumpToSummary) {
        $NextMenu = 'Show-IcingaForWindowsInstallerConfigurationSummary';
    }

    if ($ConfigElement) {
        Add-IcingaForWindowsInstallerConfigEntry `
            -InstallerStep (Get-IcingaForWindowsManagementConsoleMenu) `
            -Selection $Result `
            -Values $StoredValues `
            -Hidden:$HiddenConfigElement `
            -PasswordInput:$PasswordInput `
            -Advanced:$Advanced;
    }

    # Reset Help View
    $global:Icinga.InstallWizard.ShowHelp = $FALSE;

    if ($NextMenu -eq 'break') {
        return;
    }

    $global:Icinga.InstallWizard.NextCommand   = $NextMenu;
    $global:Icinga.InstallWizard.NextArguments = $NextArguments;

    if ($Automated) {
        return;
    }

    # In case a action is defined, execute the given action
    if ([string]::IsNullOrEmpty($ActionCmd) -eq $FALSE) {
        if ($null -eq $ActionArgs -Or $ActionArgs.Count -eq 0) {
            $ActionArgs = @{ };
        }

        & $ActionCmd @ActionArgs | Out-Null;
    }
}

function Get-IcingaForWindowsInstallerStepSelection()
{
    param (
        [string]$InstallerStep
    );

    if ([string]::IsNullOrEmpty($InstallerStep)) {
        $InstallerStep = Get-IcingaForWindowsManagementConsoleMenu;
    } else {
        $InstallerStep = Get-IcingaForWindowsManagementConsoleAlias -Command $InstallerStep;
    }

    if ($global:Icinga.InstallWizard.Config.ContainsKey($InstallerStep)) {
        return $global:Icinga.InstallWizard.Config[$InstallerStep].Selection;
    }

    return $null;
}

function Get-IcingaForWindowsInstallerValuesFromStep()
{
    param (
        [string]$InstallerStep,
        [string]$Parent
    );

    [array]$Values = @();

    $Step = Get-IcingaForWindowsManagementConsoleMenu;

    if ([string]::IsNullOrEmpty($InstallerStep) -eq $FALSE) {
        $Step = Get-IcingaForWindowsManagementConsoleAlias -Command $InstallerStep;

        if ([string]::IsNullOrEmpty($Parent) -eq $FALSE) {
            $Step = [string]::Format('{0}:{1}', $Step, $Parent);
        }
    }

    if ($global:Icinga.InstallWizard.Config.ContainsKey($Step) -eq $FALSE) {
        return @();
    }

    if ($null -eq $global:Icinga.InstallWizard.Config[$Step].Values) {
        return @();
    }

    return [array]($global:Icinga.InstallWizard.Config[$Step].Values);
}

function Write-IcingaforWindowsManagementConsoleConfigSwap()
{
    param (
        $Config = @{ }
    );

    [hashtable]$NewConfig = @{ };

    # Remove passwords - do not store them inside our local config file
    foreach ($entry in $Config.Keys) {
        $Value = $Config[$entry];

        $NewConfig.Add($entry, @{ });

        foreach ($configElement in $Value.Keys) {
            $confValue = $Value[$configElement];

            if ($Value.Password -eq $TRUE -And $configElement -eq 'Values') {
                $NewConfig[$entry].Add(
                    $configElement,
                    @( '***' )
                );
            } else {
                $NewConfig[$entry].Add(
                    $configElement,
                    $confValue
                );
            }
        }
    }

    Set-IcingaPowerShellConfig -Path 'Framework.Config.Swap' -Value $NewConfig;
}

function Test-IcingaForWindowsManagementConsoleContinue()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'c') {
        return $TRUE;
    }

    return $FALSE;
}

function Test-IcingaForWindowsManagementConsoleDelete()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'd') {
        return $TRUE;
    }

    return $FALSE;
}

function Test-IcingaForWindowsManagementConsoleExit()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'x') {
        return $TRUE;
    }

    return $FALSE;
}

function Test-IcingaForWindowsManagementConsoleHelp()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'h') {
        return $TRUE;
    }

    return $FALSE;
}

function Test-IcingaForWindowsManagementConsoleMenu()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'm') {
        return $TRUE;
    }

    return $FALSE;
}

function Test-IcingaForWindowsManagementConsolePrevious()
{
    if ([string]::IsNullOrEmpty($global:Icinga.InstallWizard.LastInput)) {
        return $FALSE;
    }

    if ($global:Icinga.InstallWizard.LastInput -eq 'p') {
        return $TRUE;
    }

    return $FALSE;
}

function Get-IcingaForWindowsManagementConsoleLastInput()
{
    return $global:Icinga.InstallWizard.LastInput;
}

function Show-IcingaWindowsManagementConsoleYesNoDialog()
{
    param (
        [string]$Caption         = '',
        [string]$Command         = '',
        [hashtable]$CmdArguments = @{ },
        [array]$Value            = @(),
        [string]$DefaultInput    = '0',
        [switch]$JumpToSummary   = $FALSE,
        [switch]$Automated       = $FALSE,
        [switch]$Advanced        = $FALSE
    );

    $LastParent = Get-IcingaForWindowsInstallerLastParent;

    Show-IcingaForWindowsInstallerMenu `
        -Header ([string]::Format('Are you sure you want to perform this action: "{0}"?', $Caption)) `
        -Entries @(
            @{
                'Caption' = 'No';
                'Command' = $LastParent;
                'Help'    = 'Do not apply the last action and return without doing anything';
            },
            @{
                'Caption' = 'Yes';
                'Command' = $LastParent;
                'Help'    = "Apply the action and confirm it's execution";
            }
        ) `
        -DefaultIndex $DefaultInput;

    if ((Get-IcingaForWindowsManagementConsoleLastInput) -eq '1') {
        if ($null -eq $CmdArguments -Or $CmdArguments.Count -eq 0) {
            & $Command | Out-Null;
        } else {
            & $Command @CmdArguments | Out-Null;
        }
        $global:Icinga.InstallWizard.LastNotice = [string]::Format('Action "{0}" has been executed', $Caption);
    }
}

function Disable-IcingaForWindowsInstallationHeaderPrint()
{
    $global:Icinga.InstallWizard.HeaderPrint = $FALSE;
}

function Disable-IcingaForWindowsInstallationJumpToSummary()
{
    $global:Icinga.InstallWizard.JumpToSummary = $FALSE;
}

function Enable-IcingaForWindowsInstallationHeaderPrint()
{
    $global:Icinga.InstallWizard.HeaderPrint = $TRUE;
}

function Enable-IcingaForWindowsInstallationJumpToSummary()
{
    $global:Icinga.InstallWizard.JumpToSummary = $TRUE;
}

function Get-IcingaForWindowsInstallationHeaderSelection()
{
    return $global:Icinga.InstallWizard.HeaderSelection;
}

function Test-IcingaForWindowsInstallationHeaderPrint()
{
    return $global:Icinga.InstallWizard.HeaderPrint;
}

function Test-IcingaForWindowsInstallationJumpToSummary()
{
    return $global:Icinga.InstallWizard.JumpToSummary;
}

function Set-IcingaForWindowsInstallationHeaderSelection()
{
    param (
        [string]$Selection = $null
    );

    $global:Icinga.InstallWizard.HeaderSelection = $Selection;
}

<#
 # This script will provide 'Enums' we can use for proper
 # error handling and to provide more detailed descriptions
 #
 # Example usage:
 # $IcingaEventLogEnums[2000]
 #>
if ($null -eq $IcingaEventLogEnums -Or $IcingaEventLogEnums.ContainsKey('Framework') -eq $FALSE) {
    [hashtable]$IcingaEventLogEnums += @{
        'Framework' = @{
            1000 = @{
                'EntryType' = 'Information';
                'Message'   = 'Generic debug message issued by the Framework or its components';
                'Details'   = 'The Framework or is components can issue generic debug message in case the debug log is enabled. Please ensure to disable it, if not used. You can do so with the command "Disable-IcingaFrameworkDebugMode"';
                'EventId'   = 1000;
            };
            1500 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to securely establish a communication between this server and the client';
                'Details'   = 'A client connection could not be established to this server. This issue is mostly caused by using Self-Signed/Icinga 2 Agent certificates for the server and the client not trusting the certificate. To resolve this issue, either use trusted certificates signed by your trusted CA or setup the client to accept untrusted certificates';
                'EventId'   = 1500;
            };
            1501 = @{
                'EntryType' = 'Error';
                'Message'   = 'Client connection was interrupted because of invalid SSL stream';
                'Details'   = 'A client connection was terminated by the Framework because no secure SSL handshake could be established. This issue in general is followed by EventId 1500.';
                'EventId'   = 1501;
            };
            1550 = @{
                'EntryType' = 'Error';
                'Message'   = 'Unsupported web authentication used';
                'Details'   = 'A web client tried to authenticate with an unsupported authorization method.';
                'EventId'   = 1550;
            };
            1551 = @{
                'EntryType' = 'Warning';
                'Message'   = 'Invalid authentication credentials provided';
                'Details'   = 'A web request for a client was rejected because of invalid formated base64 encoded credentials.';
                'EventId'   = 1551;
            };
            1552 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to parse use credentials from base64 encoding';
                'Details'   = 'Provided user credentials encoded as base64 could not be converted to domain, user and password objects.';
                'EventId'   = 1552;
            };
            1553 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to query Icinga check over internal REST-Api check handler';
                'Details'   = 'A service check could not be executed by using the internal REST-Api check handler. The check either ran into a timeout or could not be processed. Maybe the check was not registered to be allowed for being executed. Further details can be found below.';
                'EventId'   = 1553;
            };
            1560 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to test user login as no Principal Context could be established';
                'Details'   = 'A web client trying to authenticate failed as no Principal Context for the provided domain could be established.';
                'EventId'   = 1560;
            };
            1561 = @{
                'EntryType' = 'Error';
                'Message'   = 'Failed to authenticate user with given credentials';
                'Details'   = 'A web client trying to authenticate failed as the provided user credentials could not be verified.';
                'EventId'   = 1561;
            };
        }
    };
}

Export-ModuleMember -Variable @( 'IcingaEventLogEnums' );

function Register-IcingaEventLog()
{
    try {
        # Run this in a Try-Catch-Block, as we will run into an exception if it is not
        # present in the Application where it should be once we try to load the
        # Security log. If it is not found in the "public" Event-Log data, the
        # App is not registered
        $Registered = [System.Diagnostics.EventLog]::SourceExists(
            'Icinga for Windows'
        );

        if ($Registered) {
            return;
        }

        New-EventLog -LogName Application -Source 'Icinga for Windows';
    } catch {
        Exit-IcingaThrowException -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.EventLogNotInstalled -Force;
    }
}

<#
.SYNOPSIS
    Default Cmdlet for printing debug messages to console
.DESCRIPTION
    Default Cmdlet for printing debug messages to console
.FUNCTIONALITY
    Default Cmdlet for printing debug messages to console
.EXAMPLE
    PS>Write-IcingaConsoleDebug -Message 'Test message: {0}' -Objects 'Hello World';
.PARAMETER Message
    The message to print with {x} placeholdes replaced by content inside the Objects array. Replace x with the
    number of the index from the objects array
.PARAMETER Objects
    An array of objects being added to a provided message. The index of the array position has to refer to the
    message locations.
.INPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaConsoleDebug()
{
    param (
        [string]$Message,
        [array]$Objects
    );

    if ((Get-IcingaFrameworkDebugMode) -eq $FALSE) {
        return;
    }

    Write-IcingaConsoleOutput `
        -Message $Message `
        -Objects $Objects `
        -ForeColor 'Blue' `
        -Severity 'Debug';
}

<#
.SYNOPSIS
   Default Cmdlet for printing error messages to console
.DESCRIPTION
   Default Cmdlet for printing error messages to console
.FUNCTIONALITY
   Default Cmdlet for printing error messages to console
.EXAMPLE
   PS>Write-IcingaConsoleError -Message 'Test message: {0}' -Objects 'Hello World';
.PARAMETER Message
   The message to print with {x} placeholdes replaced by content inside the Objects array. Replace x with the
   number of the index from the objects array
.PARAMETER Objects
   An array of objects being added to a provided message. The index of the array position has to refer to the
   message locations.
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaConsoleError()
{
    param (
        [string]$Message,
        [array]$Objects
    );

    Write-IcingaConsoleOutput `
        -Message $Message `
        -Objects $Objects `
        -ForeColor 'Red' `
        -Severity 'Error';
}

<#
.SYNOPSIS
   Default Cmdlet for printing notice messages to console
.DESCRIPTION
   Default Cmdlet for printing notice messages to console
.FUNCTIONALITY
   Default Cmdlet for printing notice messages to console
.EXAMPLE
   PS>Write-IcingaConsoleNotice -Message 'Test message: {0}' -Objects 'Hello World';
.PARAMETER Message
   The message to print with {x} placeholdes replaced by content inside the Objects array. Replace x with the
   number of the index from the objects array
.PARAMETER Objects
   An array of objects being added to a provided message. The index of the array position has to refer to the
   message locations.
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaConsoleNotice()
{
    param (
        [string]$Message,
        [array]$Objects
    );

    Write-IcingaConsoleOutput `
        -Message $Message `
        -Objects $Objects `
        -ForeColor 'Green' `
        -Severity 'Notice';
}

<#
.SYNOPSIS
   Standardise console output and make handling of object conversion easier into messages
   by using this standard function for displaying severity and log entries
.DESCRIPTION
   Standardised function to output console messages controlled by the arguments provided
   for coloring, displaying severity and add objects into output messages
.FUNCTIONALITY
   Standardise console output and make handling of object conversion easier into messages
   by using this standard function for displaying severity and log entries
.EXAMPLE
   PS>Write-IcingaConsoleOutput -Message 'Test message: {0}' -Objects 'Hello World' -ForeColor 'Green' -Severity 'Test';
.PARAMETER Message
   The message to print with {x} placeholdes replaced by content inside the Objects array. Replace x with the
   number of the index from the objects array
.PARAMETER Objects
   An array of objects being added to a provided message. The index of the array position has to refer to the
   message locations.
.PARAMETER ForeColor
   The color the severity name will be displayed in
.PARAMETER Severity
   The severity being displayed before the actual message. Leave empty to skip.
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaConsoleOutput()
{
    param (
        [string]$Message,
        [array]$Objects,
        [ValidateSet('Default', 'Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]
        [string]$ForeColor = 'Default',
        [string]$Severity  = 'Notice'
    );

    if ((Test-IcingaFrameworkConsoleOutput) -eq $FALSE) {
        return;
    }

    # Never write console output in case the Framework is running as daemon
    if ($null -ne $global:IcingaDaemonData -And $null -ne $global:IcingaDaemonData.FrameworkRunningAsDaemon -And $global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $TRUE) {
        return;
    }

    $OutputMessage = $Message;
    [int]$Index    = 0;

    foreach ($entry in $Objects) {

        $OutputMessage = $OutputMessage.Replace(
            [string]::Format('{0}{1}{2}', '{', $Index, '}'),
            $entry
        );
        $Index++;
    }

    if ([string]::IsNullOrEmpty($Severity) -eq $FALSE) {
        Write-Host '[' -NoNewline;
        Write-Host $Severity -NoNewline -ForegroundColor $ForeColor;
        Write-Host ']: ' -NoNewline;
        Write-Host $OutputMessage;

        return;
    }

    if ($ForeColor -eq 'Default') {
        Write-Host $OutputMessage;
    } else {
        Write-Host $OutputMessage -ForegroundColor $ForeColor;
    }
}

<#
.SYNOPSIS
   Default Cmdlet for printing plain messages to console
.DESCRIPTION
   Default Cmdlet for printing plain messages to console
.FUNCTIONALITY
   Default Cmdlet for printing plain messages to console
.EXAMPLE
   PS>Write-IcingaConsolePlain -Message 'Test message: {0}' -Objects 'Hello World';
.PARAMETER Message
   The message to print with {x} placeholdes replaced by content inside the Objects array. Replace x with the
   number of the index from the objects array
.PARAMETER Objects
   An array of objects being added to a provided message. The index of the array position has to refer to the
   message locations.
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaConsolePlain()
{
    param (
        [string]$Message,
        [array]$Objects,
        [ValidateSet('Default', 'Black', 'DarkBlue', 'DarkGreen', 'DarkCyan', 'DarkRed', 'DarkMagenta', 'DarkYellow', 'Gray', 'DarkGray', 'Blue', 'Green', 'Cyan', 'Red', 'Magenta', 'Yellow', 'White')]
        [string]$ForeColor = 'Default'
    );

    Write-IcingaConsoleOutput `
        -Message $Message `
        -Objects $Objects `
        -ForeColor $ForeColor `
        -Severity $null;
}

<#
.SYNOPSIS
   Default Cmdlet for printing warning messages to console
.DESCRIPTION
   Default Cmdlet for printing warning messages to console
.FUNCTIONALITY
   Default Cmdlet for printing warning messages to console
.EXAMPLE
   PS>Write-IcingaConsoleWarning -Message 'Test message: {0}' -Objects 'Hello World';
.PARAMETER Message
   The message to print with {x} placeholdes replaced by content inside the Objects array. Replace x with the
   number of the index from the objects array
.PARAMETER Objects
   An array of objects being added to a provided message. The index of the array position has to refer to the
   message locations.
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Write-IcingaConsoleWarning()
{
    param (
        [string]$Message,
        [array]$Objects
    );

    Write-IcingaConsoleOutput `
        -Message $Message `
        -Objects $Objects `
        -ForeColor 'DarkYellow' `
        -Severity 'Warning';
}

function Write-IcingaDebugMessage()
{
    param(
        [string]$Message,
        [array]$Objects  = @()
    );

    if ([string]::IsNullOrEmpty($Message)) {
        return;
    }

    if ($null -eq $global:IcingaDaemonData -Or $global:IcingaDaemonData.DebugMode -eq $FALSE) {
        return;
    }

    [array]$DebugContent = @($Message);
    $DebugContent += $Objects;

    Write-IcingaEventMessage -EventId 1000 -Namespace 'Framework' -Objects $DebugContent;
}

function Write-IcingaErrorMessage()
{
    param(
        [int]$EventId     = 0,
        [string]$Message  = $null
    );

    if ($EventId -eq 0 -Or [string]::IsNullOrEmpty($Message)) {
        return;
    }

    Write-EventLog -LogName Application -Source 'Icinga for Windows' -EntryType Error -EventId $EventId -Message $Message;
}

function Write-IcingaEventMessage()
{
    param (
        [int]$EventId      = 0,
        [string]$Namespace = $null,
        [array]$Objects    = @()
    );

    if ($EventId -eq 0 -Or [string]::IsNullOrEmpty($Namespace)) {
        return;
    }

    [string]$EntryType = $IcingaEventLogEnums[$Namespace][$EventId].EntryType;
    [string]$Message   = $IcingaEventLogEnums[$Namespace][$EventId].Message;
    [string]$Details   = $IcingaEventLogEnums[$Namespace][$EventId].Details;

    if ([string]::IsNullOrEmpty($Details)) {
        $Details = '';
    }
    if ([string]::IsNullOrEmpty($Message)) {
        $Message = '';
    }

    [string]$ObjectDump = '';

    if ($Objects.Count -eq 0) {
        $ObjectDump = [string]::Format(
            '{0}{0}No additional object details provided.',
            (New-IcingaNewLine)
        );
    }

    foreach ($entry in $Objects) {
        $ObjectDump = [string]::Format(
            '{0}{1}',
            $ObjectDump,
            ($entry | Out-String)
        );
    }

    [string]$EventLogMessage = [string]::Format(
        '{0}{1}{1}{2}{1}{1}Object dumps if available:{1}{3}',
        $Message,
        (New-IcingaNewLine),
        $Details,
        $ObjectDump

    );

    if ($null -eq $EntryType -Or $null -eq $Message) {
        return;
    }

    [int]$MaxEventLogMessageSize = 30000;

    if ($EventLogMessage.Length -ge $MaxEventLogMessageSize) {
        while ($EventLogMessage.Length -ge $MaxEventLogMessageSize) {
            $CutMessage = $EventLogMessage.Substring(0, $MaxEventLogMessageSize);
            Write-EventLog -LogName Application `
                -Source 'Icinga for Windows' `
                -EntryType $EntryType `
                -EventId $EventId `
                -Message $CutMessage;

            $EventLogMessage = $EventLogMessage.Substring($MaxEventLogMessageSize, $EventLogMessage.Length - $MaxEventLogMessageSize);
        }
    }

    if ([string]::IsNullOrEmpty($EventLogMessage)) {
        return;
    }

    Write-EventLog -LogName Application `
        -Source 'Icinga for Windows' `
        -EntryType $EntryType `
        -EventId $EventId `
        -Message $EventLogMessage;
}

<#
.SYNOPSIS
   Adds counter instances or single counter objects to an internal cache
   by a given counter name or full path
.DESCRIPTION
   Adds counter instances or single counter objects to an internal cache
   by a given counter name or full path
.FUNCTIONALITY
   Adds counter instances or single counter objects to an internal cache
   by a given counter name or full path
.EXAMPLE
   PS>Add-IcingaPerformanceCounterCache -Counter '\Processor(*)\% processor time' -Instances $CounterInstances;
.PARAMETER Counter
   The path to the counter to store data for
.PARAMETER Instances
   The value to store for a specific path to a counter
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Add-IcingaPerformanceCounterCache()
{
    param (
        $Counter,
        $Instances
    );

    if ($global:Icinga_PerfCounterCache.ContainsKey($Counter)) {
        $global:Icinga_PerfCounterCache[$Counter] = $Instances;
    } else {
        $global:Icinga_PerfCounterCache.Add(
            $Counter, $Instances
        );
    }
}

<#
.SYNOPSIS
   Fetches stored data for a given performance counter path. Returns
   $null if no values are assigned
.DESCRIPTION
   Fetches stored data for a given performance counter path. Returns
   $null if no values are assigned
.FUNCTIONALITY
   Fetches stored data for a given performance counter path. Returns
   $null if no values are assigned
.EXAMPLE
   PS>Get-IcingaPerformanceCounterCacheItem -Counter '\Processor(*)\% processor time';
.PARAMETER Counter
   The path to the counter to fetch data for
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaPerformanceCounterCacheItem()
{
    param (
        $Counter
    );

    if ($global:Icinga_PerfCounterCache.ContainsKey($Counter)) {
        return $global:Icinga_PerfCounterCache[$Counter];
    }

    return $null;
}

<#
.SYNOPSIS
    Creates counter objects and sub-instances from a given Performance Counter
    Will return either a New-IcingaPerformanceCounterObject or New-IcingaPerformanceCounterResult
    which both contain the same members, allowing for dynmically use of objects
.DESCRIPTION
    Creates counter objects and sub-instances from a given Performance Counter
    Will return either a New-IcingaPerformanceCounterObject or New-IcingaPerformanceCounterResult
    which both contain the same members, allowing for dynmically use of objects
.FUNCTIONALITY
    Creates counter objects and sub-instances from a given Performance Counter
    Will return either a New-IcingaPerformanceCounterObject or New-IcingaPerformanceCounterResult
    which both contain the same members, allowing for dynmically use of objects
.EXAMPLE
    PS>New-IcingaPerformanceCounter -Counter '\Processor(*)\% processor time';

    FullName                       Counters
    --------                       --------
    \Processor(*)\% processor time {@{FullName=\Processor(2)\% processor time; Category=Processor; Instance=2; Counter=%...
.EXAMPLE
    PS>New-IcingaPerformanceCounter -Counter '\Processor(*)\% processor time' -SkipWait;
.PARAMETER Counter
    The path to the Performance Counter to fetch data for
.PARAMETER SkipWait
    Set this if no sleep is intended for initialising the counter. This can be useful
    if multiple counters are fetched during one call with this function if the sleep
    is done afterwards manually. A sleep is set to 500ms to ensure counter data is
    valid and contains an offset from previous/current values
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounter()
{
    param(
        [string]$Counter   = '',
        [boolean]$SkipWait = $FALSE
    );

    # Simply use the counter name, like
    # \Paging File(_total)\% Usage
    if ([string]::IsNullOrEmpty($Counter) -eq $TRUE) {
        return (New-IcingaPerformanceCounterNullObject -FullName $Counter -ErrorMessage 'Failed to initialise counter, as no counter was specified.');
    }

    [array]$CounterArray = $Counter.Split('\');
    [string]$UseCounterCategory = '';
    [string]$UseCounterName     = '';
    [string]$UseCounterInstance = '';

    # If we add the counter as it should be
    # \Paging File(_total)\% Usage
    # the first array element will be an empty string we can skip
    # Otherwise the name was wrong and we should not continue
    if (-Not [string]::IsNullOrEmpty($CounterArray[0])) {
        return (New-IcingaPerformanceCounterNullObject -FullName $Counter -ErrorMessage ([string]::Format('Failed to deserialize counter "{0}". It seems the leading "\" is missing.', $Counter)));
    }

    # In case our Performance Counter is containing instances, we should split
    # The content and read the instance and counter category out
    if ($CounterArray[1].Contains('(')) {
        [array]$TmpCounter  = $CounterArray[1].Split('(');
        $UseCounterCategory = $TmpCounter[0];
        $UseCounterInstance = $TmpCounter[1].Replace(')', '');
    } else {
        # Otherwise we only require the category
        $UseCounterCategory = $CounterArray[1];
    }

    # At last get the actual counter containing our values
    $UseCounterName = $CounterArray[2];

    # Now as we know how the counter path is constructed and has been splitted into
    # the different values, we need to know how to handle the instances of the counter

    # If we specify a instance with (*) we want the module to automaticly fetch all
    # instances for this counter. This will result in an New-IcingaPerformanceCounterResult
    # which contains the parent name including counters for all instances that
    # have been found
    if ($UseCounterInstance -eq '*') {
        # In case we already loaded the counters once, return the finished array
        $CachedCounter = Get-IcingaPerformanceCounterCacheItem -Counter $Counter;

        if ($null -ne $CachedCounter) {
            return (New-IcingaPerformanceCounterResult -FullName $Counter -PerformanceCounters $CachedCounter);
        }

        # If we need to build the array, load all instances from the counters and
        # create single performance counters and add them to a custom array and
        # later to a custom object
        try {
            [array]$AllCountersIntances = @();
            $CounterInstances = New-Object System.Diagnostics.PerformanceCounterCategory($UseCounterCategory);
            foreach ($instance in $CounterInstances.GetInstanceNames()) {
                [string]$NewCounterName = $Counter.Replace('*', $instance);
                $NewCounter             = New-IcingaPerformanceCounterObject -FullName $NewCounterName -Category $UseCounterCategory -Counter $UseCounterName -Instance $instance -SkipWait $TRUE;
                $AllCountersIntances += $NewCounter;
            }
        } catch {
            # Throw an exception in case our permissions are not enough to fetch performance counter
            Exit-IcingaThrowException -InputString $_.Exception -StringPattern 'System.UnauthorizedAccessException' -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.PerformanceCounter;
            Exit-IcingaThrowException -InputString $_.Exception -StringPattern 'System.InvalidOperationException'   -ExceptionType 'Input'     -CustomMessage $Counter -ExceptionThrown $IcingaExceptions.Inputs.PerformanceCounter;
            Exit-IcingaThrowException -InputString $_.Exception -StringPattern '' -ExceptionType 'Unhandled';
            # Shouldn't actually get down here anyways
            return (New-IcingaPerformanceCounterNullObject -FullName $Counter -ErrorMessage ([string]::Format('Failed to deserialize instances for counter "{0}". Exception: "{1}".', $Counter, $_.Exception.Message)));
        }

        # If we load multiple instances, we should add a global wait here instead of a wait for each single instance
        # This will speed up CPU loading for example with plenty of cores avaiable
        if ($SkipWait -eq $FALSE) {
            Start-Sleep -Milliseconds 500;
        }

        # Add the parent counter including the array of Performance Counters to our
        # caching mechanism and return the New-IcingaPerformanceCounterResult object for usage
        # within the monitoring modules
        Add-IcingaPerformanceCounterCache -Counter $Counter -Instances $AllCountersIntances;
        return (New-IcingaPerformanceCounterResult -FullName $Counter -PerformanceCounters $AllCountersIntances);
    } else {
        # This part will handle the counters without any instances as well as
        # specificly assigned instances, like (_Total) CPU usage.

        # In case we already have the counter within our cache, return the
        # cached informations
        $CachedCounter = Get-IcingaPerformanceCounterCacheItem -Counter $Counter;

        if ($null -ne $CachedCounter) {
            return $CachedCounter;
        }

        # If the cache is not present yet, create the Performance Counter object,
        # and add it to our cache
        $NewCounter = New-IcingaPerformanceCounterObject -FullName $Counter -Category $UseCounterCategory -Counter $UseCounterName -Instance $UseCounterInstance -SkipWait $SkipWait;
        Add-IcingaPerformanceCounterCache -Counter $Counter -Instances $NewCounter;
    }

    # This function will always return non-instance counters or
    # specificly defined instance counters. Performance Counter Arrays
    # are returned within their function. This is just to ensure that the
    # function looks finished from developer point of view
    return (Get-IcingaPerformanceCounterCacheItem -Counter $Counter);
}

<#
.SYNOPSIS
    Accepts a list of Performance Counters which will all be fetched at once and
    returned as a hashtable object. No additional configuration is required.
.DESCRIPTION
    Accepts a list of Performance Counters which will all be fetched at once and
    returned as a hashtable object. No additional configuration is required.
.FUNCTIONALITY
    Accepts a list of Performance Counters which will all be fetched at once and
    returned as a hashtable object. No additional configuration is required.
.EXAMPLE
    PS>New-IcingaPerformanceCounterArray -CounterArray '\Processor(*)\% processor time', '\Memory\committed bytes';

    Name                           Value
    ----                           -----
    \Processor(*)\% processor time {\Processor(7)\% processor time, \Processor(6)\% processor time, \Processor(0)\% proc...
    \Memory\committed bytes        {error, sample, type, value...}
.PARAMETER CounterArray
    An array of Performance Counters which will all be fetched at once
.INPUTS
    System.String
.OUTPUTS
    System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterArray()
{
    param(
        [array]$CounterArray = @()
    )

    [hashtable]$CounterResult = @{};
    [bool]$RequireSleep       = $TRUE;
    foreach ($counter in $CounterArray) {
        # We want to speed up things with loading, so we will check if a specified
        # Counter is already cached within our hashtable. If it is not, we sleep
        # at the end of the function the required 500ms and don't have to wait
        # NumOfCounters * 500 milliseconds for the first runs. This will speed
        # up the general loading of counters and will not require some fancy
        # pre-caching / configuration handler
        $CachedCounter = Get-IcingaPerformanceCounterCacheItem -Counter $Counter;

        if ($null -ne $CachedCounter) {
            $RequireSleep = $FALSE;
        }

        $obj = New-IcingaPerformanceCounter -Counter $counter -SkipWait $TRUE;
        if ($CounterResult.ContainsKey($obj.Name()) -eq $FALSE) {
            $CounterResult.Add($obj.Name(), $obj.Value());
        }
    }

    # TODO: Add a cache for our Performance Counters to only fetch them once
    #       for each session to speed up the loading. This cold be something like
    #       this:
    # New-IcingaPerformanceCounterCache $CounterResult;
    # Internally we could do something like this
    # $global:Icinga_PerfCounterCache += $CounterResult;

    # Above we initialse ever single counter and we only require a sleep once
    # in case a new, yet unknown counter was added
    if ($RequireSleep) {
        Start-Sleep -Milliseconds 500;

        # Agreed, this is some sort of code duplication but it wouldn't make
        # any sense to create a own function for this. Why are we doing
        # this anway?
        # Simple: In case we found counters which have yet not been initialised
        #         we did this above. Now we have waited 500 ms to receive proper
        #         values from these counters. As the previous generated result
        #         might have contained counters with 0 results, we will now
        #         check all counters again to receive the proper values.
        #         Agreed, might sound like a overhead, but the impact only
        #         applies to the first call of the module with the counters.
        #         This 'duplication' however decreased the execution from
        #         certain modules from 25s to 1s on the first run. Every
        #         additional run is then beeing executed within 0.x s
        #         which sounds like a very good performance and solution
        $CounterResult = @{};
        foreach ($counter in $CounterArray) {
            $obj = New-IcingaPerformanceCounter -Counter $counter -SkipWait $TRUE;
            if ($CounterResult.ContainsKey($obj.Name()) -eq $FALSE) {
                $CounterResult.Add($obj.Name(), $obj.Value());
            }
        }
    }

    return $CounterResult;
}

<#
.SYNOPSIS
    Initialises the internal cache storage for Performance Counters
.DESCRIPTION
    Initialises the internal cache storage for Performance Counters
.FUNCTIONALITY
    Initialises the internal cache storage for Performance Counters
.EXAMPLE
    PS>New-IcingaPerformanceCounterCache;
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterCache()
{
    if ($null -eq $global:Icinga_PerfCounterCache) {
        $global:Icinga_PerfCounterCache = (
            [hashtable]::Synchronized(
                @{}
            )
        );
    }
}

<#
.SYNOPSIS
    This will create a Performance Counter object in case a counter instance
    does not exis, but still returning default members to allow us to smoothly
    execute our code
.DESCRIPTION
    This will create a Performance Counter object in case a counter instance
    does not exis, but still returning default members to allow us to smoothly
    execute our code
.FUNCTIONALITY
    This will create a Performance Counter object in case a counter instance
    does not exis, but still returning default members to allow us to smoothly
    execute our code
.EXAMPLE
    PS>New-IcingaPerformanceCounterNullObject '\Processor(20)\%processor time' -ErrorMessage 'This counter with instance 20 does not exist';

    FullName                       ErrorMessage
    --------                       ------------
    \Processor(20)\%processor time This counter with instance 20 does not exist
.PARAMETER FullName
    The full path/name of the Performance Counter which does not exist
.PARAMETER ErrorMessage
    The error message which is included within the 'error' member of the Performance Counter
.INPUTS
    System.String
.OUTPUTS
    System.PSObject
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterNullObject()
{
    param(
        [string]$FullName     = '',
        [string]$ErrorMessage = ''
    );

    $pc_instance = New-Object -TypeName PSObject;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'FullName'     -Value $FullName;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'ErrorMessage' -Value $ErrorMessage;

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Name' -Value {
        return $this.FullName;
    }

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Value' -Value {
        [hashtable]$ErrorMessage = @{};

        $ErrorMessage.Add('value', $null);
        $ErrorMessage.Add('sample', $null);
        $ErrorMessage.Add('help', $null);
        $ErrorMessage.Add('type', $null);
        $ErrorMessage.Add('error', $this.ErrorMessage);

        return $ErrorMessage;
    }

    return $pc_instance;
}

<#
.SYNOPSIS
    Creates a new Performance Counter object based on given input filters.
    Returns a PSObject with custom members to access the data of the counter
.DESCRIPTION
    Creates a new Performance Counter object based on given input filters.
    Returns a PSObject with custom members to access the data of the counter
.FUNCTIONALITY
    Creates a new Performance Counter object based on given input filters.
    Returns a PSObject with custom members to access the data of the counter
.EXAMPLE
    PS>New-IcingaPerformanceCounterObject -FullName '\Processor(*)\% processor time' -Category 'Processor' -Instance '*' -Counter '% processor time';

    Category    : Processor
    Instance    : *
    Counter     : % processor time
    PerfCounter : System.Diagnostics.PerformanceCounter
    SkipWait    : False
.EXAMPLE
    PS>New-IcingaPerformanceCounterObject -FullName '\Processor(*)\% processor time' -Category 'Processor' -Instance '*' -Counter '% processor time' -SkipWait;

    Category    : Processor
    Instance    : *
    Counter     : % processor time
    PerfCounter : System.Diagnostics.PerformanceCounter
    SkipWait    : True
.PARAMETER FullName
    The full path to the Performance Counter
.PARAMETER Category
    The name of the category of the Performance Counter
.PARAMETER Instance
    The instance of the Performance Counter
.PARAMETER Counter
    The actual name of the counter to fetch
.PARAMETER SkipWait
    Set this if no sleep is intended for initialising the counter. This can be useful
    if multiple counters are fetched during one call with this function if the sleep
    is done afterwards manually. A sleep is set to 500ms to ensure counter data is
    valid and contains an offset from previous/current values
.INPUTS
    System.String
.OUTPUTS
    System.PSObject
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterObject()
{
    param(
        [string]$FullName  = '',
        [string]$Category  = '',
        [string]$Instance  = '',
        [string]$Counter   = '',
        [boolean]$SkipWait = $FALSE
    );

    $pc_instance = New-Object -TypeName PSObject;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'FullName'    -Value $FullName;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'Category'    -Value $Category;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'Instance'    -Value $Instance;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'Counter'     -Value $Counter;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'PerfCounter' -Value $Counter;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'SkipWait'    -Value $SkipWait;

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Init' -Value {

        Write-IcingaConsoleDebug `
            -Message 'Creating new Counter for Category "{0}" with Instance "{1}" and Counter "{2}". Full Name "{3}"' `
            -Objects $this.Category, $this.Instance, $this.Counter, $this.FullName;

        # Create the Performance Counter object we want to access
        $this.PerfCounter              = New-Object System.Diagnostics.PerformanceCounter;
        $this.PerfCounter.CategoryName = $this.Category;
        $this.PerfCounter.CounterName  = $this.Counter;

        # Only add an instance in case it is defined
        if ([string]::IsNullOrEmpty($this.Instance) -eq $FALSE) {
            $this.PerfCounter.InstanceName = $this.Instance
        }

        # Initialise the counter
        try {
            $this.PerfCounter.NextValue() | Out-Null;
        } catch {
            # Nothing to do here, will be handled later
        }

        <#
        # For some counters we require to wait a small amount of time to receive proper data
        # Other counters do not need these informations and we do also not require to wait
        # for every counter we use, once the counter is initialised within our environment.
        # This will allow us to skip the sleep to speed up loading counters
        #>
        if ($this.SkipWait -eq $FALSE) {
            Start-Sleep -Milliseconds 500;
        }
    }

    # Return the name of the counter as string
    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Name' -Value {
        return $this.FullName;
    }

    <#
    # Return a hashtable containting the counter value including the
    # Sample values for the counter itself. In case we run into an error,
    # keep the counter construct but add an error message in addition.
    #>
    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Value' -Value {
        [hashtable]$CounterData = @{};

        try {
            [string]$CounterType = $this.PerfCounter.CounterType;
            $CounterData.Add('value', ([math]::Round([decimal]$this.PerfCounter.NextValue(), 6)));
            $CounterData.Add('sample', $this.PerfCounter.NextSample());
            $CounterData.Add('help', $this.PerfCounter.CounterHelp);
            $CounterData.Add('type', $CounterType);
            $CounterData.Add('error', $null);
        } catch {
            $CounterData = @{};
            $CounterData.Add('value', $null);
            $CounterData.Add('sample', $null);
            $CounterData.Add('help', $null);
            $CounterData.Add('type', $null);
            $CounterData.Add('error', $_.Exception.Message);
        }

        return $CounterData;
    }

    # Initialiste the entire counter and internal handlers
    $pc_instance.Init();

    # Return this custom object
    return $pc_instance;
}

<#
.SYNOPSIS
    Will provide a virtual object, containing an array of Performance Counters.
    The object has the following members:
    * Name
    * Value
.DESCRIPTION
    Will provide a virtual object, containing an array of Performance Counters.
    The object has the following members:
    * Name
    * Value
.FUNCTIONALITY
    Will provide a virtual object, containing an array of Performance Counters.
    The object has the following members:
    * Name
    * Value
.EXAMPLE
    PS>New-IcingaPerformanceCounterResult -FullName '\Processor(*)\% processor time' -PerformanceCounters $PerformanceCounters;
.PARAMETER FullName
    The full path to the Performance Counter
.PARAMETER PerformanceCounters
    A list of all instances/counters for the given Performance Counter
.INPUTS
    System.String
.OUTPUTS
    System.PSObject
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterResult()
{
    param(
        [string]$FullName           = '',
        [array]$PerformanceCounters = @()
    );

    $pc_instance = New-Object -TypeName PSObject;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'FullName' -Value $FullName;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'Counters' -Value $PerformanceCounters;

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Name' -Value {
        return $this.FullName;
    }

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Value' -Value {
        [hashtable]$CounterResults = @{};

        foreach ($counter in $this.Counters) {
            $CounterResults.Add($counter.Name(), $counter.Value());
        }

        return $CounterResults;
    }

    return $pc_instance;
}

<#
.SYNOPSIS
    Will use an array of provided Performance Counter and sort the input by
    a given counter category. In this case we can fetch all Processor instances
    and receive values for each core which can then be accessed from a hashtable
    with an eady query. Allows to modify output in addition
.DESCRIPTION
    Will use an array of provided Performance Counter and sort the input by
    a given counter category. In this case we can fetch all Processor instances
    and receive values for each core which can then be accessed from a hashtable
    with an eady query. Allows to modify output in addition
.FUNCTIONALITY
    Will use an array of provided Performance Counter and sort the input by
    a given counter category. In this case we can fetch all Processor instances
    and receive values for each core which can then be accessed from a hashtable
    with an eady query. Allows to modify output in addition
.EXAMPLE
    PS>New-IcingaPerformanceCounterStructure -CounterCategory 'Processor' -PerformanceCounterHash (New-IcingaPerformanceCounterArray '\Processor(*)\% processor time');

    Name                           Value
    ----                           -----
    7                              {% processor time}
    3                              {% processor time}
    4                              {% processor time}
    _Total                         {% processor time}
    2                              {% processor time}
    1                              {% processor time}
    0                              {% processor time}
    6                              {% processor time}
    5                              {% processor time}
.EXAMPLE
    PS>New-IcingaPerformanceCounterStructure -CounterCategory 'Processor' -PerformanceCounterHash (New-IcingaPerformanceCounterArray '\Processor(*)\% processor time') -InstanceNameCleanupArray '_';

    Name                           Value
    ----                           -----
    7                              {% processor time}
    Total                          {}
    3                              {% processor time}
    4                              {% processor time}
    2                              {% processor time}
    1                              {% processor time}
    0                              {% processor time}
    6                              {% processor time}
    5                              {% processor time}
.PARAMETER CounterCategory
    The name of the category the sort algorithm will fetch the instances from for sorting
.PARAMETER PerformanceCounterHash
    An array of Performance Counter objects provided by 'New-IcingaPerformanceCounterArray' to sort for
.PARAMETER InstanceNameCleanupArray
    An array which will be used to remove string content from the sorted instances keys. For example '_' will change
    '_Total' to 'Total'. Replacements are done in the order added to this array
.INPUTS
    System.String
.OUTPUTS
    System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function New-IcingaPerformanceCounterStructure()
{
    param(
        [string]$CounterCategory           = '',
        [hashtable]$PerformanceCounterHash = @{},
        [array]$InstanceNameCleanupArray   = @()
    )

    # The storage variables we require to store our data
    [array]$AvailableInstances        = @();
    [hashtable]$StructuredCounterData = @{};

    # With this little trick we can fetch all instances we have and get their unique name
    $CounterInstances = New-Object System.Diagnostics.PerformanceCounterCategory($CounterCategory);
    foreach ($instance in $CounterInstances.GetInstanceNames()) {
        # For some counters we require to apply a 'cleanup' for the instance name
        # Example Disks: Some disks are stored with the name
        # 'HarddiskVolume1'
        # To be able to map the volume correctly to disks, we require to remove
        # 'HarddiskVolume' so only '1' will remain, which allows us to map the
        # volume correctly afterwards
        [string]$CleanInstanceName = $instance;
        foreach ($cleanup in $InstanceNameCleanupArray) {
            $CleanInstanceName = $CleanInstanceName.Replace($cleanup, '');
        }
        $AvailableInstances += $CleanInstanceName;
    }

    # Now let the real magic begin.

    # At first we will loop all instances of our Performance Counters, which means all
    # instances we have found above. We build a new hashtable then to list the instances
    # by their individual name and all corresponding counters as children
    # This allows us a structured output with all data for each instance
    foreach ($instance in $AvailableInstances) {

        # First build a hashtable for each instance to add data to later
        $StructuredCounterData.Add($instance, @{});

        # Now we need to loop all return values from our Performance Counters
        foreach ($InterfaceCounter in $PerformanceCounterHash.Keys) {
            # As we just looped the parent counter (Instance *), we now need to
            # loop the actual counters for each instance
            foreach ($interface in $PerformanceCounterHash[$InterfaceCounter]) {
                # Finally let's loop through all the results which contain the values
                # to build our new, structured hashtable
                foreach ($entry in $interface.Keys) {
                    # Match the counters based on our current parent index
                    # (the instance name we want to add the values as children).
                    if ($entry.Contains('(' + $instance + ')')) {
                        # To ensure we don't transmit the entire counter name,
                        # we only want to include the name of the actual counter.
                        # There is no need to return
                        # \Network Interface(Desktopadapter Intel[R] Gigabit CT)\Bytes Received/sec
                        # the naming
                        # Bytes Received/sec
                        # is enough
                        [array]$TmpOutput = $entry.Split('\');
                        [string]$OutputName = $TmpOutput[$TmpOutput.Count - 1];

                        # Now add the actual value to our parent instance with the
                        # improved value name, including the sample and counter value data
                        $StructuredCounterData[$instance].Add($OutputName, $interface[$entry]);
                    }
                }
            }
        }
    }

    return $StructuredCounterData;
}

<#
.SYNOPSIS
   Fetches all available Performance Counter caregories on the system by using the
   registry and returns the entire content as array. Allows to filter for certain
   categories only
.DESCRIPTION
   Fetches all available Performance Counter caregories on the system by using the
   registry and returns the entire content as array. Allows to filter for certain
   categories only
.FUNCTIONALITY
   Fetches all available Performance Counter caregories on the system by using the
   registry and returns the entire content as array. Allows to filter for certain
   categories only
.EXAMPLE
   PS>Show-IcingaPerformanceCounterCategories;

   System
    Memory
    Browser
    Cache
    Process
    Thread
    PhysicalDisk
    ...
.EXAMPLE
   PS>Show-IcingaPerformanceCounterCategories -Filter 'Processor';

   Processor
.EXAMPLE
   PS>Show-IcingaPerformanceCounterCategories -Filter 'Processor', 'Memory';

   Memory
    Processor
.PARAMETER Filter
   A array of counter categories to filter for. Supports wildcard search
.INPUTS
   System.String
.OUTPUTS
   System.Array
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Show-IcingaPerformanceCounterCategories()
{
    param (
        [array]$Filter = @()
    );

    [array]$Counters          = @();
    [array]$FilteredCounters  = @();
    # Load our cache if it does exist yet
    $PerfCounterCache         = Get-IcingaPerformanceCounterCacheItem 'Icinga:CachedCounterList';

    # Create a cache for all available performance counter categories on the system
    if ($null -eq $PerfCounterCache -or $PerfCounterCache.Count -eq 0) {
        # Fetch the categories from the registry
        $PerfCounterCache = Get-ItemProperty `
            -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\009' `
            -Name 'counter' | Select-Object -ExpandProperty Counter;

        # Now lets loop our registry data and fetch only for counter categories
        # Ignore everything else and drop the information
        foreach ($counter in $PerfCounterCache) {
            # First filter out the ID's of the performance counter
            if (-Not ($counter -match "^[\d\.]+$") -And [string]::IsNullOrEmpty($counter) -eq $FALSE) {
                # Now check if the value we got is a counter category
                if ([System.Diagnostics.PerformanceCounterCategory]::Exists($counter) -eq $TRUE) {
                    $Counters += $counter;
                }
            }
        }

        # Set our cache to the current list of categories
        Add-IcingaPerformanceCounterCache -Counter 'Icinga:CachedCounterList' -Instances $Counters;
        $PerfCounterCache = $Counters;
    }

    # In case we have no filter applied, simply return the entire list
    if ($Filter.Count -eq 0) {
        return $PerfCounterCache;
    }

    # In case we do, check each counter category against our filter element
    foreach ($counter in $PerfCounterCache) {
        foreach ($element in $Filter) {
            if ($counter -like $element) {
                $FilteredCounters += $counter;
            }
        }
    }

    return $FilteredCounters;
}

<#
.SYNOPSIS
    Prints the description of a Performance Counter if available on the system
.DESCRIPTION
    Prints the description of a Performance Counter if available on the system
.FUNCTIONALITY
    Prints the description of a Performance Counter if available on the system
.EXAMPLE
    PS>Show-IcingaPerformanceCounterHelp '\Processor(*)\% processor time';

    % Processor Time is the percentage of elapsed time that the processor spends to execute a non-Idle thread. It is calculated by measuring the percentage of time that the processor spends executing the idle thread and then subtracting that value from 100%. (Each processor has an idle thread that consumes cycles when no other threads are ready to run). This counter is the primary indicator of processor activity, and displays the average percentage of busy time observed during the sample interval. It should be noted that the accounting calculation of whether the processor is idle is performed at an internal sampling interval of the system clock (10ms). On todays fast processors, % Processor Time can therefore underestimate the processor utilization as the processor may be spending a lot of time servicing threads between the system clock sampling interval. Workload based timer applications are one example  of applications  which are more likely to be measured inaccurately as timers are signaled just after the sample is taken.
.EXAMPLE
    PS>Show-IcingaPerformanceCounterHelp '\Memory\system code total bytes';

    System Code Total Bytes is the size, in bytes, of the pageable operating system code currently mapped into the system virtual address space. This value is calculated by summing the bytes in Ntoskrnl.exe, Hal.dll, the boot drivers, and file systems loaded by Ntldr/osloader.  This counter does not include code that must remain in physical memory and cannot be written to disk. This counter displays the last observed value only; it is not an average.
.PARAMETER Counter
    The full path to the Performance Counter to lookup.
.INPUTS
    System.String
.OUTPUTS
    System.String
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>
function Show-IcingaPerformanceCounterHelp()
{
    param (
        [string]$Counter = ''
    );

    if ([string]::IsNullOrEmpty($Counter)) {
        Write-IcingaConsoleError 'Please enter a Performance Counter';
        return;
    }

    # Create a Performance Counter array which is easier to access later on and skip possible waits
    $PerfCounter       = New-IcingaPerformanceCounterArray -Counter $Counter -SkipWait $TRUE;
    [string]$HelpText  = '';
    [string]$ErrorText = '';

    if ($PerfCounter.ContainsKey($Counter)) {
        # Handle counters without instances, like '\Memory\system code total bytes'
        $HelpText  = $PerfCounter[$Counter].help;
        $ErrorText = $PerfCounter[$Counter].error;

        if ([string]::IsNullOrEmpty($HelpText)) {
            # Handle counters with instances, like '\Processor(*)\% processor time'
            $CounterObject = $PerfCounter[$Counter].GetEnumerator() | Select-Object -First 1;
            $CounterData   = $CounterObject.Value;
            $HelpText      = $CounterData.help;
            if ([string]::IsNullOrEmpty($ErrorText)) {
                $ErrorText = $CounterData.error;
            }
        }
    }
    
    if ([string]::IsNullOrEmpty($HelpText) -eq $FALSE) {
        return $HelpText;
    }

    Write-IcingaConsoleError `
        -Message 'Help context for the Performance Counter "{0}" could not be loaded or was not found. Error context if available: "{1}"' `
        -Objects $Counter, $ErrorText;
}

<#
.SYNOPSIS
   Displays all available instances for a provided Performance Counter
.DESCRIPTION
   Displays all available instances for a provided Performance Counter
.FUNCTIONALITY
   Displays all available instances for a provided Performance Counter
.PARAMETER Counter
   The name of the Performance Counter to fetch data for
.EXAMPLE
   PS>Show-IcingaPerformanceCounterInstances -Counter '\Processor(*)\% processor time';

   Name                           Value
    ----                           -----
    _Total                         \Processor(_Total)\% processor time
    0                              \Processor(0)\% processor time
    1                              \Processor(1)\% processor time
    2                              \Processor(2)\% processor time
    3                              \Processor(3)\% processor time
    ...
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Show-IcingaPerformanceCounterInstances()
{
    param (
        [string]$Counter
    );

    [hashtable]$Instances = @{};

    if ([string]::IsNullOrEmpty($Counter)) {
        Write-IcingaConsoleError 'Please enter a Performance Counter';
        return;
    }

    $PerfCounter  = New-IcingaPerformanceCounter -Counter $Counter -SkipWait $TRUE;

    foreach ($entry in $PerfCounter.Counters) {
        $Instances.Add(
            $entry.Instance,
            ($Counter.Replace('(*)', ([string]::Format('({0})', $entry.Instance))))
        );
    }

    if ($Instances.Count -eq 0) {
        Write-IcingaConsoleNotice `
            -Message 'No instances were found for Performance Counter "{0}". Please ensure the provided counter has instances and you are using "*" for the instance name.' `
            -Objects $Counter;

        return;
    }

    return (
        $Instances.GetEnumerator() | Sort-Object Name
    );
}

<#
.SYNOPSIS
    Prints a list of all available Performance Counters for a specified category
.DESCRIPTION
    Prints a list of all available Performance Counters for a specified category
.FUNCTIONALITY
    Prints a list of all available Performance Counters for a specified category
.EXAMPLE
    PS>Show-IcingaPerformanceCounters -CounterCategory 'Processor';

    \Processor(*)\dpcs queued/sec
    \Processor(*)\% c1 time
    \Processor(*)\% idle time
    \Processor(*)\c3 transitions/sec
    \Processor(*)\% c2 time
    \Processor(*)\% dpc time
    \Processor(*)\% privileged time
.PARAMETER CounterCategory
    The name of the category to fetch availble counters for
.INPUTS
    System.String
.OUTPUTS
    System.Array
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>
function Show-IcingaPerformanceCounters()
{
    param (
        [string]$CounterCategory
    );

    [hashtable]$counters = @{};

    if ([string]::IsNullOrEmpty($CounterCategory)) {
        $counters.Add('error', 'Please specify a counter category');
        return $counters;
    }

    try {
        # At first create our Performance Counter object for the category we specified
        $Category = New-Object System.Diagnostics.PerformanceCounterCategory($CounterCategory);

        # Now loop  through all keys to find the name of available counters
        foreach ($counter in $Category.ReadCategory().Keys) {
            [string]$CounterInstanceAddition = '';

            # As counters might also have instances (like interfaces, disks, paging file), we should
            # try to load them as well
            foreach ($instance in $Category.ReadCategory()[$counter].Keys) {
                # If we do not match this magic string, we have multiple instances we can access
                # to get informations for different disks, volumes and interfaces for example
                if ($instance -ne 'systemdiagnosticsperfcounterlibsingleinstance') {
                    # Re-Write the name we return of the counter to something we can use directly
                    # within our modules to load data from. A returned counter will look like this
                    # for example:
                    # \PhysicalDisk(*)\avg. disk bytes/read
                    [string]$UsableCounterName = [string]::Format('\{0}(*)\{1}', $CounterCategory, $counter);
                    if ($counters.ContainsKey($UsableCounterName) -eq $TRUE) {
                        $counters[$UsableCounterName] += $Category.ReadCategory()[$counter][$instance];
                    } else {
                        $counters.Add($UsableCounterName, @( $Category.ReadCategory()[$counter][$instance] ));
                    }
                } else {
                    # For counters with no instances, we still require to return a re-build Performance Counter
                    # output, to make later usage in our modules very easy. This can look like this:
                    # \System\system up time
                    [string]$UsableCounterName = [string]::Format('\{0}\{1}', $CounterCategory, $counter);
                    $counters.Add($UsableCounterName, $null);
                }
            }
        };
    } catch {
        # In case we run into an error, return an error message
        $counters.Add('error', $_.Exception.Message);
    }

    return $counters.Keys;
}

<#
.SYNOPSIS
   Test if a certain Performance Counter category exist on the systems and returns
   either true or false depending on the state
.DESCRIPTION
   Test if a certain Performance Counter category exist on the systems and returns
   either true or false depending on the state
.FUNCTIONALITY
   Test if a certain Performance Counter category exist on the systems and returns
   either true or false depending on the state
.EXAMPLE
   PS>Test-IcingaPerformanceCounterCategory -Category 'Processor';

   True
.PARAMETER Category
   The name of the category to test for
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaPerformanceCounterCategory()
{
    param (
        [string]$Category
    );

    if ([string]::IsNullOrEmpty($Category)) {
        return $FALSE;
    }

    try {
        $Counter = New-Object System.Diagnostics.PerformanceCounterCategory($Category);

        if ($null -eq $Counter -Or [string]::IsNullOrEmpty($Counter.CategoryType)) {
            return $FALSE;
        }
    } catch {
        return $FALSE;
    }

    return $TRUE;
}

function Add-IcingaRepository()
{
    param (
        [string]$Name       = $null,
        [string]$RemotePath = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    if ([string]::IsNullOrEmpty($RemotePath)) {
        Write-IcingaConsoleError 'You have to provide a remote path for the repository';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        $CurrentRepositories = New-Object -TypeName PSObject;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does already exist.' -Objects $Name;
        return;
    }

    [array]$RepoCount = $CurrentRepositories.PSObject.Properties.Count;

    $CurrentRepositories | Add-Member -MemberType NoteProperty -Name $Name -Value (New-Object -TypeName PSObject);
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'LocalPath'   -Value $null;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'RemotePath'  -Value $RemotePath;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'CloneSource' -Value $null;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'UseSCP'      -Value $FALSE;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Order'       -Value $RepoCount.Count;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Enabled'     -Value $True;

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
    Push-IcingaRepository -Name $Name -Silent;

    Write-IcingaConsoleNotice 'Remote repository "{0}" was successfully added' -Objects $Name;
}

function Disable-IcingaRepository()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}', $Name));

    if ($null -eq $CurrentRepositories) {
        Write-IcingaConsoleError 'A repository with the name "{0}" is not configured' -Objects $Name;
        return;
    }

    if ($CurrentRepositories.Enabled -eq $FALSE) {
        Write-IcingaConsoleNotice 'The repository "{0}" is already disabled' -Objects $Name;
        return;
    }

    Set-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}.Enabled', $Name)) -Value $FALSE;

    Write-IcingaConsoleNotice 'The repository "{0}" was successfully disabled' -Objects $Name;
}

function Enable-IcingaRepository()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}', $Name));

    if ($null -eq $CurrentRepositories) {
        Write-IcingaConsoleError 'A repository with the name "{0}" is not configured' -Objects $Name;
        return;
    }

    if ($CurrentRepositories.Enabled -eq $TRUE) {
        Write-IcingaConsoleNotice 'The repository "{0}" is already enabled' -Objects $Name;
        return;
    }

    Set-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}.Enabled', $Name)) -Value $TRUE;

    Write-IcingaConsoleNotice 'The repository "{0}" was successfully enabled' -Objects $Name;
}

function Get-IcingaComponentList()
{
    param (
        [switch]$Snapshot = $FALSE
    );

    $Repositories           = Get-IcingaRepositories -ExcludeDisabled;
    [Version]$LatestVersion = $null;
    [string]$SourcePath     = $null;
    [bool]$FoundPackage     = $FALSE;
    [array]$Output          = @();
    [bool]$FoundPackage     = $FALSE;

    $SearchList             = New-Object -TypeName PSObject;
    $SearchList | Add-Member -MemberType NoteProperty -Name 'Repos'      -Value @();
    $SearchList | Add-Member -MemberType NoteProperty -Name 'Components' -Value @{ };

    foreach ($entry in $Repositories) {
        $RepoContent        = Read-IcingaRepositoryFile -Name $entry.Name;

        if ($null -eq $RepoContent) {
            continue;
        }

        if ((Test-IcingaPowerShellConfigItem -ConfigObject $RepoContent -ConfigKey 'Packages') -eq $FALSE) {
            continue;
        }

        foreach ($repoEntry in $RepoContent.Packages.PSObject.Properties.Name) {

            $RepoData = New-Object -TypeName PSObject;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'Name'          -Value $entry.Name;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'RemoteSource'  -Value $RepoContent.Info.RemoteSource;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'ComponentName' -Value $repoEntry;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'Packages'      -Value @();

            foreach ($package in $RepoContent.Packages.$repoEntry) {

                $ComponentData = New-Object -TypeName PSObject;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Version'  -Value $package.Version;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Location' -Value $package.Location;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Snapshot' -Value $package.Snapshot;

                if ($Snapshot -And $package.Snapshot -eq $FALSE) {
                    continue;
                }

                if ($SearchList.Components.ContainsKey($repoEntry) -eq $FALSE) {
                    $SearchList.Components.Add($repoEntry, $package.Version);
                }

                if ([version]($SearchList.Components[$repoEntry]) -lt [version]$package.Version) {
                    $SearchList.Components[$repoEntry] = $package.Version;
                }

                $RepoData.Packages += $ComponentData;
            }

            $SearchList.Repos += $RepoData;
        }
    }

    return $SearchList;
}

function Get-IcingaComponentLock()
{
    param (
        [string]$Name    = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify the component to get the lock version';
        return;
    }

    $LockedComponents = Get-IcingaPowerShellConfig -Path 'Framework.Repository.ComponentLock';

    if ($null -eq $LockedComponents) {
        return $null;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $LockedComponents -ConfigKey $Name) {
        return $LockedComponents.$Name;
    }

    return $null;
}

function Get-IcingaForWindowsServiceData()
{
    $IcingaForWindowsService = Get-IcingaServices -Service 'icingapowershell';

    [hashtable]$ServiceData = @{
        'Directory' = '';
        'FullPath'  = '';
        'User'      = '';
    }

    if ($null -ne $IcingaForWindowsService) {
        $ServicePath           = $IcingaForWindowsService.icingapowershell.configuration.ServicePath;
        $ServicePath           = $ServicePath.SubString(0, $ServicePath.IndexOf('.exe') + 4);
        $ServicePath           = $ServicePath.Replace('"', '');
        $ServiceData.FullPath  = $ServicePath;
        $ServiceData.Directory = $ServicePath.Substring(0, $ServicePath.LastIndexOf('\') + 1);
        $ServiceData.User      = $IcingaForWindowsService.icingapowershell.configuration.ServiceUser;

        return $ServiceData;
    }

    $ServiceData.Directory = (Join-Path -Path $env:ProgramFiles -ChildPath 'icinga-framework-service');
    $ServiceData.User      = 'NT Authority\NetworkService';

    return $ServiceData;
}

function Get-IcingaInstallation()
{
    param (
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE
    )
    [hashtable]$InstalledComponents = @{ };

    $PowerShellModules = Get-Module -ListAvailable;

    foreach ($entry in $PowerShellModules) {
        $RootPath = (Get-IcingaForWindowsRootPath);

        if ($entry.Path -NotLike "$RootPath*") {
            continue;
        }

        if ($entry.Name -Like 'icinga-powershell-*') {
            $ComponentName  = $entry.Name.Replace('icinga-powershell-', '');
            $InstallPackage = (Get-IcingaRepositoryPackage -Name $ComponentName -Release:$Release -Snapshot:$Snapshot);
            $LatestVersion  = '';
            $CurrentVersion = ([string]((Get-Module -ListAvailable -Name $entry.Name -ErrorAction SilentlyContinue) | Sort-Object Version -Descending | Select-Object Version -First 1).Version);

            if ($InstallPackage.HasPackage) {
                [string]$LatestVersion = $InstallPackage.Package.Version;
            }

            if ([string]::IsNullOrEmpty($LatestVersion) -eq $FALSE -And [Version]$LatestVersion -le [Version]$CurrentVersion) {
                $LatestVersion = '';
            }

            Add-IcingaHashtableItem `
                -Hashtable $InstalledComponents `
                -Key $ComponentName `
                -Value @{
                    'Path'           = (Join-Path -Path $RootPath -ChildPath $entry.Name);
                    'CurrentVersion' = $CurrentVersion;
                    'LatestVersion'  = $LatestVersion;
                    'LockedVersion'  = (Get-IcingaComponentLock -Name $ComponentName);
                } | Out-Null;
        }
    }

    $IcingaForWindowsService = Get-IcingaServices -Service 'icingapowershell';

    if ($null -ne $IcingaForWindowsService) {
        $ServicePath = Get-IcingaForWindowsServiceData;

        if ($InstalledComponents.ContainsKey('service')) {
            $InstalledComponents.Remove('service');
        }

        $InstallPackage = (Get-IcingaRepositoryPackage -Name 'service' -Release:$Release -Snapshot:$Snapshot);
        $LatestVersion  = '';
        $CurrentVersion = ([string]((Read-IcingaServicePackage -File $ServicePath.FullPath).ProductVersion));

        if ($InstallPackage.HasPackage) {
            [string]$LatestVersion = $InstallPackage.Package.Version;
        }

        if ([string]::IsNullOrEmpty($LatestVersion) -eq $FALSE -And [Version]$LatestVersion -le [Version]$CurrentVersion) {
            $LatestVersion = '';
        }

        $InstalledComponents.Add(
            'service',
            @{
                'Path'           = $ServicePath.Directory;
                'CurrentVersion' = $CurrentVersion;
                'LatestVersion'  = $LatestVersion;
                'LockedVersion'  = (Get-IcingaComponentLock -Name 'service');
            }
        )
    }

    $IcingaAgent = Get-IcingaAgentInstallation;

    if ($InstalledComponents.ContainsKey('agent')) {
        $InstalledComponents.Remove('agent');
    }

    if ($IcingaAgent.Installed) {

        $InstallPackage = (Get-IcingaRepositoryPackage -Name 'agent' -Release:$Release -Snapshot:$Snapshot);
        $LatestVersion  = '';
        $CurrentVersion = ([string]$IcingaAgent.Version.Full);

        if ($InstallPackage.HasPackage) {
            $LatestVersion = $InstallPackage.Package.Version;
        }

        if ([string]::IsNullOrEmpty($LatestVersion) -eq $FALSE -And [Version]$LatestVersion -le [Version]$CurrentVersion) {
            $LatestVersion = '';
        }

        $InstalledComponents.Add(
            'agent',
            @{
                'Path'           = $IcingaAgent.RootDir;
                'CurrentVersion' = $CurrentVersion;
                'LatestVersion'  = $LatestVersion;
                'LockedVersion'  = (Get-IcingaComponentLock -Name 'agent');
            }
        )
    }

    return $InstalledComponents;
}

function Get-IcingaRepositories()
{
    param (
        [switch]$ExcludeDisabled = $FALSE
    );

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';
    [array]$RepoList     = $CurrentRepositories.PSObject.Properties | Sort-Object { $_.Value.Order } -Descending;

    if ($ExcludeDisabled -eq $FALSE) {
        return $RepoList;
    }

    [array]$ActiveRepos = @();

    foreach ($repo in $RepoList) {
        if ($repo.Value.Enabled -eq $FALSE) {
            continue;
        }

        $ActiveRepos += $repo;
    }

    return $ActiveRepos;
}

function Get-IcingaRepositoryHash()
{
    param (
        [string]$Path
    );

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided path "{0}" does not exist' -Objects $Path;
        return;
    }

    $RepositoryFolder  = Get-ChildItem -Path $Path -Recurse;
    [array]$FileHashes = @();

    foreach ($entry in $RepositoryFolder) {
        $FileHashes += (Get-FileHash -Path $entry.FullName -Algorithm SHA256).Hash;
    }

    $HashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create('SHA256');
    $BinaryHash    = $HashAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($FileHashes.ToString()))

    return [System.BitConverter]::ToString($BinaryHash).Replace('-', '');
}

function Get-IcingaRepositoryPackage()
{
    param (
        [string]$Name,
        [string]$Version  = $null,
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a component name';
        return;
    }

    $Repositories           = Get-IcingaRepositories -ExcludeDisabled;
    [Version]$LatestVersion = $null;
    $InstallPackage         = $null;
    $SourceRepo             = $null;
    $RepoName               = $null;
    [bool]$HasRepo          = $FALSE;

    foreach ($entry in $Repositories) {
        $RepoContent        = Read-IcingaRepositoryFile -Name $entry.Name;
        [bool]$FoundPackage = $FALSE;

        if ($null -eq $RepoContent) {
            continue;
        }

        if ((Test-IcingaPowerShellConfigItem -ConfigObject $RepoContent -ConfigKey 'Packages') -eq $FALSE) {
            continue;
        }

        if ((Test-IcingaPowerShellConfigItem -ConfigObject $RepoContent.Packages -ConfigKey $Name) -eq $FALSE) {
            continue;
        }

        foreach ($package in $RepoContent.Packages.$Name) {

            if ($Snapshot -And $package.Snapshot -eq $FALSE) {
                continue;
            }

            if ($Release -And $package.Snapshot -eq $TRUE) {
                continue;
            }

            if ([string]::IsNullOrEmpty($Version) -And ($null -eq $LatestVersion -Or $LatestVersion -lt $package.Version)) {
                [Version]$LatestVersion = [Version]$package.Version;
                $InstallPackage         = $package;
                $HasRepo                = $TRUE;
                $SourceRepo             = $RepoContent;
                $RepoName               = $entry.Name;
                continue;
            }

            if ([string]::IsNullOrEmpty($Version) -eq $FALSE -And [version]$package.Version -eq [version]$Version) {
                $InstallPackage = $package;
                $FoundPackage   = $TRUE;
                $HasRepo        = $TRUE;
                $SourceRepo     = $RepoContent;
                $RepoName       = $entry.Name;
                break;
            }
        }

        if ($FoundPackage) {
            break;
        }
    }

    return @{
        'HasPackage' = $HasRepo;
        'Package'    = $InstallPackage;
        'Source'     = $SourceRepo;
        'Repository' = $RepoName;
    };
}

function Install-IcingaComponent()
{
    param (
        [string]$Name     = $null,
        [string]$Version  = $null,
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE,
        [switch]$Confirm  = $FALSE,
        [switch]$Force    = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a component name';
        return;
    }

    Set-IcingaTLSVersion;

    if ($Version -eq 'release') {
        $Version = $null;
    }

    if ($Release -eq $TRUE -And $Snapshot -eq $TRUE) {
        Write-IcingaConsoleError 'You can only select either "Release" or "Snapshot" channel for package installation';
        return;
    }

    if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
        $Release = $TRUE;
    }

    $LockedVersion = Get-IcingaComponentLock -Name $Name;

    if ($null -ne $LockedVersion) {
        $Version = $LockedVersion;
        Write-IcingaConsoleNotice 'Component "{0}" is locked to version "{1}"' -Objects $Name, $LockedVersion;
    }

    $PackageContent = Get-IcingaRepositoryPackage -Name $Name -Version $Version -Release:$Release -Snapshot:$Snapshot;
    $InstallPackage = $PackageContent.Package;
    $SourceRepo     = $PackageContent.Source;
    $RepoName       = $PackageContent.Repository;

    if ($PackageContent.HasPackage -eq $FALSE) {
        $SearchVersion = 'release';
        if ([string]::IsNullOrEmpty($Version) -eq $FALSE) {
            $SearchVersion = $Version;
        }
        if ($Release) {
            Write-IcingaConsoleError 'The component "{0}" was not found on stable channel with version "{1}"' -Objects $Name, $SearchVersion;
            return;
        }
        if ($Snapshot) {
            Write-IcingaConsoleError 'The component "{0}" was not found on snapshot channel with version "{1}"' -Objects $Name, $SearchVersion;
            return;
        }
        return;
    }

    $FileSource = $InstallPackage.Location;

    if ($InstallPackage.RelativePath -eq $TRUE) {
        $FileSource = Join-WebPath -Path ($SourceRepo.Info.RemoteSource.Replace('\', '/')) -ChildPath ($InstallPackage.Location.Replace('\', '/'));
    }

    if ($Confirm -eq $FALSE) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you want to install component "{0}" from source "{1}" ({2})?', $Name.ToLower(), $RepoName, $FileSource)) -Default 'y').result -ne 1) {
            return;
        }
    }

    $FileName            = $FileSource.SubString($FileSource.LastIndexOf('/') + 1, $FileSource.Length - $FileSource.LastIndexOf('/') - 1);
    $DownloadDirectory   = New-IcingaTemporaryDirectory;
    $DownloadDestination = (Join-Path -Path $DownloadDirectory -ChildPath $FileName);

    Write-IcingaConsoleNotice ([string]::Format('Downloading "{0}" from "{1}"', $Name.ToLower(), $FileSource));

    if ((Invoke-IcingaWebRequest -UseBasicParsing -Uri $FileSource -OutFile $DownloadDestination).HasErrors) {
        Write-IcingaConsoleError ([string]::Format('Failed to download "{0}" from "{1}" into "{2}". Starting cleanup process', $Name.ToLower(), $FileSource, $DownloadDestination));
        Start-Sleep -Seconds 2;
        Remove-Item -Path $DownloadDirectory -Recurse -Force;

        return;
    }

    $FileHash = (Get-FileHash -Path $DownloadDestination -Algorithm SHA256).Hash;

    if ([string]::IsNullOrEmpty($InstallPackage.Hash) -eq $FALSE -And (Get-FileHash -Path $DownloadDestination -Algorithm SHA256).Hash -ne $InstallPackage.Hash) {
        Write-IcingaConsoleError ([string]::Format('File validation failed. The stored hash inside the repository "{0}" is not matching the file hash "{1}"', $InstallPackage.Hash, $FileHash));
        return;
    }

    if ([IO.Path]::GetExtension($FileName) -eq '.zip') {
        <#
            Handles installation of Icinga for Windows packages and Icinga for Windows service
        #>

        Expand-IcingaZipArchive -Path $DownloadDestination -Destination $DownloadDirectory | Out-Null;
        Start-Sleep -Seconds 2;
        Remove-Item -Path $DownloadDestination -Force;

        $FolderContent = Get-ChildItem -Path $DownloadDirectory -Recurse -Include '*.psd1';

        <#
            Handles installation of Icinga for Windows packages
        #>
        if ($null -ne $FolderContent -And $FolderContent.Count -ne 0) {
            $ManifestFile  = $null;
            $PackageName   = $null;
            $PackageRoot   = $null;

            foreach ($manifest in $FolderContent) {
                $ManifestFile = Read-IcingaPackageManifest -File $manifest.FullName;

                if ($null -ne $ManifestFile) {
                    $PackageName = $manifest.Name.Replace('.psd1', '');
                    $PackageRoot = $manifest.FullName.SubString(0, $manifest.FullName.LastIndexOf('\'));
                    $PackageRoot = Join-Path -Path $PackageRoot -ChildPath '\*'
                    break;
                }
            }

            if ($null -eq $ManifestFile) {
                Write-IcingaConsoleError ([string]::Format('Unable to read manifest for package "{0}". Aborting installation', $Name.ToLower()));
                Start-Sleep -Seconds 2;
                Remove-Item -Path $DownloadDirectory -Recurse -Force;
                return;
            }

            $ComponentFolder        = Join-Path -Path (Get-IcingaForWindowsRootPath) -ChildPath $PackageName;
            $ModuleData             = (Get-Module -ListAvailable -Name $PackageName -ErrorAction SilentlyContinue) | Sort-Object Version -Descending | Select-Object Version -First 1;
            [string]$InstallVersion = $null;
            $ServiceStatus          = $null;
            $AgentStatus            = $null;

            if ($null -ne $ModuleData) {
                [string]$InstallVersion = $ModuleData.Version;
            }

            if ($ManifestFile.ModuleVersion -eq $InstallVersion -And $Force -eq $FALSE) {
                Write-IcingaConsoleError ([string]::Format('The package "{0}" with version "{1}" is already installed. Use "-Force" to re-install the component', $Name.ToLower(), $ManifestFile.ModuleVersion));
                Start-Sleep -Seconds 2;
                Remove-Item -Path $DownloadDirectory -Recurse -Force;
                return;
            }

            # These update steps only apply for the framework
            if ($Name.ToLower() -eq 'framework') {
                $ServiceStatus = (Get-Service 'icingapowershell' -ErrorAction SilentlyContinue).Status;
                $AgentStatus   = (Get-Service 'icinga2' -ErrorAction SilentlyContinue).Status;

                if ($ServiceStatus -eq 'Running') {
                    Write-IcingaConsoleNotice 'Stopping Icinga for Windows service';
                    Stop-IcingaService 'icingapowershell';
                    Start-Sleep -Seconds 1;
                }
                if ($AgentStatus -eq 'Running') {
                    Write-IcingaConsoleNotice 'Stopping Icinga Agent service';
                    Stop-IcingaService 'icinga2';
                    Start-Sleep -Seconds 1;
                }
            }

            if ((Test-Path $ComponentFolder) -eq $FALSE) {
                [void](New-Item -ItemType Directory -Path $ComponentFolder -Force);
            }

            $ComponentFileContent = Get-ChildItem -Path $ComponentFolder;

            foreach ($entry in $ComponentFileContent) {
                if (($entry.Name -eq 'cache' -Or $entry.Name -eq 'config') -And $Name.ToLower() -eq 'framework') {
                    continue;
                }

                [void](Remove-ItemSecure -Path $entry.FullName -Recurse -Force);
            }

            [void](Copy-ItemSecure -Path $PackageRoot -Destination $ComponentFolder -Recurse -Force);

            Write-IcingaConsoleNotice 'Installing version "{0}" of component "{1}"' -Objects $ManifestFile.ModuleVersion, $Name.ToLower();

            Unblock-IcingaPowerShellFiles -Path $ComponentFolder;

            if ($Name.ToLower() -eq 'framework') {
                if (Test-IcingaFunction 'Write-IcingaFrameworkCodeCache') {
                    Write-IcingaFrameworkCodeCache;
                }

                if ($ServiceStatus -eq 'Running') {
                    Write-IcingaConsoleNotice 'Starting Icinga for Windows service';
                    Start-IcingaService 'icingapowershell';
                }
                if ($AgentStatus -eq 'Running') {
                    Write-IcingaConsoleNotice 'Starting Icinga Agent service';
                    Start-IcingaService 'icinga2';
                }
            }

            Import-Module -Name $ComponentFolder -Force;
            Write-IcingaConsoleNotice 'Installation of component "{0}" with version "{1}" was successful. Open a new PowerShell to apply the changes' -Objects $Name.ToLower(), $ManifestFile.ModuleVersion;
        } else {
            <#
                Handles installation of Icinga for Windows service
            #>

            $FolderContent = Get-ChildItem -Path $DownloadDirectory -Recurse -Include 'icinga-service.exe';

            if ($Name.ToLower() -eq 'service') {

                $ConfigDirectory  = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.IcingaForWindowsService';
                $ConfigUser       = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser';
                $ServiceData      = Get-IcingaForWindowsServiceData;
                $ServiceDirectory = $ServiceData.Directory;
                $ServiceUser      = $ServiceData.User;

                if ([string]::IsNullOrEmpty($ConfigDirectory) -eq $FALSE) {
                    $ServiceDirectory = $ConfigDirectory;
                }

                if ([string]::IsNullOrEmpty($ConfigUser) -eq $FALSE) {
                    $ServiceUser = $ConfigUser;
                }

                foreach ($binary in $FolderContent) {

                    if ((Test-IcingaZipBinaryChecksum -Path $binary.FullName) -eq $FALSE) {
                        Write-IcingaConsoleError 'The checksum for the given service binary does not match';
                        continue;
                    }

                    if ((Test-Path $ServiceDirectory) -eq $FALSE) {
                        [void](New-Item -ItemType Directory -Path $ServiceDirectory -Force);
                    }

                    $UpdateBin  = Join-Path -Path $ServiceDirectory -ChildPath 'icinga-service.exe.update';
                    $ServiceBin = Join-Path -Path $ServiceDirectory -ChildPath 'icinga-service.exe';

                    # Service is already installed
                    if (Test-Path $ServiceBin) {
                        $InstalledService = Read-IcingaServicePackage -File $ServiceBin;
                        $NewService       = Read-IcingaServicePackage -File $binary.FullName;

                        if ($InstalledService.ProductVersion -eq $NewService.ProductVersion -And $null -ne $InstalledService -And $null -ne $NewService -And $Force -eq $FALSE) {
                            Write-IcingaConsoleError ([string]::Format('The package "service" with version "{0}" is already installed. Use "-Force" to re-install the component', $InstalledService.ProductVersion));
                            Start-Sleep -Seconds 2;
                            Remove-Item -Path $DownloadDirectory -Recurse -Force;

                            return;
                        }
                    }

                    Write-IcingaConsoleNotice 'Installing component "service" into "{0}"' -Objects $ServiceDirectory;

                    Copy-ItemSecure -Path $binary.FullName -Destination $UpdateBin -Force;

                    [void](Install-IcingaForWindowsService -Path $ServiceBin -User $ServiceUser -Password (Get-IcingaInternalPowerShellServicePassword));
                    Set-IcingaInternalPowerShellServicePassword -Password $null;
                    Start-Sleep -Seconds 2;
                    Remove-Item -Path $DownloadDirectory -Recurse -Force;

                    Write-IcingaConsoleNotice 'Installation of component "service" was successful'

                    return;
                }

                Write-IcingaConsoleError 'Failed to install component "service". Either the package did not include a service binary or the checksum of the binary did not match';
                Start-Sleep -Seconds 2;
                Remove-Item -Path $DownloadDirectory -Recurse -Force;
                return;
            } else {
                Write-IcingaConsoleError 'There was no manifest file found inside the package';
                Remove-Item -Path $DownloadDirectory -Recurse -Force;
                return;
            }
        }
    } elseif ([IO.Path]::GetExtension($FileName) -eq '.msi') {

        <#
            Handles installation of Icinga Agent MSI Packages
        #>

        $IcingaData       = Get-IcingaAgentInstallation;
        $InstalledVersion = Get-IcingaAgentVersion;
        $InstallTarget    = $IcingaData.RootDir;
        $InstallDir       = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.AgentLocation';
        $ConfigUser       = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser';
        $ServiceUser      = $IcingaData.User;

        if ([string]::IsNullOrEmpty($InstallDir) -eq $FALSE) {
            if ((Test-Path $InstallDir) -eq $FALSE) {
                [void](New-Item -Path $InstallDir -ItemType Directory -Force);
            }
            $InstallTarget = $InstallDir;
        }

        if ([string]::IsNullOrEmpty($ConfigUser) -eq $FALSE) {
            $ServiceUser = $ConfigUser;
        }

        [string]$InstallFolderMsg = $InstallTarget;

        if ([string]::IsNullOrEmpty($InstallTarget) -eq $FALSE) {
            $InstallTarget = [string]::Format(' INSTALL_ROOT="{0}"', $InstallTarget);
        } else {
            $InstallTarget = '';
            if ($IcingaData.Architecture -eq 'x86') {
                $InstallFolderMsg = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'icinga2';
            } else {
                $InstallFolderMsg = Join-Path -Path $env:ProgramFiles -ChildPath 'icinga2';
            }
        }

        $MSIData = & powershell.exe -Command { Use-Icinga; return Read-IcingaMSIMetadata -File $args[0] } -Args $DownloadDestination;

        if ($InstalledVersion.Full -eq $MSIData.ProductVersion -And $Force -eq $FALSE) {
            Write-IcingaConsoleError 'The package "agent" with version "{0}" is already installed. Use "-Force" to re-install the component' -Objects $InstalledVersion.Full;
            Remove-Item -Path $DownloadDirectory -Recurse -Force;

            return;
        }

        Write-IcingaConsoleNotice 'Installing component "agent" with version "{0}" into "{1}"' -Objects $MSIData.ProductVersion, $InstallFolderMsg;

        if ($IcingaData.Installed) {
            if ((Uninstall-IcingaAgent) -eq $FALSE) {
                return;
            }
        }

        $InstallProcess = powershell.exe -Command {
            $IcingaInstaller = $args[0];
            $InstallTarget   = $args[1];
            Use-Icinga;

            $InstallProcess = Start-IcingaProcess -Executable 'MsiExec.exe' -Arguments ([string]::Format('/quiet /i "{0}" {1}', $IcingaInstaller, $InstallTarget)) -FlushNewLines;

            return $InstallProcess;
        } -Args $DownloadDestination, $InstallTarget;

        if ($InstallProcess.ExitCode -ne 0) {
            Write-IcingaConsoleError -Message 'Failed to install component "agent": {0}{1}' -Objects $InstallProcess.Message, $InstallProcess.Error;
            return $FALSE;
        }

        Set-IcingaAgentServiceUser -User $ServiceUser -SetPermission;

        Write-IcingaConsoleNotice 'Installation of component "agent" with version "{0}" was successful.' -Objects $MSIData.ProductVersion;
    } else {
        Write-IcingaConsoleError ([string]::Format('Unsupported file extension "{0}" found for package "{1}". Aborting installation', ([IO.Path]::GetExtension($FileName)), $Name.ToLower()));
    }

    Start-Sleep -Seconds 1;
    Remove-Item -Path $DownloadDirectory -Recurse -Force;
}

function Lock-IcingaComponent()
{
    param (
        [string]$Name    = $null,
        [string]$Version = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify the component to lock';
        return;
    }

    $Name = $Name.ToLower();
    if ([string]::IsNullOrEmpty($Version)) {
        if ($Name -eq 'agent') {
            $Version = (Get-IcingaAgentVersion).Full;
        } else {
            $ModuleData = Get-Module -ListAvailable -Name ([string]::Format('icinga-powershell-{0}', $Name)) -ErrorAction SilentlyContinue;

            if ($null -eq $ModuleData) {
                $ModuleData = Get-Module -ListAvailable -Name "*$Name*" -ErrorAction SilentlyContinue;
            }

            if ($null -ne $ModuleData) {
                $Version = $ModuleData.Version.ToString();
                $Name    = (Read-IcingaPackageManifest -File $ModuleData.Path).ComponentName;
            }
        }
    }

    if ([string]::IsNullOrEmpty($Version)) {
        Write-IcingaConsoleError 'Pinning the current version of component "{0}" is not possible, as it seems to be not installed. Please install the component first or manually specify version with "-Version"';
        return;
    }

    $LockedComponents = Get-IcingaPowerShellConfig -Path 'Framework.Repository.ComponentLock';

    if ($null -eq $LockedComponents) {
        $LockedComponents = New-Object -TypeName PSObject;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $LockedComponents -ConfigKey $Name) {
        $LockedComponents.$Name = $Version;
    } else {
        $LockedComponents | Add-Member -MemberType NoteProperty -Name $Name -Value $Version;
    }

    Write-IcingaConsoleNotice 'Locking of component "{0}" to version "{1}" successful. You can release the lock with "Unlock-IcingaComponent -Name {2}{0}{2}"' -Objects $Name, $Version, "'";

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.ComponentLock' -Value $LockedComponents;
}

function New-IcingaRepository()
{
    param (
        [string]$Name       = $null,
        [string]$Path       = $null,
        [string]$RemotePath = $null,
        [switch]$Force      = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided path "{0}" does not exist' -Objects $Path;
        return;
    }

    if ([string]::IsNullOrEmpty($RemotePath)) {
        Write-IcingaConsoleWarning 'No explicit remote path has been defined. Using local path "{0}" as remote path' -Objects $Path;
        $RemotePath = $Path;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        $CurrentRepositories = New-Object -TypeName PSObject;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does already exist. Use "Update-IcingaRepository -Name {1}{0}{1}" to update it.' -Objects $Name, "'";
        return;
    }

    $IcingaRepository = New-IcingaRepositoryFile -Path $Path -RemotePath $RemotePath;

    [array]$ConfigCount = $IcingaRepository.Packages.PSObject.Properties.Count;

    if ($ConfigCount.Count -eq 0) {
        Write-IcingaConsoleWarning 'Created empty repository at location "{0}"' -Objects $Path;
    }
    [array]$RepoCount = $CurrentRepositories.PSObject.Properties.Count;

    $CurrentRepositories | Add-Member -MemberType NoteProperty -Name $Name -Value (New-Object -TypeName PSObject);
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'LocalPath'   -Value $Path;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'RemotePath'  -Value $RemotePath;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'CloneSource' -Value $null;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'UseSCP'      -Value $FALSE;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Order'       -Value $RepoCount.Count;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Enabled'     -Value $True;

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
}

function New-IcingaRepositoryFile()
{
    param (
        [string]$Path       = $null,
        [string]$RemotePath = $null
    );

    $RepoFile = 'ifw.repo.json';
    $RepoPath = Join-Path -Path $Path -ChildPath $RepoFile;

    $IcingaRepository = New-Object -TypeName PSObject;
    $IcingaRepository | Add-Member -MemberType NoteProperty -Name 'Info' -Value (New-Object -TypeName PSObject);

    # Info
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'LocalSource'  -Value $Path;
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'RemoteSource' -Value $RemotePath;
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'Created'      -Value ((Get-Date).ToUniversalTime().ToString('yyyy\/MM\/dd HH:mm:ss'));
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'Updated'      -Value $IcingaRepository.Info.Created;
    $IcingaRepository.Info | Add-Member -MemberType NoteProperty -Name 'RepoHash'     -Value $null;

    # Packages
    $IcingaRepository | Add-Member -MemberType NoteProperty -Name 'Packages' -Value (New-Object -TypeName PSObject);

    $RepositoryFolder = Get-ChildItem -Path $Path -Recurse -Include '*.msi', '*.zip';

    foreach ($entry in $RepositoryFolder) {
        $RepoFilePath            = $entry.FullName.Replace($Path, '');
        $FileHash                = Get-FileHash -Path $entry.FullName -Algorithm SHA256;
        $ComponentName           = '';

        $IcingaForWindowsPackage = New-Object -TypeName PSObject;
        $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Hash'         -Value $FileHash.Hash;
        $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Location'     -Value $RepoFilePath;
        $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'RelativePath' -Value $TRUE;

        if ([IO.Path]::GetExtension($entry.Name) -eq '.zip') {
            $IcingaPackage = Read-IcingaPackageManifest -File $entry.FullName;
            $IcingaService = $null;
            $Version       = $null;

            if ($null -ne $IcingaPackage) {
                $PackageVersion = $IcingaPackage.ModuleVersion;
                $ComponentName  = $IcingaPackage.ComponentName;
            } else {
                $IcingaService = Read-IcingaServicePackage -File $entry.FullName;
            }
            if ($null -ne $IcingaService) {
                $PackageVersion = $IcingaService.ProductVersion;
                $ComponentName  = $IcingaService.ComponentName;
            }

            [bool]$IsSnapshot = $FALSE;

            if ($entry.FullName.ToLower() -like '*\master.zip') {
                $IsSnapshot = $TRUE;
            }

            if ([string]::IsNullOrEmpty($ComponentName) -eq $FALSE) {
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Version'      -Value $PackageVersion;
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Snapshot'     -Value $IsSnapshot;
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Architecture' -Value 'Multi';
            }
        } elseif ([IO.Path]::GetExtension($entry.Name) -eq '.msi') {
            $IcingaPackage = Read-IcingaMSIMetadata -File $entry.FullName;

            if ([string]::IsNullOrEmpty($IcingaPackage.ProductName) -eq $FALSE -And $IcingaPackage.ProductName -eq 'Icinga 2') {
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Version'      -Value $IcingaPackage.ProductVersion;
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Snapshot'     -Value $IcingaPackage.Snapshot;
                $IcingaForWindowsPackage | Add-Member -MemberType NoteProperty -Name 'Architecture' -Value $IcingaPackage.Architecture;
                $ComponentName = 'agent';
            }
        }

        if ([string]::IsNullOrEmpty($ComponentName)) {
            continue;
        }

        if (Test-IcingaPowerShellConfigItem -ConfigObject $IcingaRepository.Packages -ConfigKey $ComponentName) {
            $IcingaRepository.Packages.$ComponentName += $IcingaForWindowsPackage;
        } else {
            $IcingaRepository.Packages | Add-Member -MemberType NoteProperty -Name $ComponentName -Value @();
            $IcingaRepository.Packages.$ComponentName += $IcingaForWindowsPackage;
        }

        $IcingaRepository.Info.RepoHash = Get-IcingaRepositoryHash -Path $Path;
    }

    Set-Content -Path $RepoPath -Value (ConvertTo-Json -InputObject $IcingaRepository -Depth 100);

    return $IcingaRepository;
}

function Pop-IcingaRepository()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        Write-IcingaConsoleNotice 'You have no repositories configured yet.';
        return;
    }

    [array]$RepoList = Get-IcingaRepositories;
    [int]$Index      = $RepoList.Count - 1;

    foreach ($repo in $RepoList) {
        if ($repo.Name -eq $Name) {
            continue;
        }

        $CurrentRepositories.($repo.Name).Order = [int]$Index;
        $Index -= 1;
    }

    $CurrentRepositories.$Name.Order = [int]$Index;

    Write-IcingaConsoleNotice 'The repository "{0}" was put at the bottom of the repository list' -Objects $Name;

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
}

function Push-IcingaRepository()
{
    param (
        [string]$Name   = $null,
        [switch]$Silent = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        if ($Silent -eq $FALSE) {
            Write-IcingaConsoleError 'You have to provide a name for the repository';
        }
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        if ($Silent -eq $FALSE) {
            Write-IcingaConsoleNotice 'You have no repositories configured yet.';
        }
        return;
    }

    [array]$RepoList = Get-IcingaRepositories;
    [int]$Index      = 0;

    foreach ($repo in $RepoList) {
        if ($repo.Name -eq $Name) {
            continue;
        }

        $CurrentRepositories.($repo.Name).Order = [int]$Index;
        $Index += 1;
    }

    $CurrentRepositories.$Name.Order = [int]$Index;

    if ($Silent -eq $FALSE) {
        Write-IcingaConsoleNotice 'The repository "{0}" was put at the top of the repository list' -Objects $Name;
    }

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
}

function Read-IcingaMSIMetadata()
{
    param (
        [string]$File = $null
    );

    if ([string]::IsNullOrEmpty($File) -Or (Test-Path $File) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided file "{0}" does not exist' -Objects $File;
        return $null;
    }

    if ([IO.Path]::GetExtension($File) -ne '.msi') {
        Write-IcingaConsoleError 'This Cmdlet is only supporting files with .msi extension. Extension "{0}" given.' -Objects ([IO.Path]::GetExtension($File));
        return $null;
    }

    $AgentFile      = Get-Item $File;
    $MSIPackageData = @{
        'ProductCode'    = '';
        'ProductVersion' = '';
        'ProductName'    = '';
    }

    [array]$MSIObjects = $MSIPackageData.Keys;

    try {
        $InstallerInstance = New-Object -ComObject 'WindowsInstaller.Installer';
        #$MSIPackage       = $InstallerInstance.OpenDatabase($File, 0); # Not Working on Windows 2012 R2
        $MSIPackage        = $InstallerInstance.GetType().InvokeMember('OpenDatabase', 'InvokeMethod', $Null, $InstallerInstance, @($File, 0));

        foreach ($PackageInfo in $MSIObjects) {
            $MSIQuery = [string]::Format(
                "SELECT `Value` FROM `Property` WHERE `Property` = '{0}'",
                $PackageInfo
            );
            #$MSIDb     = $MSIPackage.OpenView($MSIQuery); # Not Working on Windows 2012 R2
            $MSIDb      = $MSIPackage.GetType().InvokeMember('OpenView', 'InvokeMethod', $Null, $MSIPackage, $MSIQuery);

            if ($null -eq $MSIDb) {
                continue;
            }

            #$MSIDb.Execute(); # Not Working on Windows 2012 R2
            $MSIDb.GetType().InvokeMember('Execute', 'InvokeMethod', $Null, $MSIDb, $Null);
            #$MSITable = $MSIDb.Fetch(); # Not Working on Windows 2012 R2
            $MSITable  = $MSIDb.GetType().InvokeMember('Fetch' , 'InvokeMethod', $Null, $MSIDb, $Null);

            if ($null -eq $MSITable) {
                continue;
            }

            $MSIPackageData[$PackageInfo] = $MSITable.GetType().InvokeMember('StringData', 'GetProperty', $null, $MSITable, 1);

            #$MSIDb.Close(); # Not Working on Windows 2012 R2
            $MSIDb.GetType().InvokeMember('Close', 'InvokeMethod', $null, $MSIDb, $null);
            [void]([System.Runtime.InteropServices.Marshal]::ReleaseComObject($MSIDb));
            $MSIDb = $null;
        }

        [void]([System.Runtime.InteropServices.Marshal]::ReleaseComObject($MSIPackage));
        [void]([System.Runtime.InteropServices.Marshal]::ReleaseComObject($InstallerInstance));
        $MSIPackage        = $null;
        $InstallerInstance = $null;

        if ($AgentFile.Name.Contains('x86_64')) {
            $MSIPackageData.Add('Architecture', 'x64')
        } else {
            $MSIPackageData.Add('Architecture', 'x86')
        }

        [Version]$PackageVersion = $MSIPackageData.ProductVersion;
        if ($PackageVersion.Revision -eq -1) {
            $MSIPackageData.Add('Snapshot', $False);
        } else {
            $MSIPackageData.Add('Snapshot', $True);
        }

        return $MSIPackageData;
    } catch {
        Write-IcingaConsoleError 'Failed to query MSI package information for package "{0}". Exception: {1}' -Objects $File, $_.Exception.Message;
    }

    return $null;
}

function Read-IcingaPackageManifest()
{
    param (
        [string]$File = $null
    );

    if ([string]::IsNullOrEmpty($File) -Or (Test-Path $File) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided file "{0}" does not exist' -Objects $File;
        return $null;
    }

    if ((Test-IcingaAddTypeExist 'System.IO.Compression.FileSystem') -eq $FALSE) {
        Add-Type -Assembly 'System.IO.Compression.FileSystem';
    }

    if ([IO.Path]::GetExtension($File) -ne '.zip' -And [IO.Path]::GetExtension($File) -ne '.psd1') {
        Write-IcingaConsoleError 'Your Icinga for Windows manifest must be inside a .zip file or directly given on the "-File" argument. Extension "{0}" given.' -Objects ([IO.Path]::GetExtension($File));
        return $null;
    }

    try {
        $ZipPackage = $null;

        if ([IO.Path]::GetExtension($File) -eq '.zip') {
            $ZipPackage      = [System.IO.Compression.ZipFile]::OpenRead($File);
            $PackageManifest = $null;
            $FileName        = $null;

            foreach ($entry in $ZipPackage.Entries) {
                if ([IO.Path]::GetExtension($entry.FullName) -ne '.psd1') {
                    continue;
                }

                $FileName                   = $entry.Name.Replace('.psd1', '');
                $FilePath                   = $entry.FullName.Replace($entry.Name, '');
                $FileStream                 = $entry.Open();
                $FileReader                 = [System.IO.StreamReader]::new($FileStream);
                $PackageManifestContent     = $FileReader.ReadToEnd();
                $FileReader.Dispose();

                [ScriptBlock]$PackageScript = [ScriptBlock]::Create('return ' + $PackageManifestContent);
                $PackageManifest            = (& $PackageScript);

                if ($null -eq $PackageManifest -Or $PackageManifest.Count -eq 0) {
                    continue;
                }

                if ($PackageManifest.ContainsKey('PrivateData') -eq $FALSE -Or $PackageManifest.ContainsKey('ModuleVersion') -eq $FALSE) {
                    continue;
                }

                break;
            }

            $ZipPackage.Dispose();
        } elseif ([IO.Path]::GetExtension($File) -eq '.psd1') {
            $FileName                   = (Get-Item -Path $File).Name.Replace('.psd1', '');
            $PackageManifestContent     = Get-Content -Path $File -Raw;
            [ScriptBlock]$PackageScript = [ScriptBlock]::Create('return ' + $PackageManifestContent);
            $PackageManifest            = (& $PackageScript);
        } else {
            return $null;
        }

        if ($null -eq $PackageManifest) {
            return $null;
        }

        $PackageManifest.Add('ComponentName', '');

        if ([string]::IsNullOrEmpty($FileName) -eq $FALSE) {
            if ($FileName.Contains('icinga-powershell-*')) {
                $PackageManifest.ComponentName = $FileName.Replace('icinga-powershell-', '');
            } else {
                if ($PackageManifest.ContainsKey('PrivateData') -And $PackageManifest.PrivateData.ContainsKey('Name') -And $PackageManifest.PrivateData.ContainsKey('Type')) {
                    if ($PackageManifest.PrivateData.Name -eq 'Icinga for Windows' -And $PackageManifest.PrivateData.Type -eq 'framework') {
                        $PackageManifest.ComponentName = 'framework';
                    } else {
                        $PackageManifest.ComponentName = ($PackageManifest.PrivateData.Name -Replace 'Windows' -Replace '\W').ToLower();
                    }
                }
            }
        }

        return $PackageManifest;
    } catch {
        $ExMsg = $_.Exception.Message;
        Write-IcingaConsoleError 'Failed to read package content and/or manifest file: {0}' -Objects $ExMsg;
    } finally {
        if ($null -ne $ZipPackage) {
            $ZipPackage.Dispose();
        }
    }

    return $null;
}

function Read-IcingaRepositoryFile()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return $null;
    }

    $Repository = Get-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.Repositories.{0}', $Name));

    if ($null -eq $Repository) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does not exist. Use "New-IcingaRepository" or "Sync-IcingaForWindowsRepository" to create a new one.' -Objects $Name;
        return $null;
    }

    $RepoPath = $null;
    $Content  = $null;

    if ([string]::IsNullOrEmpty($Repository.LocalPath) -eq $FALSE -And (Test-Path -Path $Repository.LocalPath)) {
        $RepoPath = $Repository.LocalPath;
        $Content  = Get-Content -Path (Join-Path -Path $RepoPath -ChildPath 'ifw.repo.json') -Raw;
    } elseif ([string]::IsNullOrEmpty($Repository.RemotePath) -eq $FALSE -And (Test-Path -Path $Repository.RemotePath)) {
        $RepoPath   = $Repository.RemotePath;
        $WebContent = Get-Content -Path (Join-Path -Path $RepoPath -ChildPath 'ifw.repo.json') -Raw;
    } else {
        try {
            $WebContent = Invoke-WebRequest -UseBasicParsing -Uri $Repository.RemotePath;
            $RepoPath   = $Repository.RemotePath;
        } catch {
            # Nothing to do
        }

        if ($null -eq $WebContent) {
            try {
                $WebContent = Invoke-WebRequest -UseBasicParsing -Uri (Join-WebPath -Path $Repository.RemotePath -ChildPath 'ifw.repo.json');
            } catch {
                Write-IcingaConsoleError 'Failed to read repository file from "{0}" or "{0}/ifw.repo.json". Exception: {1}' -Objects $Repository.RemotePath, $_.Exception.Message;
                return $null;
            }
            $RepoPath   = $Repository.RemotePath;
        }

        if ($null -eq $WebContent) {
            Write-IcingaConsoleError 'Unable to fetch data for repository "{0}" from any configured location' -Objects $Name;
            return $null;
        }

        if ($WebContent.RawContent.Contains('application/octet-stream')) {
            $Content = [System.Text.Encoding]::UTF8.GetString($WebContent.Content)
        } else {
            $Content = $WebContent.Content;
        }
    }

    if ($null -eq $Content) {
        Write-IcingaConsoleError 'Unable to fetch data for repository "{0}" from any configured location' -Objects $Name;
        return $null;
    }

    $RepositoryObject = ConvertFrom-Json -InputObject $Content;

    return $RepositoryObject;
}

function Read-IcingaServicePackage()
{
    param (
        [string]$File = $null
    );

    if ([string]::IsNullOrEmpty($File) -Or (Test-Path $File) -eq $FALSE) {
        Write-IcingaConsoleError 'The provided file "{0}" does not exist' -Objects $File;
        return $null;
    }

    if ((Test-IcingaAddTypeExist 'System.IO.Compression.FileSystem') -eq $FALSE) {
        Add-Type -Assembly 'System.IO.Compression.FileSystem';
    }

    if ([IO.Path]::GetExtension($File) -ne '.zip' -And [IO.Path]::GetExtension($File) -ne '.exe') {
        Write-IcingaConsoleError 'Your service binary must be inside a .zip file or directly given on the "-File" argument. Extension "{0}" given.' -Objects ([IO.Path]::GetExtension($File));
        return $null;
    }

    [hashtable]$BinaryData = @{
        'CompanyName'    = '';
        'FileVersion'    = '';
        'ProductVersion' = '';
        'ComponentName'  = 'service';
    }

    try {
        $ZipPackage = $null;

        if ([IO.Path]::GetExtension($File) -eq '.zip') {
            $ZipPackage      = [System.IO.Compression.ZipFile]::OpenRead($File);

            foreach ($entry in $ZipPackage.Entries) {
                if ([IO.Path]::GetExtension($entry.FullName) -ne '.exe') {
                    continue;
                }

                $ServiceTempDir = New-IcingaTemporaryDirectory;
                $BinaryFile     = (Join-Path -Path $ServiceTempDir -ChildPath $entry.Name);
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile(
                    $entry,
                    (Join-Path -Path $ServiceTempDir -ChildPath $entry.Name),
                    $TRUE
                );

                $ServiceBin = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($BinaryFile);

                if ($ServiceBin.CompanyName -ne 'Icinga GmbH') {
                    Remove-Item -Path $ServiceTempDir -Recurse -Force;
                    continue;
                }

                $BinaryData.CompanyName    = $ServiceBin.CompanyName;
                $BinaryData.ProductVersion = ([version]($ServiceBin.ProductVersion)).ToString(3);
                $BinaryData.FileVersion    = ([version]($ServiceBin.FileVersion)).ToString(3);
                break;
            }

            $ZipPackage.Dispose();
        } elseif ([IO.Path]::GetExtension($File) -eq '.exe') {
            $ServiceBin = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($File);

            if ($ServiceBin.CompanyName -ne 'Icinga GmbH') {
                return $null;
            }

            $BinaryData.CompanyName    = $ServiceBin.CompanyName;
            $BinaryData.ProductVersion = ([version]($ServiceBin.ProductVersion)).ToString(3);
            $BinaryData.FileVersion    = ([version]($ServiceBin.FileVersion)).ToString(3);
        } else {
            return $null;
        }

        if ([string]::IsNullOrEmpty($BinaryData.ProductVersion)) {
            return $null;
        }

        return $BinaryData;
    } catch {
        $ExMsg = $_.Exception.Message;
        Write-IcingaConsoleError 'Failed to read package content and/or binary file: {0}' -Objects $ExMsg;
    } finally {
        if ($null -ne $ZipPackage) {
            $ZipPackage.Dispose();
        }
    }

    return $null;
}

function Remove-IcingaRepository()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository to remove';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ((Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) -eq $FALSE) {
        Write-IcingaConsoleError 'A repository with the name "{0}" is not configured' -Objects $Name;
        return;
    }

    Push-IcingaRepository -Name $Name -Silent;

    Remove-IcingaPowerShellConfig -Path (
        [string]::Format(
            'Framework.Repository.Repositories.{0}',
            $Name
        )
    );

    Write-IcingaConsoleNotice 'The repository with the name "{0}" was successfully removed' -Objects $Name;
}

function Search-IcingaRepository()
{
    param (
        [string]$Name     = $null,
        [string]$Version  = $null,
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE
    );

    if ($Version -eq 'release') {
        $Version = $null;
    }

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a component name';
        return;
    }

    if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
        $Release = $TRUE;
    }

    $Repositories           = Get-IcingaRepositories -ExcludeDisabled;
    [Version]$LatestVersion = $null;
    [string]$SourcePath     = $null;
    [bool]$FoundPackage     = $FALSE;
    [array]$Output          = @();
    [bool]$FoundPackage     = $FALSE;

    $SearchList             = New-Object -TypeName PSObject;
    $SearchList | Add-Member -MemberType NoteProperty -Name 'Repos' -Value @();

    foreach ($entry in $Repositories) {
        $RepoContent        = Read-IcingaRepositoryFile -Name $entry.Name;

        if ($null -eq $RepoContent) {
            continue;
        }

        if ((Test-IcingaPowerShellConfigItem -ConfigObject $RepoContent -ConfigKey 'Packages') -eq $FALSE) {
            continue;
        }

        foreach ($repoEntry in $RepoContent.Packages.PSObject.Properties.Name) {

            if ($repoEntry -NotLike $Name) {
                continue;
            }

            $RepoData = New-Object -TypeName PSObject;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'Name'          -Value $entry.Name;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'RemoteSource'  -Value $RepoContent.Info.RemoteSource;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'ComponentName' -Value $repoEntry;
            $RepoData | Add-Member -MemberType NoteProperty -Name 'Packages'      -Value @();

            foreach ($package in $RepoContent.Packages.$repoEntry) {

                $ComponentData = New-Object -TypeName PSObject;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Version'  -Value $package.Version;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Location' -Value $package.Location;
                $ComponentData | Add-Member -MemberType NoteProperty -Name 'Snapshot' -Value $package.Snapshot;

                if ($Snapshot -And $package.Snapshot -eq $TRUE -And [string]::IsNullOrEmpty($Version)) {
                    $RepoData.Packages += $ComponentData;
                    continue;
                }

                if ($Snapshot -And $package.Snapshot -eq $TRUE -And [string]::IsNullOrEmpty($Version) -eq $FALSE -And [version]$package.Version -eq [version]$Version) {
                    $RepoData.Packages += $ComponentData;
                    continue;
                }

                if ($Release -And [string]::IsNullOrEmpty($Version) -And $package.Snapshot -eq $FALSE) {
                    $RepoData.Packages += $ComponentData;
                    continue;
                }

                if ([string]::IsNullOrEmpty($Version) -eq $FALSE -And $Release -eq $FALSE -And $Snapshot -eq $FALSE -And $package.Snapshot -eq $FALSE) {
                    $RepoData.Packages += $ComponentData;
                    continue;
                }
            }

            if ($RepoData.Packages.Count -ne 0) {
                $FoundPackage = $TRUE;
            }

            $SearchList.Repos += $RepoData;
        }
    }

    if ($FoundPackage -eq $FALSE) {
        $SearchVersion = 'release';
        if ([string]::IsNullOrEmpty($Version) -eq $FALSE) {
            $SearchVersion = $Version;
        }
        if ($Release) {
            Write-IcingaConsoleNotice 'The component "{0}" was not found on stable channel with version "{1}"' -Objects $Name, $SearchVersion;
        }
        if ($Snapshot) {
            Write-IcingaConsoleNotice 'The component "{0}" was not found on snapshot channel with version "{1}"' -Objects $Name, $SearchVersion;
        }
        return;
    }

    foreach ($repo in $SearchList.Repos) {
        if ($repo.Packages.Count -eq 0) {
            continue;
        }

        $Output += $repo.Name;
        $Output += '-----------';
        $Output += [string]::Format('Source => {0}', $repo.RemoteSource);
        $Output += '';
        $Output += $repo.ComponentName;

        [array]$VersionList = $repo.Packages | Sort-Object { $_.Version } -Descending;

        foreach ($componentData in $VersionList) {
            $Output += [string]::Format('{0} => {1}', $componentData.Version, $componentData.Location);
        }
        $Output += '';
    }

    Write-Host ($Output | Out-String);
}

function Show-Icinga()
{
    $IcingaInstallation      = Get-IcingaInstallation -Release;
    [array]$Output           = @( 'Icinga for Windows environment' );
    [int]$MaxComponentLength = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Keys;
    [int]$MaxVersionLength   = Get-IcingaMaxTextLength -TextArray $IcingaInstallation.Values.CurrentVersion;
    [string]$ComponentHeader = Add-IcingaWhiteSpaceToString -Text 'Component' -Length $MaxComponentLength;
    [string]$ComponentLine   = Add-IcingaWhiteSpaceToString -Text '---' -Length $MaxComponentLength;
    $Output                 += '-----------';
    $Output                 += '';
    $Output                 += 'Installed components on this system';
    $Output                 += '';
    $Output                 += [string]::Format('{0}   {1}   Available', $ComponentHeader, ((Add-IcingaWhiteSpaceToString -Text 'Version' -Length $MaxVersionLength)));
    $Output                 += [string]::Format('{0}   {1}    ---', $ComponentLine, ((Add-IcingaWhiteSpaceToString -Text '---' -Length $MaxVersionLength)));

    foreach ($component in $IcingaInstallation.Keys) {
        $Data           = $IcingaInstallation[$component];
        $LatestVersion  = $Data.LatestVersion;
        $CurrentVersion = $Data.CurrentVersion;

        if ([string]::IsNullOrEmpty($Data.LockedVersion) -eq $FALSE) {
            if ($Data.LockedVersion -eq $Data.CurrentVersion) {
                $CurrentVersion = [string]::Format('{0}*', $CurrentVersion);
            } else {
                $LatestVersion = [string]::Format('{0}*', $Data.LockedVersion);
            }
        }

        [string]$ComponentName = Add-IcingaWhiteSpaceToString -Text $component -Length $MaxComponentLength;
        $Output               += [string]::Format('{0}   {1}    {2}', $ComponentName, (Add-IcingaWhiteSpaceToString -Text $CurrentVersion -Length $MaxVersionLength), $LatestVersion);
    }

    $Output                 += '';
    $Output                 += 'Available versions flagged with "*" mean that this component is locked to this version';

    $IcingaForWindowsService = Get-IcingaForWindowsServiceData;
    $IcingaAgentService      = Get-IcingaAgentInstallation;
    $WindowsInformation      = Get-IcingaWindowsInformation Win32_OperatingSystem | Select-Object Version, BuildNumber, Caption;

    $Output += '';
    $Output += 'Environment configuration';
    $Output += '';
    $Output += ([string]::Format('PowerShell Root                 => {0}', (Get-IcingaForWindowsRootPath)));
    $Output += ([string]::Format('Icinga for Windows Service Path => {0}', $IcingaForWindowsService.Directory));
    $Output += ([string]::Format('Icinga for Windows Service User => {0}', $IcingaForWindowsService.User));
    $Output += ([string]::Format('Icinga Agent Path               => {0}', $IcingaAgentService.RootDir));
    $Output += ([string]::Format('Icinga Agent User               => {0}', $IcingaAgentService.User));
    $Output += ([string]::Format('PowerShell Version              => {0}', $PSVersionTable.PSVersion.ToString()));
    $Output += ([string]::Format('Operating System                => {0}', $WindowsInformation.Caption));
    $Output += ([string]::Format('Operating System Version        => {0}', $WindowsInformation.Version));

    $Output += '';
    $Output += (Show-IcingaRepository);

    Write-Output $Output;
}

function Show-IcingaRepository()
{
    [hashtable]$Repositories = @{ };
    [array]$RepoSummary      = @(
        'List of configured repositories on this system. The list order matches the apply order.',
        ''
    );
    [array]$RepoList = Get-IcingaRepositories;

    foreach ($repo in $RepoList) {

        $RepoSummary += $repo.Name;
        $RepoSummary += '-----------';

        [int]$MaxLength  = Get-IcingaMaxTextLength -TextArray $repo.Value.PSObject.Properties.Name;
        [array]$RepoData = @();

        foreach ($repoConfig in $repo.Value.PSObject.Properties) {
            $PrintName = Add-IcingaWhiteSpaceToString -Text $repoConfig.Name -Length $MaxLength;
            $RepoData += [string]::Format('{0} => {1}', $PrintName, $repoConfig.Value);
        }

        $RepoSummary += $RepoData | Sort-Object;
        $RepoSummary += '';
    }

    if ($RepoList.Count -eq 0) {
        $RepoSummary += 'No repositories configured';
    }

    Write-Output $RepoSummary;
}

function Sync-IcingaRepository()
{
    param (
        [string]$Name       = $null,
        [string]$Path       = $null,
        [string]$RemotePath = $null,
        [string]$Source     = $null,
        [switch]$UseSCP     = $FALSE,
        [switch]$Force      = $FALSE,
        [switch]$ForceTrust = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to provide a name for the repository';
        return;
    }

    if ($UseSCP -And $null -eq (Get-Command 'scp' -ErrorAction SilentlyContinue) -And $null -eq (Get-Command 'ssh' -ErrorAction SilentlyContinue)) {
        Write-IcingaConsoleWarning 'You cannot use SCP on this system, as SCP and/or SSH seem not to be installed';
        return;
    }

    if ($UseSCP -And $Path.Contains(':') -eq $FALSE -And $Path.Contains('@') -eq $FALSE) {
        Write-IcingaConsoleWarning 'You have to add host and username to your "-Path" argument. Example: "icinga@icinga.example.com:/var/www/icingarepo/" ';
        return;
    }

    if ([string]::IsNullOrEmpty($Path) -Or (Test-Path $Path) -eq $FALSE -And $UseSCP -eq $FALSE) {
        Write-IcingaConsoleWarning 'The provided path "{0}" does not exist and will be created' -Objects $Path;
    }

    if ([string]::IsNullOrEmpty($RemotePath)) {
        Write-IcingaConsoleWarning 'No explicit remote path has been defined. Using local path "{0}" as remote path' -Objects $Path;
        $RemotePath = $Path;
    }

    if ([string]::IsNullOrEmpty($Source)) {
        Write-IcingaConsoleError 'You have to specify a source to sync from';
        return;
    }

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    if ($null -eq $CurrentRepositories) {
        $CurrentRepositories = New-Object -TypeName PSObject;
    }

    if ((Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) -And $Force -eq $FALSE) {
        Write-IcingaConsoleError 'A repository with the given name "{0}" does already exist. Use "Update-IcingaRepository -Name {1}{0}{1}" to update it.' -Objects $Name, "'";
        return;
    }

    if ((Test-Path $Path) -eq $FALSE -And $UseSCP -eq $FALSE) {
        $FolderCreated = New-Item -Path $Path -ItemType Directory -Force -ErrorAction SilentlyContinue;

        if ($null -eq $FolderCreated) {
            Write-IcingaConsoleError 'Unable to create repository folder at location "{0}". Please verify that you have permissions to write into the location and try again or create the folder manually' -Objects $Path;
            return;
        }
    }

    $RepoFile   = $null;
    $SSHAuth    = $null;
    $RemovePath = $null;

    if (Test-Path $Source) {
        $CopySource = Join-Path -Path $Source -ChildPath '\*';
    } else {
        $CopySource = $Source;
    }

    if ($UseSCP -eq $FALSE) {
        $Path       = Join-Path -Path $Path -ChildPath '\';
        $RemovePath = Join-Path -Path $Path -ChildPath '\*';
    } else {
        $SSHIndex = $Path.IndexOf(':');
        $SSHAuth  = $Path.Substring(0, $SSHIndex);
        $Path     = $Path.Substring($SSHIndex + 1, $Path.Length - $SSHIndex - 1);

        if ($Path[-1] -eq '/') {
            $RemovePath = [string]::Format('{0}*', $Path);
        } else {
            $RemovePath = [string]::Format('{0}/*', $Path);
        }
    }

    # All cloning will be done into a local file first
    $TmpDir               = New-IcingaTemporaryDirectory;
    $RepoFile             = (Join-Path -Path $TmpDir -ChildPath 'ifw.repo.json');
    [bool]$HasNonRelative = $FALSE;

    if (Test-Path $CopySource) { # Sync source is local path
        $Success = Copy-ItemSecure -Path $CopySource -Destination $TmpDir -Recurse -Force;
    } else { # Sync Source is web path
        $ProgressPreference = "SilentlyContinue";
        try {
            Invoke-WebRequest -USeBasicParsing -Uri $Source -OutFile $RepoFile;
        } catch {
            try {
                Invoke-WebRequest -USeBasicParsing -Uri (Join-WebPath -Path $Source -ChildPath 'ifw.repo.json') -OutFile $RepoFile;
            } catch {
                Write-IcingaConsoleError 'Unable to download repository file from "{0}". Exception: "{1}"' -Objects $Source, $_.Exception.Message;
                $Success = Remove-Item -Path $TmpDir -Recurse -Force;
                return;
            }
        }

        $RepoContent = Get-Content -Path $RepoFile -Raw;
        $JsonRepo    = ConvertFrom-Json -InputObject $RepoContent;

        foreach ($component in $JsonRepo.Packages.PSObject.Properties.Name) {
            $IfWPackage = $JsonRepo.Packages.$component

            foreach ($package in $IfWPackage) {
                $DownloadLink   = $package.Location;
                $TargetLocation = $TmpDir;

                if ($package.RelativePath -eq $TRUE) {
                    $DownloadLink   = Join-WebPath -Path $JsonRepo.Info.RemoteSource -ChildPath $package.Location;
                    $TargetLocation = Join-Path -Path $TmpDir -ChildPath $package.Location;

                    [void](
                        New-Item `
                            -ItemType Directory `
                            -Path (
                                $TargetLocation.SubString(
                                    0,
                                    $TargetLocation.LastIndexOf('\')
                                )
                            ) `
                            -Force
                        );
                } else {
                    $HasNonRelative = $TRUE;
                    $FileName       = $package.Location.Replace('/', '\');
                    $Index          = $FileName.LastIndexOf('\');
                    $FileName       = $FileName.SubString($Index, $FileName.Length - $Index);
                    $TargetLocation = Join-Path -Path $TmpDir -ChildPath $component;
                    [void](New-Item -ItemType Directory -Path $TargetLocation -Force);
                    $TargetLocation = Join-Path -Path $TargetLocation -ChildPath $FileName;
                }

                try {
                    Write-IcingaConsoleNotice 'Syncing repository component "{0}" as file "{1}" into temp directory' -Objects $component, $package.Location;
                    Invoke-WebRequest -USeBasicParsing -Uri $DownloadLink -OutFile $TargetLocation;
                } catch {
                    Write-IcingaConsoleError 'Failed to download repository component "{0}". Exception: "{1}"' -Objects $DownloadLink, $_.Exception.Message;
                    continue;
                }
            }
        }
    }

    [string]$CopySource = [string]::Format('{0}\*', $TmpDir);

    if ((Test-Path $RepoFile) -eq $FALSE) {
        Write-IcingaConsoleError 'The files from this repository were cloned but no repository file was found. Deleting temporary files';
        $Success = Remove-Item -Path $TmpDir -Recurse -Force;
        return;
    }

    $RepoContent = Get-Content -Path $RepoFile -Raw;
    $JsonRepo = ConvertFrom-Json -InputObject $RepoContent;

    if ($null -eq $JsonRepo) {
        Write-IcingaConsoleError 'The repository file was found but it is either damaged or empty. Deleting temporary files';
        $Success = Remove-Item -Path $TmpDir -Recurse -Force;
        return;
    }

    $EnableRepo = $TRUE;

    if ($ForceTrust -eq $FALSE -And $UseSCP -eq $FALSE) {
        if ($null -eq $JsonRepo.Info.RepoHash -Or [string]::IsNullOrEmpty($JsonRepo.Info.RepoHash)) {
            Write-IcingaConsoleWarning 'The cloned repository file hash cannot be verified, as it is not present inside the repository file. The repository will be added, but disabled for security reasons. Review the content first and ensure you trust the source before enabling it.';
            $EnableRepo = $FALSE;
        } elseif ($JsonRepo.Info.RepoHash -ne (Get-IcingaRepositoryHash -Path $TmpDir)) {
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            Write-IcingaConsoleError 'The repository hash for the cloned repository is not matching the file hash of the files inside. Removing repository data';
            return;
        }
    }

    if ($HasNonRelative) {
        [void](New-IcingaRepositoryFile -Path $TmpDir -RemotePath $RemotePath);
        $RepoContent = Get-Content -Path $RepoFile -Raw;
        $JsonRepo    = ConvertFrom-Json -InputObject $RepoContent;
        Start-Sleep -Seconds 2;
    }

    $JsonRepo.Info.RepoHash     = Get-IcingaRepositoryHash -Path $TmpDir;
    $JsonRepo.Info.LocalSource  = $Path;
    $JsonRepo.Info.RemoteSource = $RemotePath;
    $JsonRepo.Info.Updated      = ((Get-Date).ToUniversalTime().ToString('yyyy\/MM\/dd HH:mm:ss'));

    Set-Content -Path $RepoFile -Value (ConvertTo-Json -InputObject $JsonRepo -Depth 100);

    if ($UseSCP -eq $FALSE) { # Windows target
        $Success = Remove-Item -Path $RemovePath -Recurse -Force;
        $Success = Copy-ItemSecure -Path $CopySource -Destination $Path -Recurse -Force;

        if ($Success -eq $FALSE) {
            Write-IcingaConsoleError 'Unable to sync repository from location "{0}" to destination "{1}". Please verify that you have permissions to write into the location and try again or create the folder manually' -Objects $TmpDir, $Path;
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            return;
        }
    } else { # Linux target
        Write-IcingaConsoleNotice 'Creating directory over SSH for host and user "{0}" and path "{1}"' -Objects $SSHAuth, $Path;

        $Result = Start-IcingaProcess -Executable 'ssh' -Arguments ([string]::Format('{0} mkdir -p "{1}"', $SSHAuth, $Path));
        if ($Result.ExitCode -ne 0) {
            # TODO: Add link to setup docs
            Write-IcingaConsoleError 'SSH Error on directory creation: {0}' -Objects $Result.Error;
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            return;
        }

        Write-IcingaConsoleNotice 'Removing old repository files from "{0}"' -Objects $Path;

        $Result = Start-IcingaProcess -Executable 'ssh' -Arguments ([string]::Format('{0} rm -Rf "{1}"', $SSHAuth, $RemovePath));

        if ($Result.ExitCode -ne 0) {
            Write-IcingaConsoleError 'SSH Error on removing old repository data: {0}' -Objects $Result.Error;
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            return;
        }

        Write-IcingaConsoleNotice 'Syncing new repository files to "{0}"' -Objects $Path;

        $Result = Start-IcingaProcess -Executable 'scp' -Arguments ([string]::Format('-r "{0}" "{1}:{2}"', $CopySource, $SSHAuth, $Path));

        if ($Result.ExitCode -ne 0) {
            Write-IcingaConsoleError 'SCP Error while copying repository files: {0}' -Objects $Result.Error;
            $Success = Remove-Item -Path $TmpDir -Recurse -Force;
            return;
        }
    }

    $Success = Remove-Item -Path $TmpDir -Recurse -Force;

    if ((Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) -And $Force -eq $TRUE) {
        $CurrentRepositories.$Name.Enabled = $EnableRepo;
        Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;
        Write-IcingaConsoleNotice 'Re-syncing of repository "{0}" was successful' -Objects $Name;
        return;
    }

    Write-IcingaConsoleNotice 'The repository was synced successfully. Use "Update-IcingaRepository" to sync possible changes from the source repository.';

    [array]$RepoCount = $CurrentRepositories.PSObject.Properties.Count;

    $CurrentRepositories | Add-Member -MemberType NoteProperty -Name $Name -Value (New-Object -TypeName PSObject);
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'LocalPath'   -Value $Path;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'RemotePath'  -Value $RemotePath;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'CloneSource' -Value $Source;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'UseSCP'      -Value ([bool]$UseSCP);
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Order'       -Value $RepoCount.Count;
    $CurrentRepositories.$Name | Add-Member -MemberType NoteProperty -Name 'Enabled'     -Value $EnableRepo;

    Set-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories' -Value $CurrentRepositories;

    return;
}

function Uninstall-IcingaComponent()
{
    param (
        [string]$Name               = '',
        [switch]$RemovePackageFiles = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify a component name to uninstall';
        return $FALSE;
    }

    if ($Name.ToLower() -eq 'agent') {
        return Uninstall-IcingaAgent -RemoveDataFolder:$RemovePackageFiles;
    }

    if ($Name.ToLower() -eq 'service') {
        return; Uninstall-IcingaForWindowsService -RemoveFiles:$RemovePackageFiles;
    }

    $ModuleBase         = Get-IcingaForWindowsRootPath;
    $UninstallComponent = [string]::Format('icinga-powershell-{0}', $Name);
    $UninstallPath      = Join-Path -Path $ModuleBase -ChildPath $UninstallComponent;

    if ((Test-Path $UninstallPath) -eq $FALSE) {
        Write-IcingaConsoleNotice -Message 'The Icinga for Windows component "{0}" at "{1}" could not ne found.' -Objects $UninstallComponent, $UninstallPath;
        return $FALSE;
    }

    Write-IcingaConsoleNotice -Message 'Uninstalling Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
    if (Remove-ItemSecure -Path $UninstallPath -Recurse -Force) {
        Write-IcingaConsoleNotice -Message 'Successfully removed Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
        if ($UninstallComponent -ne 'icinga-powershell-framework') {
            Remove-Module $UninstallComponent -Force -ErrorAction SilentlyContinue;
        }
        return $TRUE;
    } else {
        Write-IcingaConsoleError -Message 'Unable to uninstall Icinga for Windows component "{0}" from "{1}"' -Objects $UninstallComponent, $UninstallPath;
    }

    return $FALSE;
}

function Unlock-IcingaComponent()
{
    param (
        [string]$Name = $null
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'You have to specify the component to unlock';
        return;
    }

    $LockedComponents = Get-IcingaPowerShellConfig -Path 'Framework.Repository.ComponentLock';

    if ($null -eq $LockedComponents) {
        Write-IcingaConsoleNotice 'You have currently no components which are locked configured';
        return;
    }

    if (Test-IcingaPowerShellConfigItem -ConfigObject $LockedComponents -ConfigKey $Name) {
        Remove-IcingaPowerShellConfig -Path ([string]::Format('Framework.Repository.ComponentLock.{0}', $Name));
        Write-IcingaConsoleNotice 'Unlocking of component "{0}" was successful.' -Objects $Name;
    } else {
        Write-IcingaConsoleNotice 'The component "{0}" is not locked on this system' -Objects $Name;
    }
}

function Update-Icinga()
{
    param (
        [string]$Name     = $null,
        [switch]$Release  = $FALSE,
        [switch]$Snapshot = $FALSE,
        [switch]$Confirm  = $FALSE,
        [switch]$Force    = $FALSE
    );

    if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
        $Release = $TRUE;
    }

    $CurrentInstallation = Get-IcingaInstallation -Release:$Release -Snapshot:$Snapshot;

    foreach ($entry in $CurrentInstallation.Keys) {
        $Component = $CurrentInstallation[$entry];

        if ([string]::IsNullOrEmpty($Name) -eq $FALSE -And $Name -ne $entry) {
            continue;
        }

        $NewVersion = $Component.LatestVersion;

        if ([string]::IsNullOrEmpty($NewVersion)) {
            Write-IcingaConsoleNotice 'No update package found for component "{0}"' -Objects $entry;
            continue;
        }

        $LockedVersion = Get-IcingaComponentLock -Name $entry;

        if ($null -ne $LockedVersion) {
            $NewVersion = $LockedVersion;
        }

        if ([Version]$NewVersion -le [Version]$Component.CurrentVersion -And $Force -eq $FALSE) {
            Write-IcingaConsoleNotice 'The installed version "{0}" of component "{1}" is identical or lower than the new version "{2}". Use "-Force" to install anyway' -Objects $Component.CurrentVersion, $entry, $NewVersion;
            continue;
        }

        Install-IcingaComponent -Name $entry -Version $NewVersion -Release:$Release -Snapshot:$Snapshot -Confirm:$Confirm -Force:$Force
    }
}

function Update-IcingaRepository()
{
    param (
        [string]$Name       = $null,
        [string]$Path       = $null,
        [string]$RemotePath = $null,
        [switch]$CreateNew  = $FALSE,
        [switch]$ForceTrust = $FALSE
    );

    $CurrentRepositories = Get-IcingaPowerShellConfig -Path 'Framework.Repository.Repositories';

    [array]$ConfigCount = $CurrentRepositories.PSObject.Properties.Count;

    if (($null -eq $CurrentRepositories -Or $ConfigCount.Count -eq 0) -And $CreateNew -eq $FALSE) {
        Write-IcingaConsoleNotice 'There are no repositories configured yet. You can create a custom repository with "New-IcingaRepository" or clone an existing one with "Sync-IcingaForWindowsRepository"';
        return;
    }

    if ([string]::IsNullOrEmpty($Name) -eq $FALSE) {
        if ((Test-IcingaPowerShellConfigItem -ConfigObject $CurrentRepositories -ConfigKey $Name) -eq $FALSE -And $CreateNew -eq $FALSE) {
            Write-IcingaConsoleError 'A repository with the given name "{0}" does not exist. Use "New-IcingaRepository" or "Sync-IcingaForWindowsRepository" to create a new one.' -Objects $Name;
            return;
        }
    }

    foreach ($definedRepo in $CurrentRepositories.PSObject.Properties) {

        if ([string]::IsNullOrEmpty($Name) -eq $FALSE -And $definedRepo.Name.ToLower() -ne $Name.ToLower()) {
            continue;
        }

        if ($definedRepo.Value.Enabled -eq $FALSE) {
            Write-IcingaConsoleNotice 'Skipping disabled repository "{0}"' -Objects $definedRepo.Name;
            continue;
        }

        if ([string]::IsNullOrEmpty($definedRepo.Value.CloneSource) -eq $FALSE) {
            continue;
        }

        if ([string]::IsNullOrEmpty($definedRepo.Value.LocalPath)) {
            continue;
        }

        if ((Test-Path $definedRepo.Value.LocalPath) -eq $FALSE) {
            if ($CreateNew) {
                return $null;
            }
            continue;
        }

        $Path = Join-Path -Path $definedRepo.Value.LocalPath -ChildPath '\';

        if ($CreateNew -eq $FALSE) {
            Write-IcingaConsoleNotice 'Updating Icinga for Windows repository "{0}"' -Objects $definedRepo.Name;
        }

        $IcingaRepository = New-IcingaRepositoryFile -Path $Path -RemotePath $RemotePath;

        if ($CreateNew) {
            return $IcingaRepository;
        }
    }

    # Always sync repositories at the end, in case we updated a local repository and cloned it to somewhere else
    foreach ($definedRepo in $CurrentRepositories.PSObject.Properties) {

        if ([string]::IsNullOrEmpty($Name) -eq $FALSE -And $definedRepo.Name.ToLower() -ne $Name.ToLower()) {
            continue;
        }

        if ($definedRepo.Value.Enabled -eq $FALSE) {
            continue;
        }

        if ([string]::IsNullOrEmpty($definedRepo.Value.LocalPath)) {
            continue;
        }

        Write-IcingaConsoleNotice 'Syncing repository "{0}"' -Objects $definedRepo.Name;

        if ([string]::IsNullOrEmpty($definedRepo.Value.CloneSource) -eq $FALSE) {
            Sync-IcingaRepository `
                -Name $definedRepo.Name `
                -Path $definedRepo.Value.LocalPath `
                -RemotePath $definedRepo.Value.RemotePath `
                -Source $definedRepo.Value.CloneSource `
                -UseSCP:$definedRepo.Value.UseSCP `
                -Force `
                -ForceTrust:$ForceTrust;

            return;
        }
    }

    Write-IcingaConsoleNotice 'All Icinga for Windows repositories were successfully updated';
}

function New-IcingaThreadHash()
{
    param(
        [ScriptBlock]$ShellScript,
        [array]$Arguments
    );

    [string]$ScriptString = '';
    [string]$ArgString = ($Arguments | Out-String);
    if ($null -ne $ShellScript) {
        $ScriptString = $ShellScript.ToString();
    }
    return (Get-StringSha1 -Content ($ScriptString + $ArgString + (Get-Date -Format "MM-dd-yyyy-HH-mm-ffff")));
}

function New-IcingaThreadInstance()
{
    param(
        [string]$Name,
        $ThreadPool,
        [ScriptBlock]$ScriptBlock,
        [array]$Arguments,
        [Switch]$Start
    );

    if ([string]::IsNullOrEmpty($Name)) {
        $Name = New-IcingaThreadHash -ShellScript $ScriptBlock -Arguments $Arguments;
    }

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Creating new thread instance {0}{1}Arguments:{1}{2}',
            $Name,
            "`r`n",
            ($Arguments | Out-String)
        )
    );

    $Shell = [PowerShell]::Create();
    $Shell.RunspacePool = $ThreadPool;
    [void]$Shell.AddScript($ScriptBlock);
    foreach ($argument in $Arguments) {
        [void]$Shell.AddArgument($argument);
    }

    $Thread = New-Object PSObject;
    Add-Member -InputObject $Thread -MemberType NoteProperty -Name Shell -Value $Shell;
    if ($Start) {
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Handle -Value ($Shell.BeginInvoke());
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Started -Value $TRUE;
    } else {
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Handle -Value $null;
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Started -Value $FALSE;
    }

    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Name) -eq $FALSE) {
        $global:IcingaDaemonData.IcingaThreads.Add($Name, $Thread);
    } else {
        $global:IcingaDaemonData.IcingaThreads.Add(
            (New-IcingaThreadHash -ShellScript $ScriptBlock -Arguments $Arguments),
            $Thread
        );
    }
}

function New-IcingaThreadPool()
{
    param(
        [int]$MinInstances = 1,
        [int]$MaxInstances = 5
    );

    $Runspaces = [RunspaceFactory]::CreateRunspacePool(
        $MinInstances,
        $MaxInstances,
        [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault(),
        $host
    )

    $Runspaces.Open();

    return $Runspaces;
}

function Remove-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    Stop-IcingaThread -Thread $Thread;

    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Thread)) {
        $global:IcingaDaemonData.IcingaThreads[$Thread].Shell.Dispose();
        $global:IcingaDaemonData.IcingaThreads.Remove($Thread);
    }
}

function Restart-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    Stop-IcingaThread $Thread;
    Start-IcingaThread $Thread;
}

function Start-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Thread)) {
        if ($global:IcingaDaemonData.IcingaThreads[$Thread].Started -eq $FALSE) {
            $global:IcingaDaemonData.IcingaThreads[$Thread].Handle = $global:IcingaDaemonData.IcingaThreads[$Thread].Shell.BeginInvoke();
            $global:IcingaDaemonData.IcingaThreads[$Thread].Started = $TRUE;
        }
    }
}

function Stop-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return;
    }

    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Thread)) {
        if ($global:IcingaDaemonData.IcingaThreads[$Thread].Started -eq $TRUE) {
            $global:IcingaDaemonData.IcingaThreads[$Thread].Shell.Stop();
            $global:IcingaDaemonData.IcingaThreads[$Thread].Handle  = $null;
            $global:IcingaDaemonData.IcingaThreads[$Thread].Started = $FALSE;
        }
    }
}

function Test-IcingaThread()
{
    param(
        [string]$Thread
    );

    if ([string]::IsNullOrEmpty($Thread)) {
        return $FALSE;
    }

    return $global:IcingaDaemonData.IcingaThreads.ContainsKey($Thread);
}

function Add-IcingaArrayListItem()
{
    param (
        [System.Collections.ArrayList]$Array,
        $Element
    );

    if ($null -eq $Array -Or $null -eq $Element) {
        return;
    }

    $Array.Add($Element) | Out-Null;
}

function Add-IcingaHashtableItem()
{
    param(
        $Hashtable,
        $Key,
        $Value,
        [switch]$Override
    );

    if ($null -eq $Hashtable) {
        return $FALSE;
    }

    if ($Hashtable.ContainsKey($Key) -eq $FALSE) {
        $Hashtable.Add($Key, $Value);
        return $TRUE;
    } else {
        if ($Override) {
            $Hashtable.Remove($Key);
            $Hashtable.Add($Key, $Value);
            return $TRUE;
        }
    }
    return $FALSE;
}

function Add-IcingaWhiteSpaceToString()
{
    param (
        [string]$Text = '',
        [int]$Length  = 0
    );

    [int]$LengthOffset = $Length - $Text.Length;

    while ($LengthOffset -gt 0) {
        $Text += ' ';
        $LengthOffset -= 1;
    }

    return $Text;
}

function Add-PSCustomObjectMember()
{
    param (
        $Object,
        $Key,
        $Value
    );

    if ($null -eq $Object) {
        return $Object;
    }

    $Object | Add-Member -MemberType NoteProperty -Name $Key -Value $Value;

    return $Object;
}

<#
.SYNOPSIS
    Compare-IcingaUnixTimeWithDateTime compares a DateTime-Object with the current DateTime and returns the offset between these values as Integer
.DESCRIPTION
    Compare-IcingaUnixTimeWithDateTime compares a DateTime-Object with the current DateTime and returns the offset between these values as Integer
.PARAMETER DateTime
    DateTime object you want to compare with the Universal Time
.INPUTS
    System.DateTime
.OUTPUTS
    System.Int64
#>
function Compare-IcingaUnixTimeWithDateTime() {
    param (
        [datetime]$DateTime
    );

    # This is when the computer starts counting time
    $UnixEpochStart = (New-Object DateTime 1970, 1, 1, 0, 0, 0, ([DateTimeKind]::Utc));
    # We convert the creation and current time to seconds
    $CreationTime   = [long][System.Math]::Floor((($DateTime.ToUniversalTime() - $UnixEpochStart).Ticks / [timespan]::TicksPerSecond));
    $CurrentTime    = Get-IcingaUnixTime;

    # To find out, from the snapshot creation time to the current time, how many seconds are,
    # you have to subtract from the (Current Time in s) the (Creation Time in s)
    return ($CurrentTime - $CreationTime);
}

function Convert-Bytes()
{
    param(
        [string]$Value,
        [string]$Unit
    );

    # Ensure we always use proper formatting of values
    $Value = $Value.Replace(',', '.');

    If (($Value -Match "(^[\d\.]*) ?(B|KB|MB|GB|TB|PT|KiB|MiB|GiB|TiB|PiB)") -eq $FALSE) {
        $Value = [string]::Format('{0}B', $Value);
    }

    If (($Value -Match "(^[\d\.]*) ?(B|KB|MB|GB|TB|PT|KiB|MiB|GiB|TiB|PiB)")) {
        [single]$CurrentValue = $Matches[1];
        [string]$CurrentUnit = $Matches[2];

        switch ($CurrentUnit) {
            { 'KiB', 'MiB', 'GiB', 'TiB', 'PiB' -contains $_ } { $CurrentValue = ConvertTo-ByteIEC $CurrentValue $CurrentUnit; $boolOption = $true; }
            { 'KB', 'MB', 'GB', 'TB', 'PB' -contains $_ } { $CurrentValue = ConvertTo-ByteSI $CurrentValue $CurrentUnit; $boolOption = $true; }
        }

        switch ($Unit) {
            { 'B' -contains $_ } { $FinalValue = $CurrentValue; $boolOption = $true; }
            { 'KB' -contains $_ } { $FinalValue = ConvertTo-Kilobyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'MB' -contains $_ } { $FinalValue = ConvertTo-Megabyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'GB' -contains $_ } { $FinalValue = ConvertTo-Gigabyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'TB' -contains $_ } { $FinalValue = ConvertTo-Terabyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'PB' -contains $_ } { $FinalValue = ConvertTo-Petabyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'KiB' -contains $_ } { $FinalValue = ConvertTo-Kibibyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'MiB' -contains $_ } { $FinalValue = ConvertTo-Mebibyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'GiB' -contains $_ } { $FinalValue = ConvertTo-Gibibyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'TiB' -contains $_ } { $FinalValue = ConvertTo-Tebibyte $CurrentValue -Unit B; $boolOption = $true; }
            { 'PiB' -contains $_ } { $FinalValue = ConvertTo-Petabyte $CurrentValue -Unit B; $boolOption = $true; }

            default {
                if (-Not $boolOption) {
                    Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
                }
            }
        }
        return @{'value' = ([decimal]$FinalValue); 'pastunit' = $CurrentUnit; 'endunit' = $Unit };
    }

    Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
}

function Convert-IcingaCheckArgumentToPSObject()
{
    param (
        $Parameter = $null
    );

    $ParamValue = New-Object -TypeName PSObject;

    if ($null -eq $parameter) {
        return $ParamValue;
    }

    $ParamValue | Add-Member -MemberType NoteProperty -Name 'type'                   -Value (New-Object -TypeName PSObject);
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'Description'            -Value (New-Object -TypeName PSObject);
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'Attributes'             -Value (New-Object -TypeName PSObject);
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'position'               -Value $Parameter.position;
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'Name'                   -Value $Parameter.name;
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'required'               -Value $Parameter.required;
    $ParamValue.type | Add-Member -MemberType NoteProperty -Name 'name'              -Value $Parameter.type.name;
    $ParamValue.Description | Add-Member -MemberType NoteProperty -Name 'Text'       -Value $Parameter.Description.Text;
    $ParamValue.Attributes | Add-Member -MemberType NoteProperty -Name 'ValidValues' -Value $null;

    return $ParamValue;
}

<#
.SYNOPSIS
   Converts Icinga Network configuration from FQDN to IP
.DESCRIPTION
   This Cmdlet will convert a given Icinga Endpoint configuration based
   on a FQDN to a IPv4 based configuration and returns nothing of the
   FQDN could not be resolved
.FUNCTIONALITY
   Converts Icinga Network configuration from FQDN to IP
.EXAMPLE
   PS>Convert-IcingaEndpointsToIPv4 -NetworkConfig @( '[icinga2.example.com]:5665' );
.PARAMETER NetworkConfig
   An array of Icinga endpoint or single network configuration, like '[icinga2.example.com]:5665'
   which will be converted to IP based configuration
.INPUTS
   System.Array
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Convert-IcingaEndpointsToIPv4()
{
    param (
        [array]$NetworkConfig
    );

    [array]$ResolvedNetwork   = @();
    [array]$UnresolvedNetwork = @();
    [bool]$HasUnresolved      = $FALSE;
    [string]$Domain           = $ENV:UserDNSDomain;

    foreach ($entry in $NetworkConfig) {
        $Network = Get-IPConfigFromString -IPConfig $entry;
        try {
            $ResolvedIP       = [System.Net.Dns]::GetHostAddresses($Network.address);
            $ResolvedNetwork += $entry.Replace($Network.address, $ResolvedIP);
        } catch {
            # Once we failed in first place, try to lookup the "FQDN" with our host domain
            # we are in. Might resolve some issues if our DNS is not knowing the plain
            # hostname and untable to resolve it
            try {
                $ResolvedIP       = [System.Net.Dns]::GetHostAddresses(
                    [string]::Format(
                        '{0}.{1}',
                        $Network.address,
                        $Domain
                    )
                );
                $ResolvedNetwork += $entry.Replace($Network.address, $ResolvedIP);
            } catch {
                $UnresolvedNetwork += $Network.address;
                $HasUnresolved      = $TRUE;
            }
        }
    }

    return @{
        'Network'    = $ResolvedNetwork;
        'HasErrors'  = $HasUnresolved;
        'Unresolved' = $UnresolvedNetwork;
    };
}

<#
.SYNOPSIS
    Converts any kind of Icinga threshold with provided units
    to the lowest base of the unit which makes sense. It does
    support the Icinga plugin language, like ~:30, @10:40, 15:30,
    ...

    The conversion does currently support the following units:

    Size: B, KB, MB, GB, TB, PT, KiB, MiB, GiB, TiB, PiB
    Time: ms, s, m, h, d w, M, y
.DESCRIPTION
    Converts any kind of Icinga threshold with provided units
    to the lowest base of the unit. It does support the Icinga
    plugin language, like ~:30, @10:40, 15:30, ...

    The conversion does currently support the following units:

    Size: B, KB, MB, GB, TB, PT, KiB, MiB, GiB, TiB, PiB
    Time: ms, s, m, h, d w, M, y
.FUNCTIONALITY
    Converts values with units to the lowest unit of this category.
    Accepts Icinga Thresholds.
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '20d';

    Name                           Value
    ----                           -----
    Value                          1728000
    Unit                           s
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '5GB';

    Name                           Value
    ----                           -----
    Value                          5000000000
    Unit                           B
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '10MB:20MB';

    Name                           Value
    ----                           -----
    Value                          10000000:20000000
    Unit                           B
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '10m:1h';

    Name                           Value
    ----                           -----
    Value                          600:3600
    Unit                           s
.EXAMPLE
    PS>Convert-IcingaPluginThresholds -Threshold '@10m:1h';

    Name                           Value
    ----                           -----
    Value                          @600:3600
    Unit                           s
.EXAMPLE
    Convert-IcingaPluginThresholds -Threshold '~:1M';

    Name                           Value
    ----                           -----
    Value                          ~:2592000
    Unit                           s
.INPUTS
   System.String
.OUTPUTS
    System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Convert-IcingaPluginThresholds()
{
    param (
        [string]$Threshold = $null
    );

    [hashtable]$RetValue = @{
        'Unit'  = '';
        'Value' =  $null;
    };

    if ($null -eq $Threshold) {
        return $RetValue;
    }

    # Always ensure we are using correct digits
    $Threshold = $Threshold.Replace(',', '.');

    [array]$Content    = @();

    if ($Threshold.Contains(':')) {
        # If we have more than one ':' inside our string, lets check if this is a date time value
        # In case it is convert it properly to a FileTime we can work with later on
        if ([Regex]::Matches($Threshold, ":").Count -gt 1) {
            try {
                $DateTimeValue  = [DateTime]::ParseExact($Threshold, 'yyyy\/MM\/dd HH:mm:ss', $null);
                $RetValue.Value = $DateTimeValue.ToFileTime();
                $RetValue.Unit  = 's';
            } catch {
                $RetValue.Value = $Threshold;
            }

            return $RetValue;
        }

        $Content = $Threshold.Split(':');
    } else {
        $Content += $Threshold;
    }

    [array]$ConvertedValue = @();

    foreach ($ThresholdValue in $Content) {

        [bool]$HasTilde = $FALSE;
        [bool]$HasAt    = $FALSE;
        [bool]$Negate   = $FALSE;
        $Value          = '';
        $WorkUnit       = '';

        if ($ThresholdValue.Contains('~')) {
            $ThresholdValue = $ThresholdValue.Replace('~', '');
            $HasTilde = $TRUE;
        } elseif ($ThresholdValue.Contains('@')) {
            $HasAt = $TRUE;
            $ThresholdValue = $ThresholdValue.Replace('@', '');
        }

        if ($ThresholdValue[0] -eq '-' -And $ThresholdValue.Length -ge 1) {
            $Negate         = $TRUE;
            $ThresholdValue = $ThresholdValue.Substring(1, $ThresholdValue.Length - 1);
        }

        If (($ThresholdValue -Match "(^[\d\.]*) ?(B|KB|MB|GB|TB|PT|KiB|MiB|GiB|TiB|PiB)")) {
            $WorkUnit = 'B';
            if ([string]::IsNullOrEmpty($RetValue.Unit) -eq $FALSE -And $RetValue.Unit -ne $WorkUnit) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.MultipleUnitUsage -Force;
            }
            $Value         = (Convert-Bytes -Value $ThresholdValue -Unit $WorkUnit).Value;
            $RetValue.Unit = $WorkUnit;
        } elseif (($ThresholdValue -Match "(^[\d\.]*) ?(ms|s|m|h|d|w|M|y)")) {
            $WorkUnit = 's';
            if ([string]::IsNullOrEmpty($RetValue.Unit) -eq $FALSE -And $RetValue.Unit -ne $WorkUnit) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.MultipleUnitUsage -Force;
            }
            $Value         = (ConvertTo-Seconds -Value $ThresholdValue);
            $RetValue.Unit = $WorkUnit;
        } elseif (($ThresholdValue -Match "(^[\d\.]*) ?(%)")) {
            $WorkUnit      = '%';
            $Value         = ([string]$ThresholdValue).Replace(' ', '').Replace('%', '');
            $RetValue.Unit = $WorkUnit;
        } else {
            # Load all other units/values generically
            [string]$StrNumeric = '';
            [bool]$FirstChar    = $TRUE;
            [bool]$Delimiter    = $FALSE;
            foreach ($entry in ([string]($ThresholdValue)).ToCharArray()) {
                if ((Test-Numeric $entry) -Or ($entry -eq '.' -And $Delimiter -eq $FALSE)) {
                    $StrNumeric += $entry;
                    $FirstChar   = $FALSE;
                    if ($entry -eq '.') {
                        $Delimiter = $TRUE;
                    }
                } else {
                    if ([string]::IsNullOrEmpty($RetValue.Unit) -And $FirstChar -eq $FALSE) {
                        $RetValue.Unit = $entry;
                    } else {
                        $StrNumeric    = '';
                        $RetValue.Unit = '';
                        break;
                    }
                }
            }
            if ([string]::IsNullOrEmpty($StrNumeric)) {
                $Value = $ThresholdValue;
            } else {
                $Value = [decimal]$StrNumeric;
            }
        }

        if ((Test-Numeric $Value) -And $Negate) {
            $Value = $Value * -1;
        } elseif ($Negate) {
            $Value = [string]::Format('-{0}', $Value);
        }

        if ($HasTilde) {
            $ConvertedValue += [string]::Format('~{0}', $Value);
        } elseif ($HasAt) {
            $ConvertedValue += [string]::Format('@{0}', $Value);
        } else {
            $ConvertedValue += $Value;
        }
    }

    [string]$Value = [string]::Join(':', $ConvertedValue);

    if ([string]::IsNullOrEmpty($Value) -eq $FALSE -And $Value.Contains(':') -eq $FALSE) {
        if ((Test-Numeric $Value)) {
            $RetValue.Value = [decimal]$Value;
            return $RetValue;
        }
    }

    # Always ensure we are using correct digits
    $Value = ([string]$Value).Replace(',', '.');
    $RetValue.Value = $Value;

    return $RetValue;
}

function Convert-IcingaPluginValueToString()
{
    param (
        $Value,
        [string]$Unit         = '',
        [string]$OriginalUnit = ''
    );

    $AdjustedValue = $Value;

    if ([string]::IsNullOrEmpty($OriginalUnit)) {
        $OriginalUnit = $Unit;
    }

    try {
        $AdjustedValue = ([math]::Round([decimal]$Value, 6))
    } catch {
        $AdjustedValue = $Value;
    }

    if ($Unit -eq '%' -Or [string]::IsNullOrEmpty($Unit)) {
        return ([string]::Format('{0}{1}', ([string]$AdjustedValue).Replace(',', '.'), $Unit));
    }

    switch ($OriginalUnit) {
        { ($_ -eq "Kbit") -or ($_ -eq "Mbit") -or ($_ -eq "Gbit") -or ($_ -eq "Tbit") -or ($_ -eq "Pbit") -or ($_ -eq "Ebit") -or ($_ -eq "Zbit") -or ($_ -eq "Ybit") } {
            $TransferSpeed = Get-IcingaNetworkInterfaceUnits -Value $Value;
            return ([string]::Format('{0}{1}', $TransferSpeed.LinkSpeed, $TransferSpeed.Unit)).Replace(',', '.');
        };
        { ($_ -eq "B") -or ($_ -eq "KiB") -or ($_ -eq "MiB") -or ($_ -eq "GiB") -or ($_ -eq "TiB") -or ($_ -eq "PiB") -or ($_ -eq "EiB") -or ($_ -eq "ZiB") -or ($_ -eq "YiB") } {
            return (ConvertTo-BytesNextUnit -Value $Value -Unit $Unit -Units @('B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB', 'YiB')).Replace(',', '.');
        };
        { ($_ -eq "KB") -or ($_ -eq "MB") -or ($_ -eq "GB") -or ($_ -eq "TB") -or ($_ -eq "PB") -or ($_ -eq "EB") -or ($_ -eq "ZB") -or ($_ -eq "YB") } {
            return (ConvertTo-BytesNextUnit -Value $Value -Unit $Unit -Units @('B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')).Replace(',', '.');
        };
        's' {
            return (ConvertFrom-TimeSpan -Seconds $AdjustedValue).Replace(',', '.')
        };
    }

    return ([string]::Format('{0}{1}', ([string]$AdjustedValue).Replace(',', '.'), $Unit));
}

function ConvertFrom-IcingaArrayToString()
{
    param (
        [array]$Array          = @(),
        [switch]$AddQuotes     = $FALSE,
        [switch]$SecureContent = $FALSE
    );

    if ($null -eq $Array -Or $Array.Count -eq 0) {
        if ($AddQuotes) {
            return '""';
        }

        return '';
    }

    [array]$NewArray = @();

    if ($AddQuotes) {
        foreach ($entry in $Array) {
            if ($SecureContent) {
                $entry = '***';
            }
            $NewArray += ([string]::Format('"{0}"', $entry));
        }
    } else {
        if ($SecureContent) {
            foreach ($entry in $Array) {
                $NewArray += '***';
            }
        } else {
            $NewArray = $Array;
        }
    }

    return ([string]::Join(', ', $NewArray));
}

function ConvertFrom-IcingaSecureString()
{
    param([SecureString]$SecureString);

    if ($SecureString -eq $null) {
        return '';
    }

    [IntPtr]$BSTR   = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
    [string]$String = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    return $String;
}

function ConvertFrom-JsonUTF8()
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $TRUE, ValueFromPipeline = $TRUE)]
        $InputObject = $null
    );

    # We need to properly encode our String to UTF8
    $ContentBytes = [System.Text.Encoding]::Default.GetBytes($InputObject);
    $UTF8String   = [System.Text.Encoding]::UTF8.GetString($ContentBytes);

    # Return the correct encoded JSON
    return (ConvertFrom-Json -InputObject $UTF8String);
}

function ConvertFrom-Percent()
{
    param (
        $Value       = $null,
        $Percent     = $null,
        [int]$Digits = 0
    );

    if ($null -eq $Value -Or $null -eq $Percent) {
        return 0;
    }

    return ([math]::Round(($Value / 100 * $Percent), $Digits));
}

function ConvertFrom-TimeSpan()
{
    param (
        $Seconds = 0
    );

    if (([string]$Seconds).Contains(',') -Or (Test-Numeric $Seconds)) {
        [decimal]$Seconds = [decimal]([string]$Seconds).Replace(',', '.');
    }

    $Sign = '';
    if ($Seconds -lt 0) {
        $Seconds = [math]::Abs($Seconds);
        $Sign    = '-';
    }

    if ((Test-Numeric $Seconds) -eq $FALSE) {
        return $Seconds;
    }

    $TimeSpan = [TimeSpan]::FromSeconds($Seconds);

    if ($TimeSpan.TotalDays -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}d',
                $Sign,
                ([math]::Round($TimeSpan.TotalDays, 2))
            )
        );
    }
    if ($TimeSpan.TotalHours -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}h',
                $Sign,
                ([math]::Round($TimeSpan.TotalHours, 2))
            )
        );
    }
    if ($TimeSpan.TotalMinutes -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}m',
                $Sign,
                ([math]::Round($TimeSpan.TotalMinutes, 2))
            )
        );
    }
    if ($TimeSpan.TotalSeconds -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}s',
                $Sign,
                ([math]::Round($TimeSpan.TotalSeconds, 2))
            )
        );
    }
    if ($TimeSpan.TotalMilliseconds -ge 1.0) {
        return (
            [string]::Format(
                '{0}{1}ms',
                $Sign,
                $TimeSpan.TotalMilliseconds
            )
        );
    }

    if ($Seconds -lt 0.001) {
        return ([string]::Format('{0}{1}us', $Sign, ([math]::Ceiling([decimal]($Seconds*[math]::Pow(10, 6))))));
    }

    return ([string]::Format('{0}s', $Seconds));
}

function ConvertTo-BytesNextUnit()
{
    param (
        [string]$Value = $null,
        [string]$Unit  = $null,
        [array]$Units  = @('B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB')
    );

    [string]$UnitValue = [string]::Format('{0}{1}', $Value, $Unit);

    while ($TRUE) {
        $Unit     = Get-IcingaNextUnitIteration -Unit $Unit -Units $Units;
        [decimal]$NewValue = (Convert-Bytes -Value $UnitValue -Unit $Unit).Value;
        if ($NewValue -ge 1.0) {
            if ($Unit -eq $RetUnit) {
                break;
            }
            $RetValue = [math]::Round([decimal]$NewValue, 2);
            $RetUnit  = $Unit;
        } else {
            if ([string]::IsNullOrEmpty($RetUnit)) {
                $RetValue = $Value;
                $RetUnit  = 'B';
            }
            break;
        }
    }

    return ([string]::Format('{0}{1}', $RetValue, $RetUnit));
}

function ConvertTo-ByteIEC()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 40)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 50)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Kibibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 40)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Mebibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Gibibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Tebibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 40)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Pebibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 50)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 40)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to byte.
.DESCRIPTION
   This module converts a given unit size to byte.
   e.g Kilobyte to Byte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Byte -Unit TB 200
   200000000000000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-ByteSI()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 12)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 15)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to Kilobyte.
.DESCRIPTION
   This module converts a given unit size to Kilobyte.
   e.g byte to Kilobyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Kilobyte -Unit TB 200
   200000000000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Kilobyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 12)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to Megabyte.
.DESCRIPTION
   This module converts a given unit size to Megabyte.
   e.g byte to Megabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Kilobyte -Unit TB 200
   200000000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Megabyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to Gigabyte.
.DESCRIPTION
   This module converts a given unit size to Gigabyte.
   e.g byte to Gigabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Gigabyte -Unit TB 200
   200000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Gigabyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to Terabyte.
.DESCRIPTION
   This module converts a given unit size to Terabyte.
   e.g byte to Terabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Terabyte -Unit GB 2000000
   2000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Terabyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 12)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to Petabyte.
.DESCRIPTION
   This module converts a given unit size to Petabyte.
   e.g byte to Petabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Petabyte -Unit GB 2000000
   2
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Petabyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 15)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 12)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

<#
.SYNOPSIS
    Used to convert both IPv4 addresses and IPv6 addresses to binary.
.DESCRIPTION
    ConvertTo-IcingaIPBinaryString returns a binary string based on the given IPv4 address or IPv6 address.

    More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
    This module is intended to be used to convert an IPv4 address or IPv6 address to binary string.
.PARAMETER IP
    Used to specify an IPv4 address or IPv6 address.
.INPUTS
    System.String
.OUTPUTS
    System.String

.LINK
    https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-IcingaIPBinaryString()
{
    param (
        $IP
    );

    if ($IP -like '*.*') {
        $IP = ConvertTo-IcingaIPv4BinaryString -IP $IP;
    } elseif ($IP -like '*:*') {
        $IP = ConvertTo-IcingaIPv6BinaryString -IP $IP;
    } else {
        return 'Invalid IP was provided!';
    }

    return $IP;
}

<#
.SYNOPSIS
   Used to convert an IPv4 address to binary.
.DESCRIPTION
   ConvertTo-IcingaIPv6 returns a binary string based on the given IPv4 address.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to convert an IPv4 address to binary string. Its recommended to use ConvertTo-IcingaIPBinaryString as a smart function instead.
.PARAMETER IP
   Used to specify an IPv4 address.
.INPUTS
   System.String
.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-IcingaIPv4BinaryString()
{
    param(
        [string]$IP
    );

    try {
        $IP = $IP -split '\.' | ForEach-Object {
            [System.Convert]::ToString($_, 2).PadLeft(8, '0');
        }
        $IP = $IP -join '';
        $IP = $IP -replace '\s', '';
    } catch {
        # Todo: Should we handle errors? It might happen due to faulty routes or unhandled route config
        #       we throw errors which should have no effect at all
        return $null;
    }

    return @{
        'value' = $IP;
        'name'  = 'IPv4'
    }
}

<#
.SYNOPSIS
   Used to convert an IPv6 address to binary.
.DESCRIPTION
   ConvertTo-IcingaIPv6 returns a binary string based on the given IPv6 address.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to convert an IPv6 address to binary string. Its recommended to use ConvertTo-IcingaIPBinaryString as a smart function instead.
.PARAMETER IP
   Used to specify an IPv6 address.
.INPUTS
   System.String
.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-IcingaIPv6BinaryString()
{
    param(
        [string]$IP
    );
    [string]$IP   = Expand-IcingaIPv6String $IP;
    [array]$IPArr = $IP.Split(':');

    $IPArr = $IPArr.ToCharArray();
    $IP = $IPArr | ForEach-Object {
        [System.Convert]::ToString("0x$_", 2).PadLeft(4, '0');
    }
    $IP = $IP -join '';
    $IP = $IP -replace '\s', '';

    return @{
        'value' = $IP;
        'name'  = 'IPv6'
    }
}

<#
 # Helper class allowing to easily convert strings into SecureStrings
 # and vice-versa
 #>
function ConvertTo-IcingaSecureString()
{
    param (
        [string]$String
    );

    if ([string]::IsNullOrEmpty($String)) {
        return $null;
    }

    return (ConvertTo-SecureString -AsPlainText $string -Force);
}

<#
.SYNOPSIS
   Helper function to convert values to integer if possible
.DESCRIPTION
   Converts an input value to integer if possible in any way. Otherwise it will return the object unmodified

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   Converts an input value to integer if possible in any way. Otherwise it will return the object unmodified
.PARAMETER Value
   Any value/object is analysed and if possible converted to an integer
.INPUTS
   System.Object
.OUTPUTS
   System.Integer

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Integer()
{
    param (
        $Value,
        [switch]$NullAsEmpty
    );

    if ($null -eq $Value) {
        if ($NullAsEmpty) {
            return '';
        }

        return 0;
    }

    if ([string]::IsNullOrEmpty($Value)) {
        if ($NullAsEmpty) {
            return '';
        }

        return 0;
    }

    if ((Test-Numeric $Value)) {
        return $Value;
    }

    $Type = $value.GetType().Name;

    if ($Type -eq 'GpoBoolean' -Or $Type -eq 'Boolean' -Or $Type -eq 'SwitchParameter') {
        return [int]$Value;
    }

    if ($Type -eq 'String') {
        if ($Value.ToLower() -eq 'true' -Or $Value.ToLower() -eq 'yes' -Or $Value.ToLower() -eq 'y') {
            return 1;
        }
        if ($Value.ToLower() -eq 'false' -Or $Value.ToLower() -eq 'no' -Or $Value.ToLower() -eq 'n') {
            return 0;
        }
    }

    return $Value;
}

function ConvertTo-JsonUTF8Bytes()
{
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $TRUE, ValueFromPipeline = $TRUE)]
        $InputObject      = $null,
        [int]$Depth       = 10,
        [switch]$Compress = $FALSE
    );

    $JsonBody  = ConvertTo-Json -InputObject $InputObject -Depth 100 -Compress;
    $UTF8Bytes = ([System.Text.Encoding]::UTF8.GetBytes($JsonBody));

    # Do not remove the "," as we require to force our PowerShell to handle our return value
    # as proper collection
    return , $UTF8Bytes;
}

<#
.SYNOPSIS
   Converts unit to seconds.
.DESCRIPTION
   This module converts a given time unit to seconds.
   e.g hours to seconds.

   More Information on https://github.com/Icinga/icinga-powershell-framework

.PARAMETER Value
   Specify unit to be converted to seconds. Allowed units: ms, s, m, h, d, w, M, y
   ms = miliseconds; s = seconds; m = minutes; h = hours; d = days; w = weeks; M = months; y = years;

   Like 20d for 20 days.
.EXAMPLE
   PS> ConvertTo-Seconds 30d
   2592000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Seconds()
{
    param(
        [string]$Value
    );

    if ([string]::IsNullOrEmpty($Value)) {
        return $Value;
    }

    [string]$NumberPart = '';
    [string]$UnitPart   = '';
    [bool]$Negate       = $FALSE;
    [bool]$hasUnit      = $FALSE;

    foreach ($char in $Value.ToCharArray()) {
        if ((Test-Numeric $char)) {
            $NumberPart += $char;
        } else {
            if ($char -eq '-') {
                $Negate = $TRUE;
            } elseif ($char -eq '.' -Or $char -eq ',') {
                $NumberPart += '.';
            } else {
                $UnitPart += $char;
                $hasUnit = $TRUE;
            }
        }
    }

    if (-Not $hasUnit -Or (Test-Numeric $NumberPart) -eq $FALSE) {
        return $Value;
    }

    [single]$ValueSplitted = $NumberPart;
    $result                = 0;

    if ($Negate) {
        $ValueSplitted    *= -1;
    }

    [string]$errorMsg = (
        [string]::Format('Invalid unit type "{0}" specified for convertion. Allowed units: ms, s, m, h, d, w, M, y', $UnitPart)
    );

    if ($UnitPart -Match 'ms') {
        $result = ($ValueSplitted / [math]::Pow(10, 3));
    } else {
        if ($UnitPart.Length -gt 1) {
            return $Value;
        }

        switch ([int][char]$UnitPart) {
            { 115 -contains $_ } { $result = $ValueSplitted; break; } # s
            { 109 -contains $_ } { $result = $ValueSplitted * 60; break; } # m
            { 104 -contains $_ } { $result = $ValueSplitted * 3600; break; } # h
            { 100 -contains $_ } { $result = $ValueSplitted * 86400; break; } # d
            { 119 -contains $_ } { $result = $ValueSplitted * 604800; break; } # w
            { 77  -contains $_ } { $result = $ValueSplitted * 2592000; break; } # M
            { 121 -contains $_ } { $result = $ValueSplitted * 31536000; break; } # y
            default {
                Throw $errorMsg;
                break;
            }
        }
    }

    return $result;
}

function ConvertTo-SecondsFromIcingaThresholds()
{
    param(
        [string]$Threshold
    );

    [array]$Content    = $Threshold.Split(':');
    [array]$NewContent = @();

    foreach ($entry in $Content) {
        $NewContent += (Get-IcingaThresholdsAsSeconds -Value $entry)
    }

    [string]$Value = [string]::Join(':', $NewContent);

    if ([string]::IsNullOrEmpty($Value) -eq $FALSE -And $Value.Contains(':') -eq $FALSE) {
        return [convert]::ToDouble($Value);
    }

    return $Value;
}

function Get-IcingaThresholdsAsSeconds()
{
    param(
        [string]$Value
    );

    if ($Value.Contains('~')) {
        $Value = $Value.Replace('~', '');
        return [string]::Format('~{0}', (ConvertTo-Seconds $Value));
    } elseif ($Value.Contains('@')) {
        $Value = $Value.Replace('@', '');
        return [string]::Format('@{0}', (ConvertTo-Seconds $Value));
    }

    return (ConvertTo-Seconds $Value);
}

Export-ModuleMember -Function @( 'ConvertTo-Seconds', 'ConvertTo-SecondsFromIcingaThresholds' );

<#
.SYNOPSIS
   Used to Expand an IPv6 address.
.DESCRIPTION
   Expand-IcingaIPv6String returns the expanded version of an IPv6 address.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to expand an IPv6 address.
.EXAMPLE
   PS> Expand-IcingaIPv6String ffe8::71:ab:
   FFE8:0000:0000:0000:0000:0071:00AB:0000
.PARAMETER IP
   Used to specify an IPv6 address.
.INPUTS
   System.String
.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Expand-IcingaIPv6String()
{
    param (
        [String]$IP
    );

    $Counter = 0;
    $RelV    = -1;

    for ($Index = 0; $Index -lt $IP.Length; $Index++) {
        if ($IP[$Index] -eq ':') {
            $Counter++;
            if (($Index - 1) -ge 0 -and $IP[$Index - 1] -eq ':') {
                $RelV = $Index;
            }
        }
    }

    if ($RelV -lt 0 -and $Counter -ne 7) {
        Write-IcingaConsoleError "Invalid IP was provided!";
        return $null;
    }

    if ($Counter -lt 7) {
        $IP = $IP.Substring(0, $RelV) + (':'*(7 - $Counter)) + $IP.Substring($RelV);
    }

    $Result = @();

    foreach ($SIP in $IP -split ':') {
        $Value = 0;
        [int]::TryParse(
            $SIP,
            [System.Globalization.NumberStyles]::HexNumber,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [Ref]$Value
        ) | Out-Null;
        $Result += ('{0:X4}' -f $Value);
    }
    $Result = $Result -join ':';

    return $Result;
}

function Format-IcingaDigitCount()
{
    param(
        [string]$Value,
        [int]$Digits,
        [string]$Symbol = 0
    );

    if ([string]::IsNullOrEmpty($Value)) {
        return $Value;
    }

    $CurrentLength = $Value.Length;
    if ($CurrentLength -ge $Digits) {
        return $Value;
    }

    while ($Value.Length -lt $Digits) {
        $Value = [string]::Format('{0}{1}', $Symbol, $Value);
    }

    return $Value;
}

function Format-IcingaPerfDataLabel()
{
    param(
        $PerfData
    );

    $Output = ((($PerfData) -Replace ' ', '_') -Replace '[\W]', '');

    while ($Output.Contains('__')) {
        $Output = $Output.Replace('__', '_');
    }
    # Remove all special characters and spaces on label names
    return $Output;
}

function Format-IcingaPerfDataValue()
{
    param(
        $PerfValue
    );

    if ((Test-Numeric $PerfValue) -eq $FALSE) {
        return $PerfValue;
    }

    # Convert our value to a string and replace ',' with a '.' to allow Icinga to parse the output
    # In addition, round every output to 6 digits
    return (([string]([math]::round([decimal]$PerfValue, 6))).Replace(',', '.'));
}

<#
.SYNOPSIS
   Exports command as JSON for icinga director

.DESCRIPTION
   Get-IcingaCheckCommandConfig returns a JSON-file of one or all 'Invoke-IcingaCheck'-Commands, which can be imported via Icinga-Director
   When no single command is specified all commands will be exported, and vice versa.

   More Information on https://github.com/Icinga/icinga-powershell-framework

.FUNCTIONALITY
   This module is intended to be used to export one or all PowerShell-Modules with the namespace 'Invoke-IcingaCheck'.
   The JSON-Export, which will be generated through this module is structured like an Icinga-Director-JSON-Export, so it can be imported via the Icinga-Director the same way.

.EXAMPLE
   PS>Get-IcingaCheckCommandConfig
   Check Command JSON for the following commands:
   - 'Invoke-IcingaCheckBiosSerial'
   - 'Invoke-IcingaCheckCPU'
   - 'Invoke-IcingaCheckProcessCount'
   - 'Invoke-IcingaCheckService'
   - 'Invoke-IcingaCheckUpdates'
   - 'Invoke-IcingaCheckUptime'
   - 'Invoke-IcingaCheckUsedPartitionSpace'
   - 'Invoke-IcingaCheckUsers'
############################################################

.EXAMPLE
   Get-IcingaCheckCommandConfig -OutDirectory 'C:\Users\icinga\config-exports'
   The following commands have been exported:
   - 'Invoke-IcingaCheckBiosSerial'
   - 'Invoke-IcingaCheckCPU'
   - 'Invoke-IcingaCheckProcessCount'
   - 'Invoke-IcingaCheckService'
   - 'Invoke-IcingaCheckUpdates'
   - 'Invoke-IcingaCheckUptime'
   - 'Invoke-IcingaCheckUsedPartitionSpace'
   - 'Invoke-IcingaCheckUsers'
   JSON export created in 'C:\Users\icinga\config-exports\PowerShell_CheckCommands_09-13-2019-10-55-1989.json'

.EXAMPLE
   Get-IcingaCheckCommandConfig Invoke-IcingaCheckBiosSerial, Invoke-IcingaCheckCPU -OutDirectory 'C:\Users\icinga\config-exports'
   The following commands have been exported:
   - 'Invoke-IcingaCheckBiosSerial'
   - 'Invoke-IcingaCheckCPU'
   JSON export created in 'C:\Users\icinga\config-exports\PowerShell_CheckCommands_09-13-2019-10-58-5342.json'

.PARAMETER CheckName
   Used to specify an array of commands which should be exported.
   Separated with ','

.PARAMETER FileName
   Define a custom file name for the exported `.json`/`.conf` file

.PARAMETER IcingaConfig
   Will switch the configuration generator to write plain Icinga 2 `.conf`
   files instead of Icinga Director Basket `.json` files

.INPUTS
   System.Array

.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework

.NOTES
#>

function Get-IcingaCheckCommandConfig()
{
    param(
        [array]$CheckName,
        [string]$OutDirectory = '',
        [string]$Filename,
        [switch]$IcingaConfig
    );

    [array]$BlacklistedArguments = @(
        'ThresholdInterval'
    );

    # Check whether all Checks will be exported or just the ones specified
    if ([string]::IsNullOrEmpty($CheckName) -eq $true) {
        $CheckName = (Get-Command Invoke-IcingaCheck*).Name
    }

    [int]$FieldID = 2; # Starts at '2', because '0' and '1' are reserved for 'Verbose' and 'NoPerfData'
    [hashtable]$Basket = @{ };

    # Define basic hashtable structure by adding fields: "Datafield", "DataList", "Command"
    $Basket.Add('Datafield', @{ });
    $Basket.Add('DataList', @{ });
    $Basket.Add('Command', @{ });

    # At first generate a base Check-Command we can use as import source for all other commands
    $Basket.Command.Add(
        'PowerShell Base',
        @{
            'arguments'       = @{ };
            'command'         = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe';
            'disabled'        = $FALSE;
            'fields'          = @();
            'imports'         = @();
            'is_string'       = $NULL;
            'methods_execute' = 'PluginCheck';
            'object_name'     = 'PowerShell Base';
            'object_type'     = 'object';
            'timeout'         = '180';
            'vars'            = @{ };
            'zone'            = $NULL;
        }
    );

    $ThresholdIntervalArg = New-Object -TypeName PSObject;
    $ThresholdIntervalArg | Add-Member -MemberType NoteProperty -Name 'type'             -Value (New-Object -TypeName PSObject);
    $ThresholdIntervalArg | Add-Member -MemberType NoteProperty -Name 'Description'      -Value (New-Object -TypeName PSObject);
    $ThresholdIntervalArg | Add-Member -MemberType NoteProperty -Name 'position'         -Value 99;
    $ThresholdIntervalArg | Add-Member -MemberType NoteProperty -Name 'Name'             -Value 'ThresholdInterval';
    $ThresholdIntervalArg | Add-Member -MemberType NoteProperty -Name 'required'         -Value $FALSE;
    $ThresholdIntervalArg.type | Add-Member -MemberType NoteProperty -Name 'name'        -Value 'String';
    $ThresholdIntervalArg.Description | Add-Member -MemberType NoteProperty -Name 'Text' -Value 'Change the value your defined threshold checks against from the current value to a collected time threshold of the Icinga for Windows daemon, as described here: https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/ An example for this argument would be 1m or 15m which will use the average of 1m or 15m for monitoring.';

    # Loop through ${CheckName}, to get information on every command specified/all commands.
    foreach ($check in $CheckName) {

        # Get necessary syntax-information and more through cmdlet "Get-Help"
        $Data            = (Get-Help $check);
        $ParameterList   = (Get-Command -Name $check).Parameters;
        $CheckParamList  = @( $ThresholdIntervalArg );
        $PluginNameSpace = $Data.Name.Replace('Invoke-', '');

        foreach ($entry in $Data.parameters.parameter) {
            foreach ($BlackListArg in $BlacklistedArguments) {
                if ($BlackListArg.ToLower() -eq $entry.Name.ToLower()) {
                    Write-IcingaConsoleError -Message 'The argument "{0}" for check command "{1}" is not allowed, as this is reserved as Framework constant argument and can not be used.' -Objects $BlackListArg, $check;
                    return;
                }
            }
            $CheckParamList += (Convert-IcingaCheckArgumentToPSObject -Parameter $entry);
        }

        foreach ($arg in $ParameterList.Keys) {
            foreach ($entry in $CheckParamList) {
                if ($entry.Name -eq $arg) {
                    $entry.Attributes.ValidValues = $ParameterList[$arg].Attributes.ValidValues;
                    break;
                }
            }
        }

        # Add command Structure
        $Basket.Command.Add(
            $Data.Name, @{
                'arguments'   = @{
                    # Set the Command handling for every check command
                    '-C' = @{
                        'value' = [string]::Format('try {{ Use-Icinga -Minimal; }} catch {{ Write-Output {1}The Icinga PowerShell Framework is either not installed on the system or not configured properly. Please check https://icinga.com/docs/windows for further details{1}; Write-Output {1}Error:{1} $$($$_.Exception.Message)Components:`r`n$$( Get-Module -ListAvailable {1}icinga-powershell-*{1} )`r`n{1}Module-Path:{1}`r`n$$($$Env:PSModulePath); exit 3; }}; Exit-IcingaExecutePlugin -Command {1}{0}{1} ', $Data.Name, "'");
                        'order' = '0';
                    }
                }
                'fields'      = @();
                'imports'     = @( 'PowerShell Base' );
                'object_name' = $Data.Name;
                'object_type' = 'object';
                'vars'        = @{};
            }
        );

        # Loop through parameters of a given command
        foreach ($parameter in $CheckParamList) {

            $IsDataList      = $FALSE;

            # IsNumeric-Check on position to determine the order-value
            If (Test-Numeric($parameter.position) -eq $TRUE) {
                [string]$Order = [int]$parameter.position + 1;
            } else {
                [string]$Order = 99
            }

            $IcingaCustomVariable = [string]::Format('${0}_{1}_{2}$', $PluginNameSpace, (Get-Culture).TextInfo.ToTitleCase($parameter.type.name), $parameter.Name);

            if ($IcingaCustomVariable.Length -gt 66) {
                Write-IcingaConsoleError 'The argument "{0}" for the plugin "{1}" is too long. The maximum size of generated custom variables is 64 digits. Current argument size: "{2}", Name: "{3}"' -Objects $parameter.Name, $check, ($IcingaCustomVariable.Length - 2), $IcingaCustomVariable.Replace('$', '');
                return;
            }

            # Todo: Should we improve this? Actually the handling would be identical, we just need to assign
            #       the proper field for this
            if ($IcingaCustomVariable -like '*_Int32_Verbose$' -Or $IcingaCustomVariable -like '*_Int_Verbose$' -Or $IcingaCustomVariable -like '*_Object_Verbose$') {
                $IcingaCustomVariable = [string]::Format('${0}_Int_Verbose$', $PluginNameSpace);
            }

            # Add arguments to a given command
            if ($parameter.type.name -eq 'SwitchParameter') {
                $Basket.Command[$Data.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'set_if'        = $IcingaCustomVariable;
                        'set_if_format' = 'string';
                        'order'         = $Order;
                    }
                );

                $Basket.Command[$Data.Name].vars.Add($IcingaCustomVariable.Replace('$', ''), $FALSE);

            } elseif ($parameter.type.name -eq 'Array') {
                # Conditional whether type of parameter is array
                $Basket.Command[$Data.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'value' = @{
                            'type' = 'Function';
                            'body' = [string]::Format(
                                'var arr = macro("{0}");{1}    if (len(arr) == 0) {2}{1}        return "@()";{1}    {3}{1}    return arr.map({1}        x => if (typeof(x) == String) {2}{1}            var argLen = len(x);{1}            if (argLen != 0 && x.substr(0,1) == "{4}" && x.substr(argLen - 1, argLen) == "{4}") {2}{1}                x;{1}            {3} else {2}{1}                "{4}" + x + "{4}";{1}            {3}{1}        {3} else {2}{1}            x;{1}        {3}{1}    ).join(",");',
                                $IcingaCustomVariable,
                                "`r`n",
                                '{',
                                '}',
                                "'"
                            );
                        }
                        'order' = $Order;
                    }
                );
            } elseif ($parameter.type.name -eq 'SecureString') {
                # Convert out input string as SecureString
                $Basket.Command[$Data.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'value' = (
                            [string]::Format(
                                "(ConvertTo-IcingaSecureString '{0}')",
                                $IcingaCustomVariable
                            )
                        )
                        'order' = $Order;
                    }
                );
            } else {
                # Default to Object
                $Basket.Command[$Data.Name].arguments.Add(
                    [string]::Format('-{0}', $parameter.Name), @{
                        'value' = $IcingaCustomVariable;
                        'order' = $Order;
                    }
                );
            }

            # Determine wether a parameter is required based on given syntax-information
            if ($parameter.required -eq $TRUE) {
                $Required = 'y';
            } else {
                $Required = 'n';
            }

            $IcingaCustomVariable = [string]::Format('{0}_{1}_{2}', $PluginNameSpace, (Get-Culture).TextInfo.ToTitleCase($parameter.type.name), $parameter.Name);

            # Todo: Should we improve this? Actually the handling would be identical, we just need to assign
            #       the proper field for this
            if ($IcingaCustomVariable -like '*_Int32_Verbose' -Or $IcingaCustomVariable -like '*_Int_Verbose' -Or $IcingaCustomVariable -like '*_Object_Verbose') {
                $IcingaCustomVariable = [string]::Format('{0}_Int_Verbose', $PluginNameSpace);
            }

            [bool]$ArgumentKnown = $FALSE;

            foreach ($argument in $Basket.Datafield.Keys) {
                if ($Basket.Datafield[$argument].varname -eq $IcingaCustomVariable) {
                    $ArgumentKnown = $TRUE;
                    break;
                }
            }

            if ($ArgumentKnown) {
                continue;
            }

            $DataListName = [string]::Format('{0} {1}', $PluginNameSpace, $parameter.Name);

            if ($null -ne $parameter.Attributes.ValidValues) {
                $IcingaDataType = 'Datalist';
                Add-PowerShellDataList -Name $DataListName -Basket $Basket -Arguments $parameter.Attributes.ValidValues;
                $IsDataList = $TRUE;
            } elseif ($parameter.type.name -eq 'SwitchParameter') {
                $IcingaDataType = 'Boolean';
            } elseif ($parameter.type.name -eq 'Object') {
                $IcingaDataType = 'String';
            } elseif ($parameter.type.name -eq 'Array') {
                $IcingaDataType = 'Array';
            } elseif ($parameter.type.name -eq 'Int' -Or $parameter.type.name -eq 'Int32') {
                $IcingaDataType = 'Number';
            } else {
                $IcingaDataType = 'String';
            }

            $IcingaDataType = [string]::Format('Icinga\Module\Director\DataType\DataType{0}', $IcingaDataType)

            if ($Basket.Datafield.Values.varname -ne $IcingaCustomVariable) {
                $Basket.Datafield.Add(
                    [string]$FieldID, @{
                        'varname'     = $IcingaCustomVariable;
                        'caption'     = $parameter.Name;
                        'description' = $parameter.Description.Text;
                        'datatype'    = $IcingaDataType;
                        'format'      = $NULL;
                        'originalId'  = [string]$FieldID;
                    }
                );

                if ($IsDataList) {
                    [string]$DataListDataType = 'string';

                    if ($parameter.type.name -eq 'Array') {
                        $DataListDataType = 'array';
                    }

                    $Basket.Datafield[[string]$FieldID].Add(
                        'settings', @{
                            'datalist'  = $DataListName;
                            'data_type' = $DataListDataType;
                            'behavior'  = 'strict';
                        }
                    );
                } else {
                    $CustomVarVisibility = 'visible';

                    if ($parameter.type.name -eq 'SecureString') {
                        $CustomVarVisibility = 'hidden';
                    }

                    $Basket.Datafield[[string]$FieldID].Add(
                        'settings', @{
                            'visibility' = $CustomVarVisibility;
                        }
                    );
                }

                # Increment FieldID, so unique datafields are added.
                [int]$FieldID = [int]$FieldID + 1;
            }

            # Increment FieldNumeration, so unique fields for a given command are added.
            [int]$FieldNumeration = [int]$FieldNumeration + 1;
        }
    }

    foreach ($check in $CheckName) {
        [int]$FieldNumeration = 0;

        $Data            = (Get-Help $check)
        $PluginNameSpace = $Data.Name.Replace('Invoke-', '');
        $CheckParamList  = @( $ThresholdIntervalArg );

        foreach ($entry in $Data.parameters.parameter) {
            $CheckParamList += (Convert-IcingaCheckArgumentToPSObject -Parameter $entry);;
        }

        foreach ($parameter in $CheckParamList) {
            $IcingaCustomVariable = [string]::Format('{0}_{1}_{2}', $PluginNameSpace, (Get-Culture).TextInfo.ToTitleCase($parameter.type.name), $parameter.Name);

            # Todo: Should we improve this? Actually the handling would be identical, we just need to assign
            #       the proper field for this
            if ($IcingaCustomVariable -like '*_Int32_Verbose' -Or $IcingaCustomVariable -like '*_Int_Verbose' -Or $IcingaCustomVariable -like '*_Object_Verbose') {
                $IcingaCustomVariable = [string]::Format('{0}_Int_Verbose', $PluginNameSpace);
            }

            foreach ($DataFieldID in $Basket.Datafield.Keys) {
                [string]$varname = $Basket.Datafield[$DataFieldID].varname;
                if ([string]$varname -eq [string]$IcingaCustomVariable) {
                    $Basket.Command[$Data.Name].fields +=  @{
                        'datafield_id' = [int]$DataFieldID;
                        'is_required'  = $Required;
                        'var_filter'   = $NULL;
                    };
                }
            }
        }
    }

    [string]$FileType = '.json';
    if ($IcingaConfig) {
        $FileType = '.conf';
    }

    if ([string]::IsNullOrEmpty($Filename)) {
        $TimeStamp = (Get-Date -Format "MM-dd-yyyy-HH-mm-ffff");
        $FileName  = [string]::Format("PowerShell_CheckCommands_{0}{1}", $TimeStamp, $FileType);
    } else {
        if ($Filename.Contains($FileType) -eq $FALSE) {
            $Filename = [string]::Format('{0}{1}', $Filename, $FileType);
        }
    }

    # Generate JSON Output from Hashtable
    $output = ConvertTo-Json -Depth 100 $Basket -Compress;

    # Determine whether json output via powershell or in file (based on param -OutDirectory)
    if ([string]::IsNullOrEmpty($OutDirectory) -eq $false) {
        $ConfigDirectory = $OutDirectory;
        $OutDirectory    = (Join-Path -Path $OutDirectory -ChildPath $FileName);
        if ((Test-Path($OutDirectory)) -eq $false) {
            New-Item -Path $OutDirectory -ItemType File -Force | Out-Null;
        }

        if ((Test-Path($OutDirectory)) -eq $false) {
            throw 'Failed to create specified directory. Please try again or use a different target location.';
        }

        if ($IcingaConfig) {
            Write-IcingaPlainConfigurationFiles -Content $Basket -OutDirectory $ConfigDirectory -FileName $FileName;
        } else {
            Set-Content -Path $OutDirectory -Value $output;
        }

        # Output-Text
        Write-IcingaConsoleNotice "The following commands have been exported:"
        foreach ($check in $CheckName) {
            Write-IcingaConsoleNotice "- '$check'";
        }
        Write-IcingaConsoleNotice "JSON export created in '${OutDirectory}'"
        Write-IcingaConsoleWarning 'By using this generated check command configuration you will require the Icinga PowerShell Framework 1.4.0 or later to be installed on ALL monitored machines!';
        return;
    }

    Write-IcingaConsoleNotice "Check Command JSON for the following commands:"
    foreach ($check in $CheckName) {
        Write-IcingaConsoleNotice "- '$check'"
    }
    Write-IcingaConsoleWarning 'By using this generated check command configuration you will require the Icinga PowerShell Framework 1.4.0 or later to be installed on ALL monitored machines!';
    Write-IcingaConsoleNotice '############################################################';

    return $output;
}

function Write-IcingaPlainConfigurationFiles()
{
    param (
        $Content,
        $OutDirectory,
        $FileName
    );

    $ConfigDirectory = $OutDirectory;
    $OutDirectory    = (Join-Path -Path $OutDirectory -ChildPath $FileName);

    $IcingaConfig = '';

    foreach ($entry in $Content.Command.Keys) {
        $CheckCommand = $Content.Command[$entry];

        # Skip PowerShell base, this is written at the end in a separate file
        if ($CheckCommand.object_name -eq 'PowerShell Base') {
            continue;
        }

        # Create the CheckCommand object
        $IcingaConfig += [string]::Format('object CheckCommand "{0}" {{{1}', $CheckCommand.object_name, (New-IcingaNewLine));

        # Import all defined import templates
        foreach ($import in $CheckCommand.imports) {
            $IcingaConfig += [string]::Format('    import "{0}"{1}', $import, (New-IcingaNewLine));
        }
        $IcingaConfig += New-IcingaNewLine;

        if ($CheckCommand.arguments.Count -ne 0) {
            # Arguments for the configuration
            $IcingaConfig += '    arguments += {'
            $IcingaConfig += New-IcingaNewLine;

            foreach ($argument in $CheckCommand.arguments.Keys) {
                $CheckArgument = $CheckCommand.arguments[$argument];

                # Each single argument, like "-Verbosity" = {
                $IcingaConfig += [string]::Format('        "{0}" = {{{1}', $argument, (New-IcingaNewLine));

                foreach ($argconfig in $CheckArgument.Keys) {
                    $Value = '';

                    if ($argconfig -eq 'set_if_format') {
                        continue;
                    }

                    # Order is numeric -> no "" required
                    if ($argconfig -eq 'order') {
                        $StringFormater = '            {0} = {1}{2}';
                    } else {
                        # All other entries should be handled as strings and contain ""
                        $StringFormater ='            {0} = "{1}"{2}'
                    }

                    # In case it is a hashtable, this is most likely a DSL function
                    # We have to render it differently to also match the intends
                    if ($CheckArgument[$argconfig] -is [Hashtable]) {
                        $Value = $CheckArgument[$argconfig].body;
                        $DSLArray = $Value.Split("`r`n");
                        $Value = '';
                        foreach ($item in $DSLArray) {
                            if ([string]::IsNullOrEmpty($item)) {
                                continue;
                            }
                            $Value += [string]::Format('                {0}{1}', $item, (New-IcingaNewLine));
                        }
                        $Value = $Value.Substring(0, $Value.Length - 2);
                        $StringFormater ='            {0} = {{{{{2}{1}{2}            }}}}{2}'
                    } else {
                        # All other values besides DSL
                        $Value = $CheckArgument[$argconfig];
                    }

                    # Read description from our variables
                    if ($argconfig -eq 'value') {
                        foreach ($item in $Content.DataField.Keys) {
                            $DataField = $Content.DataField[$item];

                            if ($Value.Contains($DataField.varname)) {
                                if ([string]::IsNullOrEmpty($DataField.description)) {
                                    break;
                                }
                                $Description = $DataField.description.Replace("`r`n", ' ');
                                $Description = $Description.Replace("\", '\\');
                                $Description = $Description.Replace("`n", ' ');
                                $Description = $Description.Replace("`r", ' ');
                                $Description = $Description.Replace('"', "'");
                                $IcingaConfig += [string]::Format('            description = "{0}"{1}', $Description, (New-IcingaNewLine));
                                break;
                            }
                        }
                    }

                    # Write the argument to your CheckCommand
                    $IcingaConfig += [string]::Format($StringFormater, $argconfig, $Value, (New-IcingaNewLine));
                }

                # Close this specific argument
                $IcingaConfig += '        }'
                $IcingaConfig += New-IcingaNewLine;
            }

            $IcingaConfig = $IcingaConfig.Substring(0, $IcingaConfig.Length - 2);

            # Close all arguments content
            $IcingaConfig += New-IcingaNewLine;
            $IcingaConfig += '    }'
        }

        # In case we pre-define custom variables, we should add them here
        if ($CheckCommand.vars.Count -ne 0) {
            $IcingaConfig += New-IcingaNewLine;

            foreach ($var in $CheckCommand.vars.Keys) {
                [string]$Value = $CheckCommand.vars[$var];
                $IcingaConfig += [string]::Format('    vars.{0} = {1}{2}', $var, $Value.ToLower(), (New-IcingaNewLine));
            }
        } else {
            $IcingaConfig += New-IcingaNewLine;
        }

        # Close the CheckCommand object
        $IcingaConfig += '}';
        if ($Content.Command.Count -gt 2) {
            $IcingaConfig += New-IcingaNewLine;
            $IcingaConfig += New-IcingaNewLine;
        }
    }

    # Write the PowerShell Base command to a separate file for Icinga 2 configuration
    [string]$PowerShellBase  = [string]::Format('object CheckCommand "PowerShell Base" {{{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('    import "plugin-check-command"{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('    command = [{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('        "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('    ]{0}', (New-IcingaNewLine));
    $PowerShellBase         += [string]::Format('    timeout = 3m{0}', (New-IcingaNewLine));
    $PowerShellBase         += '}';

    Set-Content -Path (Join-Path -Path $ConfigDirectory -ChildPath 'PowerShell_Base.conf') -Value $PowerShellBase;
    Set-Content -Path $OutDirectory -Value $IcingaConfig;
}

function Add-PowerShellDataList()
{
    param(
        $Name,
        $Basket,
        $Arguments
    );

    $Basket.DataList.Add(
        $Name, @{
            'list_name'  = $Name;
            'owner'      = $env:username;
            'originalId' = '2';
            'entries'    = @();
        }
    );

    foreach ($entry in $Arguments) {
        if ([string]::IsNullOrEmpty($entry)) {
            Write-IcingaConsoleWarning `
                -Message 'The plugin argument "{0}" contains the illegal ValidateSet $null which will not be rendered. Please remove it from the arguments list of "{1}"' `
                -Objects $Name, $Arguments;

            continue;
        }
        $Basket.DataList[$Name]['entries'] += @{
            'entry_name'    = $entry;
            'entry_value'   = $entry;
            'format'        = 'string';
            'allowed_roles' = $NULL;
        };
    }
}

function Get-IcingaHashtableItem()
{
    param(
        $Hashtable,
        $Key,
        $NullValue = $null
    );

    if ($null -eq $Hashtable) {
        return $NullValue;
    }

    if ($Hashtable.ContainsKey($Key) -eq $FALSE) {
        return $NullValue;
    }

    return $Hashtable[$Key];
}

function Get-IcingaMaxTextLength()
{
    param (
        [array]$TextArray = ''
    );

    [int]$MaxLength = 0;

    foreach ($text in $TextArray) {
        if ($MaxLength -lt $text.Length) {
            $MaxLength = $text.Length;
        }
    }

    return $MaxLength;
}

<#
.SYNOPSIS
   Returns interface ip address, which will be used for the host object within the icinga director.
.DESCRIPTION
   Get-IcingaNetworkInterface returns the ip address of the interface, which will be used for the host object within the icinga director.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   This module is intended to be used to determine the interface ip address, during kickstart wizard, but will also function standalone.
.EXAMPLE
   PS> Get-IcingaNetworkInterface 'icinga.com'
   192.168.243.88
.EXAMPLE
   PS> Get-IcingaNetworkInterface '8.8.8.8'
   192.168.243.88
.PARAMETER IP
   Used to specify either an IPv4, IPv6 address or an FQDN.
.INPUTS
   System.String
.OUTPUTS
   System.String

.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Get-IcingaNetworkInterface()
{
    param(
        [string]$IP
    );

    if ([string]::IsNullOrEmpty($IP)) {
        Write-IcingaConsoleError 'Please specify a valid IP-Address or FQDN';
        return $null;
    }

    # Ensure that we can still process on older Windows system where
    # Get-NetRoute ist not available
    if ((Test-IcingaFunction 'Get-NetRoute') -eq $FALSE) {
        Write-IcingaConsoleWarning 'Your Windows system does not support "Get-NetRoute". A fallback solution is used to fetch the IP of the first Network Interface routing through 0.0.0.0'
        return (Get-IcingaNetworkRoute).Interface;
    }

    try {
        [array]$IP = ([System.Net.Dns]::GetHostAddresses($IP)).IPAddressToString;
    } catch {
        Write-IcingaConsoleError 'Invalid IP was provided!';
        return $null;
    }

    $IPBinStringMaster = ConvertTo-IcingaIPBinaryString -IP $IP;

    [hashtable]$InterfaceData=@{};

    $InterfaceInfo = Get-NetRoute;
    $Counter = 0;

    foreach ( $Info in $InterfaceInfo ) {
        $Counter++;

        $Divide   = $Info.DestinationPrefix;
        $IP, $Mask = $Divide.Split('/');

        foreach ($destinationIP in $IPBinStringMaster) {
            [string]$Key     = '';
            [string]$MaskKey = '';
            <# IPv4 #>
            if ($destinationIP.name -eq 'IPv4') {
                if ($IP -like '*.*') {
                    if ([int]$Mask -lt 10) {
                        $MaskKey = [string]::Format('00{0}', $Mask);
                    } else {
                        $MaskKey = [string]::Format('0{0}', $Mask);
                    }
                }
            }
            <# IPv6 #>
            if ($destinationIP.name -eq 'IPv6') {
                if ($IP -like '*:*') {
                    if ([int]$Mask -lt 10) {
                        $MaskKey = [string]::Format('00{0}', $Mask);
                    } elseif ([int]$Mask -lt 100) {
                        $MaskKey = [string]::Format('0{0}', $Mask);
                    } else {
                        $MaskKey = $Mask;
                    }
                }
            }

            $Key = [string]::Format('{0}-{1}', $MaskKey, $Counter);

            if ($InterfaceData.ContainsKey($Key)) {
                continue;
            }

            $InterfaceData.Add(
                $Key, @{
                    'Binary IP String' = (ConvertTo-IcingaIPBinaryString -IP $IP).value;
                    'Mask'             = $Mask;
                    'Interface'        = $Info.ifIndex;
                }
            );
        }
    }

    $InterfaceDataOrdered = $InterfaceData.GetEnumerator() | Sort-Object -Property Name -Descending;
    $ExternalInterfaces   = @{};

    foreach ( $Route in $InterfaceDataOrdered ) {
        foreach ($destinationIP in $IPBinStringMaster) {
            [string]$RegexPattern = [string]::Format("^.{{{0}}}", $Route.Value.Mask);
            [string]$ToBeMatched = $Route.Value."Binary IP String";
            if ($null -eq $ToBeMatched) {
                continue;
            }

            $Match1=[regex]::Matches($ToBeMatched, $RegexPattern).Value;
            $Match2=[regex]::Matches($destinationIP.Value, $RegexPattern).Value;

            If ($Match1 -like $Match2) {
                $ExternalInterface = ((Get-NetIPAddress -InterfaceIndex $Route.Value.Interface -AddressFamily $destinationIP.Name -ErrorAction SilentlyContinue).IPAddress);

                # If no interface was found -> skip this entry
                if ($null -eq $ExternalInterface) {
                    continue;
                }

                if ($ExternalInterfaces.ContainsKey($ExternalInterface)) {
                    $ExternalInterfaces[$ExternalInterface].count += 1;
                } else {
                    $ExternalInterfaces.Add(
                        $ExternalInterface,
                        @{
                            'count' = 1
                        }
                    );
                }
            }
        }
    }

    if ($ExternalInterfaces.Count -eq 0) {
        foreach ($destinationIP in $IPBinStringMaster) {
            $ExternalInterface = ((Get-NetIPAddress -InterfaceIndex (Get-NetRoute | Where-Object -Property DestinationPrefix -Like '0.0.0.0/0')[0].IfIndex -AddressFamily $destinationIP.name).IPAddress).split('%')[0];
            if ($ExternalInterfaces.ContainsKey($ExternalInterface)) {
                $ExternalInterfaces[$ExternalInterface].count += 1;
            } else {
                $ExternalInterfaces.Add(
                    $ExternalInterface,
                    @{
                        'count' = 1
                    }
                );
            }
        }
    }

    $InternalCount        = 0;
    [array]$UseInterface  = @();
    foreach ($interface in $ExternalInterfaces.Keys) {
        $currentCount = $ExternalInterfaces[$interface].count;
        if ($currentCount -gt $InternalCount) {
            $InternalCount = $currentCount;
            $UseInterface += $interface;
        }
    }

    # In case we found multiple interfaces, fallback to our
    # 'route print' function and return this interface instead
    if ($UseInterface.Count -ne 1) {
        return (Get-IcingaNetworkRoute).Interface;
    }

    return $UseInterface[0];
}

function Get-IcingaNetworkInterfaceUnits()
{
    param (
        [long]$Value
    );

    [hashtable]$InterfaceData = @{
        'RawValue'  = $Value;
        'LinkSpeed' = 0;
        'Unit'      = 'Mbit'
    };

    [decimal]$result = ($Value / [Math]::Pow(10, 6));

    if ($result -ge 1000) {
        $InterfaceData.LinkSpeed = [decimal]($result / 1000);
        $InterfaceData.Unit      = 'Gbit';
    } else {
        $InterfaceData.LinkSpeed = $result;
        $InterfaceData.Unit      = 'Mbit';
    }

    return $InterfaceData;
}

<#
.SYNOPSIS
   Fetch the used interface for our Windows System
.DESCRIPTION
   Newer Windows systems provide a Cmdlet 'Get-NetRoute' for fetching the
   network route configurations. Older systems however do not provide this
   and to ensure some sort of backwards compatibility, we will have a look
   on our route configuration and return the first valid interface found
.FUNCTIONALITY
   This Cmdlet will return first valid IP for our interface
.EXAMPLE
   PS>Get-IcingaNetworkRoute
.OUTPUTS
   System.Array
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Get-IcingaNetworkRoute()
{
    $RouteConfig = (&route print | Where-Object {
        $_.TrimStart() -Like "0.0.0.0*";
    }).Split() | Where-Object {
        return $_;
    };

    $Interface   = @{
        'Destination' = $RouteConfig[0];
        'Netmask'     = $RouteConfig[1];
        'Gateway'     = $RouteConfig[2];
        'Interface'   = $RouteConfig[3];
        'Metric'      = $RouteConfig[4];
    }

    return $Interface;
}

function Get-IcingaNextUnitIteration()
{
    param (
        [string]$Unit = '',
        [array]$Units = @()
    );

    [bool]$Found = $FALSE;

    foreach ($entry in $Units) {
        if ($Found) {
            return $entry;
        }
        if ($entry -eq $Unit) {
            $Found = $TRUE;
        }
    }

    return '';
}

function Get-IcingaPSObjectProperties()
{
    param(
        $Object         = $null,
        [array]$Include = @(),
        [array]$Exclude = @()
    );

    [hashtable]$RetValue = @{};

    if ($null -eq $Object) {
        return $RetValue;
    }

    foreach ($property in $Object.PSObject.Properties) {
        [string]$DataType = $property.TypeNameOfValue;

        if ($Include.Count -ne 0 -And -Not ($Include -Contains $property.Name)) {
            continue;
        }

        if ($Exclude.Count -ne 0 -And $Exclude -Contains $property.Name) {
            continue;
        }

        if ($DataType.Contains('string') -or $DataType.Contains('int') -Or $DataType.Contains('bool')) {
            $RetValue.Add(
                $property.Name,
                $property.Value
            );
        } else {
            try {
                $RetValue.Add(
                    $property.Name,
                    (Get-IcingaPSObjectProperties -Object $property.Value)
                );
            } catch {
                $RetValue.Add(
                    $property.Name,
                    ([string]$property.Value)
                );
            }

        }
    }

    return $RetValue;
}

function Get-IcingaServices()
{
    param (
        [array]$Service,
        [array]$Exclude = @()
    );

    $ServiceInformation = Get-Service -Name $Service -ErrorAction SilentlyContinue;
    $ServiceWmiInfo     = $null;

    if ($Service.Count -eq 0) {
        $ServiceWmiInfo = Get-IcingaWindowsInformation Win32_Service;
    } else {
        $ServiceWmiInfo = Get-IcingaWindowsInformation Win32_Service | Where-Object { $Service -Contains $_.Name } | Select-Object StartName, Name, ExitCode, StartMode, PathName;
    }

    if ($null -eq $ServiceInformation) {
        return $null;
    }

    [hashtable]$ServiceData = @{ };

    foreach ($service in $ServiceInformation) {

        [array]$DependentServices = $null;
        [array]$DependingServices = $null;
        $ServiceExitCode          = 0;
        [string]$ServiceUser      = '';
        [string]$ServicePath      = '';
        [int]$StartModeId         = 5;
        [string]$StartMode        = 'Unknown';

        if ($Exclude -contains $service.ServiceName) {
            continue;
        }

        foreach ($wmiService in $ServiceWmiInfo) {
            if ($wmiService.Name -eq $service.ServiceName) {
                $ServiceUser     = $wmiService.StartName;
                $ServicePath     = $wmiService.PathName;
                $ServiceExitCode = $wmiService.ExitCode;
                if ([string]::IsNullOrEmpty($wmiService.StartMode) -eq $FALSE) {
                    $StartModeId = ([int]$IcingaEnums.ServiceWmiStartupType[$wmiService.StartMode]);
                    $StartMode   = $IcingaEnums.ServiceStartupTypeName[$StartModeId];
                }
                break;
            }
        }

        #Dependent / Child
        foreach ($dependency in $service.DependentServices) {
            if ($null -eq $DependentServices) {
                $DependentServices = @();
            }
            $DependentServices += $dependency.Name;
        }

        #Depends / Parent
        foreach ($dependency in $service.ServicesDependedOn) {
            if ($null -eq $DependingServices) {
                $DependingServices = @();
            }
            $DependingServices += $dependency.Name;
        }

        $ServiceData.Add(
            $service.Name, @{
                'metadata'      = @{
                    'DisplayName'   = $service.DisplayName;
                    'ServiceName'   = $service.ServiceName;
                    'Site'          = $service.Site;
                    'Container'     = $service.Container;
                    'ServiceHandle' = $service.ServiceHandle;
                    'Dependent'     = $DependentServices;
                    'Depends'       = $DependingServices;
                };
                'configuration' = @{
                    'CanPauseAndContinue' = $service.CanPauseAndContinue;
                    'CanShutdown'         = $service.CanShutdown;
                    'CanStop'             = $service.CanStop;
                    'Status'              = @{
                        'raw'   = [int]$service.Status;
                        'value' = $service.Status;
                    };
                    'ServiceType'         = @{
                        'raw'   = [int]$service.ServiceType;
                        'value' = $service.ServiceType;
                    };
                    'ServiceHandle'       = $service.ServiceHandle;
                    'StartType'           = @{
                        'raw'   = $StartModeId;
                        'value' = $StartMode;
                    };
                    'ServiceUser'         = $ServiceUser;
                    'ServicePath'         = $ServicePath;
                    'ExitCode'            = $ServiceExitCode;
                }
            }
        );
    }
    return $ServiceData;
}

function Get-IcingaUnixTime()
{
    param(
        [switch]$Milliseconds = $FALSE
    );

    if ($Milliseconds) {
        return ([int64](([DateTime]::UtcNow) - (Get-Date '1/1/1970')).TotalMilliseconds / 1000);
    }

    return [int][double]::Parse(
        (Get-Date -UFormat %s -Date (Get-Date).ToUniversalTime())
    );
}

function Get-IcingaUserSID()
{
    param(
        [string]$User
    );

    if ($User -eq 'LocalSystem') {
        $User = 'NT Authority\SYSTEM';
    }

    $UserData = Split-IcingaUserDomain -User $User;

    try {
        $NTUser       = New-Object System.Security.Principal.NTAccount($UserData.Domain, $UserData.User);
        $SecurityData = $NTUser.Translate([System.Security.Principal.SecurityIdentifier]);
    } catch {
        throw $_.Exception;
    }

    if ($null -eq $SecurityData) {
        throw 'Failed to fetch user information from system';
    }

    return $SecurityData.Value;
}

<#
.SYNOPSIS
   Compares two numeric input values and returns the lower or higher value
.DESCRIPTION
   Compares two numeric numbers and returns either the higher or lower value
   depending on the configuration of the argument

   More Information on https://github.com/Icinga/icinga-powershell-framework
.FUNCTIONALITY
   Compares two numeric input values and returns the lower or higher value
.PARAMETER Value
   The input value to check for
.PARAMETER Compare
   The value to compare against
.PARAMETER Minimum
   Configures the command to return the lower number of both inputs
.PARAMETER Maximum
   Configures the command to return the higher number of both inputs
.EXAMPLE
   PS> Get-IcingaValue -Value 10 -Compare 12 -Minimum;
.EXAMPLE
   PS> Get-IcingaValue -Value 10 -Compare 12 -Maximum;
.INPUTS
   System.Integer
.OUTPUTS
   System.Integer
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Get-IcingaValue()
{
    param(
        $Value,
        $Compare,
        [switch]$Minimum = $FALSE,
        [switch]$Maximum = $FALSE
    );

    # If none of both is set, return the current value
    if (-Not $Minimum -And -Not $Maximum) {
        return $Value;
    }

    # Return the lower value
    if ($Minimum) {
        # If the value is greater or equal the compared value, return the compared one
        if ($Value -ge $Compare) {
            return $Compare;
        }

        # Otherwise return the value itself
        return $Value;
    }

    # Return the higher value
    if ($Maximum) {
        # If the value is greater or equal the compared one, return the value
        if ($Value -ge $Compare) {
            return $Value;
        }

        # Otherwise return the compared value
        return $Compare;
    }

    # Shouldnt happen anyway
    return $Value;
}

function Get-IPConfigFromString()
{
    param(
        [string]$IPConfig
    );

    if ($IPConfig.Contains(':') -and ($IPConfig.Contains('[') -eq $FALSE -And $IPConfig.Contains(']') -eq $FALSE)) {
        throw 'Invalid IP-Address format. For IPv6 and/or port configuration, the syntax must be like [ip]:port';
    }

    if ($IPConfig.Contains('[') -eq $FALSE) {
        return @{
            'address' = $IPConfig;
            'port'    = $null
        };
    }

    if ($IPConfig.Contains('[') -eq $FALSE -or $IPConfig.Contains(']') -eq $FALSE) {
        throw 'Invalid IP-Address format. It must match the following [ip]:port';
    }

    $StartBracket  = $IPConfig.IndexOf('[') + 1;
    $EndBracket    = $IPConfig.IndexOf(']') - 1;
    $PortDelimeter = $IPConfig.LastIndexOf(':') + 1;

    $Port = '';
    $IP   = $IPConfig.Substring($StartBracket, $EndBracket);

    if ($PortDelimeter -ne 0 -And $PortDelimeter -ge $EndBracket) {
        $Port = $IPConfig.Substring($PortDelimeter, $IPConfig.Length - $PortDelimeter);
    }

    return @{
        'address' = $IP;
        'port'    = $Port
    };
}

function Get-StringSha1()
{
    param (
        [string]$Content
    );

    $CryptoAlgorithm = New-Object System.Security.Cryptography.SHA1CryptoServiceProvider;
    $ContentHash     = [System.Text.Encoding]::UTF8.GetBytes($Content);
    $ContentBytes    = $CryptoAlgorithm.ComputeHash($ContentHash);
    $OutputHash      = '';

    foreach ($byte in $ContentBytes) {
        $OutputHash += $byte.ToString()
    }

    return $OutputHash;
}

function Get-UnitPrefixIEC()
{
    param(
        [single]$Value
    );

    If ( $Value / [math]::Pow(2, 50) -ge 1 ) {
        return 'PiB'
    } elseif ( $Value / [math]::Pow(2, 40) -ge 1 ) {
        return 'TiB'
    } elseif ( $Value / [math]::Pow(2, 30) -ge 1 ) {
        return 'GiB'
    } elseif ( $Value / [math]::Pow(2, 20) -ge 1 ) {
        return 'MiB'
    } elseif ( $Value / [math]::Pow(2, 10) -ge 1 ) {
        return 'KiB'
    } else {
        return 'B'
    }
}


function Get-UnitPrefixSI()
{
    param(
        [single]$Value
    );

    If ( $Value / [math]::Pow(10, 15) -ge 1 ) {
        return 'PB'
    } elseif ( $Value / [math]::Pow(10, 12) -ge 1 ) {
        return 'TB'
    } elseif ( $Value / [math]::Pow(10, 9) -ge 1 ) {
        return 'GB'
    } elseif ( $Value / [math]::Pow(10, 6) -ge 1 ) {
        return 'MB'
    } elseif ( $Value / [math]::Pow(10, 3) -ge 1 ) {
        return 'KB'
    } else {
        return 'B'
    }
}

function Join-WebPath()
{
    param(
        [string]$Path,
        [string]$ChildPath
    );

    if ([string]::IsNullOrEmpty($Path) -Or [string]::IsNullOrEmpty($ChildPath)) {
        return $Path;
    }

    [int]$Length = $Path.Length;
    [int]$Slash  = $Path.LastIndexOf('/') + 1;

    if ($Length -eq $Slash) {
        $Path = $Path.Substring(0, $Path.Length - 1);
    }

    if ($ChildPath[0] -eq '/') {
        return ([string]::Format('{0}{1}', $Path, $ChildPath));
    }

    return ([string]::Format('{0}/{1}', $Path, $ChildPath));
}

<#
.SYNOPSIS
   Creates a basic auth header for web requests in case the Get-Credential
   method is not supported or working properly
.DESCRIPTION
   Creates a basic auth header for web requests in case the Get-Credential
   method is not supported or working properly
.FUNCTIONALITY
   Creates a hashtable with a basic authorization header as Base64 encoded
.EXAMPLE
   PS>New-IcingaBasicAuthHeader -Username 'example_user' -Password $SecurePasswordString;
.EXAMPLE
   PS>New-IcingaBasicAuthHeader -Username 'example_user' -Password (Read-Host -Prompt 'Please enter your password' -AsSecureString);
.EXAMPLE
   PS>New-IcingaBasicAuthHeader -Username 'example_user' -Password (ConvertTo-IcingaSecureString 'my_secret_password');
.PARAMETER Username
   The user we will use to authenticate for
.PARAMETER Password
   The password for the user provided as SecureString
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaBasicAuthHeader()
{
    param(
        [string]$Username       = $null,
        [SecureString]$Password = $null
    );

    if ($null -eq $Password -or [string]::IsNullOrEmpty($Username)) {
        Write-IcingaConsoleWarning 'Please specify your username and password to continue';
        return @{};
    }

    $Credentials = [System.Convert]::ToBase64String(
        [System.Text.Encoding]::ASCII.GetBytes(
            [string]::Format(
                '{0}:{1}',
                $Username,
                (ConvertFrom-IcingaSecureString $Password)
            )
        )
    );

    return @{
        'Authorization' = [string]::Format('Basic {0}', $Credentials)
    };
}

function New-IcingaCheckCommand()
{
    param(
        [string]$Name = '',
        [array]$Arguments    = @(
            'Warning',
            'Critical',
            '[switch]NoPerfData',
            '[int]Verbose'
        )
    );

    if ([string]::IsNullOrEmpty($Name) -eq $TRUE) {
        throw 'Please specify a command name';
    }

    if ($Name -match 'Invoke' -or $Name -match 'IcingaCheck') {
        throw 'Please specify a command name only without PowerShell Cmdlet naming';
    }

    [string]$CommandName = [string]::Format(
        'Invoke-IcingaCheck{0}',
        (Get-Culture).TextInfo.ToTitleCase($Name.ToLower())
    );

    [string]$CommandFile = [string]::Format(
        'icinga-powershell-{0}.psm1',
        $Name.ToLower()
    );
    [string]$PSDFile = [string]::Format(
        'icinga-powershell-{0}.psd1',
        $Name.ToLower()
    );

    [string]$ModuleFolder = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath (
        [string]::Format('icinga-powershell-{0}', $Name.ToLower())
    );
    [string]$ScriptFile   = Join-Path -Path $ModuleFolder -ChildPath $CommandFile;
    [string]$PSDFile      = Join-Path -Path $ModuleFolder -ChildPath $PSDFile;

    if ((Test-Path $ModuleFolder) -eq $TRUE) {
        throw 'This module folder does already exist.';
    }

    if ((Test-Path $ScriptFile) -eq $TRUE) {
        throw 'This check command does already exist.';
    }

    New-Item -Path $ModuleFolder -ItemType Directory | Out-Null;

    Add-Content -Path $ScriptFile -Value '';
    Add-Content -Path $ScriptFile -Value "function $CommandName()";
    Add-Content -Path $ScriptFile -Value "{";

    if ($Arguments.Count -ne 0) {
        Add-Content -Path $ScriptFile -Value "    param(";
        [int]$index = $Arguments.Count - 1;
        foreach ($argument in $Arguments) {

            if ($argument.Contains('$') -eq $FALSE) {
                if ($argument.Contains(']') -eq $TRUE) {
                    $splittedArguments = $argument.Split(']');
                    $argument = [string]::Format('{0}]${1}', $splittedArguments[0], $splittedArguments[1]);
                } else {
                    $argument = [string]::Format('${0}', $argument);
                }
            }

            if ($index -ne 0) {
                [string]$content = [string]::Format('{0},', $argument);
            } else {
                [string]$content = [string]::Format('{0}', $argument);
            }
            Add-Content -Path $ScriptFile -Value "        $content";

            $index -= 1;
        }
        Add-Content -Path $ScriptFile -Value "    );";
    }

    Add-Content -Path $ScriptFile -Value "";
    Add-Content -Path $ScriptFile -Value '    <# Icinga Basic Check-Plugin Template. Below you will find an example structure. #>';
    Add-Content -Path $ScriptFile -Value ([string]::Format('    $CheckPackage = New-IcingaCheckPackage -Name {0}New Package{0} -OperatorAnd -Verbose $Verbose;', "'"));
    Add-Content -Path $ScriptFile -Value ([string]::Format('    $IcingaCheck  = New-IcingaCheck -Name {0}New Check{0} -Value 10 -Unit {0}%{0}', "'"));
    Add-Content -Path $ScriptFile -Value ([string]::Format('    $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;', "'"));
    Add-Content -Path $ScriptFile -Value ([string]::Format('    $CheckPackage.AddCheck($IcingaCheck);', "'"));
    Add-Content -Path $ScriptFile -Value "";
    Add-Content -Path $ScriptFile -Value ([string]::Format('    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);', "'"));

    Add-Content -Path $ScriptFile -Value "}";

    Write-IcingaConsoleNotice ([string]::Format('The Check-Command "{0}" was successfully added.', $CommandName));

    # Try to open the default Editor for the new Cmdlet
    $DefaultEditor = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.psm1\OpenWithList' -Name a).a;
    $DefaultEditor = $DefaultEditor.Replace('.exe', '');

    New-ModuleManifest `
        -Path $PSDFile `
        -ModuleToProcess $CommandFile `
        -RequiredModules @('icinga-powershell-framework') `
        -FunctionsToExport @('*') `
        -CmdletsToExport @('*') `
        -VariablesToExport '*' | Out-Null;

    Unblock-IcingaPowerShellFiles -Path $ModuleFolder;

    Import-Module $ScriptFile -Global;

    if ([string]::IsNullOrEmpty($DefaultEditor) -eq $FALSE -And ($null -eq (Get-Command $DefaultEditor -ErrorAction SilentlyContinue)) -And ((Test-Path $DefaultEditor) -eq $FALSE)) {
        Write-IcingaConsoleWarning 'No default editor for .psm1 files found. Specify a default editor to automatically open the newly generated check plugin.';
        return;
    }

    & $DefaultEditor "$ScriptFile";
}

function New-IcingaNewLine()
{
    return "`r`n";
}

function New-IcingaTemporaryDirectory()
{
    [string]$TmpDirectory  = '';
    [string]$DirectoryPath = '';

    while ($TRUE) {
        $TmpDirectory  = [string]::Format('tmp_icinga{0}.d', (Get-Random));
        $DirectoryPath = Join-Path $Env:TMP -ChildPath $TmpDirectory;

        if ((Test-Path $DirectoryPath) -eq $FALSE) {
            break;
        }
    }

    return (New-Item -Path $DirectoryPath -ItemType Directory);
}

function New-IcingaTemporaryFile()
{
    [string]$TmpFile  = '';
    [string]$FilePath = '';

    while ($TRUE) {
        $TmpFile  = [string]::Format('tmp_icinga{0}.tmp', (Get-Random));
        $FilePath = Join-Path $Env:TMP -ChildPath $TmpFile;

        if ((Test-Path $FilePath) -eq $FALSE) {
            break;
        }
    }

    return (New-Item -Path $FilePath -ItemType File);
}

function New-StringTree()
{
    param(
        [int]$Spacing
    )

    if ($Spacing -eq 0) {
        return '';
    }

    [string]$spaces = '\_ ';

    while ($Spacing -gt 1) {
        $Spacing -= 1;
        $spaces = '   ' + $spaces;
    }

    return $spaces;
}

function Pop-IcingaArrayListItem()
{
    param(
        [System.Collections.ArrayList]$Array
    );

    if ($null -eq $Array) {
        return $null;
    }

    if ($Array.Count -eq 0) {
        return $null;
    }

    $Content = $Array[0];
    $Array.RemoveAt(0);

    return $Content;
}

<#
.SYNOPSIS
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.DESCRIPTION
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.FUNCTIONALITY
   Reads content of a file in read-only mode, ensuring no data corruption is happening
.EXAMPLE
   PS>Read-IcingaFileContent -File 'config.json';
.OUTPUTS
   System.Object
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Read-IcingaFileContent()
{
    param (
        [string]$File
    );

    if ((Test-Path $File) -eq $FALSE) {
        return $null;
    }

    [System.IO.FileStream]$FileStream = [System.IO.File]::Open(
        $File,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    );

    $ReadArray    = New-Object Byte[] $FileStream.Length;
    $UTF8Encoding = New-Object System.Text.UTF8Encoding $TRUE;
    $FileContent  = '';

    while ($FileStream.Read($ReadArray, 0 , $ReadArray.Length)) {
        $FileContent = [System.String]::Concat($FileContent, $UTF8Encoding.GetString($ReadArray));
    }

    $FileStream.Dispose();

    return $FileContent;
}

function Remove-IcingaDirectorSelfServiceKey()
{
    $Path  = 'IcingaDirector.SelfService.ApiKey';
    $Value = Get-IcingaPowerShellConfig $Path;
    if ($null -ne $Value) {
        Remove-IcingaPowerShellConfig 'IcingaDirector.SelfService.ApiKey';
        $Value = Get-IcingaPowerShellConfig $Path;
        if ($null -eq $Value) {
            Write-IcingaConsoleNotice 'Icinga Director Self-Service Api key was successfully removed. Please dont forget to drop it within the Icinga Director as well';
        }
    } else {
        Write-IcingaConsoleWarning 'There is no Self-Service Api key configured on this system';
    }
}

function Remove-IcingaHashtableItem()
{
    param(
        $Hashtable,
        $Key
    );

    if ($null -eq $Hashtable) {
        return;
    }

    if ($Hashtable.ContainsKey($Key)) {
        $Hashtable.Remove($Key);
    }
}

<#
.SYNOPSIS
   Sets nummeric values to be negative
.DESCRIPTION
   This module sets a numeric value to be negative.
   e.g 12 to -12

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> Set-NumericNegative 32
   -32
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>


function Set-NumericNegative()
{
    param(
        $Value
    );

    $Value = $Value * -1;

    return $Value;
}
function Show-IcingaDirecorSelfServiceKey()
{
    $Path  = 'IcingaDirector.SelfService.ApiKey';
    $Value = Get-IcingaPowerShellConfig $Path;

    if ($null -ne $Value) {
        Write-IcingaConsoleNotice ([string]::Format('Self-Service Key: "{0}"', $Value));
    } else {
        Write-IcingaConsoleWarning 'There is no Self-Service Api key configured on this system';
    }
}

function Show-IcingaEventLogAnalysis()
{
    param (
        [string]$LogName         = 'Application'
    );

    Write-IcingaConsoleNotice 'Analysing EventLog "{0}"...' -Objects $LogName;

    Start-IcingaTimer 'EventLog Analyser';

    try {
        [array]$BasicLogArray = Get-WinEvent -ListLog $LogName -ErrorAction Stop;
        $BasicLogData         = $BasicLogArray[0];
    } catch {
        Write-IcingaConsoleError 'Failed to fetch data for EventLog "{0}". Probably this log does not exist.' -Objects $LogName;
        return;
    }

    Write-IcingaConsoleNotice 'Logging Mode: {0}' -Objects $BasicLogData.LogMode;
    Write-IcingaConsoleNotice 'Maximum Size: {0} GB' -Objects ([math]::Round((Convert-Bytes -Value $BasicLogData.MaximumSizeInBytes -Unit 'GB').value, 2));
    Write-IcingaConsoleNotice 'Current Entries: {0}' -Objects $BasicLogData.RecordCount;

    [hashtable]$LogAnalysis = @{
        'Day'    = @{
            'Entries' = @{ };
            'Count'   = 0;
            'Average' = 0;
            'Maximum' = 0;
        };
        'Hour'   = @{
            'Entries' = @{ };
            'Count'   = 0;
            'Average' = 0;
            'Maximum' = 0;
        };
        'Minute' = @{
            'Entries' = @{ };
            'Count'   = 0;
            'Average' = 0;
            'Maximum' = 0;
        };
    };

    $LogData             = Get-WinEvent -LogName $LogName;
    [string]$NewestEntry = $null;
    [string]$OldestEntry = $null;

    foreach ($entry in $LogData) {
        [string]$DayOfLogging = $entry.TimeCreated.ToString('yyyy\/MM\/dd');
        [string]$HourOfLogging = $entry.TimeCreated.ToString('yyyy\/MM\/dd-HH');
        [string]$MinuteOfLogging = $entry.TimeCreated.ToString('yyyy\/MM\/dd-HH-mm');

        $OldestEntry = $entry.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss');

        if ([string]::IsNullOrEmpty($NewestEntry)) {
            $NewestEntry = $OldestEntry;
        }

        if ($LogAnalysis.Day.Entries.ContainsKey($DayOfLogging) -eq $FALSE) {
            $LogAnalysis.Day.Entries.Add($DayOfLogging, 0);
        }

        if ($LogAnalysis.Hour.Entries.ContainsKey($HourOfLogging) -eq $FALSE) {
            $LogAnalysis.Hour.Entries.Add($HourOfLogging, 0);
        }

        if ($LogAnalysis.Minute.Entries.ContainsKey($MinuteOfLogging) -eq $FALSE) {
            $LogAnalysis.Minute.Entries.Add($MinuteOfLogging, 0);
        }

        $LogAnalysis.Day.Entries[$DayOfLogging]       += 1;
        $LogAnalysis.Hour.Entries[$HourOfLogging]     += 1;
        $LogAnalysis.Minute.Entries[$MinuteOfLogging] += 1;

        $LogAnalysis.Day.Count    += 1;
        $LogAnalysis.Hour.Count   += 1;
        $LogAnalysis.Minute.Count += 1;

        $LogAnalysis.Day.Average    = [math]::Ceiling($LogAnalysis.Day.Count / $LogAnalysis.Day.Entries.Count);
        $LogAnalysis.Hour.Average   = [math]::Ceiling($LogAnalysis.Hour.Count / $LogAnalysis.Hour.Entries.Count);
        $LogAnalysis.Minute.Average = [math]::Ceiling($LogAnalysis.Minute.Count / $LogAnalysis.Minute.Entries.Count);
    }

    foreach ($value in $LogAnalysis.Day.Entries.Values) {
        $LogAnalysis.Day.Maximum = Get-IcingaValue -Value $value -Compare $LogAnalysis.Day.Maximum -Maximum;
    }
    foreach ($value in $LogAnalysis.Hour.Entries.Values) {
        $LogAnalysis.Hour.Maximum = Get-IcingaValue -Value $value -Compare $LogAnalysis.Hour.Maximum -Maximum;
    }
    foreach ($value in $LogAnalysis.Minute.Entries.Values) {
        $LogAnalysis.Minute.Maximum = Get-IcingaValue -Value $value -Compare $LogAnalysis.Minute.Maximum -Maximum;
    }
    Stop-IcingaTimer 'EventLog Analyser';

    Write-IcingaConsoleNotice 'Average Logs per Day: {0}' -Objects $LogAnalysis.Day.Average;
    Write-IcingaConsoleNotice 'Average Logs per Hour: {0}' -Objects $LogAnalysis.Hour.Average;
    Write-IcingaConsoleNotice 'Average Logs per Minute: {0}' -Objects $LogAnalysis.Minute.Average;
    Write-IcingaConsoleNotice 'Maximum Logs per Day: {0}' -Objects $LogAnalysis.Day.Maximum;
    Write-IcingaConsoleNotice 'Maximum Logs per Hour: {0}' -Objects $LogAnalysis.Hour.Maximum;
    Write-IcingaConsoleNotice 'Maximum Logs per Minute: {0}' -Objects $LogAnalysis.Minute.Maximum;
    Write-IcingaConsoleNotice 'Newest entry timestamp: {0}' -Objects $NewestEntry;
    Write-IcingaConsoleNotice 'Oldest entry timestamp: {0}' -Objects $OldestEntry;
    Write-IcingaConsoleNotice 'Analysing Time: {0}s' -Objects ([math]::Round((Get-IcingaTimer 'EventLog Analyser').Elapsed.TotalSeconds, 2));
}

function Split-IcingaCheckCommandArgs()
{
    [array]$arguments = @();
    foreach ($arg in $args) {
        $arguments += $arg;
    }

    return $arguments;
}

<#
.SYNOPSIS
    Splits a username containing a domain into a hashtable to easily use both values independently.
    If no domain is specified the hostname will used as "local domain"
.DESCRIPTION
    Splits a username containing a domain into a hashtable to easily use both values independently.
    If no domain is specified the hostname will used as "local domain"
.PARAMETER User
    A user object either containing only the user or domain information
.EXAMPLE
    PS>Split-IcingaUserDomain -User 'icinga';

    Name                           Value
    ----                           -----
    User                           icinga
    Domain                         icinga-win
.EXAMPLE
    PS>Split-IcingaUserDomain -User 'ICINGADOMAIN\icinga';

    Name                           Value
    ----                           -----
    User                           icinga
    Domain                         ICINGADOMAIN
.EXAMPLE
    PS>Split-IcingaUserDomain -User 'icinga@ICINGADOMAIN';

    Name                           Value
    ----                           -----
    User                           icinga
    Domain                         ICINGADOMAIN
.EXAMPLE
    PS>Split-IcingaUserDomain -User '.\icinga';

    Name                           Value
    ----                           -----
    User                           icinga
    Domain                         icinga-win
.INPUTS
    System.String
.OUTPUTS
    System.Hashtable
#>

function Split-IcingaUserDomain()
{
    param (
        $User
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError 'Please enter a valid username';
        return '';
    }

    [array]$UserData  = @();

    if ($User.Contains('\')) {
        $UserData = $User.Split('\');
    } elseif ($User.Contains('@')) {
        [array]$Split = $User.Split('@');
        $UserData = @(
            $Split[1],
            $Split[0]
        );
    } else {
        $UserData = @(
            (Get-IcingaNetbiosName),
            $User
        );
    }

    if ([string]::IsNullOrEmpty($UserData[0]) -Or $UserData[0] -eq '.' -Or $UserData[0] -eq 'BUILTIN') {
        $UserData[0] = (Get-IcingaNetbiosName);
    }

    return @{
        'Domain' = $UserData[0];
        'User'   = $UserData[1];
    };
}

function Start-IcingaProcess()
{
    param(
        [string]$Executable,
        [string]$Arguments,
        [switch]$FlushNewLines
    );

    $processData = New-Object System.Diagnostics.ProcessStartInfo;
    $processData.FileName = $Executable;
    $processData.RedirectStandardError = $true;
    $processData.RedirectStandardOutput = $true;
    $processData.UseShellExecute = $false;
    $processData.Arguments = $Arguments;

    $process = New-Object System.Diagnostics.Process;
    $process.StartInfo = $processData;
    $process.Start() | Out-Null;

    $stdout = $process.StandardOutput.ReadToEnd();
    $stderr = $process.StandardError.ReadToEnd();
    $process.WaitForExit();

    if ($flushNewLines) {
        $stdout = $stdout.Replace("`n", '').Replace("`r", '');
        $stderr = $stderr.Replace("`n", '').Replace("`r", '');
    } else {
        if ($stdout.Contains("`n")) {
            $stdout = $stdout.Substring(0, $stdout.LastIndexOf("`n"));
        }
    }
    return @{
        'Message'  = $stdout;
        'Error'    = $stderr;
        'ExitCode' = $process.ExitCode;
    };
}

function Test-AdministrativeShell()
{
    $WindowsPrincipcal = New-Object System.Security.Principal.WindowsPrincipal(
        [System.Security.Principal.WindowsIdentity]::GetCurrent()
    );

    if ($WindowsPrincipcal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $TRUE;
    }
    return $FALSE;
}

function Test-IcingaAddTypeExist()
{
    param (
        [string]$Type = $null
    );

    if ([string]::IsNullOrEmpty($Type)) {
        return $FALSE;
    }

    foreach ($entry in [System.AppDomain]::CurrentDomain.GetAssemblies()) {
        if ($entry.GetTypes() -Match $Type) {
            return $TRUE;
        }
    }

    return $FALSE;
}

<#
.SYNOPSIS
    Tests for binary operators with -band if a specific Value contains binary
    operators within a Compare array. In addition you can use a Namespace
    argument to provide a hashtable in which your key values are included to 
    reduce the amount of code to write
.DESCRIPTION
    Tests for binary operators with -band if a specific Value contains binary
    operators within a Compare array. In addition you can use a Namespace
    argument to provide a hashtable in which your key values are included to 
    reduce the amount of code to write
.EXAMPLE
    PS>Test-IcingaBinaryOperator -Value Ok -Compare EmptyClass, InvalidNameSpace, PermissionError, Ok -Namespace $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo;
    True
.EXAMPLE
    PS>Test-IcingaBinaryOperator -Value 2 -Compare 1,4,8,16,32,64,128,256;
    False
.PARAMETER Value
    The value to check if it is included within the compare argument. This can either be
    the name of the key for a Namespace or a numeric value
.PARAMETER Compare
    An array of values to compare for and check if the value matches with the -band operator
    The array can either contain the key names of your Namespace, numeric values or both cominbed
.PARAMETER Namespace
    A hashtable object containing values you want to compare for. By providing a hashtable here
    you can use the key names for each value on the Value and Compare argument
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaBinaryOperator()
{
    param (
        $Value                = $null,
        [array]$Compare       = @(),
        [hashtable]$Namespace = $null
    );

    [long]$BinaryValue = 0;

    foreach ($entry in $Compare) {
        if ($null -ne $Namespace) {
            if ($Namespace.ContainsKey($entry)) {
                $BinaryValue += $Namespace[$entry];
            } else {
                if (Test-Numeric $entry) {
                    $BinaryValue += $entry;
                }
            }
        } else {
            $BinaryValue += $entry;
        }
    }

    if ($null -ne $Value -and (Test-Numeric $Value)) {
        if (($Value -band $BinaryValue) -eq $Value) {
            return $TRUE;
        }
    }

    if ($null -ne $Namespace -and $Namespace.ContainsKey($Value)) {
        if (($Namespace[$Value] -band $BinaryValue) -eq $Namespace[$Value]) {
            return $TRUE;
        }
    }    

    return $FALSE;
}

function Test-IcingaDecimal()
{
    param (
        $Value = $null
    );

    [hashtable]$RetValue = @{
        'Value'   = $Value;
        'Decimal' = $FALSE;
    };

    if ($null -eq $Value -Or [string]::IsNullOrEmpty($Value)) {
        return $RetValue;
    }

    $TmpValue = ([string]$Value).Replace(',', '.');

    if ((Test-Numeric $TmpValue) -eq $FALSE) {
        return $RetValue;
    }

    $RetValue.Value   = [decimal]$TmpValue;
    $RetValue.Decimal = $TRUE;

    return $RetValue;
}

function Test-IcingaFunction()
{
    param(
        [string]$Name
    );

    if ([string]::IsNullOrEmpty($Name)) {
        return $FALSE;
    }

    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        return $TRUE;
    }

    return $FALSE;
}

<#
.SYNOPSIS
   Tests whether a value is numeric
.DESCRIPTION
   This module tests whether a value is numeric

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> Test-Numeric 32
   True
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>
function Test-Numeric ($number) {
    return $number -Match "^-?[0-9]\d*(\.\d+)?$";
}

function Test-PSCustomObjectMember()
{
    param(
        $PSObject,
        $Name
    );

    if ($null -eq $PSObject) {
        return $FALSE;
    }

    return ([bool]($PSObject.PSobject.Properties.Name -eq $Name));
}

function Write-IcingaConsoleHeader()
{
    param (
        [array]$HeaderLines = @()
    );

    [array]$ParsedHeaders  = @();
    [int]$MaxHeaderLength  = 0;
    [int]$TableHeaderCount = 0;
    [array]$TableHeader    = @();

    Import-LocalizedData `
        -BaseDirectory (Get-IcingaFrameworkRootPath) `
        -FileName 'icinga-powershell-framework.psd1' `
        -BindingVariable IcingaFrameworkData;

    foreach ($line in $HeaderLines) {
        $line = $line.Replace('$FrameworkVersion', $IcingaFrameworkData.PrivateData.Version);
        $line = $line.Replace('$Copyright', $IcingaFrameworkData.Copyright);
        $line = $line.Replace('$UserDomain', $env:USERDOMAIN);
        $line = $line.Replace('$Username', $env:USERNAME);

        $ParsedHeaders += $line;
    }

    foreach ($line in $ParsedHeaders) {
        if ($MaxHeaderLength -lt $line.Length) {
            $MaxHeaderLength = $line.Length
        }
    }

    $TableHeaderCount = $MaxHeaderLength + 6;

    while ($TableHeaderCount -ne 0) {
        $TableHeader += '*';
        $TableHeaderCount -= 1;
    }

    $TableHeaderCount = $MaxHeaderLength + 6;

    Write-IcingaConsolePlain ([string]::Join('', $TableHeader));

    foreach ($line in $ParsedHeaders) {
        [array]$LeftSpacing = @();
        [array]$RightSpacing = @();

        if ($line.Length -lt $MaxHeaderLength) {
            $Spacing = [math]::floor(($MaxHeaderLength - $line.Length) / 2);

            while ($Spacing -gt 0) {
                $LeftSpacing  += ' ';
                $RightSpacing += ' ';
                $Spacing      -= 1;
            }

            if ($TableHeaderCount -gt ($line.Length + $LeftSpacing.Count + $RightSpacing.Count + 6)) {
                [int]$RightOffset = $TableHeaderCount - ($line.Length + $LeftSpacing.Count + $RightSpacing.Count + 6)
                while ($RightOffset -gt 0) {
                    $RightSpacing += ' ';
                    $RightOffset  -= 1;
                }
            }
        }
        Write-IcingaConsolePlain -Message '**{1} {0} {2}**' -Objects $line, ([string]::Join('', $LeftSpacing)), ([string]::Join('', $RightSpacing));
    }

    Write-IcingaConsolePlain ([string]::Join('', $TableHeader));
}

function Get-IcingaBackgroundDaemons()
{
    $Daemons = Get-IcingaPowerShellConfig -Path 'BackgroundDaemon.EnabledDaemons';

    if ($null -eq $Daemons) {
        return $null;
    }

    [hashtable]$Output = @{};

    foreach ($daemon in $Daemons.PSObject.Properties) {
        $Arguments = @{ };

        foreach ($argument in $daemon.Value.Arguments.PSObject.Properties) {
            $Arguments.Add($argument.Name, $argument.Value);
        }

        $Output.Add($daemon.Name, $Arguments);
    }

    return $Output;
}

function Register-IcingaBackgroundDaemon()
{
    param(
        [string]$Command,
        [hashtable]$Arguments
    );

    if ([string]::IsNullOrEmpty($Command)) {
        throw 'Please specify a Cmdlet to run as Background Daemon';
    }

    if (-Not (Test-IcingaFunction $Command)) {
        throw ([string]::Format('The Cmdlet "{0}" is not available in your session. Please restart the session and try again or verify your input', $Command));
    }

    $Path = [string]::Format('BackgroundDaemon.EnabledDaemons.{0}', $Command);

    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Command', $Path)) -Value $Command;
    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Arguments', $Path)) -Value $Arguments;

    Write-IcingaConsoleNotice ([string]::Format('Background daemon Cmdlet "{0}" has been configured', $Command));
}

function Start-IcingaPowerShellDaemon()
{
    param(
        [switch]$RunAsService
    );

    $ScriptBlock = {
        param($IcingaDaemonData);

        Use-Icinga -LibOnly -Daemon;

        try {
            $EnabledDaemons = Get-IcingaBackgroundDaemons;

            foreach ($daemon in $EnabledDaemons.Keys) {
                if (-Not (Test-IcingaFunction $daemon)) {
                    continue;
                }

                $daemonArgs = $EnabledDaemons[$daemon];
                &$daemon @daemonArgs;
            }
        } catch {
            # Todo: Add exception handling
        }

        while ($TRUE) {
            Start-Sleep -Seconds 1;
        }
    };

    $global:IcingaDaemonData.FrameworkRunningAsDaemon = $TRUE;
    $global:IcingaDaemonData.Add('BackgroundDaemon', [hashtable]::Synchronized(@{}));
    # Todo: Add config for active background tasks. Set it to 20 for the moment
    $global:IcingaDaemonData.IcingaThreadPool.Add('BackgroundPool', (New-IcingaThreadPool -MaxInstances 20));
    $global:IcingaDaemonData.Add('Config', (Read-IcingaPowerShellConfig));

    New-IcingaThreadInstance -Name "Icinga_PowerShell_Background_Daemon" -ThreadPool $IcingaDaemonData.IcingaThreadPool.BackgroundPool -ScriptBlock $ScriptBlock -Arguments @( $global:IcingaDaemonData ) -Start;

    if ($RunAsService) {
        while ($TRUE) {
            Start-Sleep -Seconds 100;
        }
    }
}

function Unregister-IcingaBackgroundDaemon()
{
    param(
        [string]$BackgroundDaemon,
        [hashtable]$Arguments
    );

    if ([string]::IsNullOrEmpty($BackgroundDaemon)) {
        throw 'Please specify a Cmdlet to remove from running as Background Daemon';
    }

    $Path = [string]::Format('BackgroundDaemon.EnabledDaemons.{0}', $BackgroundDaemon);

    Remove-IcingaPowerShellConfig -Path $Path;

    Write-IcingaConsoleNotice 'Background daemon has been removed';
}

function Get-IcingaRegisteredServiceChecks()
{
    $Services = Get-IcingaPowerShellConfig -Path 'BackgroundDaemon.RegisteredServices';
    [hashtable]$Output = @{};

    foreach ($service in $Services.PSObject.Properties) {
        $Content = @{
            'Id'           = $service.Name;
            'CheckCommand' = $service.Value.CheckCommand;
            'Arguments'    = $service.Value.Arguments;
            'Interval'     = $service.Value.Interval;
            'TimeIndexes'  = $service.Value.TimeIndexes;
        };

        $Output.Add($service.Name, $Content);
    }

    return $Output;
}

function Register-IcingaServiceCheck()
{
    param(
        [string]$CheckCommand,
        [hashtable]$Arguments,
        [int]$Interval        = 60,
        [array]$TimeIndexes   = @()
    );

    if ([string]::IsNullOrEmpty($CheckCommand)) {
        throw 'Please specify a CheckCommand';
    }

    $Hash = Get-StringSha1 ([string]::Format('{0} {1}', $CheckCommand, ($Arguments | Out-String)));
    $Path = [string]::Format('BackgroundDaemon.RegisteredServices.{0}', $Hash);

    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.CheckCommand', $Path)) -Value $CheckCommand;
    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Arguments', $Path)) -Value $Arguments;
    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Interval', $Path)) -Value $Interval;
    Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.TimeIndexes', $Path)) -Value $TimeIndexes;

    Write-IcingaConsoleNotice 'Icinga Service Check has been configured';
}

function Set-IcingaRegisteredServiceCheckConfig()
{
    param(
        [string]$ServiceId,
        [hashtable]$Arguments = $null,
        $Interval             = $null,
        [array]$TimeIndexes   = $null
    );

    $Services = Get-IcingaRegisteredServiceChecks;

    if ($Services.ContainsKey($ServiceId) -eq $FALSE) {
        Write-IcingaConsoleError 'Service Id was not found';
        return;
    }

    [bool]$Modified = $FALSE;
    $Path = [string]::Format('BackgroundDaemon.RegisteredServices.{0}', $ServiceId);

    if ($null -ne $Arguments) {
        Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Arguments', $Path)) -Value $Arguments;
        $Modified = $TRUE;
    }
    if ($null -ne $Interval) {
        Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.Interval', $Path)) -Value $Interval;
        $Modified = $TRUE;
    }
    if ($null -ne $TimeIndexes) {
        Set-IcingaPowerShellConfig -Path ([string]::Format('{0}.TimeIndexes', $Path)) -Value $TimeIndexes;
        $Modified = $TRUE;
    }

    if ($Modified) {
        Write-IcingaConsoleNotice 'Service configuration was successfully updated';
    } else {
        Write-IcingaConsoleWarning 'No arguments were specified to update the service configuration';
    }
}

function Show-IcingaRegisteredServiceChecks()
{
    $Services = Get-IcingaRegisteredServiceChecks;

    foreach ($service in $Services.Keys) {
        Write-IcingaConsoleNotice ([string]::Format('Service Id: {0}', $service));
        Write-IcingaConsoleNotice (
            $Services[$service] | Out-String
        );
    }
}

<#
.SYNOPSIS
   A background daemon executing registered service checks in the background to fetch
   metrics for certain checks over time. Time frames are configurable individual
.DESCRIPTION
   This background daemon will execute checks registered with "Register-IcingaServiceCheck"
   for the given time interval and store the collected metrics for a defined period of time
   inside a JSON file. Check values collected by this daemon are then automatically added
   to regular check executions for additional performance metrics.

   Example: Register-IcingaServiceCheck -CheckCommand 'Invoke-IcingaCheckCPU' -Interval 30 -TimeIndexes 1,3,5,15;

   This will execute the CPU check every 30 seconds and calculate the average of 1, 3, 5 and 15 minutes

   More Information on
   https://icinga.com/docs/icinga-for-windows/latest/doc/service/02-Register-Daemons/
   https://icinga.com/docs/icinga-for-windows/latest/doc/service/10-Register-Service-Checks/
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function Start-IcingaServiceCheckDaemon()
{
    $ScriptBlock = {
        param($IcingaDaemonData);

        Use-Icinga -LibOnly -Daemon;

        $IcingaDaemonData.IcingaThreadPool.Add('ServiceCheckPool', (New-IcingaThreadPool -MaxInstances (Get-IcingaConfigTreeCount -Path 'BackgroundDaemon.RegisteredServices')));

        while ($TRUE) {

            $RegisteredServices = Get-IcingaRegisteredServiceChecks;

            foreach ($service in $RegisteredServices.Keys) {
                [string]$ThreadName = [string]::Format('Icinga_Background_Service_Check_{0}', $service);
                if ((Test-IcingaThread $ThreadName)) {
                    continue;
                }

                [hashtable]$ServiceArgs = @{ };

                if ($null -ne $RegisteredServices[$service].Arguments) {
                    foreach ($property in $RegisteredServices[$service].Arguments.PSObject.Properties) {
                        if ($ServiceArgs.ContainsKey($property.Name)) {
                            continue;
                        }

                        $ServiceArgs.Add($property.Name, $property.Value)
                    }
                }

                Start-IcingaServiceCheckTask -CheckId $service -CheckCommand $RegisteredServices[$service].CheckCommand -Arguments $ServiceArgs -Interval $RegisteredServices[$service].Interval -TimeIndexes $RegisteredServices[$service].TimeIndexes;
            }
            Start-Sleep -Seconds 1;
        }
    };

    New-IcingaThreadInstance -Name "Icinga_PowerShell_ServiceCheck_Scheduler" -ThreadPool $IcingaDaemonData.IcingaThreadPool.BackgroundPool -ScriptBlock $ScriptBlock -Arguments @( $global:IcingaDaemonData ) -Start;
}

function Start-IcingaServiceCheckTask()
{
    param(
        $CheckId,
        $CheckCommand,
        $Arguments,
        $Interval,
        $TimeIndexes
    );

    [string]$ThreadName = [string]::Format('Icinga_Background_Service_Check_{0}', $CheckId);

    $ScriptBlock = {
        param($IcingaDaemonData, $CheckCommand, $Arguments, $Interval, $TimeIndexes, $CheckId);

        Use-Icinga -LibOnly -Daemon;
        $PassedTime   = 0;
        $SortedResult = $null;
        $PerfCache    = @{ };
        $AverageCalc  = @{ };
        [int]$MaxTime = 0;

        # Initialise some global variables we use to actually store check result data from
        # plugins properly. This is doable from each thread instance as this part isn't
        # shared between daemons
        New-IcingaCheckSchedulerEnvironment;

        foreach ($index in $TimeIndexes) {
            # Only allow numeric index values
            if ((Test-Numeric $index) -eq $FALSE) {
                continue;
            }
            if ($AverageCalc.ContainsKey([string]$index) -eq $FALSE) {
                $AverageCalc.Add(
                    [string]$index,
                    @{
                        'Interval' = ([int]$index);
                        'Time'     = ([int]$index * 60);
                        'Sum'      = 0;
                        'Count'    = 0;
                    }
                );
            }
            if ($MaxTime -le [int]$index) {
                $MaxTime = [int]$index;
            }
        }

        [int]$MaxTimeInSeconds = $MaxTime * 60;

        if (-Not ($global:Icinga.CheckData.ContainsKey($CheckCommand))) {
            $global:Icinga.CheckData.Add($CheckCommand, @{ });
            $global:Icinga.CheckData[$CheckCommand].Add('results', @{ });
            $global:Icinga.CheckData[$CheckCommand].Add('average', @{ });
        }

        $LoadedCacheData = Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName $CheckCommand;

        if ($null -ne $LoadedCacheData) {
            foreach ($entry in $LoadedCacheData.PSObject.Properties) {
                $global:Icinga.CheckData[$CheckCommand]['results'].Add(
                    $entry.name,
                    @{ }
                );
                foreach ($item in $entry.Value.PSObject.Properties) {
                    $global:Icinga.CheckData[$CheckCommand]['results'][$entry.name].Add(
                        $item.Name,
                        $item.Value
                    );
                }
            }
        }

        while ($TRUE) {
            if ($PassedTime -ge $Interval) {
                try {
                    & $CheckCommand @Arguments | Out-Null;
                } catch {
                    # Just for debugging. Not required in production or usable at all
                    $ErrMsg = $_.Exception.Message;
                    Write-IcingaConsoleError $ErrMsg;
                }

                try {
                    $UnixTime = Get-IcingaUnixTime;

                    foreach ($result in $global:Icinga.CheckData[$CheckCommand]['results'].Keys) {
                        [string]$HashIndex = $result;
                        $SortedResult = $global:Icinga.CheckData[$CheckCommand]['results'][$HashIndex].GetEnumerator() | Sort-Object name -Descending;
                        Add-IcingaHashtableItem -Hashtable $PerfCache -Key $HashIndex -Value @{ } | Out-Null;

                        foreach ($timeEntry in $SortedResult) {

                            if ((Test-Numeric $timeEntry.Value) -eq $FALSE) {
                                continue;
                            }

                            foreach ($calc in $AverageCalc.Keys) {
                                if (($UnixTime - $AverageCalc[$calc].Time) -le [int]$timeEntry.Key) {
                                    $AverageCalc[$calc].Sum   += $timeEntry.Value;
                                    $AverageCalc[$calc].Count += 1;
                                }
                            }
                            if (($UnixTime - $MaxTimeInSeconds) -le [int]$timeEntry.Key) {
                                Add-IcingaHashtableItem -Hashtable $PerfCache[$HashIndex] -Key ([string]$timeEntry.Key) -Value ([string]$timeEntry.Value) | Out-Null;
                            }
                        }

                        foreach ($calc in $AverageCalc.Keys) {
                            if ($AverageCalc[$calc].Count -ne 0) {
                                $AverageValue         = ($AverageCalc[$calc].Sum / $AverageCalc[$calc].Count);
                                [string]$MetricName   = Format-IcingaPerfDataLabel (
                                    [string]::Format('{0}_{1}', $HashIndex, $AverageCalc[$calc].Interval)
                                );

                                Add-IcingaHashtableItem `
                                    -Hashtable $global:Icinga.CheckData[$CheckCommand]['average'] `
                                    -Key $MetricName -Value $AverageValue -Override | Out-Null;
                            }

                            $AverageCalc[$calc].Sum   = 0;
                            $AverageCalc[$calc].Count = 0;
                        }
                    }

                    # Flush data we no longer require in our cache to free memory
                    [array]$CheckStores = $global:Icinga.CheckData[$CheckCommand]['results'].Keys;

                    foreach ($CheckStore in $CheckStores) {
                        [string]$CheckKey       = $CheckStore;
                        [array]$CheckTimeStamps = $global:Icinga.CheckData[$CheckCommand]['results'][$CheckKey].Keys;

                        foreach ($TimeSample in $CheckTimeStamps) {
                            if (($UnixTime - $MaxTimeInSeconds) -gt [int]$TimeSample) {
                                Remove-IcingaHashtableItem -Hashtable $global:Icinga.CheckData[$CheckCommand]['results'][$CheckKey] -Key ([string]$TimeSample);
                            }
                        }
                    }

                    Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult' -KeyName $CheckCommand -Value $global:Icinga.CheckData[$CheckCommand]['average'];
                    # Write collected metrics to disk in case we reload the daemon. We will load them back into the module after reload then
                    Set-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult_store' -KeyName $CheckCommand -Value $PerfCache;
                } catch {
                    # Just for debugging. Not required in production or usable at all
                    $ErrMsg = $_.Exception.Message;
                    Write-IcingaConsoleError 'Failed to handle check result processing: {0}' -Objects $ErrMsg;
                }

                # Cleanup the error stack and remove not required data
                $Error.Clear();

                # Always ensure our check data is cleared regardless of possible
                # exceptions which might occur
                Get-IcingaCheckSchedulerPerfData | Out-Null;
                Get-IcingaCheckSchedulerPluginOutput | Out-Null;

                $PassedTime   = 0;
                $SortedResult.Clear();
                $PerfCache.Clear();
            }

            $PassedTime += 1;
            Start-Sleep -Seconds 1;
            # Force PowerShell to call the garbage collector to free memory
            [System.GC]::Collect();
        }
    };

    New-IcingaThreadInstance -Name $ThreadName -ThreadPool $IcingaDaemonData.IcingaThreadPool.ServiceCheckPool -ScriptBlock $ScriptBlock -Arguments @( $global:IcingaDaemonData, $CheckCommand, $Arguments, $Interval, $TimeIndexes, $CheckId ) -Start;
}

function Unregister-IcingaServiceCheck()
{
    param(
        [string]$ServiceId
    );

    if ([string]::IsNullOrEmpty($ServiceId)) {
        throw 'Please specify a Service Id';
    }

    $Path = [string]::Format('BackgroundDaemon.RegisteredServices.{0}', $ServiceId);

    Remove-IcingaPowerShellConfig -Path $Path;

    Write-IcingaConsolePlain 'Icinga Service Check has been configured';
}

function Get-IcingaHelpThresholds()
{
    param (
        $Value,
        $Warning,
        $Critical
    );

    if ([string]::IsNullOrEmpty($Value) -eq $FALSE) {
        $ExampleCheck = New-IcingaCheck -Name 'Example' -Value $Value;
        $ExampleCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;

        return (New-IcingaCheckResult -Check $ExampleCheck -Compile);
    }

    Write-IcingaConsolePlain
    '
    Icinga is providing a basic handling for thresholds to make it easier to check if certain values of metrics should rise an event or not.
    By default, you are always fine to specify simple numeric values for thresholds throughout the entire Check-Plugins.

    #####################

    -Warning  60
    -Critical 90

    This example will always raise an event, in case the value is below 0. On the other hand, it will raise
    Warning, if the value is above 60 and
    Critical, if the value is above 90.

    Example: Get-IcingaHelpThresholds -Value 40 -Warning 60 -Critical 90; #This will return Ok
             Get-IcingaHelpThresholds -Value 70 -Warning 60 -Critical 90; #This will return Warning

    There is however a smart way available, to check for ranges of metric values which are explained below.

    #####################

    Between Range
    -Warning "30:50"

    This configuration will check if a value is within the specified range. In this example it would return Ok, whenver the
    value is >= 30 and <= 50

    Example: Get-IcingaHelpThresholds -Value 40 -Warning "30:50" -Critical "10:70"; #This will return Ok
             Get-IcingaHelpThresholds -Value 20 -Warning "30:50" -Critical "10:70"; #This will return Warning
             Get-IcingaHelpThresholds -Value 5 -Warning "30:50" -Critical "10:70"; #This will return Critical

    #####################

    Outside Range
    -Warning "@40:70"

    The exact opposite of the between range. Simply write an @ before your range and it will return Ok only, if the value is
    outside the range. In this case, it will only return Ok if the value is <= 40 and >= 70

    Example: Get-IcingaHelpThresholds -Value 10 -Warning "@20:90" -Critical "@40:60"; #This will return Ok
             Get-IcingaHelpThresholds -Value 20 -Warning "@20:90" -Critical "@40:60"; #This will return Warning
             Get-IcingaHelpThresholds -Value 50 -Warning "@20:90" -Critical "@40:60"; #This will return Critical

    #####################

    Above value
    -Warning "50:"

    A threshold followed by a : will always return Ok in case the value is above the configured start value. In this case it will
    always return Ok as long as the value itself is above 50

    Example: Get-IcingaHelpThresholds -Value 100 -Warning "90:" -Critical "50:"; #This will return Ok
             Get-IcingaHelpThresholds -Value 60 -Warning "90:" -Critical "50:"; #This will return Warning
             Get-IcingaHelpThresholds -Value 10 -Warning "90:" -Critical "50:"; #This will return Critical

    #####################

    Below value
    -Warning "~:40"

    Like the above value, you can also configure a threshold to require to be lower then a certain value. In this example, every value
    below 40 will return Ok

    Example: Get-IcingaHelpThresholds -Value 20 -Warning "~:40" -Critical "~:70"; #This will return Ok
             Get-IcingaHelpThresholds -Value 60 -Warning "~:40" -Critical "~:70"; #This will return Warning
             Get-IcingaHelpThresholds -Value 90 -Warning "~:40" -Critical "~:70"; #This will return Critical

    #####################

    You can play around yourself with this by using this Cmdlet with different values and -Warning / -Critical thresholds:

    Get-IcingaHelpThresholds -Value <value> -Warning <warning> -Critical <critical>;
    ';
}

<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

[hashtable]$IcingaExitCode = @{
    Ok       = 0;
    Warning  = 1;
    Critical = 2;
    Unknown  = 3;
};

[hashtable]$IcingaExitCodeText = @{
    0 = '[OK]';
    1 = '[WARNING]';
    2 = '[CRITICAL]';
    3 = '[UNKNOWN]';
};

[hashtable]$IcingaExitCodeColor = @{
    0 = 'Green';
    1 = 'Yellow';
    2 = 'Red';
    3 = 'Magenta';
};

[hashtable]$IcingaMeasurementUnits = @{
    's'    = 'seconds';
    'ms'   = 'milliseconds';
    'us'   = 'microseconds';
    '%'    = 'percent';
    'B'    = 'bytes';
    'KB'   = 'Kilobytes';
    'MB'   = 'Megabytes';
    'GB'   = 'Gigabytes';
    'TB'   = 'Terabytes';
    'c'    = 'counter';
    'Kbit' = 'Kilobit';
    'Mbit' = 'Megabit';
    'Gbit' = 'Gigabit';
    'Tbit' = 'Terabit';
    'Pbit' = 'Petabit';
    'Ebit' = 'Exabit';
    'Zbit' = 'Zettabit';
    'Ybit' = 'Yottabit';
};

<##################################################################################################
################# Service Enums ##################################################################
##################################################################################################>

[hashtable]$ServiceStartupTypeName = @{
    0 = 'Boot';
    1 = 'System';
    2 = 'Automatic';
    3 = 'Manual';
    4 = 'Disabled';
    5 = 'Unknown'; # Custom
}

[hashtable]$ServiceWmiStartupType = @{
    'Boot'     = 0;
    'System'   = 1;
    'Auto'     = 2;
    'Manual'   = 3;
    'Disabled' = 4;
    'Unknown'  = 5; # Custom
}

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaEnums.IcingaExitCode.Ok
 #>
 if ($null -eq $IcingaEnums) {
    [hashtable]$IcingaEnums = @{
        IcingaExitCode         = $IcingaExitCode;
        IcingaExitCodeText     = $IcingaExitCodeText;
        IcingaExitCodeColor    = $IcingaExitCodeColor;
        IcingaMeasurementUnits = $IcingaMeasurementUnits;
        #services
        ServiceStartupTypeName = $ServiceStartupTypeName;
        ServiceWmiStartupType  = $ServiceWmiStartupType;
    }
}

Export-ModuleMember -Variable @( 'IcingaEnums' );

[hashtable]$TestIcingaWindowsInfo = @{
    'Ok'                 = 1;
    'EmptyClass'         = 2;
    'PermissionError'    = 4;
    'ObjectNotFound'     = 8;
    'InvalidNameSpace'   = 16;
    'UnhandledException' = 32;
    'NotSpecified'       = 64;
    'CimNotInstalled'    = 128;
}

[hashtable]$TestIcingaWindowsInfoText = @{
    1   = 'Everything is fine.';
    2   = 'No class specified to check';
    4   = 'Unable to query data using the given WMI-Class. You are either missing permissions or the service is not running properly';
    8   = 'The specified WMI Class could not be found in the specified NameSpace.';
    16  = 'No namespace with the specified name could be found on this system.';
    32  = 'Windows unhandled exception is thrown. Please enable frame DebugMode for information.';
    64  = 'Either the service has been stopped or you are not authorized to access the service.';
    128 = 'The Cmdlet Get-CimClass is not available on your system.';
}

[hashtable]$TestIcingaWindowsInfoExceptionType = @{
    1   = 'OK';
    2   = 'EmptyClass';
    4   = 'PermissionError';
    8   = 'ObjectNotFound';
    16  = 'InvalidNameSpace';
    32  = 'UnhandledException';
    64  = 'NotSpecified';
    128 = 'CimNotInstalled';
}

[hashtable]$TestIcingaWindowsInfoEnums = @{
    TestIcingaWindowsInfo              = $TestIcingaWindowsInfo;
    TestIcingaWindowsInfoText          = $TestIcingaWindowsInfoText;
    TestIcingaWindowsInfoExceptionType = $TestIcingaWindowsInfoExceptionType;
}

Export-ModuleMember -Variable @( 'TestIcingaWindowsInfoEnums' );

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
                    return $cmd.Path;
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

function Exit-IcingaThrowCritical()
{
    param (
        [string]$Message      = '',
        [string]$FilterString = $null,
        [string]$SearchString = $null,
        [switch]$Force        = $FALSE
    );

    if ($Force -eq $FALSE) {
        if ([string]::IsNullOrEmpty($FilterString) -Or [string]::IsNullOrEmpty($SearchString)) {
            return;
        }

        if ($FilterString -NotLike "*$SearchString*") {
            return;
        }
    }

    [string]$OutputMessage = [string]::Format(
        '[CRITICAL] {0}',
        $Message
    );

    Set-IcingaInternalPluginExitCode -ExitCode $IcingaEnums.IcingaExitCode.Critical;
    Set-IcingaInternalPluginException -PluginException $OutputMessage;

    if ($null -eq $global:IcingaDaemonData -Or $global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        Write-IcingaConsolePlain $OutputMessage;
        exit $IcingaEnums.IcingaExitCode.Critical;
    }
}

function Exit-IcingaThrowException()
{
    param(
        [string]$InputString,
        [string]$StringPattern,
        [string]$CustomMessage,
        $ExceptionThrown,
        [ValidateSet('Permission', 'Input', 'Configuration', 'Connection', 'Unhandled', 'Custom')]
        [string]$ExceptionType    = 'Unhandled',
        [hashtable]$ExceptionList = @{ },
        [string]$KnowledgeBaseId,
        [switch]$Force
    );

    if ($Force -eq $FALSE) {
        if ($null -eq $InputString -Or [string]::IsNullOrEmpty($InputString)) {
            return;
        }

        if (-Not $InputString.Contains($StringPattern)) {
            return;
        }
    }

    if ($null -eq $ExceptionList -Or $ExceptionList.Count -eq 0) {
        $ExceptionList = $IcingaExceptions;
    }

    $ExceptionMessageLib = $null;
    $ExceptionTypeString = '';

    switch ($ExceptionType) {
        'Permission' {
            $ExceptionTypeString = 'Permission';
            $ExceptionMessageLib = $ExceptionList.Permission;
        };
        'Input' {
            $ExceptionTypeString = 'Invalid Input';
            $ExceptionMessageLib = $ExceptionList.Inputs;
        };
        'Configuration' {
            $ExceptionTypeString = 'Invalid Configuration';
            $ExceptionMessageLib = $ExceptionList.Configuration;
        };
        'Connection' {
            $ExceptionTypeString = 'Connection error';
            $ExceptionMessageLib = $ExceptionList.Connection;
        };
        'Unhandled' {
            $ExceptionTypeString = 'Unhandled';
        };
        'Custom' {
            $ExceptionTypeString = 'Custom';
        };
    }

    [string]$ExceptionName = '';
    [string]$ExceptionIWKB = $KnowledgeBaseId;

    if ($null -ne $ExceptionMessageLib) {
        foreach ($definedError in $ExceptionMessageLib.Keys) {
            if ($ExceptionMessageLib.$definedError -eq $ExceptionThrown) {
                $ExceptionName = $definedError;
                break;
            }
        }
    }
    if ($null -eq $ExceptionMessageLib -Or [string]::IsNullOrEmpty($ExceptionName)) {
        $ExceptionName   = [string]::Format('{0} Exception', $ExceptionTypeString);
        if ([string]::IsNullOrEmpty($InputString)) {
            $InputString = $ExceptionThrown;
        }
        $ExceptionThrown = [string]::Format(
            '{0} exception occured:{1}{2}',
            $ExceptionTypeString,
            "`r`n",
            $InputString
        );
    }

    if ($ExceptionThrown -is [hashtable]) {
        $ExceptionIWKB   = $ExceptionThrown.IWKB;
        $ExceptionThrown = $ExceptionThrown.Message;
    }

    if ([string]::IsNullOrEmpty($ExceptionIWKB) -eq $FALSE) {
        $ExceptionIWKB = [string]::Format(
            '{0}{0}Further details can be found on the Icinga for Windows Knowledge base: https://icinga.com/docs/windows/latest/doc/knowledgebase/{1}',
            (New-IcingaNewLine),
            $ExceptionIWKB
        );
    }

    $OutputMessage = '{0}: Icinga {6} Error was thrown: {4}: {5}{2}{2}{3}{1}';
    if ([string]::IsNullOrEmpty($CustomMessage) -eq $TRUE) {
        $OutputMessage = '{0}: Icinga {6} Error was thrown: {4}{2}{2}{3}{5}{1}';
    }

    $OutputMessage = [string]::Format(
        $OutputMessage,
        $IcingaEnums.IcingaExitCodeText.($IcingaEnums.IcingaExitCode.Unknown),
        $ExceptionIWKB,
        (New-IcingaNewLine),
        $ExceptionThrown,
        $ExceptionName,
        $CustomMessage,
        $ExceptionTypeString
    );

    Set-IcingaInternalPluginExitCode -ExitCode $IcingaEnums.IcingaExitCode.Unknown;
    Set-IcingaInternalPluginException -PluginException $OutputMessage;

    if ($null -eq $global:IcingaDaemonData -Or $global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        Write-IcingaConsolePlain $OutputMessage;
        exit $IcingaEnums.IcingaExitCode.Unknown;
    }
}

<#
.SYNOPSIS
    This function returns the HRESULT unique value thrown by the last exception
.DESCRIPTION
    This function returns the HRESULT unique value thrown by the last exception
.OUTPUTS
    System.String
#>
function Get-IcingaLastExceptionId()
{
    if ([string]::IsNullOrEmpty($Error)) {
        return '';
    }

    [string]$ExceptionId = ([string]($Error.FullyQualifiedErrorId)).Split(',')[0].Split(' ')[1];
    $Error.Clear();

    return $ExceptionId;
}

<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>

[hashtable]$Permission = @{
    PerformanceCounter = 'A Plugin failed to fetch Performance Counter information. This may be caused when the used Service User is not permitted to access these information. To fix this, please add the User the Icinga Agent is running on into the "Performance Monitor Users" group and restart the service.';
    CacheFolder        = "A plugin failed to write new data into the configured cache directory. Please update the permissions of this folder to allow write access for the user the Icinga Service is running with or use another folder as cache directory.";
    CimInstance        = @{
        'Message' = 'The user you are running this command as does not have permission to access the requested Cim-Object. To fix this, please add the user the Agent is running with to the "Remote Management Users" groups and grant access to the WMI branch for the Class/Namespace mentioned above and add the permission "Remote enable".';
        'IWKB'    = 'IWKB000001';
    }
    WMIObject          = @{
        'Message' = 'The user you are running this command as does not have permission to access the requested Wmi-Object. To fix this, please add the user the Agent is running with to the "Remote Management Users" groups and grant access to the WMI branch for the Class/Namespace mentioned above and add the permission "Remote enable".';
        'IWKB'    = 'IWKB000001';
    }
    WindowsUpdate      = @{
        'Message' = 'The user you are running this command as does not have permission to access the Windows Update ComObject "Microsoft.Update.Session".';
        'IWKB'    = 'IWKB000006';
    }
};

[hashtable]$Inputs = @{
    PerformanceCounter      = 'A plugin failed to fetch Performance Counter information. Please ensure the counter is written properly and available on your system.';
    EventLogLogName         = 'Failed to fetch EventLog information. Please specify a valid LogName.';
    EventLog                = 'Failed to fetch EventLog information. Please check your inputs for EntryTypes and other categories and try again.';
    ConversionUnitMissing   = 'Unable to parse input value. You have to add an unit to your input value. Example: "10GB". Allowed units are: "B, KB, MB, GB, TB, PB, KiB, MiB, GiB, TiB, PiB".';
    MultipleUnitUsage       = 'Failed to convert your Icinga threshold units as you were trying to convert values with a different type of unit category. This feature only supports the conversion of one unit category. For example you can not convert 20MB:10d in the same call, as size and time units are not compatible.';
    CimClassNameUnknown     = 'The provided class name you try to fetch with Get-CimInstance is not known on this system.';
    WmiObjectClassUnknown   = 'The provided class name you try to fetch with Get-WmiObject is not known on this system.';
    MSSQLCredentialHandling = 'The connection to MSSQL was not possible because your login credential was not correct.';
    MSSQLCommandMissing     = 'Failed to build a SQL query'
};

[hashtable]$Configuration = @{
    PluginArgumentConflict     = 'Your plugin argument configuration is causing a conflict. Mostly this error is caused by missmatching configurations by enabling multiple switch arguments which are resulting in a conflicting configuration for the plugin.';
    PluginArgumentMissing      = 'Your plugin argument configuration is missing mandatory arguments. This error is caused when mandatory or required arguments are missing from a plugin call and the operation is unable to process without them.';
    PluginNotInstalled         = 'The plugin assigned to this service check seems not to be installed on this machine. Please review your service check configuration for spelling errors and check if the plugin is installed and executable on this machine by PowerShell.';
    PluginNotAssigned          = 'Your check for this service could not be processed because it seems like no valid Cmdlet was assigned to the check command. Please review your check command to ensure that a valid Cmdlet is assigned and executed by a PowerShell call.';
    EventLogNotInstalled       = 'Your Icinga PowerShell Framework has been executed by an unprivileged user before it was properly installed. The Windows EventLog application could not be registered because the current user has insufficient permissions. Please log into the machine and run "Use-Icinga" once from an administrative shell to complete the setup process. Once done this error should vanish.';
    PerfCounterCategoryMissing = 'The specified Performance Counter category was not found on this system. This could either be a configuration error on your local Windows machine or a wrong usage of the plugin. Please check on different Windows machines if this issue persis. In case it only occurs on certain machines it is likely that the counter is simply not present and the plugin can not be processed.';
}

[hashtable]$Connection = @{
    MSSQLConnectionError = 'Could not open a connection to SQL Server. This failure may be caused by the fact that under the default settings SQL Server does not allow remote connections or the host is unreachable.';
}

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaException.Inputs.PerformanceCounter
 #>

if ($null -eq $IcingaExceptions) {
    [hashtable]$IcingaExceptions = @{
        Permission    = $Permission;
        Inputs        = $Inputs;
        Configuration = $Configuration;
        Connection    = $Connection;
    }
}

Export-ModuleMember -Variable @( 'IcingaExceptions' );

function Compare-IcingaPluginThresholds()
{
    param (
        [string]$Threshold      = $null,
        $InputValue             = $null,
        $BaseValue              = $null,
        [switch]$Matches        = $FALSE,
        [switch]$NotMatches     = $FALSE,
        [switch]$DateTime       = $FALSE,
        [string]$Unit           = '',
        $ThresholdCache         = $null,
        [string]$CheckName      = '',
        [hashtable]$Translation = @{ },
        $Minium                 = $null,
        $Maximum                = $null,
        [switch]$IsBetween      = $FALSE,
        [switch]$IsLowerEqual   = $FALSE,
        [switch]$IsGreaterEqual = $FALSE,
        [string]$TimeInterval   = $null
    );

    # Fix possible numeric value comparison issues
    $TestInput = Test-IcingaDecimal $InputValue;
    $BaseInput = Test-IcingaDecimal $BaseValue;

    if ($TestInput.Decimal) {
        [decimal]$InputValue = [decimal]$TestInput.Value;
    }
    if ($BaseInput.Decimal) {
        [decimal]$BaseValue = [decimal]$BaseInput.Value;
    }

    $IcingaThresholds = New-Object -TypeName PSObject;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Value'           -Value $InputValue;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'BaseValue'       -Value $BaseValue;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'RawValue'        -Value $InputValue;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Unit'            -Value $Unit;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'OriginalUnit'    -Value $Unit;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'PerfUnit'        -Value $Unit;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'IcingaThreshold' -Value $Threshold;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'RawThreshold'    -Value $Threshold;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'CompareValue'    -Value $null;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'MinRangeValue'   -Value $null;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'MaxRangeValue'   -Value $null;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'PercentValue'    -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'TimeSpan'        -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'InRange'         -Value $TRUE;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Message'         -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'Range'           -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'FullMessage'     -Value (
        [string]::Format('{0}', (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $Unit -Value $InputValue)))
    );
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'HeaderValue'     -Value $IcingaThresholds.FullMessage;
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'ErrorMessage'    -Value '';
    $IcingaThresholds | Add-Member -MemberType NoteProperty -Name 'HasError'        -Value $FALSE;

    # In case we are using % values, we should set the BaseValue always to 100
    if ($Unit -eq '%' -And $null -eq $BaseValue) {
        $BaseValue = 100;
    }

    if ([string]::IsNullOrEmpty($TimeInterval) -eq $FALSE -And $null -ne $ThresholdCache) {
        $TimeSeconds        = ConvertTo-Seconds $TimeInterval;
        $MinuteInterval     = ([TimeSpan]::FromSeconds($TimeSeconds)).Minutes;
        $CheckPerfDataLabel = [string]::Format('{0}_{1}', (Format-IcingaPerfDataLabel $CheckName), $MinuteInterval);

        if ($null -ne $ThresholdCache.$CheckPerfDataLabel) {
            $InputValue                = $ThresholdCache.$CheckPerfDataLabel;
            $InputValue                = [math]::round([decimal]$InputValue, 6);
            $IcingaThresholds.TimeSpan = $MinuteInterval;
        } else {
            $IcingaThresholds.HasError     = $TRUE;
            $IcingaThresholds.ErrorMessage = [string]::Format(
                'The provided time interval "{0}" which translates to "{1}m" in your "-ThresholdInterval" argument does not exist',
                $TimeInterval,
                $MinuteInterval
            );

            return $IcingaThresholds;
        }
    } <#else {
        # The symbol splitting our threshold from the time index value
        # Examples:
        # @20:40#15m
        # ~:40#15m
        # 40#15m
        $TimeIndexSeparator = '#';

        # In case we found a ~ not starting at the beginning, we should load the
        # time index values created by our background daemon
        # Allows us to specify something like "40:50#15"
        if ($Threshold.Contains($TimeIndexSeparator) -And $null -ne $ThresholdCache) {
            [int]$LastIndex = $Threshold.LastIndexOf($TimeIndexSeparator);
            if ($LastIndex -ne 0) {
                $TmpValue       = $Threshold;
                $Threshold      = $TmpValue.Substring(0, $LastIndex);
                $TimeIndex      = $TmpValue.Substring($LastIndex + 1, $TmpValue.Length - $LastIndex - 1);
                $TimeSeconds    = ConvertTo-Seconds $TimeIndex;
                $MinuteInterval = ([TimeSpan]::FromSeconds($TimeSeconds)).Minutes;

                $CheckPerfDataLabel = [string]::Format('{0}_{1}', (Format-IcingaPerfDataLabel $CheckName), $MinuteInterval);

                if ($null -ne $ThresholdCache.$CheckPerfDataLabel) {
                    $InputValue                = $ThresholdCache.$CheckPerfDataLabel;
                    $InputValue                = [math]::round([decimal]$InputValue, 6);
                    $IcingaThresholds.TimeSpan = $MinuteInterval;
                } else {
                    $IcingaThresholds.HasError     = $TRUE;
                    $IcingaThresholds.ErrorMessage = [string]::Format(
                        'The provided time interval "{0}{1}" which translates to "{2}m" in your "-ThresholdInterval" argument does not exist',
                        $TimeIndexSeparator,
                        $TimeIndex,
                        $MinuteInterval
                    );
                }
            }
        }
    }#>

    [bool]$UseDynamicPercentage       = $FALSE;
    [hashtable]$ConvertedThreshold    = Convert-IcingaPluginThresholds -Threshold $Threshold;
    $Minimum                          = (Convert-IcingaPluginThresholds -Threshold $Minimum).Value;
    $Maximum                          = (Convert-IcingaPluginThresholds -Threshold $Maximum).Value;
    [string]$ThresholdValue           = $ConvertedThreshold.Value;
    $IcingaThresholds.Unit            = $ConvertedThreshold.Unit;
    $IcingaThresholds.IcingaThreshold = $ThresholdValue;
    $TempValue                        = (Convert-IcingaPluginThresholds -Threshold ([string]::Format('{0}{1}', $InputValue, $Unit)));
    $InputValue                       = $TempValue.Value;
    $TmpUnit                          = $TempValue.Unit;
    $TestInput                        = Test-IcingaDecimal $InputValue;

    if ($TestInput.Decimal) {
        [decimal]$InputValue = [decimal]$TestInput.Value;
    }

    $IcingaThresholds.RawValue        = $InputValue;
    $TempValue                        = (Convert-IcingaPluginThresholds -Threshold ([string]::Format('{0}{1}', $BaseValue, $Unit)));
    $BaseValue                        = $TempValue.Value;
    $Unit                             = $TmpUnit;
    $IcingaThresholds.PerfUnit        = $Unit;
    $IcingaThresholds.BaseValue       = $BaseValue;

    if ([string]::IsNullOrEmpty($IcingaThresholds.Unit)) {
        $IcingaThresholds.Unit = $Unit;
    }

    # Calculate % value from base value of set
    if ([string]::IsNullOrEmpty($BaseValue) -eq $FALSE -And $BaseValue -ne 0 -And $IcingaThresholds.Unit -eq '%') {
        $InputValue           = $InputValue / $BaseValue * 100;
        $UseDynamicPercentage = $TRUE;
    } elseif (([string]::IsNullOrEmpty($BaseValue) -eq $TRUE -Or $BaseValue -eq 0) -And $IcingaThresholds.Unit -eq '%') {
        $IcingaThresholds.HasError = $TRUE;
        $IcingaThresholds.ErrorMessage = 'This argument does not support the % unit';

        return $IcingaThresholds;
    }

    # Always override our InputValue, case we might have change it
    $IcingaThresholds.Value = $InputValue;

    # If we simply provide a numeric number, we always check Value > Threshold or Value < 0
    if ($Matches) {
        # Checks if the InputValue Matches the Threshold
        if ($InputValue -Like $ThresholdValue) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is matching threshold';
            $IcingaThresholds.Range   = [string]::Format(
                '{0}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit))
            );
        }
    } elseif ($NotMatches) {
        # Checks if the InputValue not Matches the Threshold
        if ($InputValue -NotLike $ThresholdValue) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is not matching threshold';
            $IcingaThresholds.Range   = [string]::Format(
                '{0}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit))
            );
        }
    } elseif ($DateTime) {
        # Checks if the InputValue Is Inside our time value

        try {
            $DateTimeValue          = 0;
            [decimal]$TimeThreshold = 0;
            $CurrentDate            = $global:Icinga.CurrentDate;
            $IcingaThresholds.Unit  = '';

            if ([string]::IsNullOrEmpty($InputValue) -eq $FALSE) {
                $DateTimeValue          = [DateTime]::FromFileTime($InputValue);
                $IcingaThresholds.Value = $DateTimeValue.ToString('yyyy\/MM\/dd HH:mm:ss');
            }

            if ([string]::IsNullOrEmpty($ThresholdValue) -eq $FALSE) {
                $TimeThreshold                    = (ConvertTo-Seconds -Value $Threshold);
                $CurrentDate                      = $CurrentDate.AddSeconds($TimeThreshold);
                $IcingaThresholds.IcingaThreshold = $CurrentDate.ToFileTimeUtc();
            }

            if ([string]::IsNullOrEmpty($ThresholdValue) -eq $FALSE -And ($DateTimeValue -eq 0 -Or $DateTimeValue -lt $CurrentDate)) {
                $IcingaThresholds.InRange = $FALSE;
                $IcingaThresholds.Message = 'is lower than';
                $IcingaThresholds.Range   = [string]::Format(
                    '{0} ({1}{2})',
                    ((Get-Date).ToString('yyyy\/MM\/dd HH:mm:ss')),
                    ( $( if ($TimeThreshold -ge 0) { '+'; } else { ''; } )),
                    $Threshold
                );
            }
        } catch {
            $IcingaThresholds.ErrorMessage = [string]::Format(
                'Invalid date time specified. Your InputValue "{0}" seems not be a valid date time or your provided Threshold "{1}" cannot be converted to seconds. Exception: {2}',
                $InputValue,
                $ThresholdValue,
                $_.Exception.Message
            );
            $IcingaThresholds.HasError = $TRUE;

            return $IcingaThresholds;
        }
    } elseif ($IsBetween) {
        if ($InputValue -gt $Minium -And $InputValue -lt $Maximum) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is inside range';
            $IcingaThresholds.Range   = [string]::Format(
                '{0} and {1}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $Minium -OriginalUnit $IcingaThresholds.OriginalUnit)),
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $Maximum -OriginalUnit $IcingaThresholds.OriginalUnit))
            );
        }

        if ($IcingaThresholds.Unit -eq '%') {
            $IcingaThresholds.RawThreshold = [string]::Format(
                '{0}% ({2}) {1}% ({3})',
                (ConvertFrom-Percent -Value $BaseValue -Percent $Minium),
                (ConvertFrom-Percent -Value $BaseValue -Percent $Maximum),
                (Convert-IcingaPluginValueToString -Unit $Unit -Value $Minium -OriginalUnit $IcingaThresholds.OriginalUnit),
                (Convert-IcingaPluginValueToString -Unit $Unit -Value $Maximum -OriginalUnit $IcingaThresholds.OriginalUnit)
            );
            $IcingaThresholds.PercentValue = [string]::Format(
                '@{0}:{1}',
                (ConvertFrom-Percent -Value $BaseValue -Percent $Minium),
                (ConvertFrom-Percent -Value $BaseValue -Percent $Maximum)
            );
        }
    } elseif ($IsLowerEqual) {
        if ($InputValue -le $ThresholdValue) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is lower equal than threshold';
            $IcingaThresholds.Range   = [string]::Format(
                '{0}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit))
            );
        }

        if ($IcingaThresholds.Unit -eq '%') {
            $IcingaThresholds.RawThreshold = [string]::Format(
                '{0}% ({1})',
                (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue),
                (Convert-IcingaPluginValueToString -Unit $Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit)
            );
            $IcingaThresholds.PercentValue = [string]::Format(
                '{0}:',
                (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue)
            );
        }
    } elseif ($IsGreaterEqual) {
        if ($InputValue -ge $ThresholdValue) {
            $IcingaThresholds.InRange = $FALSE;
            $IcingaThresholds.Message = 'is greater equal than threshold';
            $IcingaThresholds.Range   = [string]::Format(
                '{0}',
                (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit))
            );
        }

        if ($IcingaThresholds.Unit -eq '%') {
            $IcingaThresholds.RawThreshold = [string]::Format(
                '{0}% ({1})',
                (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue),
                (Convert-IcingaPluginValueToString -Unit $Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit)
            );

            $IcingaThresholds.PercentValue = [string]::Format(
                '~:{0}',
                (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue)
            );
        }
    } else {
        if ((Test-Numeric $ThresholdValue)) {
            if ($InputValue -gt $ThresholdValue -Or $InputValue -lt 0) {
                $IcingaThresholds.InRange = $FALSE;
                $IcingaThresholds.Message = 'is greater than threshold';
                $IcingaThresholds.Range   = [string]::Format('{0}', (Convert-IcingaPluginValueToString -Unit $Unit -Value $ThresholdValue -OriginalUnit $IcingaThresholds.OriginalUnit));
            }

            $IcingaThresholds.CompareValue = [decimal]$ThresholdValue;

            if ($IcingaThresholds.Unit -eq '%') {
                $IcingaThresholds.RawThreshold = [string]::Format('{0}% ({1})', $ThresholdValue, (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue) -OriginalUnit $IcingaThresholds.OriginalUnit));

                $IcingaThresholds.PercentValue = [string]::Format(
                    '{0}',
                    (ConvertFrom-Percent -Value $BaseValue -Percent $ThresholdValue)
                );
            }
        } else {
            # Transform our provided thresholds to split everything into single objects
            [array]$thresholds = $ThresholdValue.Split(':');
            [string]$rangeMin  = $thresholds[0];
            [string]$rangeMax  = $thresholds[1];
            [bool]$IsNegating  = $rangeMin.Contains('@');
            [string]$rangeMin  = $rangeMin.Replace('@', '');

            if ((Test-Numeric ($rangeMin.Replace('@', '').Replace('~', '')))) {
                $IcingaThresholds.MinRangeValue = [decimal]($rangeMin.Replace('@', '').Replace('~', ''));
                [decimal]$rangeMin = [decimal]$rangeMin;
            }
            if ((Test-Numeric $rangeMax)) {
                $IcingaThresholds.MaxRangeValue = [decimal]$rangeMax;
                [decimal]$rangeMax = [decimal]$rangeMax;
            }

            if ($IsNegating -eq $FALSE -And (Test-Numeric $rangeMin) -And (Test-Numeric $rangeMax)) {
                # Handles:  30:40
                # Error on: < 30 or > 40
                # Ok on:    between {30 .. 40}

                if ($InputValue -lt $rangeMin -Or $InputValue -gt $rangeMax) {
                    $IcingaThresholds.InRange = $FALSE;
                    $IcingaThresholds.Message = 'is outside range';
                    $IcingaThresholds.Range   = [string]::Format(
                        '{0} and {1}',
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit)),
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );
                }

                if ($IcingaThresholds.Unit -eq '%') {
                    $IcingaThresholds.RawThreshold = [string]::Format(
                        '{0}% ({2}) and {1}% ({3})',
                        $rangeMin,
                        $rangeMax,
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit)),
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );

                    $IcingaThresholds.PercentValue = [string]::Format(
                        '{0}:{1}',
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin),
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax)
                    );
                }
            } elseif ((Test-Numeric $rangeMin) -And [string]::IsNullOrEmpty($rangeMax) -eq $TRUE) {
                # Handles:  20:
                # Error on: 20:
                # Ok on:    between 20 .. ∞

                if ($InputValue -lt $rangeMin) {
                    $IcingaThresholds.InRange = $FALSE;
                    $IcingaThresholds.Message = 'is lower than threshold';
                    $IcingaThresholds.Range   = [string]::Format(
                        '{0}',
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );
                }

                if ($IcingaThresholds.Unit -eq '%') {
                    $IcingaThresholds.RawThreshold = [string]::Format(
                        '{0}% ({1})',
                        $rangeMin,
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );

                    $IcingaThresholds.PercentValue = [string]::Format(
                        '{0}:',
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin)
                    );
                }
            } elseif ($rangeMin -eq '~' -And (Test-Numeric $rangeMax)) {
                # Handles:  ~:20
                # Error on: > 20
                # Ok on:    between -∞ .. 20

                if ($InputValue -gt $rangeMax) {
                    $IcingaThresholds.InRange = $FALSE;
                    $IcingaThresholds.Message = 'is greater than threshold';
                    $IcingaThresholds.Range   = [string]::Format(
                        '{0}',
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );
                }

                if ($IcingaThresholds.Unit -eq '%') {
                    $IcingaThresholds.RawThreshold = [string]::Format(
                        '{0}% ({1})',
                        $rangeMax,
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );

                    $IcingaThresholds.PercentValue = [string]::Format(
                        '~:{0}',
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax)
                    );
                }
            } elseif ($IsNegating -And (Test-Numeric $rangeMin) -And (Test-Numeric $rangeMax)) {
                # Handles:  @30:40
                # Error on: ≥ 30 and ≤ 40
                # Ok on:    -∞ .. 29 and 41 .. ∞

                if ($InputValue -ge $rangeMin -And $InputValue -le $rangeMax) {
                    $IcingaThresholds.InRange = $FALSE;
                    $IcingaThresholds.Message = 'is inside range';
                    $IcingaThresholds.Range   = [string]::Format(
                        '{0} and {1}',
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit)),
                        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );
                }

                if ($IcingaThresholds.Unit -eq '%') {
                    $IcingaThresholds.RawThreshold = [string]::Format(
                        '{0}% ({2}) {1}% ({3})',
                        $rangeMin,
                        $rangeMax,
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin -OriginalUnit $IcingaThresholds.OriginalUnit)),
                        (Convert-IcingaPluginValueToString -Unit $Unit -Value (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax -OriginalUnit $IcingaThresholds.OriginalUnit))
                    );

                    $IcingaThresholds.PercentValue = [string]::Format(
                        '@{0}:{1}',
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMin),
                        (ConvertFrom-Percent -Value $BaseValue -Percent $rangeMax)
                    );
                }
            } else {
                if ([string]::IsNullOrEmpty($Threshold) -eq $FALSE) {
                    # Unhandled
                    $IcingaThresholds.ErrorMessage = [string]::Format(
                        'Invalid range specified for threshold: InputValue "{0}" and Threshold {1}',
                        $InputValue,
                        $Threshold
                    );
                    $IcingaThresholds.HasError = $TRUE;

                    return $IcingaThresholds;
                }
            }
        }
    }

    $PluginOutputMessage = New-Object -TypeName 'System.Text.StringBuilder';

    [string]$PluginCurrentValue = [string]::Format(
        '{0}',
        (ConvertTo-IcingaPluginOutputTranslation -Translation $Translation -Value (Convert-IcingaPluginValueToString -Unit $IcingaThresholds.Unit -Value $IcingaThresholds.Value -OriginalUnit $IcingaThresholds.OriginalUnit))
    );

    [string]$PluginThresholdValue = $IcingaThresholds.Range;

    if ($UseDynamicPercentage -And $Unit -ne '%') {
        $IcingaThresholds.IcingaThreshold = $IcingaThresholds.PercentValue;
        $PluginCurrentValue       = [string]::Format('{0}% ({1})', ([string]([math]::Round($IcingaThresholds.Value, 2))).Replace(',', '.'), (Convert-IcingaPluginValueToString -Unit $Unit -Value $IcingaThresholds.RawValue -OriginalUnit $IcingaThresholds.OriginalUnit));
        $PluginThresholdValue     = $IcingaThresholds.RawThreshold;
    }

    $IcingaThresholds.HeaderValue = $PluginCurrentValue;
    $PluginOutputMessage.Append($PluginCurrentValue) | Out-Null;

    if ([string]::IsNullOrEmpty($IcingaThresholds.Message) -eq $FALSE) {
        $PluginOutputMessage.Append(' ') | Out-Null;
        $PluginOutputMessage.Append($IcingaThresholds.Message.Replace(',', '.')) | Out-Null;

        if ([string]::IsNullOrEmpty($PluginThresholdValue) -eq $FALSE) {
            $PluginOutputMessage.Append(' ') | Out-Null;
            $PluginOutputMessage.Append(([string]$PluginThresholdValue).Replace(',', '.')) | Out-Null;
        }
    }

    # Lets build our full message for adding on the value
    $IcingaThresholds.FullMessage = $PluginOutputMessage.ToString();

    return $IcingaThresholds;
}

function ConvertTo-IcingaPluginOutputTranslation()
{
    param (
        $Value                  = $null,
        [hashtable]$Translation = @{ }
    );

    if ($null -eq $Value) {
        return 'Nothing';
    }

    if ($null -eq $Translation -Or $Translation.Count -eq 0) {
        return $Value;
    }

    [array]$TranslationKeys   = $Translation.Keys;
    [array]$TranslationValues = $Translation.Values;
    [int]$Index               = 0;
    [bool]$FoundTranslation   = $FALSE;

    foreach ($entry in $TranslationKeys) {
        if (([string]($Value)).ToLower() -eq ([string]($entry)).ToLower()) {
            $FoundTranslation = $TRUE;
            break;
        }
        $Index += 1;
    }

    if ($FoundTranslation -eq $FALSE) {
        return $Value;
    }

    return $TranslationValues[$Index];
}

function Exit-IcingaExecutePlugin()
{
    param (
        [string]$Command = ''
    );

    Invoke-IcingaInternalServiceCall -Command $Command -Arguments $args;

    try {
        # Load the entire framework now, as we require to execute plugins locally
        if ($null -eq $global:IcingaDaemonData) {
            Use-Icinga;
        }

        Exit-IcingaPluginNotInstalled -Command $Command;

        exit (& $Command @args);
    } catch {
        $ExMsg      = $_.Exception.Message;
        $StackTrace = $_.ScriptStackTrace;
        $ExErrorId  = $_.FullyQualifiedErrorId;
        $ArgName    = $_.Exception.ParameterName;
        $ListArgs   = $args;

        if ($ExErrorId -Like "*ParameterArgumentTransformationError*" -And $ExMsg.Contains('System.Security.SecureString')) {
            $ExMsg = [string]::Format(
                'Cannot bind parameter {0}. Cannot convert the provided value for argument "{0}" of type "System.String" to type "System.Security.SecureString".',
                $ArgName
            );

            $args.Clear();
            $ListArgs = 'Hidden for security reasons';
        }

        Write-IcingaConsolePlain '[UNKNOWN] Icinga Exception: {0}{1}{1}CheckCommand: {2}{1}Arguments: {3}{1}{1}StackTrace:{1}{4}' -Objects $ExMsg, (New-IcingaNewLine), $Command, $ListArgs, $StackTrace;
        exit 3;
    }
}

function Get-IcingaThresholdCache()
{
    param (
        [string]$CheckCommand = $null
    );

    if ([string]::IsNullOrEmpty($CheckCommand)) {
        return $null;
    }

    if ($null -eq $Global:Icinga) {
        return $null;
    }

    if ($Global:Icinga.ContainsKey('ThresholdCache') -eq $FALSE) {
        return $null;
    }

    if ($Global:Icinga.ThresholdCache.ContainsKey($CheckCommand) -eq $FALSE) {
        return $null;
    }

    return $Global:Icinga.ThresholdCache[$CheckCommand];
}

function New-IcingaCheck()
{
    param(
        [string]$Name       = '',
        $Value              = $null,
        $BaseValue          = $null,
        $Unit               = '',
        [string]$Minimum    = '',
        [string]$Maximum    = '',
        $ObjectExists       = -1,
        $Translation        = $null,
        [string]$LabelName  = $null,
        [switch]$NoPerfData = $FALSE
    );

    $IcingaCheck = New-IcingaCheckBaseObject;

    $IcingaCheck.Name         = $Name;
    $IcingaCheck.__ObjectType = 'IcingaCheck';

    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Value'             -Value $Value;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'BaseValue'         -Value $BaseValue;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Unit'              -Value $Unit;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Minimum'           -Value $Minimum;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Maximum'           -Value $Maximum;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'ObjectExists'      -Value $ObjectExists;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'Translation'       -Value $Translation;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'LabelName'         -Value $LabelName;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name 'NoPerfData'        -Value $NoPerfData;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__WarningValue'    -Value $null;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__CriticalValue'   -Value $null;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__LockedState'     -Value $FALSE;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__ThresholdObject' -Value $null;
    $IcingaCheck | Add-Member -MemberType NoteProperty -Name '__TimeInterval'    -Value $null;

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name 'Compile' -Value {
        $this.__ValidateThresholdInput();
        if ($null -eq $this.__ThresholdObject) {
            $this.__CreateDefaultThresholdObject();
        }
        $this.__SetCheckOutput();
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__SetInternalTimeInterval' -Value {
        $CallStack           = Get-PSCallStack;
        [bool]$FoundInterval = $FALSE;

        foreach ($entry in $CallStack) {
            if ($FoundInterval) {
                break;
            }
            [string]$CheckCommand = $entry.Command;
            if ($CheckCommand -eq $this.__CheckCommand) {
                [string]$CheckArguments = $entry.Arguments.Replace('{', '').Replace('}', '');
                [array]$SplitArgs       = $CheckArguments.Split(',');

                foreach ($SetArg in $SplitArgs) {
                    $SetArg = $SetArg.Replace(' ', '');
                    if ($FoundInterval) {
                        $this.__TimeInterval = $SetArg;
                        break;
                    }
                    if ($SetArg -eq '-ThresholdInterval') {
                        $FoundInterval = $TRUE;
                        continue;
                    }
                }
                break;
            }
        }
    }

    # Override shared function
    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__GetHeaderOutputValue' -Value {
        if ($null -eq $this.__ThresholdObject) {
            return ''
        }

        if ([string]::IsNullOrEmpty($this.__ThresholdObject.HeaderValue)) {
            return '';
        }

        return (
            [string]::Format(
                ' ({0})',
                $this.__ThresholdObject.HeaderValue
            )
        )
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__CreateDefaultThresholdObject' -Value {
        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $this.__ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;
        $this.__SetCheckState($this.__ThresholdObject, $IcingaEnums.IcingaExitCode.Ok);
    }

    # Override shared function
    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__SetCheckOutput' -Value {
        param ($PluginOutput);

        if ($this.__InLockState()) {
            return;
        }

        $PluginThresholds = '';
        $TimeSpan         = '';
        $PluginThresholds = $this.__ThresholdObject.FullMessage;

        if ([string]::IsNullOrEmpty($PluginOutput) -eq $FALSE) {
            $PluginThresholds = $PluginOutput;
        }

        if ($null -ne $this.__ThresholdObject -And [string]::IsNullOrEmpty($this.__ThresholdObject.TimeSpan) -eq $FALSE) {
            $TimeSpan = [string]::Format(
                '{0}({1}m avg.)',
                (&{ if ([string]::IsNullOrEmpty($PluginThresholds)) { return ''; } else { return ' ' } }),
                $this.__ThresholdObject.TimeSpan
            );
        }

        [bool]$AddColon = $TRUE;

        if ([string]::IsNullOrEmpty($this.Name) -eq $FALSE -And $this.Name[$this.Name.Length - 1] -eq ':') {
            $AddColon = $FALSE;
        }

        $this.__CheckOutput = [string]::Format(
            '{0} {1}{2} {3}{4}',
            $IcingaEnums.IcingaExitCodeText[$this.__CheckState],
            $this.Name,
            (&{ if ($AddColon) { return ':'; } else { return ''; } }),
            $PluginThresholds,
            $TimeSpan
        );

        $this.__SetPerformanceData();
    }

    # __GetTimeSpanThreshold(0, 'Core_30_20', 'Core_30')
    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__GetTimeSpanThreshold' -Value {
        param ($TimeSpanLabel, $Label);

        [hashtable]$TimeSpans = @{
            'Warning'  = '';
            'Critical' = '';
        }

        [string]$LabelName = (Format-IcingaPerfDataLabel $this.Name);
        if ([string]::IsNullOrEmpty($this.LabelName) -eq $FALSE) {
            $LabelName = $this.LabelName;
        }

        if ($Label -ne $LabelName) {
            return $TimeSpans;
        }

        $TimeSpan = $TimeSpanLabel.Replace($Label, '').Replace('_', '');

        if ($null -ne $this.__WarningValue -And [string]::IsNullOrEmpty($this.__WarningValue.TimeSpan) -eq $FALSE -And $this.__WarningValue.TimeSpan -eq $TimeSpan) {
            $TimeSpans.Warning = $this.__WarningValue.IcingaThreshold;
        }
        if ($null -ne $this.__CriticalValue -And [string]::IsNullOrEmpty($this.__CriticalValue.TimeSpan) -eq $FALSE -And $this.__CriticalValue.TimeSpan -eq $TimeSpan) {
            $TimeSpans.Critical = $this.__CriticalValue.IcingaThreshold;
        }

        return $TimeSpans;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__GetWarningThresholdObject' -Value {
        return $this.__WarningValue;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__GetCriticalThresholdObject' -Value {
        return $this.__CriticalValue;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__SetPerformanceData' -Value {
        if ($null -eq $this.__ThresholdObject -Or $this.NoPerfData) {
            return;
        }

        [string]$LabelName = (Format-IcingaPerfDataLabel $this.Name);
        $value             = ConvertTo-Integer -Value $this.__ThresholdObject.RawValue -NullAsEmpty;
        $warning           = '';
        $critical          = '';

        # Set our threshold to nothing if we use time spans, as it would cause performance metrics to
        # contain warning/critical values for everything, which is not correct
        if ([string]::IsNullOrEmpty($this.__WarningValue.TimeSpan)) {
            $warning = ConvertTo-Integer -Value $this.__WarningValue.IcingaThreshold -NullAsEmpty;
        }
        if ([string]::IsNullOrEmpty($this.__CriticalValue.TimeSpan)) {
            $critical = ConvertTo-Integer -Value $this.__CriticalValue.IcingaThreshold -NullAsEmpty;
        }

        if ([string]::IsNullOrEmpty($this.LabelName) -eq $FALSE) {
            $LabelName = $this.LabelName;
        }

        if ([string]::IsNullOrEmpty($this.Minimum) -And [string]::IsNullOrEmpty($this.Maximum)) {
            if ($this.Unit -eq '%') {
                $this.Minimum = '0';
                $this.Maximum = '100';
            } elseif ($null -ne $this.BaseValue) {
                $this.Minimum = '0';
                $this.Maximum = $this.__ThresholdObject.BaseValue;
            }

            if ($this.Value -gt $this.Maximum -And [string]::IsNullOrEmpty($this.Maximum) -eq $FALSE) {
                $this.Maximum = $this.__ThresholdObject.RawValue;
            }
        }

        $this.__CheckPerfData = @{
            'label'    = $LabelName;
            'perfdata' = '';
            'unit'     = $this.__ThresholdObject.PerfUnit;
            'value'    = (Format-IcingaPerfDataValue $value);
            'warning'  = (Format-IcingaPerfDataValue $warning);
            'critical' = (Format-IcingaPerfDataValue $critical);
            'minimum'  = (Format-IcingaPerfDataValue $this.Minimum);
            'maximum'  = (Format-IcingaPerfDataValue $this.Maximum);
            'package'  = $FALSE;
        };
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__ValidateObject' -Value {
        if ($null -eq $this.ObjectExists) {
            $this.SetUnknown() | Out-Null;
            $this.__SetCheckOutput('The object does not exist');
            $this.__LockState();
        }
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__LockState' -Value {
        $this.__LockedState = $TRUE;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__InLockState' -Value {
        return $this.__LockedState;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__ValidateUnit' -Value {
        if ([string]::IsNullOrEmpty($this.Unit) -eq $FALSE -And (-Not $IcingaEnums.IcingaMeasurementUnits.ContainsKey($this.Unit))) {
            $this.SetUnknown();
            $this.__SetCheckOutput(
                [string]::Format(
                    'Usage of invalid plugin unit "{0}". Allowed units are: {1}',
                    $this.Unit,
                    (($IcingaEnums.IcingaMeasurementUnits.Keys | Sort-Object name)  -Join ', ')
                )
            );

            $this.__LockState();
            $this.unit = $null;
        }
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__ConvertMinMax' -Value {
        if ([string]::IsNullOrEmpty($this.Unit) -eq $FALSE) {
            if ([string]::IsNullOrEmpty($this.Minimum) -eq $FALSE) {
                $this.Minimum = (Convert-IcingaPluginThresholds -Threshold ([string]::Format('{0}{1}', $this.Minimum, $this.Unit))).Value;
            }
            if ([string]::IsNullOrEmpty($this.Maximum) -eq $FALSE) {
                $this.Maximum = (Convert-IcingaPluginThresholds -Threshold ([string]::Format('{0}{1}', $this.Maximum, $this.Unit))).Value;
            }
        }
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__SetCurrentExecutionTime' -Value {
        if ($null -eq $global:Icinga) {
            $global:Icinga = @{ };
        }

        if ($global:Icinga.ContainsKey('CurrentDate') -eq $FALSE) {
            $global:Icinga.Add('CurrentDate', (Get-Date));
            return;
        }

        if ($null -ne $global:Icinga.CurrentDate) {
            return;
        }

        $global:Icinga.CurrentDate = (Get-Date).ToUniversalTime();
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__AddCheckDataToCache' -Value {

        # We only require this in case we are running as daemon
        if ([string]::IsNullOrEmpty($this.__CheckCommand) -Or $global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
            return;
        }

        # If no check table has been created, do nothing
        if ($null -eq $global:Icinga -Or $global:Icinga.ContainsKey('CheckData') -eq $FALSE) {
            return;
        }

        if ($global:Icinga.CheckData.ContainsKey($this.__CheckCommand) -eq $FALSE) {
            return;
        }

        # Fix possible error for identical time stamps due to internal exceptions
        # and check execution within the same time slot because of this
        [string]$TimeIndex = Get-IcingaUnixTime;

        Add-IcingaHashtableItem -Hashtable $global:Icinga.CheckData[$this.__CheckCommand]['results'] -Key $this.Name -Value @{ } | Out-Null;
        Add-IcingaHashtableItem -Hashtable $global:Icinga.CheckData[$this.__CheckCommand]['results'][$this.Name] -Key $TimeIndex -Value $this.Value -Override | Out-Null;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'SetOk' -Value {
        param ([string]$Message, [bool]$Lock);

        if ($this.__InLockState() -eq $FALSE) {
            $this.__CheckState = $IcingaEnums.IcingaExitCode.Ok;
            $this.__SetCheckOutput($Message);
        }

        if ($Lock) {
            $this.__LockState();
        }

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'SetWarning' -Value {
        param ([string]$Message, [bool]$Lock);

        if ($this.__InLockState() -eq $FALSE) {
            $this.__CheckState = $IcingaEnums.IcingaExitCode.Warning;
            $this.__SetCheckOutput($Message);
        }

        if ($Lock) {
            $this.__LockState();
        }

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'SetCritical' -Value {
        param ([string]$Message, [bool]$Lock);

        if ($this.__InLockState() -eq $FALSE) {
            $this.__CheckState = $IcingaEnums.IcingaExitCode.Critical;
            $this.__SetCheckOutput($Message);
        }

        if ($Lock) {
            $this.__LockState();
        }

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'SetUnknown' -Value {
        param ([string]$Message, [bool]$Lock);

        if ($this.__InLockState() -eq $FALSE) {
            $this.__CheckState = $IcingaEnums.IcingaExitCode.Unknown;
            $this.__SetCheckOutput($Message);
        }

        if ($Lock) {
            $this.__LockState();
        }

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__SetCheckState' -Value {
        param ($ThresholdObject, $State);

        if ($ThresholdObject.HasError) {
            $this.SetUnknown() | Out-Null;
            $this.__ThresholdObject = $ThresholdObject;
            $this.__SetCheckOutput($this.__ThresholdObject.ErrorMessage);
            $this.__LockState();
            return;
        }

        if ($this.__InLockState()) {
            return;
        }

        # In case no thresholds are set, always set the first value
        if ($null -eq $this.__ThresholdObject) {
            $this.__ThresholdObject = $ThresholdObject;
        }

        if ($ThresholdObject.InRange -eq $FALSE) {
            if ($this.__CheckState -lt $State) {
                $this.__CheckState      = $State;
                $this.__ThresholdObject = $ThresholdObject;
            }
        }

        $this.__SetCheckOutput();
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name '__GetBaseThresholdArguments' -Value {
        return @{
            '-InputValue'     = $this.Value;
            '-BaseValue'      = $this.BaseValue;
            '-Unit'           = $this.Unit;
            '-CheckName'      = $this.__GetName();
            '-ThresholdCache' = (Get-IcingaThresholdCache -CheckCommand $this.__CheckCommand);
            '-Translation'    = $this.Translation;
            '-TimeInterval'   = $this.__TimeInterval;
        };
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnOutOfRange' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnOutOfRange($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnDateTime' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnDateTime($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-DateTime', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfLike' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnIfLike($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-Matches', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfNotLike' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnIfNotLike($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-NotMatches', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfMatch' -Value {
        param ($Threshold);

        return $this.WarnIfLike($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfNotMatch' -Value {
        param ($Threshold);

        return $this.WarnIfNotLike($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritOutOfRange' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritOutOfRange($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritDateTime' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritDateTime($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-DateTime', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfLike' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritIfLike($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-Matches', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfNotLike' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritIfNotLike($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-NotMatches', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfMatch' -Value {
        param ($Threshold);

        return $this.CritIfLike($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfNotMatch' -Value {
        param ($Threshold);

        return $this.CritIfNotLike($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfBetweenAndEqual' -Value {
        param ($Min, $Max);

        [string]$Threshold = [string]::Format('@{0}:{1}', $Min, $Max);

        return $this.WarnOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfBetweenAndEqual' -Value {
        param ($Min, $Max);

        [string]$Threshold = [string]::Format('@{0}:{1}', $Min, $Max);

        return $this.CritOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfLowerThan' -Value {
        param ($Value);

        if ($null -ne $Value -And $Value.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Value) {
                $this.WarnIfLowerThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [string]$Threshold = [string]::Format('{0}:', $Value);

        return $this.WarnOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfLowerThan' -Value {
        param ($Value);

        if ($null -ne $Value -And $Value.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Value) {
                $this.CritIfLowerThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [string]$Threshold = [string]::Format('{0}:', $Value);

        return $this.CritOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfGreaterThan' -Value {
        param ($Value);

        if ($null -ne $Value -And $Value.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Value) {
                $this.WarnIfGreaterThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [string]$Threshold = [string]::Format('~:{0}', $Value);

        return $this.WarnOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfGreaterThan' -Value {
        param ($Value);

        if ($null -ne $Value -And $Value.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Value) {
                $this.CritIfGreaterThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [string]$Threshold = [string]::Format('~:{0}', $Value);

        return $this.CritOutOfRange($Threshold);
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfBetween' -Value {
        param ($Min, $Max);

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Minimum', $Min);
        $ThresholdArguments.Add('-Maximum', $Max);
        $ThresholdArguments.Add('-IsBetween', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfBetween' -Value {
        param ($Min, $Max);

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Minimum', $Min);
        $ThresholdArguments.Add('-Maximum', $Max);
        $ThresholdArguments.Add('-IsBetween', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfLowerEqualThan' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnIfLowerEqualThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-IsLowerEqual', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfLowerEqualThan' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritIfLowerEqualThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-IsLowerEqual', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'WarnIfGreaterEqualThan' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.WarnIfGreaterEqualThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-IsGreaterEqual', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__WarningValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Warning);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Name 'CritIfGreaterEqualThan' -Value {
        param ($Threshold);

        if ($null -ne $Threshold -And $Threshold.GetType().BaseType.Name.ToLower() -eq 'array') {
            foreach ($entry in $Threshold) {
                $this.CritIfGreaterEqualThan($entry) | Out-Null;

                # Break on first value causing a warning
                if ($ThresholdObject.InRange -eq $FALSE) {
                    break;
                }
            }

            return $this;
        }

        [hashtable]$ThresholdArguments = $this.__GetBaseThresholdArguments();
        $ThresholdArguments.Add('-Threshold', $Threshold);
        $ThresholdArguments.Add('-IsGreaterEqual', $TRUE);

        $ThresholdObject = Compare-IcingaPluginThresholds @ThresholdArguments;

        $this.__CriticalValue = $ThresholdObject;
        $this.__SetCheckState($ThresholdObject, $IcingaEnums.IcingaExitCode.Critical);

        return $this;
    }

    $IcingaCheck | Add-Member -MemberType ScriptMethod -Force -Name '__ValidateThresholdInput' -Value {
        if ($null -eq $this.__WarningValue -Or $null -eq $this.__CriticalValue) {
            return;
        }

        [bool]$OutOfRange = $FALSE;

        #Handles 20
        if ($null -ne $this.__WarningValue.CompareValue -And $null -ne $this.__CriticalValue.CompareValue) {
            if ($this.__WarningValue.CompareValue -gt $this.__CriticalValue.CompareValue) {
                $OutOfRange = $TRUE;
            }
        }

        # Handles:  @30:40 and 30:40
        # Never throw an "error" here, as these ranges can be dynamic
        if ($null -ne $this.__WarningValue.MinRangeValue -And $null -ne $this.__CriticalValue.MinRangeValue -And $null -ne $this.__WarningValue.MaxRangeValue -And $null -ne $this.__CriticalValue.MaxRangeValue) {
            return;
        }

        # Handles:  20:
        if ($null -ne $this.__WarningValue.MinRangeValue -And $null -ne $this.__CriticalValue.MinRangeValue -And $null -eq $this.__WarningValue.MaxRangeValue -And $null -eq $this.__CriticalValue.MaxRangeValue) {
            if ($this.__WarningValue.MinRangeValue -lt $this.__CriticalValue.MinRangeValue) {
                $OutOfRange = $TRUE;
            }
        }

        # Handles:  ~:20
        if ($null -eq $this.__WarningValue.MinRangeValue -And $null -eq $this.__CriticalValue.MinRangeValue -And $null -ne $this.__WarningValue.MaxRangeValue -And $null -ne $this.__CriticalValue.MaxRangeValue) {
            if ($this.__WarningValue.MaxRangeValue -gt $this.__CriticalValue.MaxRangeValue) {
                $OutOfRange = $TRUE;
            }
        }

        if ($OutOfRange) {
            $this.SetUnknown([string]::Format('Warning threshold range "{0}" is greater than Critical threshold range "{1}"', $this.__WarningValue.RawThreshold, $this.__CriticalValue.RawThreshold), $TRUE) | Out-Null;
        }
    }

    $IcingaCheck.__ValidateObject();
    $IcingaCheck.__ValidateUnit();
    $IcingaCheck.__SetCurrentExecutionTime();
    $IcingaCheck.__AddCheckDataToCache();
    $IcingaCheck.__SetInternalTimeInterval();
    $IcingaCheck.__ConvertMinMax();

    return $IcingaCheck;
}

function New-IcingaCheckBaseObject()
{
    $IcingaCheckBaseObject = New-Object -TypeName PSObject;

    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name 'Name'            -Value '';
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name 'Verbose'         -Value 0;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__CheckPerfData' -Value @{ };
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__Hidden'        -Value $FALSE;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__Parent'        -Value $IcingaCheckBaseObject;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__Indention'     -Value 0;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__ErrorMessage'  -Value '';
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__CheckState'    -Value $IcingaEnums.IcingaExitCode.Ok;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__CheckCommand'  -Value '';
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__CheckOutput'   -Value $null;
    $IcingaCheckBaseObject | Add-Member -MemberType NoteProperty -Name '__ObjectType'    -Value 'IcingaCheckBaseObject';

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetCheckCommand' -Value {
        $CallStack = Get-PSCallStack;

        foreach ($entry in $CallStack) {
            [string]$CheckCommand = $entry.Command;
            if ($CheckCommand.ToLower() -Like 'invoke-icingacheck*') {
                $this.__CheckCommand = $CheckCommand;
                break;
            }
        }

        if ([string]::IsNullOrEmpty($this.__CheckCommand)) {
            return;
        }

        if ($null -eq $Global:Icinga) {
            $Global:Icinga = @{ };
        }

        if ($Global:Icinga.ContainsKey('ThresholdCache') -eq $FALSE) {
            $Global:Icinga.Add('ThresholdCache', @{ });
        }

        if ($Global:Icinga.ThresholdCache.ContainsKey($this.__CheckCommand) -eq $FALSE) {
            $Global:Icinga.ThresholdCache.Add($this.__CheckCommand, $null);
        }

        if ($null -ne $Global:Icinga.ThresholdCache[$this.__CheckCommand]) {
            return;
        }

        $Global:Icinga.ThresholdCache[$this.__CheckCommand] = (Get-IcingaCacheData -Space 'sc_daemon' -CacheStore 'checkresult' -KeyName $this.__CheckCommand);
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetParent' -Value {
        param ($Parent);

        $this.__Parent = $Parent;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetParent' -Value {
        return $this.__Parent;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__IsHidden' -Value {
        return $this.__Hidden;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetHidden' -Value {
        param ([bool]$Hidden);

        $this.__Hidden = $Hidden;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetName' -Value {
        return $this.Name;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetIndention' -Value {
        param ($Indention);

        $this.__Indention = $Indention;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetIndention' -Value {
        return $this.__Indention;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__NewIndention' -Value {
        return ($this.__Indention + 1);
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetCheckState' -Value {
        return $this.__CheckState;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetCheckCommand' -Value {
        return $this.__CheckCommand;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Force -Name '__SetCheckOutput' -Value {
        param ($PluginOutput);
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetCheckOutput' -Value {

        if ($this.__IsHidden()) {
            return ''
        };

        if ($this._CanOutput() -eq $FALSE) {
            return '';
        }

        return (
            [string]::Format(
                '{0}{1}',
                (New-StringTree -Spacing $this.__GetIndention()),
                $this.__CheckOutput
            )
        );
    }

    # Shared function
    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name 'Compile' -Value {
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__SetVerbosity' -Value {
        param ($Verbosity);

        $this.Verbose = $Verbosity;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetVerbosity' -Value {
        return $this.Verbose;
    }

    # Shared function
    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetHeaderOutputValue' -Value {
        return '';
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '_CanOutput' -Value {
        # Always allow the output of the top parent elements
        if ($this.__GetIndention() -eq 0) {
            return $TRUE;
        }

        switch ($this.Verbose) {
            0 { # Only print states not being OK
                if ($this.__CheckState -ne $IcingaEnums.IcingaExitCode.Ok) {
                    return $TRUE;
                }

                if ($this.__ObjectType -eq 'IcingaCheckPackage') {
                    return $this.__HasNotOkChecks();
                }

                return $FALSE;
            };
            1 { # Print states not being OK and all content of affected check packages
                if ($this.__CheckState -ne $IcingaEnums.IcingaExitCode.Ok) {
                    return $TRUE;
                }

                if ($this.__ObjectType -eq 'IcingaCheckPackage') {
                    return $this.__HasNotOkChecks();
                }

                if ($this.__GetParent().__ObjectType -eq 'IcingaCheckPackage') {
                    return $this.__GetParent().__HasNotOkChecks();
                }

                return $FALSE;
            };
        }

        # For any other verbosity, print everything
        return $TRUE;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__GetPerformanceData' -Value {
        return $this.__CheckPerfData;
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name '__ValidateThresholdInput' -Value {
        # Shared function
    }

    $IcingaCheckBaseObject | Add-Member -MemberType ScriptMethod -Name 'HasChecks' -Value {
        # Shared function
    }

    $IcingaCheckBaseObject.__SetCheckCommand();

    return $IcingaCheckBaseObject;
}

function New-IcingaCheckPackage()
{
    param (
        [string]$Name               = '',
        [switch]$OperatorAnd        = $FALSE,
        [switch]$OperatorOr         = $FALSE,
        [switch]$OperatorNone       = $FALSE,
        [int]$OperatorMin           = -1,
        [int]$OperatorMax           = -1,
        [array]$Checks              = @(),
        [int]$Verbose               = 0,
        [switch]$IgnoreEmptyPackage = $FALSE,
        [switch]$Hidden             = $FALSE,
        [switch]$AddSummaryHeader   = $FALSE
    );

    $IcingaCheckPackage = New-IcingaCheckBaseObject;

    $IcingaCheckPackage.Name         = $Name;
    $IcingaCheckPackage.__ObjectType = 'IcingaCheckPackage';
    $IcingaCheckPackage.__SetHidden($Hidden);
    $IcingaCheckPackage.__SetVerbosity($Verbose);

    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorAnd'        -Value $OperatorAnd;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorOr'         -Value $OperatorOr;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorNone'       -Value $OperatorNone;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorMin'        -Value $OperatorMin;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'OperatorMax'        -Value $OperatorMax;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'IgnoreEmptyPackage' -Value $IgnoreEmptyPackage;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name 'AddSummaryHeader'   -Value $AddSummaryHeader;
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__Checks'           -Value @();
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__OkChecks'         -Value @();
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__WarningChecks'    -Value @();
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__CriticalChecks'   -Value @();
    $IcingaCheckPackage | Add-Member -MemberType NoteProperty -Name '__UnknownChecks'    -Value @();

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Name 'ValidateOperators' -Value {
        if ($this.OperatorMin -ne -1) {
            return;
        }

        if ($this.OperatorMax -ne -1) {
            return;
        }

        if ($this.OperatorNone -ne $FALSE) {
            return;
        }

        if ($this.OperatorOr -ne $FALSE) {
            return;
        }

        # If no operator is set, use And as default
        $this.OperatorAnd = $TRUE;
    }

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Name 'AddCheck' -Value {
        param([array]$Checks);

        if ($null -eq $Checks -Or $Checks.Count -eq 0) {
            return;
        }

        foreach ($check in $Checks) {
            $check.__SetIndention($this.__NewIndention());
            $check.__SetCheckOutput();
            $check.__SetVerbosity($this.__GetVerbosity());
            $check.__SetParent($this);
            [array]$this.__Checks += $check;
        }
    }

    # Override shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__SetIndention' -Value {
        param ($Indention);

        $this.__Indention = $Indention;

        foreach ($check in $this.__Checks) {
            $check.__SetIndention($this.__NewIndention());
        }
    }

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Name '__SetCheckState' -Value {
        param ($State);

        if ($this.__GetCheckState() -lt $State) {
            $this.__CheckState = $State;
            $this.__SetCheckOutput();
        }
    }

    # Override shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__SetCheckOutput' -Value {
        param ($PluginOutput);

        $UnknownChecks    = '';
        $CriticalChecks   = '';
        $WarningChecks    = '';
        $CheckSummary     = New-Object -TypeName 'System.Text.StringBuilder';
        [bool]$HasContent = $FALSE;

        # Only apply this to the top parent package
        if ($this.__GetIndention() -eq 0) {
            if ($this.__UnknownChecks.Count -ne 0) {
                $UnknownChecks = [string]::Format(' [UNKNOWN] {0}', ([string]::Join(', ', $this.__UnknownChecks)));
                $CheckSummary.Append(
                    [string]::Format(' {0} Unknown', $this.__UnknownChecks.Count)
                ) | Out-Null;
            }
            if ($this.__CriticalChecks.Count -ne 0) {
                $CriticalChecks = [string]::Format(' [CRITICAL] {0}', ([string]::Join(', ', $this.__CriticalChecks)));
                $CheckSummary.Append(
                    [string]::Format(' {0} Critical', $this.__CriticalChecks.Count)
                ) | Out-Null;
            }
            if ($this.__WarningChecks.Count -ne 0) {
                $WarningChecks = [string]::Format(' [WARNING] {0}', ([string]::Join(', ', $this.__WarningChecks)));
                $CheckSummary.Append(
                    [string]::Format(' {0} Warning', $this.__WarningChecks.Count)
                ) | Out-Null;
            }
        }

        if ($this.__OkChecks.Count -ne 0) {
            $CheckSummary.Append(
                [string]::Format(' {0} Ok', $this.__OkChecks.Count)
            ) | Out-Null;
        }

        if ($this.AddSummaryHeader -eq $FALSE) {
            $CheckSummary.Clear() | Out-Null;
            $CheckSummary.Append('') | Out-Null;
        } elseif ($CheckSummary.Length -ne 0) {
            $HasContent = $TRUE;
        }

        if ([string]::IsNullOrEmpty($this.__ErrorMessage) -eq $FALSE) {
            $HasContent = $TRUE;
        }

        $this.__CheckOutput = [string]::Format(
            '{0} {1}{2}{3}{4}{5}{6}{7}{8}',
            $IcingaEnums.IcingaExitCodeText[$this.__GetCheckState()],
            $this.Name,
            (&{ if ($HasContent) { return ':'; } else { return ''; } }),
            $CheckSummary.ToString(),
            ([string]::Format('{0}{1}', (&{ if ($this.__ErrorMessage.Length -gt 1) { return ' '; } else { return ''; } }), $this.__ErrorMessage)),
            $UnknownChecks,
            $CriticalChecks,
            $WarningChecks,
            $this.__ShowPackageConfig()
        );
    }

    $IcingaCheckPackage | Add-Member -Force -MemberType ScriptMethod -Name 'Compile' -Value {
        $this.__OkChecks.Clear();
        $this.__WarningChecks.Clear();
        $this.__CriticalChecks.Clear();
        $this.__UnknownChecks.Clear();

        $WorstState  = $IcingaEnums.IcingaExitCode.Ok;
        $BestState   = $IcingaEnums.IcingaExitCode.Ok;
        $NotOkChecks = 0;
        $OkChecks    = 0;

        if ($this.__Checks.Count -eq 0 -And $this.IgnoreEmptyPackage -eq $FALSE) {
            $this.__ErrorMessage = 'No checks added to this package';
            $this.__SetCheckState($IcingaEnums.IcingaExitCode.Unknown);
            $this.__SetCheckOutput();
            return;
        }

        [array]$this.__Checks = ($this.__Checks | Sort-Object -Property Name);

        # Loop all checks to understand the content of result
        foreach ($check in $this.__Checks) {

            $check.Compile();

            if ($check.__IsHidden()) {
                continue;
            }

            if ($WorstState -lt $check.__GetCheckState()) {
                $WorstState = $check.__GetCheckState();
            }

            if ($BestState -gt $check.__GetCheckState()) {
                $BestState = $check.__GetCheckState();
            }

            [string]$CheckStateOutput = [string]::Format(
                '{0}{1}',
                $check.__GetName(),
                $check.__GetHeaderOutputValue()
            );

            switch ($check.__GetCheckState()) {
                $IcingaEnums.IcingaExitCode.Ok {
                    $this.__OkChecks += $CheckStateOutput;
                    $OkChecks += 1;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Warning {
                    $this.__WarningChecks += $CheckStateOutput;
                    $NotOkChecks += 1;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Critical {
                    $this.__CriticalChecks += $CheckStateOutput;
                    $NotOkChecks += 1;
                    break;
                };
                $IcingaEnums.IcingaExitCode.Unknown {
                    $this.__UnknownChecks += $CheckStateOutput;
                    $NotOkChecks += 1;
                    break;
                };
            }
        }

        if ($this.OperatorAnd -And $NotOkChecks -ne 0) {
            $this.__SetCheckState($WorstState);
        } elseif ($this.OperatorOr -And $OkChecks -eq 0 ) {
            $this.__SetCheckState($WorstState);
        } elseif ($this.OperatorNone -And $OkChecks -ne 0 ) {
            $this.__SetCheckState($WorstState);
        } elseif ($this.OperatorMin -ne -1) {
            if (-Not ($this.__Checks.Count -eq 0 -And $this.IgnoreEmptyPackage -eq $TRUE)) {
                if ($this.OperatorMin -gt $this.__Checks.Count) {
                    $this.__SetCheckState($IcingaEnums.IcingaExitCode.Unknown);
                    $this.__ErrorMessage = [string]::Format('Minium check count ({0}) is larger than number of assigned checks ({1})', $this.OperatorMin, $this.__Checks.Count);
                } elseif ($OkChecks -lt $this.OperatorMin) {
                    $this.__SetCheckState($WorstState);
                    $this.__ErrorMessage = '';
                }
            }
        } elseif ($this.OperatorMax -ne -1) {
            if (-Not ($this.__Checks.Count -eq 0 -And $this.IgnoreEmptyPackage -eq $TRUE)) {
                if ($this.OperatorMax -gt $this.__Checks.Count) {
                    $this.__SetCheckState($IcingaEnums.IcingaExitCode.Unknown);
                    $this.__ErrorMessage = [string]::Format('Maximum check count ({0}) is larger than number of assigned checks ({1})', $this.OperatorMax, $this.__Checks.Count);
                } elseif ($OkChecks -gt $this.OperatorMax) {
                    $this.__SetCheckState($WorstState);
                    $this.__ErrorMessage = '';
                }
            }
        }

        $this.__SetCheckOutput();
    }

    # Override default behaviour from shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__SetVerbosity' -Value {
        param ($Verbosity);
        # Do nothing for check packages
    }

    # Override default behaviour from shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__GetCheckOutput' -Value {

        if ($this.__IsHidden()) {
            return ''
        };

        if ($this._CanOutput() -eq $FALSE) {
            return '';
        }

        $CheckOutput = [string]::Format(
            '{0}{1}',
            (New-StringTree -Spacing $this.__GetIndention()),
            $this.__CheckOutput
        );

        foreach ($check in $this.__Checks) {
            if ($check.__IsHidden()) {
                continue;
            };

            if ($check._CanOutput() -eq $FALSE) {
                continue;
            }

            $CheckOutput = [string]::Format(
                '{0}{1}{2}',
                $CheckOutput,
                "`n",
                $check.__GetCheckOutput()
            );
        }

        return $CheckOutput;
    }

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__HasNotOkChecks' -Value {

        if ($this.__WarningChecks.Count -ne 0) {
            return $TRUE;
        }

        if ($this.__CriticalChecks.Count -ne 0) {
            return $TRUE;
        }

        if ($this.__UnknownChecks.Count -ne 0) {
            return $TRUE;
        }

        return $FALSE;
    }

    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__ShowPackageConfig' -Value {
        if ($this.__GetVerbosity() -lt 3) {
            return '';
        }

        if ($this.OperatorAnd) {
            return ' (All must be [OK])';
        }
        if ($this.OperatorOr) {
            return ' (Atleast one must be [OK])';
        }
        if ($this.OperatorMin -ne -1) {
            return ([string]::Format(' (Atleast {0} must be [OK])', $this.OperatorMin));
        }
        if ($this.OperatorMax -ne -1) {
            return ([string]::Format(' (Not more than {0} must be [OK])', $this.OperatorMax));
        }

        return '';
    }

    # Override default behaviour from shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__GetPerformanceData' -Value {
        [string]$perfData             = '';
        [hashtable]$CollectedPerfData = @{ };

        # At first lets collect all perf data, but ensure we only add possible label duplication only once
        foreach ($check in $this.__Checks) {
            $data = $check.__GetPerformanceData();

            if ($null -eq $data -Or $null -eq $data.label) {
                continue;
            }

            if ($CollectedPerfData.ContainsKey($data.label)) {
                continue;
            }

            $CollectedPerfData.Add($data.label, $data);
        }

        return @{
            'label'    = $this.Name;
            'perfdata' = $CollectedPerfData;
            'package'  = $TRUE;
        }
    }

    # __GetTimeSpanThreshold(0, 'Core_30_20', 'Core_30')
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name '__GetTimeSpanThreshold' -Value {
        param ($TimeSpanLabel, $Label);

        foreach ($check in $this.__Checks) {
            $Result = $check.__GetTimeSpanThreshold($TimeSpanLabel, $Label);

            if ([string]::IsNullOrEmpty($Result) -eq $FALSE) {
                return $Result;
            }
        }

        return @{
            'Warning'  = '';
            'Critical' = '';
        };
    }

    # Override shared function
    $IcingaCheckPackage | Add-Member -MemberType ScriptMethod -Force -Name 'HasChecks' -Value {
        if ($this.__Checks.Count -eq 0) {
            return $FALSE;
        }

        return $TRUE;
    }

    $IcingaCheckPackage.ValidateOperators();
    $IcingaCheckPackage.AddCheck($Checks);

    return $IcingaCheckPackage;
}

function New-IcingaCheckResult()
{
    param (
        $Check,
        [bool]$NoPerfData = $FALSE,
        [switch]$Compile  = $FALSE
    );

    $IcingaCheckResult = New-Object -TypeName PSObject;
    $IcingaCheckResult | Add-Member -MemberType NoteProperty -Name 'Check'      -Value $Check;
    $IcingaCheckResult | Add-Member -MemberType NoteProperty -Name 'NoPerfData' -Value $NoPerfData;

    $IcingaCheckResult | Add-Member -MemberType ScriptMethod -Name 'Compile' -Value {
        if ($null -eq $this.Check) {
            return $IcingaEnums.IcingaExitCode.Unknown;
        }

        # Compile the check / package if not already done
        $this.Check.Compile();

        Write-IcingaPluginOutput -Output ($this.Check.__GetCheckOutput());

        if ($this.NoPerfData -eq $FALSE) {
            Write-IcingaPluginPerfData -IcingaCheck $this.Check;
        }

        # Ensure we reset our internal cache once the plugin was executed
        $Global:Icinga.ThresholdCache[$this.Check.__GetCheckCommand()] = $null;
        # Reset the current execution date
        $Global:Icinga.CurrentDate                                     = $null;

        $ExitCode = $this.Check.__GetCheckState();

        Set-IcingaInternalPluginExitCode -ExitCode $ExitCode;

        return $ExitCode;
    }

    if ($Compile) {
        return $IcingaCheckResult.Compile();
    }

    return $IcingaCheckResult;
}

function New-IcingaPerformanceDataEntry()
{
    param (
        $PerfDataObject,
        $Label          = $null,
        $Value          = $null,
        $Warning        = $null,
        $Critical       = $null
    );

    if ($null -eq $PerfDataObject) {
        return '';
    }

    [string]$LabelName     = $PerfDataObject.label;
    [string]$PerfValue     = $PerfDataObject.value;
    [string]$WarningValue  = $PerfDataObject.warning;
    [string]$CriticalValue = $PerfDataObject.critical;

    if ([string]::IsNullOrEmpty($Label) -eq $FALSE) {
        $LabelName = $Label;
    }
    if ([string]::IsNullOrEmpty($Value) -eq $FALSE) {
        $PerfValue = $Value;
    }

    # Override our warning/critical values only if the label does not match.
    # Eg. Core_1 not matching Core_1_5 - this is only required for time span checks
    if ([string]::IsNullOrEmpty($Label) -eq $FALSE -And $Label -ne $PerfDataObject.label) {
        $WarningValue  = $Warning;
        $CriticalValue = $Critical;
    }

    $minimum = '';
    $maximum = '';

    if ([string]::IsNullOrEmpty($PerfDataObject.minimum) -eq $FALSE) {
        $minimum = [string]::Format(';{0}', $PerfDataObject.minimum);
    }
    if ([string]::IsNullOrEmpty($PerfDataObject.maximum) -eq $FALSE) {
        $maximum = [string]::Format(';{0}', $PerfDataObject.maximum);
    }

    return (
        [string]::Format(
            "'{0}'={1}{2};{3};{4}{5}{6} ",
            $LabelName.ToLower(),
            (Format-IcingaPerfDataValue $PerfValue),
            $PerfDataObject.unit,
            (Format-IcingaPerfDataValue $WarningValue),
            (Format-IcingaPerfDataValue $CriticalValue),
            (Format-IcingaPerfDataValue $minimum),
            (Format-IcingaPerfDataValue $maximum)
        )
    );
}

function Set-IcingaInternalPluginException()
{
    param (
        [string]$PluginException = ''
    );

    if ($null -eq $Global:Icinga) {
        $Global:Icinga = @{ };
    }

    if ($Global:Icinga.ContainsKey('PluginExecution') -eq $FALSE) {
        $Global:Icinga.Add(
            'PluginExecution',
            @{
                'PluginException' = $PluginException;
            }
        )
    } else {
        if ($Global:Icinga.PluginExecution.ContainsKey('PluginException') -eq $FALSE) {
            $Global:Icinga.PluginExecution.Add('PluginException', $PluginException);
            return;
        }

        # Only catch the first exception
        if ([string]::IsNullOrEmpty($Global:Icinga.PluginExecution.PluginException)) {
            $Global:Icinga.PluginExecution.PluginException = $PluginException;
        }
    }
}

function Set-IcingaInternalPluginExitCode()
{
    param (
        $ExitCode = 0
    );

    if ($null -eq $Global:Icinga) {
        $Global:Icinga = @{ };
    }

    if ($Global:Icinga.ContainsKey('PluginExecution') -eq $FALSE) {
        $Global:Icinga.Add(
            'PluginExecution',
            @{
                'LastExitCode' = $ExitCode;
            }
        )
    } else {
        if ($Global:Icinga.PluginExecution.ContainsKey('LastExitCode') -eq $FALSE) {
            $Global:Icinga.PluginExecution.Add('LastExitCode', $ExitCode);
            return;
        }

        # Only add the first exit code we should cover during one runtime
        if ($null -eq $Global:Icinga.PluginExecution.LastExitCode) {
            $Global:Icinga.PluginExecution.LastExitCode = $ExitCode;
        }
    }
}

function Write-IcingaPluginOutput()
{
    param (
        $Output
    );

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        if ($null -ne $global:Icinga -And $global:Icinga.Minimal) {
            Clear-Host;
        }
        Write-IcingaConsolePlain $Output;
    } else {
        # New behavior with local thread separated results
        $global:Icinga.CheckResults += $Output;
    }
}

function Write-IcingaPluginPerfData()
{
    param (
        $IcingaCheck = $null
    );

    if ($null -eq $IcingaCheck) {
        return;
    }

    $PerformanceData = $IcingaCheck.__GetPerformanceData();
    $CheckCommand    = $IcingaCheck.__GetCheckCommand();

    if ($PerformanceData.package -eq $FALSE) {
        $PerformanceData = @{
            $PerformanceData.label = $PerformanceData;
        }
    } else {
        $PerformanceData = $PerformanceData.perfdata;
    }

    $CheckResultCache = $Global:Icinga.ThresholdCache[$CheckCommand];

    if ($global:IcingaDaemonData.FrameworkRunningAsDaemon -eq $FALSE) {
        [string]$PerfDataOutput = (Get-IcingaPluginPerfDataContent -PerfData $PerformanceData -CheckResultCache $CheckResultCache -IcingaCheck $IcingaCheck);
        Write-IcingaConsolePlain ([string]::Format('| {0}', $PerfDataOutput));
    } else {
        [void](Get-IcingaPluginPerfDataContent -PerfData $PerformanceData -CheckResultCache $CheckResultCache -AsObject $TRUE -IcingaCheck $IcingaCheck);
    }
}

function Get-IcingaPluginPerfDataContent()
{
    param(
        $PerfData,
        $CheckResultCache,
        [bool]$AsObject = $FALSE,
        $IcingaCheck    = $null
    );

    [string]$PerfDataOutput = '';

    foreach ($package in $PerfData.Keys) {
        $data = $PerfData[$package];
        if ($data.package) {
            $PerfDataOutput += (Get-IcingaPluginPerfDataContent -PerfData $data.perfdata -CheckResultCache $CheckResultCache -AsObject $AsObject -IcingaCheck $IcingaCheck);
        } else {
            foreach ($checkresult in $CheckResultCache.PSobject.Properties) {

                $SearchPattern = [string]::Format('{0}_', $data.label);
                $SearchEntry   = $checkresult.Name;
                if ($SearchEntry -like "$SearchPattern*") {
                    $TimeSpan  = $IcingaCheck.__GetTimeSpanThreshold($SearchEntry, $data.label);

                    $cachedresult = (New-IcingaPerformanceDataEntry -PerfDataObject $data -Label $SearchEntry -Value $checkresult.Value -Warning $TimeSpan.Warning -Critical $TimeSpan.Critical);

                    if ($AsObject) {
                        # New behavior with local thread separated results
                        $global:Icinga.PerfData += $cachedresult;
                    }
                    $PerfDataOutput += $cachedresult;
                }
            }

            $compiledPerfData = (New-IcingaPerformanceDataEntry $data);

            if ($AsObject) {
                # New behavior with local thread separated results
                $global:Icinga.PerfData += $compiledPerfData;
            }
            $PerfDataOutput += $compiledPerfData;
        }
    }

    return $PerfDataOutput;
}

Export-ModuleMember -Function @( 'Write-IcingaPluginPerfData' );

<#
.SYNOPSIS
   Closes a open connection to a MSSQL server
.DESCRIPTION
   This Cmdlet will close an open connection to a MSSQL server.
.FUNCTIONALITY
   Closes an open connection to a MSSQL server.
.EXAMPLE
   PS>Close-IcingaMSSQLConnection $OpenMSSQLConnection;
.INPUTS
   System.Data.SqlClient.SqlConnection
.OUTPUTS
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Close-IcingaMSSQLConnection()
{
    param (
        [System.Data.SqlClient.SqlConnection]$SqlConnection = $null
    );

    if ($null -eq $SqlConnection) {
        return;
    }

    Write-IcingaDebugMessage `
        -Message 'Closing client connection for endpoint {0}' `
        -Objects $SqlConnection;

    $SqlConnection.Close();
    $SqlConnection.Dispose();
    $SqlConnection = $null;
}

function Get-IcingaMSSQLInstanceName()
{
    param (
        $SqlConnection              = $null,
        [string]$Username,
        [securestring]$Password,
        [string]$Address            = "localhost",
        [int]$Port                  = 1433,
        [switch]$IntegratedSecurity = $FALSE,
        [switch]$TestConnection     = $FALSE
    );

    [bool]$NewSqlConnection = $FALSE;

    if ($null -eq $SqlConnection) {
        $SqlConnection = Open-IcingaMSSQLConnection -Username $Username -Password $Password -Address $Address -IntegratedSecurity:$IntegratedSecurity -Port $Port -TestConnection:$TestConnection;

        if ($null -eq $SqlConnection) {
            return 'Unknown';
        }

        $NewSqlConnection = $TRUE;
    }

    $Query        = 'SELECT @@servicename'
    $SqlCommand   = New-IcingaMSSQLCommand -SqlConnection $SqlConnection -SqlQuery $Query;
    $InstanceName = (Send-IcingaMSSQLCommand -SqlCommand $SqlCommand).Column1;

    if ($NewSqlConnection -eq $TRUE) {
        Close-IcingaMSSQLConnection -SqlConnection $SqlConnection;
    }

    return $InstanceName;
}

<#
.SYNOPSIS
   Builds a SQL query
.DESCRIPTION
   This Cmdlet will  build a SQL query
   and returns it as an string.
.FUNCTIONALITY
   Build a SQL query
.EXAMPLE
   PS>New-IcingaMSSQLCommand -SqlConnection $SqlConnection -SqlQuery "SELECT object_name FROM sys.dm_os_performance_counters";
.PARAMETER SqlConnection
   An open SQL connection object e.g. $SqlConnection = Open-IcingaMSSQLConnection -IntegratedSecurity;
.PARAMETER SqlQuery
   A SQL query as string.
.INPUTS
   System.Data.SqlClient.SqlConnection
   System.String
.OUTPUTS
   System.Data.SqlClient.SqlCommand
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function New-IcingaMSSQLCommand()
{
    param (
        [System.Data.SqlClient.SqlConnection]$SqlConnection = $null,
        [string]$SqlQuery                                   = $null
    );

    $SqlCommand             = New-Object System.Data.SqlClient.SqlCommand;
    $SqlCommand.Connection  = $SqlConnection;

    if ($null -eq $SqlCommand.Connection) {
        Exit-IcingaThrowException -ExceptionType 'Input' `
            -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCommandMissing `
            -CustomMessage 'It seems the -SqlConnection is empty or invalid' `
            -Force;
    }

    $SqlCommand.CommandText = $SqlQuery;

    return $SqlCommand;
}

<#
.SYNOPSIS
   Opens a connection to a MSSQL server
.DESCRIPTION
   This Cmdlet will open a  connection to a MSSQL server
   and returns that connection object.
.FUNCTIONALITY
   Opens a connection to a MSSQL server
.EXAMPLE
   PS>Open-IcingaMSSQLConnection -IntegratedSecurity -Address localhost;
.EXAMPLE
   PS>Open-IcingaMSSQLConnection -Username Exampleuser -Password (ConvertTo-IcingaSecureString 'examplePassword') -Address 123.125.123.2;
.PARAMETER Username
    The username for connecting to the MSSQL database
.PARAMETER Password
    The password for connecting to the MSSQL database as secure string
.PARAMETER Address
    The IP address or FQDN to the MSSQL server to connect to (default: localhost)
.PARAMETER Port
    The port of the MSSQL server/instance to connect to with the provided credentials (default: 1433)
.PARAMETER SqlDatabase
    The name of a specific database to connect to. Leave empty to connect "globaly"
.PARAMETER IntegratedSecurity
    Allows this plugin to use the credentials of the current PowerShell session inherited by
    the user the PowerShell is running with. If this is set and the user the PowerShell is
    running with can access to the MSSQL database you will not require to provide username
    and password
.PARAMETER TestConnection
    Set this if you want to return $null on connection errors during MSSQL.open() instead of
    exception messages.
.OUTPUTS
   System.Data.SqlClient.SqlConnection
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Open-IcingaMSSQLConnection()
{
    param (
        [string]$Username,
        [securestring]$Password,
        [string]$Address            = "localhost",
        [int]$Port                  = 1433,
        [string]$SqlDatabase,
        [switch]$IntegratedSecurity = $FALSE,
        [switch]$TestConnection     = $FALSE
    );

    if ($IntegratedSecurity -eq $FALSE) {
        if ([string]::IsNullOrEmpty($Username)) {
            Exit-IcingaThrowException `
                -ExceptionType 'Input' `
                -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling `
                -CustomMessage '-Username not set and -IntegratedSecurity is false' `
                -Force;
        } elseif ($null -eq $Password) {
            Exit-IcingaThrowException `
                -ExceptionType 'Input' `
                -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling `
                -CustomMessage '-Password not set and -IntegratedSecurity is false' `
                -Force;
        }

        $Password.MakeReadOnly();
        $SqlCredential = New-Object System.Data.SqlClient.SqlCredential($Username, $Password);
    }

    try {
        $SqlConnection                  = New-Object System.Data.SqlClient.SqlConnection;
        $SqlConnection.ConnectionString = "Server=$Address,$Port;";

        if ([string]::IsNullOrEmpty($SqlDatabase) -eq $FALSE) {
            $SqlConnection.ConnectionString += "Database=$SqlDatabase;";
        }

        if ($IntegratedSecurity -eq $TRUE) {
            $SqlConnection.ConnectionString += "Integrated Security=True;";
        }

        $SqlConnection.Credential = $SqlCredential;

        Write-IcingaDebugMessage `
            -Message 'Open client connection for endpoint {0}' `
            -Objects $SqlConnection;

        $SqlConnection.Open();
    } catch {

        if ($TestConnection) {
            return $null;
        }

        if ([string]::IsNullOrEmpty($Username) -eq $FALSE) {
            Exit-IcingaThrowException `
                -InputString $_.Exception.Message `
                -StringPattern $Username `
                -ExceptionType 'Input' `
                -ExceptionThrown $IcingaExceptions.Inputs.MSSQLCredentialHandling;
        }

        Exit-IcingaThrowException `
            -InputString $_.Exception.Message `
            -StringPattern 'error: 40' `
            -ExceptionType 'Connection' `
            -ExceptionThrown $IcingaExceptions.Connection.MSSQLConnectionError;

        Exit-IcingaThrowException `
            -InputString $_.Exception.Message `
            -StringPattern 'error: 0' `
            -ExceptionType 'Connection' `
            -ExceptionThrown $IcingaExceptions.Connection.MSSQLConnectionError;

        Exit-IcingaThrowException `
            -InputString $_.Exception.Message `
            -StringPattern 'error: 25' `
            -ExceptionType 'Connection' `
            -ExceptionThrown $IcingaExceptions.Connection.MSSQLConnectionError;
        # Last resort
        Exit-IcingaThrowException `
            -InputString $_.Exception.Message `
            -ExceptionType 'Custom' `
            -Force;
    }

    return $SqlConnection;
}

<#
.SYNOPSIS
   Executes a SQL query
.DESCRIPTION
   This Cmdlet will send a SQL query to a given database and
   execute the query and returns the output.
.FUNCTIONALITY
   Executes a SQL query
.EXAMPLE
   PS> Send-IcingaMSSQLCommand -SqlCommand $SqlCommand;
.PARAMETER SqlCommand
   The SQL query which will be executed, e.g. $SqlCommand = New-IcingaMSSQLCommand
.INPUTS
   System.Data.SqlClient.SqlCommand
.OUTPUTS
   System.Data.DataSet
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>
function Send-IcingaMSSQLCommand()
{
    param (
        [System.Data.SqlClient.SqlCommand]$SqlCommand = $null
    );

    $Adapter = New-Object System.Data.SqlClient.SqlDataAdapter $SqlCommand;

    $Data    = New-Object System.Data.DataSet;
    $Adapter.Fill($Data) | Out-Null;

    return $Data.Tables;
}

<#
.SYNOPSIS
   Disables the progress bar during file downloads or while loading certain modules.
   This will increase the speed of certain tasks, for example file downloads
.DESCRIPTION
   Disables the progress bar during file downloads or while loading certain modules.
   This will increase the speed of certain tasks, for example file downloads
.FUNCTIONALITY
   Sets the $ProgressPreference to 'SilentlyContinue'
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Disable-IcingaProgressPreference()
{
    $global:ProgressPreference = "SilentlyContinue";
}

<#
.SYNOPSIS
   Fetches the configuration of the configured Proxy server for the Framework, in
   case it is set
.DESCRIPTION
   etches the configuration of the configured Proxy server for the Framework, in
   case it is set
.FUNCTIONALITY
   etches the configuration of the configured Proxy server for the Framework, in
   case it is set
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaFrameworkProxyServer()
{
    return (Get-IcingaPowerShellConfig -Path 'Framework.Proxy.Server');
}

<#
.SYNOPSIS
    A wrapper function for Invoke-WebRequest to allow easier proxy support and
    to catch errors more directly.
.DESCRIPTION
    A wrapper function for Invoke-WebRequest to allow easier proxy support and
    to catch errors more directly.
.FUNCTIONALITY
    Uses Invoke-WebRequest to fetch information and returns the same output, but
    with direct error handling and global proxy support by configuration
.EXAMPLE
     PS>Invoke-IcingaWebRequest -Uri 'https://icinga.com';
.EXAMPLE
    PS>Invoke-IcingaWebRequest -Uri 'https://icinga.com' -UseBasicParsing;
.EXAMPLE
    PS>Invoke-IcingaWebRequest -Uri 'https://{0}.com' -UseBasicParsing -Objects 'icinga';
.EXAMPLE
    PS>Invoke-IcingaWebRequest -Uri 'https://{0}.com' -UseBasicParsing -Objects 'icinga' -Headers @{ 'accept' = 'application/json' };
.PARAMETER Uri
    The Uri for the web request
.PARAMETER Body
    Specifies the body of the request. The body is the content of the request that follows the headers. You can
    also pipe a body value to Invoke-WebRequest.

    The Body parameter can be used to specify a list of query parameters or specify the content of the response.

    When the input is a GET request and the body is an IDictionary (typically, a hash table), the body is added
    to the URI as query parameters. For other GET requests, the body is set as the value of the request body in
    the standard name=value format.

    When the body is a form, or it is the output of an Invoke-WebRequest call, Windows PowerShell sets the
    request content to the form fields.
.PARAMETER Headers
    Web headers send with the request as hashtable
.PARAMETER Method
    The request method to send to the destination.
    Allowed values: 'Get', 'Post', 'Put', 'Trace', 'Patch', 'Options', 'Merge', 'Head', 'Default', 'Delete'
.PARAMETER OutFile
    Specifies the output file for which this cmdlet saves the response body. Enter a path and file name. If you omit the path, the default is the current location.
.PARAMETER UseBasicParsing
    Indicates that the cmdlet uses the response object for HTML content without Document Object Model (DOM)
    parsing.

    This parameter is required when Internet Explorer is not installed on the computers, such as on a Server
    Core installation of a Windows Server operating system.
.PARAMETER Objects
    Use placeholders within the `-Uri` argument, like {0} and replace them with array elements of this argument.
    The index entry of {0} has to match the order of this argument.
.INPUTS
   System.String
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Invoke-IcingaWebRequest()
{
    param (
        [string]$Uri             = '',
        $Body,
        [hashtable]$Headers,
        [ValidateSet('Get', 'Post', 'Put', 'Trace', 'Patch', 'Options', 'Merge', 'Head', 'Default', 'Delete')]
        [string]$Method          = 'Get',
        [string]$OutFile,
        [switch]$UseBasicParsing,
        [array]$Objects          = @()
    );

    [int]$Index = 0;
    foreach ($entry in $Objects) {

        $Uri = $Uri.Replace(
            [string]::Format('{0}{1}{2}', '{', $Index, '}'),
            $entry
        );
        $Index++;
    }

    $WebArguments = @{
        'Uri'    = $Uri;
        'Method' = $Method;
    }

    if ($Method -ne 'Get' -And $null -ne $Body -and [string]::IsNullOrEmpty($Body) -eq $FALSE) {
        $WebArguments.Add('Body', $Body);
    }

    if ($Headers.Count -ne 0) {
        $WebArguments.Add('Headers', $Headers);
    }

    if ([string]::IsNullOrEmpty($OutFile) -eq $FALSE) {
        $WebArguments.Add('OutFile', $OutFile);
    }

    $ProxyServer = Get-IcingaFrameworkProxyServer;

    if ([string]::IsNullOrEmpty($ProxyServer) -eq $FALSE) {
        $WebArguments.Add('Proxy', $ProxyServer);
    }

    Set-IcingaTLSVersion;
    Disable-IcingaProgressPreference;

    try {
        $Response = Invoke-WebRequest -UseBasicParsing:$UseBasicParsing @WebArguments -ErrorAction Stop;
    } catch {
        [string]$ErrorId = ([string]$_.FullyQualifiedErrorId).Split(',')[0];
        [string]$Message = $_.Exception.Message;

        switch ($ErrorId) {
            'System.UriFormatException' {
                Write-IcingaConsoleError 'The provided Url "{0}" is not a valid format' -Objects $Uri;
                break;
            };
            'WebCmdletWebResponseException' {
                Write-IcingaConsoleError 'The remote host for address "{0}" could not be resolved' -Objects $Uri;
                break;
            };
            'System.InvalidOperationException' {
                Write-IcingaConsoleError 'Failed to query host "{0}". Possible this is caused by an invalid Proxy Server configuration: "{1}".' -Objects $Uri, $ProxyServer;
                break;
            };
            Default {
                Write-IcingaConsoleError 'Unhandled exception for Url "{0}" with error id "{1}":{2}{2}{3}' -Objects $Uri, $ErrorId, (New-IcingaNewLine), $Message;
                break;
            };
        }

        # Return some sort of objects which are often used to ensure we at least have some out-of-the-box compatibility
        return @{
            'HasErrors'    = $TRUE;
            'BaseResponse' = @{
                'ResponseUri' = @{
                    'AbsoluteUri' = $Uri;
                };
            };
            'StatusCode'   = 900;
        };
    }

    return $Response;
}

<#
.SYNOPSIS
   Sets the configuration for a proxy server which is used by all Invoke-WebRequests
   to ensure internet connections are working correctly.
.DESCRIPTION
   Sets the configuration for a proxy server which is used by all Invoke-WebRequests
   to ensure internet connections are working correctly.
.FUNCTIONALITY
   Sets the configuration for a proxy server which is used by all Invoke-WebRequests
   to ensure internet connections are working correctly.
.EXAMPLE
   PS>Set-IcingaFrameworkProxyServer -Server 'http://example.com:8080';
.PARAMETER Server
   The server with the port for the Proxy. Example: 'http://example.com:8080'
.INPUTS
   System.String
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Set-IcingaFrameworkProxyServer()
{
    param (
        [string]$Server = ''
    );

    Set-IcingaPowerShellConfig -Path 'Framework.Proxy.Server' -Value $Server;

    Write-IcingaConsoleNotice 'The Proxy server for the PowerShell Framework has been set to "{0}"' -Objects $Server;
}

<#
.SYNOPSIS
   Sets the allowed TLS version for communicating with endpoints to TLS 1.2 and 1.1
.DESCRIPTION
   Sets the allowed TLS version for communicating with endpoints to TLS 1.2 and 1.1
.FUNCTIONALITY
   Uses the [Net.ServicePointManager] to set the SecurityProtocol to TLS 1.2 and 1.1
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Set-IcingaTLSVersion()
{
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
}

function Close-IcingaTCPConnection()
{
    param(
        [System.Net.Sockets.TcpClient]$Client = $null
    );

    if ($null -eq $Client) {
        return;
    }

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Closing client connection for endpoint {0}',
            (Get-IcingaTCPClientRemoteEndpoint -Client $Client)
        )
    );

    $Client.Close();
    $Client.Dispose();
    $Client = $null;
}

function Close-IcingaTCPSocket()
{
    param(
        [System.Net.Sockets.TcpListener]$Socket = $null
    );

    if ($null -eq $Socket) {
        return;
    }

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Closing TCP socket {0}',
            $Socket.LocalEndpoint
        )
    );

    $Socket.Stop();
}

<#
.SYNOPSIS
   Converts a provided Authorization header to credentials
.DESCRIPTION
   Converts a provided Authorization header to credentials
.FUNCTIONALITY
   Converts a provided Authorization header to credentials
.EXAMPLE
   PS>Convert-Base64ToCredentials -AuthString "Basic =Bwebb474567b56756b...";
.PARAMETER AuthString
   The value of the Authorization header of the web request
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Convert-Base64ToCredentials()
{
    param (
        [String]$AuthString
    );

    [hashtable]$Credentials = @{};

    $AuthArray = $AuthString.Split(' ');

    switch ($AuthArray[0]) {
        'Basic' {
            $AuthString = $AuthArray[1];
        };
        default {
            Write-IcingaEventMessage -EventId 1550 -Namespace 'Framework' -Objects $AuthArray[0];
            return @{};
        }
    }

    # Convert the Base64 Secure String back to a normal string
    [string]$AuthString     = [System.Text.Encoding]::UTF8.GetString(
        [System.Convert]::FromBase64String(
            $AuthString
        )
    );

    # If no ':' is within the string, the credential data is not properly formated
    if ($AuthString.Contains(':') -eq $FALSE) {
        Write-IcingaEventMessage -EventId 1551 -Namespace 'Framework';
        $AuthString = $null;
        return $Credentials;
    }

    try {
        # Build our User Data and Password from the string
        [string]$UserData = $AuthString.Substring(
            0,
            $AuthString.IndexOf(':')
        );
        $Credentials.Add(
            'password',
            (
                ConvertTo-IcingaSecureString `
                    $AuthString.Substring($AuthString.IndexOf(':') + 1, $AuthString.Length - $UserData.Length - 1)
            )
        );

        $AuthString = $null;

        # Extract a possible domain
        if ($UserData.Contains('\')) {
            # Split the auth string on the '\'
            [array]$AuthData = $UserData.Split('\');
            # First value of the array is the Domain, second is the Username
            $Credentials.Add('domain', $AuthData[0]);
            $Credentials.Add(
                'user',
                (
                    ConvertTo-IcingaSecureString $AuthData[1]
                )
            );
            $AuthData = $null;
        } else {
            $Credentials.Add('domain', $null);
            $Credentials.Add(
                'user',
                (
                    ConvertTo-IcingaSecureString $UserData
                )
            );
        }

        $UserData = $null;
    } catch {
        Write-IcingaEventMessage -EventId 1552 -Namespace 'Framework' -Objects $_.Exception;
        return @{};
    }

    return $Credentials;
}

function ConvertTo-IcingaX509Certificate()
{
    param(
        [string]$CertFile          = $null,
        [string]$OutFile           = $null,
        [switch]$Force             = $FALSE
    );

    if ([string]::IsNullOrEmpty($CertFile)) {
        throw 'Please specify a valid path to an existing certificate (.cer, .pem, .cert)';
    }

    if ((Test-Path $CertFile) -eq $FALSE) {
        throw 'The provided path to your certificate was not valid';
    }

    # Use an empty password for converted certificates
    $Password       = $null;
    # Use a target file to specify if we use temp files or not
    $TargetFile     = $OutFile;
    # Temp Cert
    [bool]$TempFile = $FALSE;

    # Create a temp file to store the certificate in
    if ([string]::IsNullOrEmpty($OutFile)) {
        # Create a temporary file for full path and name
        $TargetFile = New-IcingaTemporaryFile;
        # Get the actual path to work with
        $TargetFile = $TargetFile.FullName;
        # Set internally that we are using a temp file
        $TempFile   = $TRUE;
        # Delete the file again
        Remove-Item $TargetFile -Force -ErrorAction SilentlyContinue;
    }

    # Convert our certificate if our target file does not exist
    # it is a temp file or we force its creation
    if (-Not (Test-Path $TargetFile) -Or $TempFile -Or $Force) {
        Write-Output "$Password
        $Password" | certutil -mergepfx "$CertFile" "$TargetFile" | Set-Variable -Name 'CertUtilOutput';
    }

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Certutil merge request has been completed. Certutil message:{0}{0}{1}',
            (New-IcingaNewLine),
            $CertUtilOutput
        )
    );

    # If no target file exists afterwards (a valid PFX certificate)
    # then throw an exception
    if (-Not (Test-Path $TargetFile)) {
        throw 'The specified/created certificate file could not be found.';
    }

    # Now load the actual certificate from the path
    $Certificate = New-Object Security.Cryptography.X509Certificates.X509Certificate2 $TargetFile;
    # Delete the PFX-Certificate which will be present after certutil merge
    if ($TempFile) {
        Remove-Item $TargetFile -Force -ErrorAction SilentlyContinue;
    }

    # Return the certificate
    return $Certificate
}

function Disable-IcingaUntrustedCertificateValidation()
{
    try {
        [System.Net.ServicePointManager]::CertificatePolicy = $null;

        Write-IcingaConsoleNotice 'Successfully disabled untrusted certificate validation for this shell instance';
    } catch {
        Write-IcingaConsoleError (
            [string]::Format(
                'Failed to disable untrusted certificate policy: {0}', $_.Exception.Message
            )
        );
    }
}

function Enable-IcingaUntrustedCertificateValidation()
{
    param (
        [switch]$SuppressMessages = $FALSE
    );

    try {
        # There is no other way as to use C# for this specific
        # case to configure the certificate validation check
        Add-Type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;

        public class IcingaUntrustedCertificateValidation : ICertificatePolicy {
            public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@

        [System.Net.ServicePointManager]::CertificatePolicy = New-Object IcingaUntrustedCertificateValidation;

        if ($SuppressMessages -eq $FALSE) {
            Write-IcingaConsoleNotice 'Successfully enabled untrusted certificate validation for this shell instance';
        }
    } catch {
        if ($SuppressMessages -eq $FALSE) {
            Write-IcingaConsoleError -Message 'Failed to enable untrusted certificate policy: {0}' -Objects $_.Exception.Message;
        }
    }
}

function Get-IcingaRESTHeaderValue()
{
    param(
        [hashtable]$Request = @{},
        [string]$Header     = $null
    );

    if ($null -eq $Request -or [string]::IsNullOrEmpty($Header) -Or $Request.Count -eq 0) {
        return $null;
    }

    if ($Request.Header.ContainsKey($Header) -eq $FALSE) {
        return $null
    }

    return $Request.Header[$Header];
}

function Get-IcingaRESTPathElement()
{
    param(
        [Hashtable]$Request = @{},
        [int]$Index         = 0
    );

    if ($null -eq $Request -Or $Request.Count -eq 0) {
        return '';
    }

    if ($Request.ContainsKey('RequestPath') -eq $FALSE) {
        return '';
    }

    if (($Index + 1) -gt $Request.RequestPath.PathArray.Count) {
        return '';
    }

    return $Request.RequestPath.PathArray[$Index];
}

function Get-IcingaSSLCertForSocket()
{
    param(
        [string]$CertFile       = $null,
        [string]$CertThumbprint = $null
    );

    # At first check if we assigned a cert file to use directly and check
    # if it is there and either import a PFX or use our convert function
    # to get a proper certificate
    if ([string]::IsNullOrEmpty($CertFile) -eq $FALSE) {
        if ((Test-Path $CertFile)) {
            if ([IO.Path]::GetExtension($CertFile) -eq '.pfx') {
                return (New-Object Security.Cryptography.X509Certificates.X509Certificate2 $CertFile);
            } else {
                return ConvertTo-IcingaX509Certificate -CertFile $CertFile;
            }
        }
    }

    # We could also have assigned a Thumbprint to use from the
    # Windows cert store. Try to look it up an return it if
    # it is found
    if ([string]::IsNullOrEmpty($CertThumbprint) -eq $FALSE) {
        $Certificates = Get-ChildItem `
            -Path 'cert:\*' `
            -Recurse `
            -Include $CertThumbprint `
            -ErrorAction SilentlyContinue `
            -WarningAction SilentlyContinue;

        if ($Certificates.Count -ne 0) {
            return $Certificates[0];
        }
    }

    # If no cert file or thumbprint was specified or simpy as fallback,
    # we should use the Icinga 2 Agent certificates
    $AgentCertificate = Get-IcingaAgentHostCertificate;

    # If Agent is not installed or certificates were not found,
    # simply return null
    if ($null -eq $AgentCertificate) {
        return $null;
    }

    return (ConvertTo-IcingaX509Certificate -CertFile $AgentCertificate.CertFile);
}

function Get-IcingaTCPClientRemoteEndpoint()
{
    param(
        [System.Net.Sockets.TcpClient]$Client = $null
    );

    if ($null -eq $Client) {
        return 'unknown';
    }

    return $Client.Client.RemoteEndPoint;
}

<#
 # This script will provide 'Enums' we can use within our module to
 # easier access constants and to maintain a better overview of the
 # entire components
 #>
[hashtable]$HTTPResponseCode = @{
    200 = 'Ok';
    400 = 'Bad Request';
    401 = 'Unauthorized';
    403 = 'Forbidden';
    404 = 'Not Found'
    500 = 'Internal Server Error';
};

[hashtable]$HTTPResponseType = @{
    'Ok'                    = 200;
    'Bad Request'           = 400;
    'Unauthorized'          = 401;
    'Forbidden'             = 403;
    'Not Found'             = 404;
    'Internal Server Error' = 500;
};

<#
 # Once we defined a new enum hashtable above, simply add it to this list
 # to make it available within the entire module.
 #
 # Example usage:
 # $IcingaHTTPEnums.HTTPResponseType.Ok
 #>
[hashtable]$IcingaHTTPEnums = @{
    HTTPResponseCode = $HTTPResponseCode;
    HTTPResponseType = $HTTPResponseType;
}

Export-ModuleMember -Variable @( 'IcingaHTTPEnums' );

function New-IcingaSSLStream()
{
    param(
        [System.Net.Sockets.TcpClient]$Client                                 = $null,
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null
    );

    if ($null -eq $Client) {
        return $null;
    }

    try {
        $SSLStream = New-Object System.Net.Security.SslStream($Client.GetStream(), $false)
        $SSLStream.AuthenticateAsServer($Certificate, $false, [System.Security.Authentication.SslProtocols]::Tls12, $true) | Out-Null;
    } catch {
        Write-IcingaEventMessage -EventId 1500 -Namespace 'Framework' -Objects $Client.Client;
        return $null;
    }

    return $SSLStream;
}

function New-IcingaTCPClient()
{
    param(
        [System.Net.Sockets.TcpListener]$Socket = $null
    );

    if ($null -eq $Socket) {
        return $null;
    }

    [System.Net.Sockets.TcpClient]$Client = $Socket.AcceptTcpClient();

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'New incoming client connection for endpoint {0}',
            (Get-IcingaTCPClientRemoteEndpoint -Client $Client)
        )
    );

    return $Client;
}

function New-IcingaTCPClientRESTMessage()
{
    param(
        [Hashtable]$Headers = $null,
        $ContentBody        = $null,
        [int]$HTTPResponse  = 200,
        [switch]$BasicAuth  = $FALSE
    );

    [string]$ContentLength = '';
    [string]$HTMLContent   = '';
    [string]$AuthHeader    = '';

    if ($null -ne $ContentBody) {
        $json         = ConvertTo-Json $ContentBody -Depth 100 -Compress;
        $bytes        = [System.Text.Encoding]::UTF8.GetBytes($json);
        $HTMLContent  = [System.Text.Encoding]::UTF8.GetString($bytes);
        if ($bytes.Length -gt 0) {
            $ContentLength = [string]::Format(
                'Content-Length: {0}{1}',
                $bytes.Length,
                (New-IcingaNewLine)
            );
        }
    }

    if ($BasicAuth) {
        $AuthHeader = [string]::Format(
            'WWW-Authenticate: Basic realm="Icinga for Windows"{0}',
            (New-IcingaNewLine)
        );
    }

    $ResponseMeessage = -Join(
        [string]::Format(
            'HTTP/1.1 {0} {1}{2}',
            $HTTPResponse,
            $IcingaHTTPEnums.HTTPResponseCode[$HTTPResponse],
            (New-IcingaNewLine)
        ),
        [string]::Format(
            'Server: {0}{1}',
            (Get-IcingaHostname -LowerCase $TRUE -AutoUseFQDN $TRUE),
            (New-IcingaNewLine)
        ),
        [string]::Format(
            'Content-Type: application/json{0}',
            (New-IcingaNewLine)
        ),
        $AuthHeader,
        $ContentLength,
        (New-IcingaNewLine),
        $HTMLContent
    );

    # Encode our message before sending it
    $UTF8Message = [System.Text.Encoding]::UTF8.GetBytes($ResponseMeessage);

    return @{
        'message' = $UTF8Message;
        'length'  = $UTF8Message.Length;
    };
}

function New-IcingaTCPSocket()
{
    param (
        [string]$Address = '',
        [int]$Port       = 0,
        [switch]$Start   = $FALSE
    );

    if ($Port -eq 0) {
        throw 'Please specify a valid port to open a TCP socket for';
    }

    # Listen on localhost by default
    $ListenAddress = New-Object System.Net.IPEndPoint([IPAddress]::Loopback, $Port);

    if ([string]::IsNullOrEmpty($Address) -eq $FALSE) {
        $ListenAddress = New-Object System.Net.IPEndPoint([IPAddress]::Parse($Address), $Port);
    }

    $TCPSocket = New-Object 'System.Net.Sockets.TcpListener' $ListenAddress;

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Creating new TCP socket on Port {0}. Endpoint configuration {1}',
            $Port,
            $TCPSocket.LocalEndpoint
        )
    );

    if ($Start) {
        Write-IcingaDebugMessage -Message (
            [string]::Format(
                'Starting TCP socket for endpoint {0}',
                $TCPSocket.LocalEndpoint
            )
        );
        $TCPSocket.Start();
    }

    return $TCPSocket;
}

function Open-IcingaTCPClientConnection()
{
    param(
        [System.Net.Sockets.TcpClient]$Client                                 = $null,
        [Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = $null
    );

    if ($null -eq $Client -Or $null -eq $Certificate) {
        return $null;
    }

    $Stream = New-IcingaSSLStream -Client $Client -Certificate $Certificate;

    return @{
        'Client' = $Client;
        'Stream' = $Stream;
    };
}

function Read-IcingaRESTMessage()
{
    param(
        [string]$RestMessage   = $null,
        [hashtable]$Connection = $null
    );

    # Just in case we didnt receive anything - no need to
    # parse through everything
    if ([string]::IsNullOrEmpty($RestMessage)) {
        return $null;
    }

    Write-IcingaDebugMessage (
        [string]::Format(
            'Receiving client message{0}{0}{1}',
            (New-IcingaNewline),
            $RestMessage
        )
    );

    [hashtable]$Request = @{};
    $RestMessage -match '(.+) (.+) (.+)' | Out-Null;

    $Request.Add('Method', $Matches[1]);
    $Request.Add('FullRequest', $Matches[2]);
    $Request.Add('RequestPath', @{});
    $Request.Add('RequestArguments', @{});

    #Path
    $PathMatch = $Matches[2];
    $PathMatch -match '((\/[^\/\?]+)*)\??([^\/]*)' | Out-Null;
    $Arguments = $Matches[3];
    $Request.RequestPath.Add('FullPath', $Matches[1]);
    $Request.RequestPath.Add('PathArray', $Matches[1].TrimStart('/').Split('/'));

    $Matches = $null;

    # Arguments
    $ArgumentsSplit = $Arguments.Split('&');
    $ArgumentsSplit+='\\\\\\\\\\\\=FIN';
    foreach ( $Argument in $ArgumentsSplit | Sort-Object -Descending) {
        if ($Argument.Contains('=')) {
            $Argument -match '(.+)=(.+)' | Out-Null;
            If (($Matches[1] -ne $Current) -And ($NULL -ne $Current)) {
                $Request.RequestArguments.Add( $Current, $ArgumentContent );
                [array]$ArgumentContent = $null;
            }
            $Current = $Matches[1];
            [array]$ArgumentContent += ($Matches[2]);
        } else {
            $Request.RequestArguments.Add( $Argument, $null );
        }
    }

    # Header
    $Request.Add( 'Header', @{ } );
    $SplitString = $RestMessage.Split("`r`n");

    foreach ( $SingleString in $SplitString ) {
        if ( ([string]::IsNullOrEmpty($SingleString) -eq $FALSE) -And ($SingleString -match '^{.+' -eq $FALSE) -And $SingleString.Contains(':') -eq $TRUE ) {
            $SingleSplitString = $SingleString.Split(':', 2);
            $Request.Header.Add( $SingleSplitString[0], $SingleSplitString[1].Trim());
        }
    }

    $Request.Add('ContentLength', [int](Get-IcingaRESTHeaderValue -Header 'Content-Length' -Request $Request));

    $Matches = $null;

    # Body
    $RestMessage -match '(\{(.*\n)*}|\{.*\})' | Out-Null;

    if ($null -ne $Matches) {
        $Request.Add('Body', $Matches[1]);
    }

    # We received a content length, but couldnt load the body. Some clients will send the body as separate message
    # Lets try to read the body content
    if ($null -ne $Connection) {
        if ($Request.ContainsKey('ContentLength') -And $Request.ContentLength -gt 0 -And ($Request.ContainsKey('Body') -eq $FALSE -Or [string]::IsNullOrEmpty($Request.Body))) {
            $Request.Body = Read-IcingaTCPStream -Client $Connection.Client -Stream $Connection.Stream -ReadLength $Request.ContentLength;
            Write-IcingaDebugMessage -Message 'Body Content' -Objects $Request;
        }
    }

    return $Request;
}

function Read-IcingaTCPStream()
{
    param(
        [System.Net.Sockets.TcpClient]$Client  = @{},
        [System.Net.Security.SslStream]$Stream = $null,
        [int]$ReadLength                       = 0
    );

    if ($ReadLength -eq 0) {
        $ReadLength = $Client.ReceiveBufferSize;
    }

    if ($null -eq $Stream) {
        return $null;
    }

    # Get the maxium size of our buffer
    [byte[]]$bytes = New-Object byte[] $ReadLength;

    # Read the content of our SSL stream
    $MessgeSize = $Stream.Read($bytes, 0, $ReadLength);

    Write-IcingaDebugMessage -Message 'Network Stream message size and content in bytes' -Objects $MessgeSize, $bytes;

    # Resize our array to the correct size
    [byte[]]$resized = New-Object byte[] $MessgeSize;
    [array]::Copy($bytes, 0, $resized, 0, $MessgeSize);

    # Return our message content
    return [System.Text.Encoding]::UTF8.GetString($resized);
}

function Send-IcingaTCPClientMessage()
{
    param(
        [Hashtable]$Message                     = @{},
        [System.Net.Security.SslStream]$Stream = $null
    );

    if ($null -eq $Message -Or $Message.Count -eq 0 -Or $Message.length -eq 0) {
        return;
    }

    $Stream.Write($Message.message, 0, $Message.length);
    $Stream.Flush();
}

<#
.SYNOPSIS
   Sends a basic auth request back to the client
.DESCRIPTION
   Sends a basic auth request back to the client
.FUNCTIONALITY
   Sends a basic auth request back to the client
.EXAMPLE
   PS>Send-IcingaWebAuthMessage -Connection $Connection;
.PARAMETER Connection
   The connection data of the Framework containing the client and stream object
.INPUTS
   System.Hashtable
.OUTPUTS
   Null
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Send-IcingaWebAuthMessage()
{
    param (
        [Hashtable]$Connection = @{}
    );

    Send-IcingaTCPClientMessage -Message (
        New-IcingaTCPClientRESTMessage `
            -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.Unauthorized) `
            -ContentBody 'Please provide your credentials for login.' `
            -BasicAuth
    ) -Stream $Connection.Stream;
}


<#
.SYNOPSIS
   Tests provided credentials against either the local machine or a domain controller
.DESCRIPTION
   Tests provided credentials against either the local machine or a domain controller
.FUNCTIONALITY
   Tests provided credentials against either the local machine or a domain controller
.EXAMPLE
   PS>Test-IcingaRESTCredentials $UserName $SecureUser -Password $SecurePassword;
.EXAMPLE
   PS>Test-IcingaRESTCredentials $UserName $SecureUser -Password $SecurePassword -Domain 'Example';
.PARAMETER UserName
   The username to use for login as SecureString
.PARAMETER Password
   The password to use for login as SecureString
.PARAMETER Domain
   The domain to use for login as string
.INPUTS
   System.SecureString
.OUTPUTS
   System.Boolean
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Test-IcingaRESTCredentials()
{
    param (
        [SecureString]$UserName,
        [SecureString]$Password,
        [String]$Domain
    );

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement;

    # Base handling: We try to authenticate against a local user on the machine
    [string]$AuthMethod = [System.DirectoryServices.AccountManagement.ContextType]::Machine;
    [string]$AuthDomain = $env:COMPUTERNAME;

    # If we specify a domain, we should authenticate against our Domain
    if ([string]::IsNullOrEmpty($Domain) -eq $FALSE) {
        $AuthMethod = [System.DirectoryServices.AccountManagement.ContextType]::Domain;
        $AuthDomain = $Domain;
    }

    try {
        # Create an Account Management object based on the above determined settings
        $AccountService = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
            $AuthMethod,
            $AuthDomain
        );
    } catch {
        # Regardless of the error, print the message and return false to prevent further execution
        Write-IcingaEventMessage -EventId 1560 -Namespace 'Framework' -Objects $_.Exception;
        return $FALSE;
    }

    # In case we couldn't setup the Account Service, always return false
    if ($null -eq $AccountService) {
        return $FALSE;
    }

    try {
        # Try to authenticate and either return true or false as integer
        [bool]$AuthResult = [int]($AccountService.ValidateCredentials(
                (ConvertFrom-IcingaSecureString $UserName),
                (ConvertFrom-IcingaSecureString $Password)
            )
        );

        return $AuthResult;
    } catch {
        Write-IcingaEventMessage -EventId 1561 -Namespace 'Framework' -Objects $_.Exception;
    }

    return $FALSE;
}

<#
.SYNOPSIS
    Sets permissions for a specific Wmi namespace for a user. You can grant basic permissions based
    on the arguments available and grant additional ones with the `-Flags` argument.
.DESCRIPTION
    Sets permissions for a specific Wmi namespace for a user. You can grant basic permissions based
    on the arguments available and grant additional ones with the `-Flags` argument.
.PARAMETER User
    The user to set permissions for. Can either be a local or domain user
.PARAMETER Namespace
    The Wmi namespace to grant permissions for. Required namespaces are listed within each plugin documentation
.PARAMETER Enable
    Enables the account and grants the user read permissions. This is a default access right for all users and corresponds to the Enable Account permission on the Security tab of the WMI Control. For more information, see Setting Namespace Security with the WMI Control.
.PARAMETER RemoteAccess
    Allows a user account to remotely perform any operations allowed by the permissions described above. Only members of the Administrators group have this right. WBEM_REMOTE_ACCESS corresponds to the Remote Enable permission on the Security tab of the WMI Control.
.PARAMETER Recurse
    Applies a container inherit flag and grants permission not only on the specific Wmi tree but also objects within this namespace (recommended)
.PARAMETER DenyAccess
    Blocks the user from having access to this Wmi and or subnamespace tree.
.PARAMETER Flags
    Allows to specify additional flags for permssion granting: PartialWrite, Subscribe, ProviderWrite,ReadSecurity, WriteSecurity, Publish, MethodExecute, FullWrite
.EXAMPLE
    PS>Add-IcingaWmiPermissions -Namespace 'root\cimv2' -User icinga -Enable;
.EXAMPLE
    PS>Add-IcingaWmiPermissions -Namespace 'root\cimv2' -User 'ICINGADOMAIN\icinga' -Enable -RemoteAccess;
.EXAMPLE
    PS>Add-IcingaWmiPermissions -Namespace 'root\cimv2' -User 'ICINGADOMAIN\icinga' -Enable -RemoteAccess -Recurse;
.EXAMPLE
    PS>Add-IcingaWmiPermissions -Namespace 'root\cimv2' -User 'ICINGADOMAIN\icinga' -Enable -RemoteAccess -Flags 'ReadSecurity', 'MethodExecute' -Recurse;
.INPUTS
    System.String
.OUTPUTS
    System.Boolean
#>

function Add-IcingaWmiPermissions()
{
    param (
        [string]$User,
        [string]$Namespace,
        [switch]$Enable,
        [switch]$RemoteAccess,
        [switch]$Recurse,
        [switch]$DenyAccess,
        [array]$Flags
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError 'Please enter a valid username';
        return $FALSE;
    }

    if ([string]::IsNullOrEmpty($Namespace)) {
        Write-IcingaConsoleError 'You have to specify a Wmi namespace to grant permissions for';
        return $FALSE;
    }

    [int]$PermissionMask = New-IcingaWmiPermissionMask -Enable:$Enable -RemoteAccess:$RemoteAccess -Flags $Flags;

    if ($PermissionMask -eq 0) {
        Write-IcingaConsoleError 'You have to specify permissions to grant for a specific user';
        return $FALSE;
    }

    if (Test-IcingaWmiPermissions -User $User -Namespace $Namespace -Enable:$Enable -RemoteAccess:$RemoteAccess -Recurse:$Recurse -DenyAccess:$DenyAccess -Flags $Flags) {
        Write-IcingaConsoleNotice 'Wmi permissions for user "{0}" are already set.' -Objects $User;
        return $TRUE;
    } else {
        Write-IcingaConsoleNotice 'Removing possible existing configuration for this user before continuing';
        Remove-IcingaWmiPermissions -User $User -Namespace $Namespace | Out-Null;
    }

    $WmiSecurity = Get-IcingaWmiSecurityData -User $User -Namespace $Namespace;

    if ($null -eq $WmiSecurity) {
        return $FALSE;
    }

    $WmiAce            = (New-Object System.Management.ManagementClass("Win32_Ace")).CreateInstance();
    $WmiAce.AccessMask = $PermissionMask;

    if ($Recurse) {
        $WmiAce.AceFlags = $IcingaWBEM.AceFlags.Container_Inherit;
    } else {
        $WmiAce.AceFlags = 0;
    }

    $WmiTrustee           = (New-Object System.Management.ManagementClass("Win32_Trustee")).CreateInstance();
    $WmiTrustee.SidString = Get-IcingaUserSID -User $User;
    $WmiAce.Trustee       = $WmiTrustee

    if ($DenyAccess) {
        $WmiAce.AceType = $IcingaWBEM.AceFlags.Access_Denied;
    } else {
        $WmiAce.AceType = $IcingaWBEM.AceFlags.Access_Allowed;
    }

    $WmiSecurity.WmiAcl.DACL += $WmiAce.PSObject.immediateBaseObject;

    $WmiSecurity.WmiArguments.Name = 'SetSecurityDescriptor';
    $WmiSecurity.WmiArguments.Add('ArgumentList', $WmiSecurity.WmiAcl.PSObject.immediateBaseObject);
    $WmiArguments = $WmiSecurity.WmiArguments;
 
    $WmiSecurityData = Invoke-WmiMethod @WmiArguments;
    if ($WmiSecurityData.ReturnValue -ne 0) {
        Write-IcingaConsoleError 'Failed to set Wmi security descriptor information with error {0}' -Objects $WmiSecurityData.ReturnValue;
        return $FALSE;
    }

    Write-IcingaConsoleNotice 'Wmi permissions for Namespace "{0}" and user "{1}" have been set successfully' -Objects $Namespace, $User;

    return $TRUE;
}

<#
.SYNOPSIS
    Allows to query Wmi information by either using Wmi directly or Cim. This provides a save handling
    to call Wmi classes, as we are catching possible errors including missing permissions for better
    and improved error output during plugin execution.
.DESCRIPTION
    Allows to query Wmi information by either using Wmi directly or Cim. This provides a save handling
    to call Wmi classes, as we are catching possible errors including missing permissions for better
    and improved error output during plugin execution.
.PARAMETER ClassName
    The Wmi class to fetch information from
.PARAMETER Filter
    Allows to filter only for specific Wmi information. The syntax is identical to Get-WmiObject and Get-CimInstance
.PARAMETER Namespace
    The Wmi namespace to lookup additional information. The syntax is identical to Get-WmiObject and Get-CimInstance
.PARAMETER ForceWMI
    Forces the usage of `Get-WmiObject` instead of `Get-CimInstance`
.EXAMPLE
    PS>Get-IcingaWindowsInformation -ClassName Win32_Service;
.EXAMPLE
    PS>Get-IcingaWindowsInformation -ClassName Win32_Service -ForceWMI;
.EXAMPLE
    PS>Get-IcingaWindowsInformation -ClassName MSFT_NetAdapter -NameSpace 'root\StandardCimv2';
.EXAMPLE
    PS>Get-IcingaWindowsInformation Win32_LogicalDisk -Filter 'DriveType = 3';
.INPUTS
    System.String
.OUTPUTS
    System.Boolean
#>

function Get-IcingaWindowsInformation()
{
    param (
        [string]$ClassName,
        $Filter,
        $Namespace,
        [switch]$ForceWMI  = $FALSE
    );

    $Arguments = @{
        'ClassName' = $ClassName;
    }

    if ([string]::IsNullOrEmpty($Filter) -eq $FALSE) {
        $Arguments.Add(
            'Filter', $Filter
        );
    }
    if ([string]::IsNullOrEmpty($Namespace) -eq $FALSE) {
        $Arguments.Add(
            'Namespace', $Namespace
        );
    }

    if ($ForceWMI -eq $FALSE -And (Get-Command 'Get-CimInstance' -ErrorAction SilentlyContinue)) {
        try {
            $CimData = (Get-CimInstance @Arguments -ErrorAction Stop);

            Write-IcingaDebugMessage 'Debug output for "Get-IcingaWindowsInformation::Get-CimInstance"' -Objects $ClassName, $Filter, $Namespace, ($CimData | Out-String);

            return $CimData;
        } catch {
            $ErrorName    = $_.Exception.NativeErrorCode;
            $ErrorMessage = $_.Exception.Message;
            $ErrorCode    = $_.Exception.StatusCode;

            if ([string]::IsNullOrEmpty($Namespace)) {
                $Namespace = 'root/cimv2';
            }

            switch ($ErrorCode) {
                # Permission error
                2 {
                    Exit-IcingaThrowException -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.CimInstance -CustomMessage ([string]::Format('Class: "{0}", Namespace: "{1}"', $ClassName, $Namespace)) -Force;
                };
                # InvalidClass
                5 {
                    Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.CimClassNameUnknown -CustomMessage $ClassName -Force;
                };
                # All other errors
                default {
                    Exit-IcingaThrowException -ExceptionType 'Custom' -InputString $ErrorMessage -CustomMessage ([string]::Format('CimInstanceUnhandledError: Class "{0}": Error "{1}": Id "{2}"', $ClassName, $ErrorName, $ErrorCode)) -Force;
                }
            }
        }
    }

    if ((Get-Command 'Get-WmiObject' -ErrorAction SilentlyContinue)) {
        try {
            $WmiData = (Get-WmiObject @Arguments -ErrorAction Stop);

            Write-IcingaDebugMessage 'Debug output for "Get-IcingaWindowsInformation::Get-WmiObject"' -Objects $ClassName, $Filter, $Namespace, ($WmiData | Out-String);

            return $WmiData;
        } catch {
            $ErrorName    = $_.CategoryInfo.Category;
            $ErrorMessage = $_.Exception.Message;
            $ErrorCode    = ($_.Exception.HResult -band 0xFFFF);

            if ([string]::IsNullOrEmpty($Namespace)) {
                $Namespace = 'root/cimv2';
            }

            switch ($ErrorName) {
                # Permission error
                'InvalidOperation' {
                    Exit-IcingaThrowException -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.WMIObject -CustomMessage ([string]::Format('Class: "{0}", Namespace: "{1}"', $ClassName, $Namespace)) -Force;
                };
                # Invalid Class
                'InvalidType' {
                    Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.WmiObjectClassUnknown -CustomMessage $ClassName -Force;
                };
                # All other errors
                default {
                    Exit-IcingaThrowException -ExceptionType 'Custom' -InputString $ErrorMessage -CustomMessage ([string]::Format('WmiObjectUnhandledError: Class "{0}": Error "{1}": Id "{2}"', $ClassName, $ErrorName, $ErrorCode)) -Force;
                }
            }
        }
    }

    # Exception
    Exit-IcingaThrowException -ExceptionType 'Custom' -InputString 'Failed to fetch Windows information by using CimInstance or WmiObject. Both commands are not present on the system.' -CustomMessage ([string]::Format('CimWmiUnhandledError: Class "{0}"', $ClassName)) -Force;
}

<#
.SYNOPSIS
    Returns several information about the Wmi namespace and the provided user data to
    work with them while adding/testing/removing Wmi permissions
.DESCRIPTION
    Returns several information about the Wmi namespace and the provided user data to
    work with them while adding/testing/removing Wmi permissions
.PARAMETER User
    The user to set permissions for. Can either be a local or domain user
.PARAMETER Namespace
    The Wmi namespace to grant permissions for. Required namespaces are listed within each plugin documentation
.INPUTS
    System.String
.OUTPUTS
    System.Hashtable
#>

function Get-IcingaWmiSecurityData()
{
    param (
        [string]$User,
        [string]$Namespace
    );

    [hashtable]$WmiArguments = @{
        'Name'      = 'GetSecurityDescriptor';
        'Namespace' = $Namespace;
        'Path'      = "__systemsecurity=@";
    }

    $WmiSecurityData = Invoke-WmiMethod @WmiArguments;

    if ($WmiSecurityData.ReturnValue -ne 0) {
        Write-IcingaConsoleError 'Fetching Wmi security descriptor information failed with error {0}' -Objects $WmiSecurityData.ReturnValue;
        return $null;
    }

    $UserData = Split-IcingaUserDomain -User $User;
    $UserSID  = Get-IcingaUserSID -User $User;
    $WmiAcl   = $WmiSecurityData.Descriptor;

    if ([string]::IsNullOrEmpty($UserSID)) {
        Write-IcingaConsoleError 'Unable to load the SID for user "{0}"' -Objects $User;
        return $null;
    }

    return @{
        'WmiArguments' = $WmiArguments;
        'UserData'     = $UserData;
        'UserSID'      = $UserSID;
        'WmiAcl'       = $WmiAcl;
    }
}

<#
 # WMI WBEM_SECURITY_FLAGS
 # https://docs.microsoft.com/en-us/windows/win32/api/wbemcli/ne-wbemcli-wbem_security_flags
 # https://docs.microsoft.com/en-us/windows/win32/secauthz/standard-access-rights
 #>
 
 [hashtable]$SecurityFlags = @{
    'WBEM_Enable'            = 1;
    'WBEM_Method_Execute'    = 2;
    'WBEM_Full_Write_Rep'    = 4;
    'WBEM_Partial_Write_Rep' = 8;
    'WBEM_Write_Provider'    = 0x10;
    'WBEM_Remote_Access'     = 0x20;
    'WBEM_Right_Subscribe'   = 0x40;
    'WBEM_Right_Publish'     = 0x80;
    'Read_Control'           = 0x20000;
    'Write_DAC'              = 0x40000;
};

[hashtable]$SecurityDescription = @{
    1       = 'Enables the account and grants the user read permissions. This is a default access right for all users and corresponds to the Enable Account permission on the Security tab of the WMI Control. For more information, see Setting Namespace Security with the WMI Control.';
    2       = 'Allows the execution of methods. Providers can perform additional access checks. This is a default access right for all users and corresponds to the Execute Methods permission on the Security tab of the WMI Control.';
    4       =  'Allows a user account to write to classes in the WMI repository as well as instances. A user cannot write to system classes. Only members of the Administrators group have this permission. WBEM_FULL_WRITE_REP corresponds to the Full Write permission on the Security tab of the WMI Control.';
    8       = 'Allows you to write data to instances only, not classes. A user cannot write classes to the WMI repository. Only members of the Administrators group have this right. WBEM_PARTIAL_WRITE_REP corresponds to the Partial Write permission on the Security tab of the WMI Control.';
    0x10    = 'Allows writing classes and instances to providers. Note that providers can do additional access checks when impersonating a user. This is a default access right for all users and corresponds to the Provider Write permission on the Security tab of the WMI Control.';
    0x20    = 'Allows a user account to remotely perform any operations allowed by the permissions described above. Only members of the Administrators group have this right. WBEM_REMOTE_ACCESS corresponds to the Remote Enable permission on the Security tab of the WMI Control.';
    0x40    = 'Specifies that a consumer can subscribe to the events delivered to a sink. Used in IWbemEventSink::SetSinkSecurity.';
    0x80    = 'Specifies that the account can publish events to the instance of __EventFilter that defines the event filter for a permanent consumer. Available in wbemcli.h.';
    0x20000 = 'The right to read the information in the objects security descriptor, not including the information in the system access control list (SACL).';
    0x40000 = 'The right to modify the discretionary access control list (DACL) in the objects security descriptor.';
};

[hashtable]$SecurityNames = @{
    'Enable'        = 'WBEM_Enable';
    'MethodExecute' = 'WBEM_Method_Execute';
    'FullWrite'     = 'WBEM_Full_Write_Rep';
    'PartialWrite'  = 'WBEM_Partial_Write_Rep';
    'ProviderWrite' = 'WBEM_Write_Provider';
    'RemoteAccess'  = 'WBEM_Remote_Access';
    'Subscribe'     = 'WBEM_Right_Subscribe';
    'Publish'       = 'WBEM_Right_Publish';
    'ReadSecurity'  = 'Read_Control';
    'WriteSecurity' = 'Write_DAC';
};

[hashtable]$AceFlags = @{
    'Access_Allowed'    = 0x0;
    'Access_Denied'     = 0x1;
    'Container_Inherit' = 0x2;
}

[hashtable]$IcingaWBEM = @{
    SecurityFlags       = $SecurityFlags;
    SecurityDescription = $SecurityDescription
    SecurityNames       = $SecurityNames;
    AceFlags            = $AceFlags;
}

Export-ModuleMember -Variable @( 'IcingaWBEM' );

<#
.SYNOPSIS
    Generates a permission mask based on the set and provided flags which are used
    for adding/testing Wmi permissions
.DESCRIPTION
    Generates a permission mask based on the set and provided flags which are used
    for adding/testing Wmi permissions
.PARAMETER Enable
    Enables the account and grants the user read permissions. This is a default access right for all users and corresponds to the Enable Account permission on the Security tab of the WMI Control. For more information, see Setting Namespace Security with the WMI Control.
.PARAMETER RemoteAccess
    Allows a user account to remotely perform any operations allowed by the permissions described above. Only members of the Administrators group have this right. WBEM_REMOTE_ACCESS corresponds to the Remote Enable permission on the Security tab of the WMI Control.
.PARAMETER Flags
    Allows to specify additional flags for permssion granting: PartialWrite, Subscribe, ProviderWrite,ReadSecurity, WriteSecurity, Publish, MethodExecute, FullWrite
.INPUTS
    System.String
.OUTPUTS
    System.Int
#>

function New-IcingaWmiPermissionMask()
{
    param (
        [switch]$Enable,
        [switch]$RemoteAccess,
        [array]$Flags
    );

    [int]$PermissionMask = 0;

    if ($Enable) {
        $PermissionMask += $IcingaWBEM.SecurityFlags.WBEM_Enable;
    }
    if ($RemoteAccess) {
        $PermissionMask += $IcingaWBEM.SecurityFlags.WBEM_Remote_Access;
    }

    foreach ($flag in $Flags) {
        if ($flag -like 'Enable' -And $Enable) {
            continue;
        }
        if ($flag -like 'RemoteAccess' -And $RemoteAccess) {
            continue;
        }

        if ($IcingaWBEM.SecurityNames.ContainsKey($flag) -eq $FALSE) {
            Write-IcingaConsoleError 'Invalid Security flag "{0}" . Supported flags: {1}' -Objects $flag, $IcingaWBEM.SecurityNames.Keys;
            return $FALSE;
        }

        $PermissionMask += $IcingaWBEM.SecurityFlags[$IcingaWBEM.SecurityNames[$flag]];
    }

    return $PermissionMask;
}

<#
.SYNOPSIS
    Removes a user from a specific Wmi namespace
.DESCRIPTION
    Removes a user from a specific Wmi namespace
.PARAMETER User
    The user to set permissions for. Can either be a local or domain user
.PARAMETER Namespace
    The Wmi namespace to grant permissions for. Required namespaces are listed within each plugin documentation
.INPUTS
    System.String
.OUTPUTS
    System.Boolean
#>

function Remove-IcingaWmiPermissions()
{
    param (
        [string]$User,
        [string]$Namespace
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError 'Please enter a valid username';
        return $FALSE;
    }

    if ([string]::IsNullOrEmpty($Namespace)) {
        Write-IcingaConsoleError 'You have to specify a Wmi namespace to grant permissions for';
        return $FALSE;
    }

    $WmiSecurity = Get-IcingaWmiSecurityData -User $User -Namespace $Namespace;

    if ($null -eq $WmiSecurity) {
        return $FALSE;
    }

    [System.Management.ManagementBaseObject[]]$RebasedDACL = @()
    [bool]$UserPresent = $FALSE;

    foreach ($entry in $WmiSecurity.WmiAcl.DACL) {
        if ($entry.Trustee.SidString -ne $WmiSecurity.UserSID) {
            $RebasedDACL += $entry.PSObject.immediateBaseObject;
        } else {
            $UserPresent = $TRUE;
        }
    }

    if ($UserPresent -eq $FALSE) {
        Write-IcingaConsoleNotice 'User "{0}" is not configured for namespace "{1}"' -Objects $User, $Namespace;
        return $TRUE;
    }

    $WmiSecurity.WmiAcl.DACL = $RebasedDACL.PSObject.immediateBaseObject;

    $WmiSecurity.WmiArguments.Name = 'SetSecurityDescriptor';
    $WmiSecurity.WmiArguments.Add('ArgumentList', $WmiSecurity.WmiAcl.PSObject.immediateBaseObject);
    $WmiArguments = $WmiSecurity.WmiArguments
 
    $WmiSecurityData = Invoke-WmiMethod @WmiArguments;
    if ($WmiSecurityData.ReturnValue -ne 0) {
        Write-IcingaConsoleError 'Failed to set Wmi security descriptor information with error {0}' -Objects $WmiSecurityData.ReturnValue;
        return $FALSE;
    }

    Write-IcingaConsoleNotice 'Removed user "{0}" from Namespace "{1}" successfully' -Objects $User, $Namespace;

    return $TRUE;
}

<#
.SYNOPSIS
    Tests if a specific WMI class including the Namespace can be accessed and returns status codes for possible errors/exceptions that might occur.
    Returns binary operator values for easier comparison. In case no errors occurred it will return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok
.DESCRIPTION
    Tests if a specific WMI class including the Namespace can be accessed and returns status codes for possible errors/exceptions that might occur.
    Returns binary operator values for easier comparison. In case no errors occurred it will return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok
.ROLE
    ### WMI Permissions

    No special permissions required as this Cmdlet will validate all input data and reports back the result.
.OUTPUTS
    Name                           Value
    ----                           -----
    Ok                             1
    EmptyClass                     2
    PermissionError                4
    ObjectNotFound                 8
    InvalidNameSpace               16
    UnhandledException             32
    NotSpecified                   64
    CimNotInstalled                128
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>
function Test-IcingaWindowsInformation()
{
    param (
        [string]$ClassName,
        [string]$NameSpace = 'Root\Cimv2'
    );

    if ([string]::IsNullOrEmpty($ClassName)) {
        return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.EmptyClass;
    }

    # Check with Get-CimClass for the specified WMI class and in the specified namespace default root\cimv2
    if ((Test-IcingaFunction 'Get-CimInstance') -eq $FALSE ) {
        return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.CimNotInstalled;
    }

    # We clear all previous errors so that we can catch the last error message from this try/catch in the plugins.
    $Error.Clear();

    try {
        Get-CimInstance -ClassName $ClassName -Namespace $NameSpace -ErrorAction Stop | Out-Null;
    } catch {

        Write-IcingaConsoleDebug `
            -Message "WMIClass: '{0}' : Namespace : {1} {2} {3}" `
            -Objects $ClassName, $NameSpace, (New-IcingaNewLine), $_.Exception.Message;

        if ($_.CategoryInfo.Category -like 'MetadataError') {
            return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.InvalidNameSpace;
        }

        if ($_.CategoryInfo.Category -like 'ObjectNotFound') {
            return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.ObjectNotFound;
        }

        if ($_.CategoryInfo.Category -like 'NotSpecified') {
            return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.NotSpecified;
        }

        if ($_.CategoryInfo.Category -like 'PermissionDenied') {
            return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.PermissionError;
        }

        return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.UnhandledException;
    }

    return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok;
}

<#
.SYNOPSIS
    Tests the current set permissions for a user on a specific namespace and returns true if the
    current configuration is matching the intended configuration and returns false if either no
    permissions are set yet or the intended configuration is not matching the current configuration
.DESCRIPTION
    Tests the current set permissions for a user on a specific namespace and returns true if the
    current configuration is matching the intended configuration and returns false if either no
    permissions are set yet or the intended configuration is not matching the current configuration
.PARAMETER User
    The user to set permissions for. Can either be a local or domain user
.PARAMETER Namespace
    The Wmi namespace to grant permissions for. Required namespaces are listed within each plugin documentation
.PARAMETER Enable
    Enables the account and grants the user read permissions. This is a default access right for all users and corresponds to the Enable Account permission on the Security tab of the WMI Control. For more information, see Setting Namespace Security with the WMI Control.
.PARAMETER RemoteAccess
    Allows a user account to remotely perform any operations allowed by the permissions described above. Only members of the Administrators group have this right. WBEM_REMOTE_ACCESS corresponds to the Remote Enable permission on the Security tab of the WMI Control.
.PARAMETER Recurse
    Applies a container inherit flag and grants permission not only on the specific Wmi tree but also objects within this namespace (recommended)
.PARAMETER DenyAccess
    Blocks the user from having access to this Wmi and or subnamespace tree.
.PARAMETER Flags
    Allows to specify additional flags for permssion granting: PartialWrite, Subscribe, ProviderWrite,ReadSecurity, WriteSecurity, Publish, MethodExecute, FullWrite
.INPUTS
    System.String
.OUTPUTS
    System.Boolean
#>

function Test-IcingaWmiPermissions()
{
    param (
        [string]$User,
        [string]$Namespace,
        [switch]$Enable,
        [switch]$RemoteAccess,
        [switch]$Recurse,
        [switch]$DenyAccess,
        [array]$Flags
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError 'Please enter a valid username';
        return $FALSE;
    }

    if ([string]::IsNullOrEmpty($Namespace)) {
        Write-IcingaConsoleError 'You have to specify a Wmi namespace to grant permissions for';
        return $FALSE;
    }

    [int]$PermissionMask = [int]$PermissionMask = New-IcingaWmiPermissionMask -Enable:$Enable -RemoteAccess:$RemoteAccess -Flags $Flags;

    if ($PermissionMask -eq 0) {
        Write-IcingaConsoleError 'You have to specify permissions to grant for a specific user';
        return $FALSE;
    }

    $WmiSecurity = Get-IcingaWmiSecurityData -User $User -Namespace $Namespace;

    if ($null -eq $WmiSecurity) {
        return $FALSE;
    }

    [System.Management.ManagementBaseObject]$UserACL = $null;

    foreach ($entry in $WmiSecurity.WmiAcl.DACL) {
        if ($entry.Trustee.SidString -eq $WmiSecurity.UserSID) {
            $UserACL = $entry.PSObject.immediateBaseObject;
            break;
        }
    }

    # No permissions granted for this user
    if ($null -eq $UserACL) {
        return $FALSE;
    }

    [bool]$RecurseMatch = $TRUE;

    if ($Recurse -And $UserACL.AceFlags -ne $IcingaWBEM.AceFlags.Container_Inherit) {
        $RecurseMatch = $FALSE;
    } elseif ($Recurse -eq $FALSE -And $UserACL.AceFlags -ne 0) {
        $RecurseMatch = $FALSE;
    }

    if ($UserACL.AccessMask -ne $PermissionMask -Or $RecurseMatch -eq $FALSE) {
        return $FALSE;
    }
    
    return $TRUE;
}

Export-ModuleMember -Function @( '*' )
