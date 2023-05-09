<#
    ### Note ###

    This file is shipping plain with Icinga for Windows for each version.
    Once the module is loaded, this content will entirely be replaced with
    all modules and components shipped by the Icinga PowerShell Framework.

    Manually enabling the feature is no longer required.
#>

# Ensure we only load this module once
if ($null -ne $Global:Icinga -And $Global:Icinga.ContainsKey('CacheBuilding') -And $Global:Icinga['CacheBuilding']) {
    return;
}

if ($null -eq $Global:Icinga) {
    $Global:Icinga = @{ };
}

if ($Global:Icinga.ContainsKey('CacheBuilding') -eq $FALSE) {
    $Global:Icinga.Add('CacheBuilding', $TRUE);
} else {
    $Global:Icinga.CacheBuilding = $TRUE;
}

# Ensures that VS Code is not generating the cache file
if ($null -ne $env:TERM_PROGRAM) {
    Write-IcingaFrameworkCodeCache -DeveloperMode;
    return;
}

Write-IcingaFrameworkCodeCache;

Import-Module icinga-powershell-framework -Global -Force;
Import-Module icinga-powershell-framework -Force;

if ($null -ne $env:TERM_PROGRAM -Or $Global:Icinga.Protected.DeveloperMode) {
    Copy-IcingaFrameworkCacheTemplate;
}

$Global:Icinga.CacheBuilding = $FALSE;
