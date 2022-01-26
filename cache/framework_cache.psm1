<#
    ### Note ###

    This file is shipping plain with Icinga for Windows for each version.
    Once the module is loaded, this content will entirely be replaced with
    all modules and components shipped by the Icinga PowerShell Framework.

    Manually enabling the feature is no longer required.
#>

Write-IcingaFrameworkCodeCache;

Import-Module icinga-powershell-framework -Global -Force;
Import-Module icinga-powershell-framework -Force;
