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

    if ($CheckList.Count -eq 0) {
        Write-IcingaConsoleNotice 'The module "{0}" is not containing any plugins' -Objects $ComponentName;
        return;
    }

    Get-IcingaCheckCommandConfig -CheckName $CheckList -OutDirectory $BasketConfigDir -FileName ([string]::Format('{0}_Bundle', (Get-Culture).TextInfo.ToTitleCase($ComponentName)));
    Get-IcingaCheckCommandConfig -CheckName $CheckList -OutDirectory $IcingaConfigDir -FileName ([string]::Format('{0}_Bundle', (Get-Culture).TextInfo.ToTitleCase($ComponentName))) -IcingaConfig;
}
