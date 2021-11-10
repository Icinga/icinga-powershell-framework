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
        [array]$ModuleList       = @()
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

    [array]$ManifestContent = Get-Content -Path (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName)));

    if ($null -eq $ManifestContent -Or $ManifestContent.Count -eq 0) {
        Write-IcingaConsoleWarning 'The manifest file of module "{0}" could not be loaded for updating NestedModules' -Objects $ModuleName;
        return;
    }

    [bool]$UpdateNestedModules = $FALSE;

    foreach ($entry in $ManifestContent) {
        [string]$ManifestLine = $entry;

        if ($UpdateNestedModules -And $entry -Like '*)*') {
            $UpdateNestedModules = $FALSE;
            continue;
        }

        if ($UpdateNestedModules) {
            continue;
        }

        if ($entry -Like '*nestedmodules*') {
            if ($entry -NotLike '*)*') {
                $UpdateNestedModules = $TRUE;
            }
            $ContentString.AppendLine('    NestedModules     = @(') | Out-Null;

            if ($ModuleList.Count -ne 0) {
                [array]$NestedModules = (ConvertFrom-IcingaArrayToString -Array $ModuleList -AddQuotes -UseSingleQuotes).Split(',');
                [int]$ModuleIndex     = 0;
                foreach ($module in $NestedModules) {
                    if ([string]::IsNullOrEmpty($module)) {
                        continue;
                    }

                    $ModuleIndex += 1;

                    if ($ModuleIndex -ne $NestedModules.Count) {
                        if ($ModuleIndex -eq 1) {
                            $ManifestLine = [string]::Format('        {0},', $module);
                        } else {
                            $ManifestLine = [string]::Format('       {0},', $module);
                        }
                    } else {
                        if ($ModuleIndex -eq 1) {
                            $ManifestLine = [string]::Format('        {0}', $module);
                        } else {
                            $ManifestLine = [string]::Format('       {0}', $module);
                        }
                    }

                    $ContentString.AppendLine($ManifestLine) | Out-Null;
                }
            }

            $ContentString.AppendLine('    )') | Out-Null;
            continue;
        }

        if ([string]::IsNullOrEmpty($ManifestLine.Replace(' ', '')) -Or $ManifestLine -eq "`r`n" -Or $ManifestLine -eq "`n") {
            continue;
        }

        $ContentString.AppendLine($ManifestLine) | Out-Null;
    }

    Write-IcingaFileSecure -File (Join-Path -Path $ModuleDir -ChildPath ([string]::Format('{0}.psd1', $ModuleName))) -Value $ContentString.ToString();
}
