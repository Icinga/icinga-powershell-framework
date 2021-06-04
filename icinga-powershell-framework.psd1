@{
    RootModule        = 'icinga-powershell-framework.psm1'
    ModuleVersion     = '1.5.1'
    GUID              = 'fcd7a805-a41b-49f9-afee-9d17a2b76d42'
    Author            = 'Lord Hepipud'
    CompanyName       = 'Icinga GmbH'
    Copyright         = '(c) 2021 Icinga GmbH | MIT'
    Description       = 'Icinga for Windows module which allows to entirely monitor the Windows Host system.'
    PowerShellVersion = '4.0'
    NestedModules     = @(
        '.\lib\core\framework\Get-IcingaFrameworkCodeCache.psm1',
        '.\lib\config\Get-IcingaPowerShellConfig.psm1',
        '.\lib\config\Read-IcingaPowerShellConfig.psm1',
        '.\lib\config\Test-IcingaPowerShellConfigItem.psm1',
        '.\lib\core\logging\Write-IcingaConsoleOutput.psm1',
        '.\lib\core\logging\Write-IcingaConsoleNotice.psm1',
        '.\lib\core\logging\Write-IcingaConsoleWarning.psm1',
        '.\lib\core\tools\Read-IcingaFileContent.psm1',
        '.\lib\core\framework\Invoke-IcingaInternalServiceCall.psm1',
        '.\lib\core\framework\Get-IcingaFrameworkApiChecks.psm1',
        '.\lib\daemon\Get-IcingaBackgroundDaemons.psm1',
        '.\lib\webserver\Enable-IcingaUntrustedCertificateValidation.psm1',
        '.\lib\core\logging\Write-IcingaEventMessage.psm1',
        '.\lib\icinga\plugin\Exit-IcingaExecutePlugin.psm1',
        '.\lib\icinga\exception\Exit-IcingaPluginNotInstalled.psm1',
        '.\lib\icinga\exception\Exit-IcingaThrowException.psm1',
        '.\lib\web\Set-IcingaTLSVersion.psm1',
        '.\lib\web\Disable-IcingaProgressPreference.psm1',
        '.\lib\core\tools\New-IcingaNewLine.psm1',
        '.\lib\core\logging\Write-IcingaConsolePlain.psm1',
        '.\lib\core\tools\Test-IcingaFunction.psm1',
        '.\lib\core\tools\Write-IcingaConsoleHeader.psm1',
        '.\lib\core\framework\Test-IcingaFrameworkConsoleOutput.psm1',
        '.\lib\core\tools\ConvertTo-IcingaSecureString.psm1',
        '.\lib\core\tools\ConvertTo-JsonUTF8Bytes.psm1',
        '.\lib\core\tools\ConvertFrom-JsonUTF8.psm1'
    )
    FunctionsToExport = @(
        'Use-Icinga',
        'Invoke-IcingaCommand',
        'Import-IcingaLib',
        'Get-IcingaFrameworkCodeCacheFile',
        'Write-IcingaFrameworkCodeCache',
        'Publish-IcingaModuleManifest',
        'Publish-IcingaEventlogDocumentation',
        'Get-IcingaPluginDir',
        'Get-IcingaCustomPluginDir',
        'Get-IcingaCacheDir',
        'Get-IcingaPowerShellConfigDir',
        'Get-IcingaFrameworkRootPath',
        'Get-IcingaForWindowsRootPath',
        'Get-IcingaPowerShellModuleFile',
        'Start-IcingaShellAsUser',
        'Get-IcingaPowerShellConfig',
        'Get-IcingaFrameworkCodeCache',
        'Read-IcingaPowerShellConfig',
        'Test-IcingaPowerShellConfigItem',
        'Write-IcingaConsoleOutput',
        'Write-IcingaConsoleNotice',
        'Write-IcingaConsoleWarning',
        'Read-IcingaFileContent',
        'Invoke-IcingaInternalServiceCall',
        'Get-IcingaFrameworkApiChecks',
        'Get-IcingaBackgroundDaemons',
        'Enable-IcingaUntrustedCertificateValidation',
        'Write-IcingaEventMessage',
        'Exit-IcingaExecutePlugin',
        'Exit-IcingaPluginNotInstalled',
        'Exit-IcingaThrowException',
        'Set-IcingaTLSVersion',
        'Disable-IcingaProgressPreference',
        'New-IcingaNewLine',
        'Write-IcingaConsolePlain',
        'Test-IcingaFunction',
        'Write-IcingaConsoleHeader',
        'Test-IcingaFrameworkConsoleOutput',
        'ConvertTo-IcingaSecureString',
        'ConvertTo-JsonUTF8Bytes',
        'ConvertFrom-JsonUTF8'
    )
    CmdletsToExport   = @('*')
    VariablesToExport = '*'
    AliasesToExport   = @( 'icinga' )
    PrivateData       = @{
        PSData  = @{
            Tags         = @( 'icinga', 'icinga2', 'IcingaPowerShellFramework', 'IcingaPowerShell', 'IcingaforWindows', 'IcingaWindows')
            LicenseUri   = 'https://github.com/Icinga/icinga-powershell-framework/blob/master/LICENSE'
            ProjectUri   = 'https://github.com/Icinga/icinga-powershell-framework'
            ReleaseNotes = 'https://github.com/Icinga/icinga-powershell-framework/releases'
        };
        Version  = 'v1.5.1';
        Name     = 'Icinga for Windows';
        Type     = 'framework';
        Function = '';
        Endpoint = '';
    }
    HelpInfoURI       = 'https://github.com/Icinga/icinga-powershell-framework'
}
