@{
    ModuleToProcess = 'icinga-powershell-framework.psm1'
    ModuleVersion = '1.1.0'
    GUID = 'fcd7a805-a41b-49f9-afee-9d17a2b76d42'
    Author = 'Lord Hepipud'
    CompanyName = 'Icinga GmbH'
    Copyright = '(c) 2020 Icinga GmbH | MIT'
    Description = 'Icinga for Windows module which allows to entirely monitor the Windows Host system.'
    PowerShellVersion = '4.0'
    FunctionsToExport = @( 'Use-Icinga', 'Import-IcingaLib', 'Publish-IcingaModuleManifests', 'Publish-IcingaEventlogDocumentation', 'Get-IcingaPluginDir', 'Get-IcingaCustomPluginDir', 'Get-IcingaCacheDir', 'Get-IcingaPowerShellConfigDir', 'Get-IcingaFrameworkRootPath', 'Get-IcingaPowerShellModuleFile' )
    CmdletsToExport = @()
    VariablesToExport = '*'
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @( 'icinga','icinga2','IcingaPowerShellFramework','IcingaPowerShell','IcingaforWindows','IcingaWindows')
            LicenseUri = 'https://github.com/Icinga/icinga-powershell-framework/blob/master/LICENSE'
            ProjectUri = 'https://github.com/Icinga/icinga-powershell-framework'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-framework/releases'
        };
        Version = 'v1.1.0';
    }
    HelpInfoURI = 'https://github.com/Icinga/icinga-powershell-framework'
}
