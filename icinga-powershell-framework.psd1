@{
    RootModule        = 'icinga-powershell-framework.psm1'
    ModuleVersion     = '1.11.1'
    GUID              = 'fcd7a805-a41b-49f9-afee-9d17a2b76d42'
    Author            = 'Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2023 Icinga GmbH | MIT'
    Description       = 'Icinga for Windows module which allows to entirely monitor the Windows Host system.'
    PowerShellVersion = '4.0'
    NestedModules     = @( '.\cache\framework_cache.psm1' )
    FunctionsToExport = @( '*' )
    CmdletsToExport   = @( '*' )
    VariablesToExport = @( '*' )
    AliasesToExport   = @( '*' )
    PrivateData       = @{
        PSData   = @{
            Tags         = @( 'icinga', 'icinga2', 'IcingaPowerShellFramework', 'IcingaPowerShell', 'IcingaforWindows', 'IcingaWindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-framework/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-framework'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-framework/releases'
        };
        Version  = 'v1.11.1';
        Name     = 'Icinga for Windows';
        Type     = 'framework';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-framework'
}
