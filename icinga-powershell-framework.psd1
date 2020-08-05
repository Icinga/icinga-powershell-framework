@{
    RootModule        = 'icinga-powershell-framework.psm1'
    ModuleVersion     = '1.2.0'
    GUID              = 'fcd7a805-a41b-49f9-afee-9d17a2b76d42'
    Author            = 'Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2020 Icinga GmbH | MIT'
    Description       = 'Icinga for Windows module which allows to entirely monitor the Windows Host system.'
    PowerShellVersion = '4.0'
    FunctionsToExport = @(
        'Use-Icinga',
        'Invoke-IcingaCommand',
        'Import-IcingaLib',
        'Publish-IcingaModuleManifest',
        'Publish-IcingaEventlogDocumentation',
        'Get-IcingaPluginDir',
        'Get-IcingaCustomPluginDir',
        'Get-IcingaCacheDir',
        'Get-IcingaPowerShellConfigDir',
        'Get-IcingaFrameworkRootPath',
        'Get-IcingaPowerShellModuleFile',
        'Start-IcingaTimer',
        'Test-IcingaTimer',
        'Add-IcingaHashtableItem',
        'Get-IcingaHashtableItem',
        'Register-IcingaEventLog'
    )
    NestedModules     = @(
        '.\lib\core\framework\Start-IcingaTimer.psm1',
        '.\lib\core\framework\Test-IcingaTimer.psm1',
        '.\lib\core\tools\Add-IcingaHashtableItem.psm1'
        '.\lib\core\tools\Get-IcingaHashtableItem.psm1',
        '.\lib\core\logging\Register-IcingaEventLog.psm1'
    )
    CmdletsToExport   = @()
    VariablesToExport = '*'
    AliasesToExport   = @( 'icinga' )
    PrivateData       = @{
        PSData  = @{
            Tags         = @( 'icinga', 'icinga2', 'IcingaPowerShellFramework', 'IcingaPowerShell', 'IcingaforWindows', 'IcingaWindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-framework/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-framework'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-framework/releases'
        };
        Version = 'v1.2.0';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-framework'
}
