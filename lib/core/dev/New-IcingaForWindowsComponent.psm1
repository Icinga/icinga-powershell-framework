<#
.SYNOPSIS
    Creates an empty new Icinga for Windows module
.DESCRIPTION
    Creates an empty new Icinga for Windows module
.PARAMETER Name
    The name of the Icinga for Windows component and module
.PARAMETER Author
    The author of the module as string
.PARAMETER CompanyName
    The company this module belongs to as string
.PARAMETER Copyright
    The copyright owner of this module as string
.PARAMETER ModuleVersion
    The version of this module as 3 digit version number, eg '1.0.0'
.PARAMETER Description
    The description of what this module does as string
.PARAMETER RequiredModules
    The required modules this module depends on, as an array of hashtables e.g.
    @( @{ ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.7.0' } )
.PARAMETER Tags
    An array of string tags and keywords, for finding this module on the installation list
.PARAMETER ProjectUri
    The url of the project as string
.PARAMETER LicenseUri
    The url to the license as string
.PARAMETER ComponentType
    Defines on how Icinga for Windows will load this module. Valid options are
    'plugins', 'apiendpoint', 'daemon', 'library'
.PARAMETER OpenInEditor
    Will open the newly created module within the editor
#>
function New-IcingaForWindowsComponent()
{
    param (
        [string]$Name,
        [string]$Author            = $env:USERNAME,
        [string]$CompanyName       = '',
        [string]$Copyright         = ([string]::Format('(c) {0} {1} | GPL v2.0', [DateTime]::Now.Year, $env:USERNAME)),
        [Version]$ModuleVersion    = '1.0.0',
        [string]$Description       = '',
        [array]$RequiredModules    = @( @{ ModuleName = 'icinga-powershell-framework'; ModuleVersion = '1.7.0' } ),
        [string[]]$Tags            = $Name,
        [string]$ProjectUri        = '',
        [string]$LicenseUri        = '',
        [ValidateSet('plugins', 'apiendpoint', 'daemon', 'library')]
        [string]$ComponentType     = 'plugins',
        [switch]$OpenInEditor      = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'Please specify a name for your new component';
        return;
    }

    [string]$ModuleName     = [string]::Format('icinga-powershell-{0}', $Name.ToLower());
    [string]$ModuleRoot     = Get-IcingaForWindowsRootPath;
    [string]$ModuleDir      = Join-Path -Path $ModuleRoot -ChildPath $ModuleName;
    [string]$DaemonFunction = '';
    [string]$EndpointName   = '';

    if (Test-Path $ModuleDir) {
        Write-IcingaConsoleError 'A component with this name does already exist. Use "Publish-IcingaForWindowsComponent" to apply changes';
        return;
    }

    $TextInfo = (Get-Culture).TextInfo;

    New-Item -ItemType Directory -Path $ModuleDir | Out-Null;
    New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'doc') | Out-Null;
    New-Item -ItemType File -Path (Join-Path -Path $ModuleDir -ChildPath 'README.md') | Out-Null;
    New-Item -ItemType File -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psm1', $ModuleName))) | Out-Null;

    switch ($ComponentType) {
        'plugins' {
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'plugins') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'provider') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'provider\public') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'provider\private') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib\public') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib\private') | Out-Null;

            break;
        };
        'apiendpoint' {
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'endpoint') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib\public') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib\private') | Out-Null;

            [string]$RegisterFunction     = ([string]::Format('Register-IcingaRESTAPIEndpoint{0}', $TextInfo.ToTitleCase($Name.ToLower())));
            [string]$RegisterFunctionFile = (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('endpoint\{0}.psm1', $RegisterFunction)));
            [string]$InvokeFunction       = ([string]::Format('Invoke-IcingaForWindowsApiRESTCall{0}', $TextInfo.ToTitleCase($Name.ToLower())));
            [string]$InvokeFunctionFile   = (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('endpoint\{0}.psm1', $InvokeFunction)));

            Set-Content -Path $RegisterFunctionFile -Value ([string]::Format('function {0}()', $RegisterFunction));
            Add-Content -Path $RegisterFunctionFile -Value '{';
            Add-Content -Path $RegisterFunctionFile -Value '    # Ensure that we can call our API with a specific endpoint';
            Add-Content -Path $RegisterFunctionFile -Value '    return @{';
            Add-Content -Path $RegisterFunctionFile -Value ([string]::Format("        'Alias'   = '{0}';", $Name.ToLower()));
            Add-Content -Path $RegisterFunctionFile -Value ([string]::Format("        'Command' = '{0}';", $InvokeFunction));
            Add-Content -Path $RegisterFunctionFile -Value '    }';
            Add-Content -Path $RegisterFunctionFile -Value '}';

            Set-Content -Path $InvokeFunctionFile -Value ([string]::Format('function {0}()', $InvokeFunction));
            Add-Content -Path $InvokeFunctionFile -Value '{';
            Add-Content -Path $InvokeFunctionFile -Value '    # Do not modify the param section';
            Add-Content -Path $InvokeFunctionFile -Value '    param (';
            Add-Content -Path $InvokeFunctionFile -Value '        [Hashtable]$Request    = @{},';
            Add-Content -Path $InvokeFunctionFile -Value '        [Hashtable]$Connection = @{},';
            Add-Content -Path $InvokeFunctionFile -Value '        [string]$ApiVersion    = $null';
            Add-Content -Path $InvokeFunctionFile -Value '    );'
            Add-Content -Path $InvokeFunctionFile -Value '';
            Add-Content -Path $InvokeFunctionFile -Value '    # This is the main function for your API endpoint.';
            Add-Content -Path $InvokeFunctionFile -Value '    # Also check the developer guide for further details: https://icinga.com/docs/icinga-for-windows/latest/doc/900-Developer-Guide/12-Custom-API-Endpoints/';
            Add-Content -Path $InvokeFunctionFile -Value '';
            Add-Content -Path $InvokeFunctionFile -Value '    # Send a success message once you connect to the endpoint as example';
            Add-Content -Path $InvokeFunctionFile -Value '    Send-IcingaTCPClientMessage -Message (';
            Add-Content -Path $InvokeFunctionFile -Value '        New-IcingaTCPClientRESTMessage `';
            Add-Content -Path $InvokeFunctionFile -Value '            -HTTPResponse ($IcingaHTTPEnums.HTTPResponseType.Ok) `';
            Add-Content -Path $InvokeFunctionFile -Value "            -ContentBody 'Api endpoint is installed'";
            Add-Content -Path $InvokeFunctionFile -Value '    ) -Stream $Connection.Stream;';
            Add-Content -Path $InvokeFunctionFile -Value '}';

            $EndpointName = $Name.ToLower();

            break;
        };
        'daemon' {
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'daemon') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib\public') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib\private') | Out-Null;
            New-Item `
                -ItemType File `
                -Path (Join-Path -Path (Join-Path -Path $ModuleDir -ChildPath 'daemon') -ChildPath ([string]::Format('Start-IcingaForWindowsDaemon{0}.psm1', $TextInfo.ToTitleCase($Name.ToLower())))) | Out-Null;

            $DaemonFunction = ([string]::Format('Start-IcingaForWindowsDaemon{0}', $TextInfo.ToTitleCase($Name.ToLower())));
            $DaemonEntry    = ([string]::Format('Add-IcingaIcingaForWindowsDaemonEntry{0}', $TextInfo.ToTitleCase($Name.ToLower())));

            Set-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value ([string]::Format('function {0}()', $DaemonFunction));
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value '{';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value '    # This is the entry point for Icinga for Windows. Use this function for registering your background daemon';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value '    # Also check the developer guide for further details: https://icinga.com/docs/icinga-for-windows/latest/doc/900-Developer-Guide/10-Custom-Daemons/';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value '';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value '    New-IcingaThreadInstance `';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value (
                [string]::Format(
                    '        -Name {1}IcingaForWindows_Daemon_{0}{1} `',
                    $TextInfo.ToTitleCase($Name.ToLower()),
                    "'"
                )
            );
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value (
                [string]::Format(
                    '        -ThreadPool (Get-IcingaThreadPool -Name {0}MainPool{0}) `',
                    "'"
                )
            );
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value (
                [string]::Format(
                    '        -Command {0}{1}{0} `',
                    "'",
                    $DaemonEntry
                )
            );
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value (
                [string]::Format(
                    '        -CmdParameters @{{ }} `',
                    "'"
                )
            );
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value '        -Start;';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonFunction))) -Value '}';

            Set-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value ([string]::Format('function {0}()', $DaemonEntry));
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '{';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '    # This is your main daemon function. Add your code inside the WHILE() loop which is executed once the daemon is loaded.';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '    # Also check the developer guide for further details: https://icinga.com/docs/icinga-for-windows/latest/doc/900-Developer-Guide/10-Custom-Daemons/';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '    while ($TRUE) {';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '        # Add your daemon code within this loop';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '        Start-Sleep -Seconds 1;';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '    }';
            Add-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('daemon\{0}.psm1', $DaemonEntry))) -Value '}';

            break;
        };
        'library' {
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib\public') | Out-Null;
            New-Item -ItemType Directory -Path (Join-Path -Path $ModuleDir -ChildPath 'lib\private') | Out-Null;

            break;
        }
    }

    Copy-ItemSecure `
        -Path (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'templates\Manifest.psd1.template') `
        -Destination (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName))) `
        -Force | Out-Null;

    Write-IcingaForWindowsComponentManifest -Name $Name -ModuleConfig @{
        '$MODULENAME$'        = ([string]::Format('Windows {0}', $Name));
        '$GUID$'              = (New-Guid);
        '$AUTHOR$'            = $Author;
        '$COMPANYNAME$'       = $CompanyName;
        '$COPYRIGHT$'         = $Copyright;
        '$MODULEVERSION$'     = $ModuleVersion.ToString();
        '$VMODULEVERSION$'    = ([string]::Format('v{0}', $ModuleVersion.ToString()));
        '$DESCRIPTION$'       = $Description;
        '$REQUIREDMODULES$'   = $RequiredModules;
        '$NESTEDMODULES$'     = '';
        '$FUNCTIONSTOEXPORT$' = '';
        '$VARIABLESTOEXPORT$' = '';
        '$ALIASESTOEXPORT$'   = '';
        '$TAGS$'              = $Tags;
        '$PROJECTURI$'        = $ProjectUri;
        '$LICENSEURI$'        = $LicenseUri;
        '$COMPONENTTYPE$'     = $ComponentType;
        '$DAEMONFUNCTION$'    = $DaemonFunction;
        '$APIENDPOINT$'       = $EndpointName;
    };

    Set-Content `
        -Path (Join-Path -Path $ModuleDir -ChildPath 'README.md') `
        -Value ([string]::Format('# Icinga for Windows - {0}', $Name));


    Add-Content `
        -Path (Join-Path -Path $ModuleDir -ChildPath 'README.md') `
        -Value '';

    Add-Content `
        -Path (Join-Path -Path $ModuleDir -ChildPath 'README.md') `
        -Value ([string]::Format('This is the auto generated readme for the Icinga for Windows Module `icinga-powershell-{0}`', $Name.ToLower()));

    Add-Content `
        -Path (Join-Path -Path $ModuleDir -ChildPath 'README.md') `
        -Value '';

    Add-Content `
        -Path (Join-Path -Path $ModuleDir -ChildPath 'README.md') `
        -Value 'You can start to modify this readme including writing your PowerShell code. Use "Publish-IcingaForWindowsComponent" to generate Icinga 2/Icinga Director configuration files for plugins, auto-generate your configuration and update your module manifest to include all module files you created into the base module.';

    Add-Content `
        -Path (Join-Path -Path $ModuleDir -ChildPath 'README.md') `
        -Value '';

    Copy-ItemSecure `
        -Path (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'templates\PSScriptAnalyzerSettings.psd1.template') `
        -Destination (Join-Path -Path $ModuleDir -ChildPath 'PSScriptAnalyzerSettings.psd1') `
        -Force | Out-Null;

    Write-IcingaConsoleNotice 'New component "{0}" has been created as module "icinga-powershell-{1}" at location "{2}"' -Objects $Name, $Name.ToLower(), $ModuleDir;
    Publish-IcingaForWindowsComponent -Name $Name -NoOutput;

    Import-Module $ModuleDir -Force;
    Import-Module $ModuleDir -Global -Force;

    if ($OpenInEditor) {
        Open-IcingaForWindowsComponentInEditor -Name $Name;
    }
}
