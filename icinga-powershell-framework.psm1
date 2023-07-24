<#
.Synopsis
   Icinga PowerShell Module - Powerful PowerShell Framework for monitoring Windows Systems
.DESCRIPTION
   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   Install-Icinga
 .NOTES
#>

function Use-Icinga()
{
    param (
        [switch]$LibOnly   = $FALSE,
        [switch]$Daemon    = $FALSE,
        [switch]$DebugMode = $FALSE,
        [switch]$Minimal   = $FALSE
    );

    # Only apply migrations if we directly call "Use-Icinga" without any other argument
    if ($LibOnly -eq $FALSE -And $Daemon -eq $FALSE -and $Minimal -eq $FALSE) {
        Invoke-IcingaForWindowsMigration;
    }

    Disable-IcingaProgressPreference;

    if ($Minimal) {
        $Global:Icinga.Protected.Minimal = $TRUE;
    }

    # Ensure we autoload Icinga for Windows modules into this session
    Import-IcingaForWindowsModulesInSession;

    if ($Daemon) {
        $Global:Icinga.Protected.RunAsDaemon = $TRUE;
    }

    if ($DebugMode) {
        $Global:Icinga.Protected.DebugMode = $TRUE;
    }

    # Enable DebugMode in case it is enabled in our config
    if (Get-IcingaFrameworkDebugMode) {
        Enable-IcingaFrameworkDebugMode;
    }

    $EventLogMessages = Invoke-IcingaNamespaceCmdlets -Command 'Register-IcingaEventLogMessages*';
    foreach ($entry in $EventLogMessages.Values) {
        foreach ($event in $entry.Keys) {
            if ($LibOnly -eq $FALSE -And $Daemon -eq $FALSE) {
                Register-IcingaEventLog -LogName $event;
            }
            Add-IcingaHashtableItem -Hashtable $global:IcingaEventLogEnums `
                -Key $event `
                -Value $entry[$event] | Out-Null;
        }
    }

    if ($LibOnly -eq $FALSE -And $Daemon -eq $FALSE) {
        Register-IcingaEventLog;
    }
}

function Import-IcingaForWindowsModulesInSession()
{
    $CommandList = Get-Command 'Import-IcingaPowerShellComponent*';

    foreach ($entry in $CommandList) {
        $ModuleName = $entry.Module.Name;
        $ModulePath = $entry.Module.Path;
        $RootPath   = $ModulePath.Substring(0, $ModulePath.IndexOf($ModuleName));
        $Command    = $entry.Name;

        if ($RootPath.ToLower() -ne (Get-IcingaForWindowsRootPath).ToLower()) {
            continue;
        }

        if ([string]::IsNullOrEmpty($Command) -Or (Test-IcingaFunction $Command) -eq $FALSE) {
            continue;
        }

        # Execute the command if the module is located at the same location as our Framework
        & $Command | Out-Null;
    }
}

function Import-IcingaForWindowsModules()
{
    [array]$IcingaForWindowsModules = Get-ChildItem -Path (Get-IcingaForWindowsRootPath);

    foreach ($module in $IcingaForWindowsModules) {
        if ($module.Name -Like 'icinga-powershell-*') {
            try {
                Import-Module $module.Name -Force -ErrorAction Stop;
                Import-Module $module.Name -Force -Global -ErrorAction Stop;
            } catch {
                Write-Host ([string]::Format('Failed to import Icinga for Windows module "{0}": {1}', $module.Name, $_.Exception.Message));
            }
        }
    }

    Import-Module 'icinga-powershell-framework' -Force;
    Import-Module 'icinga-powershell-framework' -Force -Global;
}

function Get-IcingaFrameworkCodeCacheFile()
{
    return (Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'framework_cache.psm1');
}

function Import-IcingaLib()
{
    # Do nothing, just leave it here as compatibility layer until we
    # cleaned every other repository
}

