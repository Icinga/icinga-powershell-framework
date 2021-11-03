<#
.SYNOPSIS
    Test an Icinga for Windows component and validate the functionality
    including the code styling
.DESCRIPTION
    Test an Icinga for Windows component and validate the functionality
    including the code styling
.PARAMETER Name
    The name of the Icinga for Windows component and module
.PARAMETER ShowIssues
    Prints a list of all code styling issues found within the module
    for resolving them
.EXAMPLE
    Test-IcingaForWindowsComponent -Name 'framework' -ShowIssues;
#>
function Test-IcingaForWindowsComponent()
{
    param (
        [string]$Name,
        [switch]$ShowIssues = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'Please specify the name of the component you want to test';
        return;
    }

    [string]$ModuleName     = [string]::Format('icinga-powershell-{0}', $Name.ToLower());
    [string]$ModuleRoot     = Get-IcingaForWindowsRootPath;
    [string]$ModuleDir      = Join-Path -Path $ModuleRoot -ChildPath $ModuleName;
    [string]$ScriptAnalyzer = Join-Path -Path $ModuleDir -ChildPath 'PSScriptAnalyzerSettings.psd1';
    [string]$ModuleManifest = (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName)))

    if ((Test-Path $ModuleDir) -eq $FALSE) {
        Write-IcingaConsoleError 'A component with the name "{0}" does not exist. Use "New-IcingaForWindowsComponent" to create a new one or verify that the provided name is correct.' -Objects $Name;
        return;
    }

    if ($null -ne (Get-Command -Name 'Invoke-ScriptAnalyzer' -ErrorAction SilentlyContinue)) {
        $ScriptAnalyzerContent                  = Get-Content -Raw -Path $ScriptAnalyzer;
        [ScriptBlock]$ScriptAnalyzerScriptBlock = [ScriptBlock]::Create('return ' + $ScriptAnalyzerContent);
        $ScriptAnalyzerData                     = (& $ScriptAnalyzerScriptBlock);

        $ScriptAnalyzerData.Add('IncludeRule', $ScriptAnalyzerData.IncludeRules);
        $ScriptAnalyzerData.Add('ExcludeRule', $ScriptAnalyzerData.ExcludeRules);
        $ScriptAnalyzerData.Remove('Rules');
        $ScriptAnalyzerData.Remove('IncludeRules');
        $ScriptAnalyzerData.Remove('ExcludeRules');

        $Result = Invoke-ScriptAnalyzer -Path $ModuleDir -Recurse -ReportSummary @ScriptAnalyzerData;

        if ($Result.Count -ne 0) {
            if ($ShowIssues -eq $FALSE) {
                Write-IcingaConsoleWarning 'Your script analyzer has found issues inside this module. Use "-ShowIssues" to print each of them, allowing you to fix them.';
            } else {
                Write-Host ($Result | Out-String);
            }
        } else {
            Write-IcingaConsoleNotice 'Your module does not have any code styling errors';
        }
    } else {
        Write-IcingaConsoleWarning 'The PowerShell ScriptAnalyzer is not installed on this system. Validating the module is not possible.';
    }

    try {
        Import-Module -Name $ModuleDir -Force -ErrorAction Stop;

        Write-IcingaConsoleNotice 'Your module was successfully loaded. No errors were detected';
    }
    catch {
        $ErrorScriptName = $_.InvocationInfo.ScriptName;
        $ErrorScriptLine = $_.InvocationInfo.Line;
        $PositionMessage = $_.InvocationInfo.PositionMessage;

        if (([string]$_.FullyQualifiedErrorId).Contains('System.IO.FileLoadException')) {
            $ErrorScriptName = $ModuleManifest;
            $ErrorScriptLine = 'Check your NestedModule argument to verify that all included modules are present and valid'
        }

        Write-IcingaConsoleError `
            -Message 'Failed to import the module "{0}": {1}{2}{2}Module File: {3}{2}Error Line: {4}{2}Position: {5}{2}{2}Full Error: {6}' `
            -Objects @(
                $ModuleName,
                $_.FullyQualifiedErrorId,
                (New-IcingaNewLine),
                $ErrorScriptName,
                $ErrorScriptLine,
                $PositionMessage,
                $_.Exception.Message
            );
    }
}
