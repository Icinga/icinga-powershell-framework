<#
.SYNOPSIS
    Updates a Icinga for Windows manifest file by updating NestedModules for
    easier usage
.DESCRIPTION
    Updates a Icinga for Windows manifest file by updating NestedModules for
    easier usage
.PARAMETER Name
    The name of the Icinga for Windows component to edit
.PARAMETER ModuleConfig
    Configuration parsed as hashtable to update our manifest template with proper data
.PARAMETER ModuleList
    An array of PowerShell module files within module to update the NestedModule entry with
#>
function Write-IcingaForWindowsComponentManifest()
{
    param (
        [string]$Name,
        [hashtable]$ModuleConfig = @{ },
        [array]$ModuleList       = @(),
        [array]$FunctionList     = @(),
        [array]$CmdletList       = @(),
        [array]$VariableList     = @(),
        [array]$AliasList        = @()
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError 'Please specify a name for writing the component manifest';
        return;
    }

    $PSDefaultParameterValues = @{ '*:Encoding' = 'utf8' };

    [string]$ModuleName       = [string]::Format('icinga-powershell-{0}', $Name.ToLower());
    [string]$ModuleRoot       = Get-IcingaForWindowsRootPath;
    [string]$ModuleDir        = Join-Path -Path $ModuleRoot -ChildPath $ModuleName;
    [string]$ManifestFileData = Read-IcingaFileSecure -File (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName)));
    $ContentString            = New-Object -TypeName 'System.Text.StringBuilder';

    if ([string]::IsNullOrEmpty($ManifestFileData)) {
        Write-IcingaConsoleWarning 'The manifest file of module "{0}" could not be loaded' -Objects $ModuleName;
        return;
    }

    $ManifestFileData = $ManifestFileData.Substring($ManifestFileData.IndexOf('@'), $ManifestFileData.Length - $ManifestFileData.IndexOf('@'));

    if ($null -ne $ModuleConfig -And $ModuleConfig.Count -ne 0) {
        foreach ($entry in $ModuleConfig.Keys) {
            $Value            = $ModuleConfig[$entry];

            if ($entry -Like '$TAGS$') {
                $Value = (ConvertFrom-IcingaArrayToString -Array $Value -AddQuotes -UseSingleQuotes)
            } elseif ($entry -Like '$REQUIREDMODULES$') {
                [int]$CurrentIndex = 0;
                foreach ($module in $Value) {
                    $CurrentIndex += 1;
                    $ContentString.Append('@{ ') | Out-Null;

                    foreach ($dependency in $module.Keys) {
                        $DependencyValue = $module[$dependency];

                        $ContentString.Append([string]::Format("{0} = '{1}'; ", $dependency, $DependencyValue)) | Out-Null;
                    }
                    $ContentString.Append('}') | Out-Null;

                    if ($CurrentIndex -ne $Value.Count) {
                        $ContentString.Append(",`r`n        ") | Out-Null;
                    }
                }

                $Value = $ContentString.ToString();
            }

            $ManifestFileData = $ManifestFileData.Replace($entry, $Value);
        }

        Write-IcingaFileSecure -File (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName))) -Value $ManifestFileData;
    }

    $ContentString.Clear() | Out-Null;

    [string]$ManifestFile = (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName)));

    Update-IcingaForWindowsManifestArray -ArrayVariableName 'NestedModules' -ArrayVariableValues $ModuleList -ManifestFile $ManifestFile;
    Update-IcingaForWindowsManifestArray -ArrayVariableName 'FunctionsToExport' -ArrayVariableValues $FunctionList -ManifestFile $ManifestFile;
    Update-IcingaForWindowsManifestArray -ArrayVariableName 'CmdletsToExport' -ArrayVariableValues $CmdletList -ManifestFile $ManifestFile;
    Update-IcingaForWindowsManifestArray -ArrayVariableName 'VariablesToExport' -ArrayVariableValues $VariableList -ManifestFile $ManifestFile;
    Update-IcingaForWindowsManifestArray -ArrayVariableName 'AliasesToExport' -ArrayVariableValues $AliasList -ManifestFile $ManifestFile;

    Import-Module -Name $ManifestFile -Force;
    Import-Module -Name $ManifestFile -Force -Global;
}