function Write-IcingaFrameworkCodeCache()
{
    param (
        [switch]$DeveloperMode = $FALSE
    );

    [string]$CacheFile    = Get-IcingaFrameworkCodeCacheFile;
    [string]$directory    = Join-Path -Path $PSScriptRoot -ChildPath 'lib\';
    [string]$CacheContent = '';

    # Load modules from directory
    Get-ChildItem -Path $directory -Recurse -Filter '*.psm1' |
        ForEach-Object {
            [System.IO.FileStream]$FileStream = [System.IO.File]::Open(
                $_.FullName,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read,
                [System.IO.FileShare]::Read
            );
            $FileReader                       = New-Object 'System.IO.StreamReader'($FileStream), (New-Object System.Text.UTF8Encoding $TRUE);
            $CacheContent                     += $FileReader.ReadToEnd();
            $FileReader.Close();
            $FileReader.Dispose();
        }

    $CacheContent += "Export-ModuleMember -Function @( '*' ) -Alias @( '*' ) -Variable @( '*' )";

    if ($DeveloperMode -Or $Global:Icinga.Protected.DeveloperMode) {
        [ScriptBlock]$CodeCache = [ScriptBlock]::Create($CacheContent);
        . $CodeCache;

        Copy-IcingaFrameworkCacheTemplate;
        return;
    }

    [System.IO.File]::WriteAllLines($CacheFile, $CacheContent, (New-Object System.Text.UTF8Encoding $TRUE));

    $DependencyFile = Join-Path -Path (Get-IcingaCacheDir) -ChildPath 'framework_dependencies.json';

    if ((Test-Path $DependencyFile)) {
        Remove-Item -Path $DependencyFile -Force | Out-Null;
    }

    if ($Global:Icinga.Protected.DeveloperMode) {
        Copy-IcingaFrameworkCacheTemplate;
    }
}

function Copy-IcingaFrameworkCacheTemplate()
{
    Copy-ItemSecure -Path (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath '\templates\framework_cache.psm1.template') -Destination (Get-IcingaFrameworkCodeCacheFile) -Force | Out-Null;

    $WindowsModules = Get-Module -Name 'icinga-powershell-*' -ListAvailable;

    foreach ($entry in $WindowsModules) {
        $ModulePath = $entry.Path.Replace([string]::Format('{0}.psd1', $entry.Name), '');
        $CacheFile  = Join-Path -Path $ModulePath -ChildPath ([string]::Format('\compiled\{0}.ifw_compilation.psm1', $entry.Name));

        if (Test-Path $CacheFile) {
            Copy-ItemSecure -Path (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath '\templates\compilation.psm1.template') -Destination $CacheFile -Force | Out-Null;
        }
    }
}

function Publish-IcingaEventLogDocumentation()
{
    param(
        [string]$Namespace,
        [string]$OutFile
    );

    [string]$DocContent = [string]::Format(
        '# {0} EventLog Documentation',
        $Namespace
    );
    $DocContent += New-IcingaNewLine;
    $DocContent += New-IcingaNewLine;
    $DocContent += "Below you will find a list of EventId's which are exported by this module. The short and detailed message are both written directly into the EventLog. This documentation shall simply provide a summary of available EventId's";

    $SortedArray = $IcingaEventLogEnums[$Namespace].Keys.GetEnumerator() | Sort-Object;

    foreach ($entry in $SortedArray) {
        $entry = $IcingaEventLogEnums[$Namespace][$entry];

        $DocContent = [string]::Format(
            '{0}{2}{2}## Event Id {1}{2}{2}| Category | Short Message | Detailed Message |{2}| --- | --- | --- |{2}| {3} | {4} | {5} |',
            $DocContent,
            $entry.EventId,
            (New-IcingaNewLine),
            $entry.EntryType,
            $entry.Message,
            $entry.Details
        );
    }

    if ([string]::IsNullOrEmpty($OutFile)) {
        Write-Output $DocContent;
    } else {
        Write-IcingaFileSecure -File $OutFile -Value $DocContent;
    }
}

