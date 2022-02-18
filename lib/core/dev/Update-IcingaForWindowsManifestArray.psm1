function Update-IcingaForWindowsManifestArray()
{
    param (
        [string]$ManifestFile       = '',
        [array]$ArrayVariableValues = @(),
        [string]$ArrayVariableName  = ''
    );

    if ([string]::IsNullOrEmpty($ArrayVariableName)) {
        return;
    }

    # Remove duplicate entries
    $ArrayVariableValues = $ArrayVariableValues | Select-Object -Unique;

    [array]$ManifestContent = Get-Content -Path $ManifestFile -ErrorAction SilentlyContinue;

    if ($null -eq $ManifestContent -Or $ManifestContent.Count -eq 0) {
        Write-IcingaConsoleWarning 'The manifest file "{0}" could not be loaded for updating array element "{1}2' -Objects $ManifestFile, $ArrayVariableName;
        return;
    }

    $ContentString             = New-Object -TypeName 'System.Text.StringBuilder';
    [bool]$UpdatedArrayContent = $FALSE;

    foreach ($entry in $ManifestContent) {
        [string]$ManifestLine = $entry;

        if ($UpdatedArrayContent -And $entry -Like '*)*') {
            $UpdatedArrayContent = $FALSE;
            continue;
        }

        if ($UpdatedArrayContent) {
            continue;
        }

        if ($entry -Like ([string]::Format('*{0}*', $ArrayVariableName.ToLower()))) {
            if ($entry -NotLike '*)*') {
                $UpdatedArrayContent = $TRUE;
            }
            $ContentString.AppendLine(([string]::Format('    {0}     = @(', $ArrayVariableName))) | Out-Null;

            if ($ArrayVariableValues.Count -ne 0) {
                [array]$NestedModules = (ConvertFrom-IcingaArrayToString -Array $ArrayVariableValues -AddQuotes -UseSingleQuotes).Split(',');
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

    Write-IcingaFileSecure -File $ManifestFile -Value $ContentString.ToString();
}