function Get-IcingaPluginDir()
{
    return (Join-Path -Path $PSScriptRoot -ChildPath 'lib\plugins\');
}

function Get-IcingaCustomPluginDir()
{
    return (Join-Path -Path $PSScriptRoot -ChildPath 'custom\plugins\');
}

function Get-IcingaCacheDir()
{
    return (Join-Path -Path $PSScriptRoot -ChildPath 'cache');
}

function Get-IcingaPowerShellConfigDir()
{
    return (Join-Path -Path $PSScriptRoot -ChildPath 'config');
}

function Get-IcingaFrameworkRootPath()
{
    [string]$Path = $PSScriptRoot;

    return $PSScriptRoot;
}

function Get-IcingaForWindowsRootPath()
{
    [string]$Path = $PSScriptRoot;
    [int]$Index   = $Path.LastIndexOf('icinga-powershell-framework');
    $Path         = $Path.Substring(0, $Index);

    return $Path;
}

function Get-IcingaPowerShellModuleFile()
{
    return (Join-Path -Path $PSScriptRoot -ChildPath 'icinga-powershell-framework.psd1');
}

function Invoke-IcingaCommand()
{
    [CmdletBinding()]
    param (
        $ScriptBlock,
        [switch]$SkipHeader      = $FALSE,
        [switch]$Manage          = $FALSE, # Only for backwards compatibility, has no use at all
        [switch]$Shell           = $FALSE,
        [switch]$NoSSLValidation = $FALSE,
        [switch]$RebuildCache    = $FALSE,
        [switch]$DeveloperMode   = $FALSE,
        [switch]$NoNewInstance   = $FALSE,
        [array]$ArgumentList     = @()
    );

    If ($DeveloperMode -And $NoNewInstance) {
        Write-Host 'DeveloperMode is not supported while using NoNewInstance argument.' -ForegroundColor red;
        return;
    }

    Import-LocalizedData `
        -BaseDirectory (Get-IcingaFrameworkRootPath) `
        -FileName 'icinga-powershell-framework.psd1' `
        -BindingVariable IcingaFrameworkData;

    # Ensure we always remove the update file in case present
    Set-IcingaForWindowsManagementConsoleUpdating -Completed;

    # Print a header informing our user that loaded the Icinga Framework with a specific
    # version. We can also skip the header by using $SKipHeader
    if ([string]::IsNullOrEmpty($ScriptBlock) -And $SkipHeader -eq $FALSE -And $Shell) {
        [array]$Headers = @(
            'Icinga for Windows $FrameworkVersion',
            'Copyright $Copyright',
            'User environment $UserDomain\$Username'
        );

        if ($null -eq (Get-Command -Name 'Write-IcingaConsoleHeader' -ErrorAction SilentlyContinue)) {
            Use-Icinga;
        }

        Write-IcingaConsoleHeader -HeaderLines $Headers;
    }

    if ($DeveloperMode) {
        $Global:Icinga.Protected.DeveloperMode = $TRUE;
    }

    if ($RebuildCache -Or $DeveloperMode) {
        Copy-IcingaFrameworkCacheTemplate;
        Write-IcingaFrameworkCodeCache -DeveloperMode:$DeveloperMode;
    }

    # Try to re-import everything within the same instance
    if ($NoNewInstance) {
        Import-IcingaForWindowsModules;
        Use-Icinga;

        return;
    }

    if ($null -ne $psISE) {
        Use-Icinga;
        Write-IcingaConsoleError -Message 'Icinga for Windows was loaded, but the Icinga Management Console is not available within the PowerShell ISE context. Please start a regular PowerShell to use it.';
        return;
    }

    if ($null -ne $psISE) {
        Write-IcingaConsoleWarning -Message 'Icinga for Windows was successfully loaded, but the current PowerShell ISE environment is not fully supported. For advanced and production tasks, please use Icinga for Windows inside a regular PowerShell environment.';
        return;
    }

    # Ensure we set the path to another folder to prevent locking the Framework Root Folder
    Set-Location (Get-IcingaForWindowsRootPath);

    powershell.exe -NoExit -Command {
        $Script          = $args[0];
        $RootPath        = $args[1];
        $Version         = $args[2];
        $Shell           = $args[3];
        $IcingaShellArgs = $args[4];
        $DeveloperMode   = $args[5];
        $NoSSLValidation = $args[6];

        # Load our Icinga Framework
        Use-Icinga;

        # Always ensure we use the proper TLS Version
        Set-IcingaTLSVersion;

        # Ignore SSL validation in case we set the flag
        if ($NoSSLValidation) {
            Enable-IcingaUntrustedCertificateValidation;
        }

        if ($DeveloperMode) {
            $Global:Icinga.Protected.DeveloperMode = $TRUE;
            Copy-IcingaFrameworkCacheTemplate;
        }

        $Host.UI.RawUI.WindowTitle = ([string]::Format('Icinga for Windows {0}', $Version));

        # Set the location to the Icinga Framework module folder
        Set-Location $RootPath;

        if ($Shell -eq $FALSE -And [string]::IsNullOrEmpty($Script)) {
            Install-Icinga;
            exit $LASTEXITCODE;
        }

        # If we added a block to execute, do it right here and exit the shell
        # with the last exit code of the command
        if ([string]::IsNullOrEmpty($Script) -eq $FALSE) {
            Invoke-Command -ScriptBlock ([Scriptblock]::Create($Script));
            exit $LASTEXITCODE;
        }

        # Set our "path" to something different so we know that we loaded the Framework
        function prompt {
            Write-Host -Object "icinga" -NoNewline;
            return "> "
        }

    } -Args $ScriptBlock, $PSScriptRoot, $IcingaFrameworkData.PrivateData.Version, ([bool]$Shell), $ArgumentList, ([bool]$DeveloperMode), ([bool]$NoSSLValidation);

    # In case we close the newly created PowerShell, ensure we set the script root back to the Framework folder
    if (Test-Path $PSScriptRoot) {
        Set-Location $PSScriptRoot;
    }

    # In case we applied updates to the Framework while inside the IMC -> reopen it
    if (Test-IcingaForWindowsManagementConsoleUpdating) {
        Set-IcingaForWindowsManagementConsoleUpdating -Completed;

        # Use the same arguments again to open the IMC
        $IMCReopenArguments = @{
            'ScriptBlock'     = $ScriptBlock;
            'SkipHeader'      = $SkipHeader;
            'Manage'          = $Manage;
            'Shell'           = $Shell;
            'NoSSLValidation' = $NoSSLValidation;
            'RebuildCache'    = $RebuildCache;
            'DeveloperMode'   = $DeveloperMode;
            'ArgumentList'    = $ArgumentList;
        };

        Invoke-IcingaCommand @IMCReopenArguments;
    }
}

function Start-IcingaShellAsUser()
{
    param (
        [string]$User = ''
    );

    Start-Process `
        -WorkingDirectory $PSHOME `
        -FilePath 'powershell.exe' `
        -Verb RunAs `
        -ArgumentList (
            [string]::Format(
                "-Command `"Start-Process -FilePath `"powershell.exe`" -WorkingDirectory `"{0}`" -Credential (Get-Credential -UserName '{1}' -Message 'Please enter your credentials to open an Icinga Shell with') -ArgumentList icinga`"",
                $PSHOME,
                $User
            )
        );
}

# Always ensure our environment variables are set to reduce possibles errors
# in case we call functions accessing them
if (Get-Command -Name 'New-IcingaEnvironmentVariable' -ErrorAction SilentlyContinue) {
    New-IcingaEnvironmentVariable;
}

Set-Alias icinga Invoke-IcingaCommand -Description "Execute Icinga Framework commands in a new PowerShell instance for testing or quick access to data";
Export-ModuleMember -Alias * -Function * -Variable *;
