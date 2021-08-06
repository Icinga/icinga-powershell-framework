function Write-IcingaJEAProfile()
{
    param (
        [switch]$RebuildFramework  = $FALSE,
        [switch]$AllowScriptBlocks = $FALSE
    );

    [hashtable]$JeaConfig = Get-IcingaJEAConfiguration -RebuildFramework:$RebuildFramework -AllowScriptBlocks:$AllowScriptBlocks;
    $JeaFile              = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'templates\IcingaForWindows.psrc.template';
    $JeaString            = Get-Content $JeaFile;
    $NewJeaFile           = '';

    foreach ($line in $JeaString) {
        if ($line -like '*ModulesToImport*') {
            $NewJeaFile += [string]::Format('    ModulesToImport     = {0}{1}', (ConvertFrom-IcingaArrayToString -Array $JeaConfig.Modules -AddQuotes), "`n");
            continue;
        }
        if ($line -like '*VisibleCmdlets*') {
            $NewJeaFile += [string]::Format('    VisibleCmdlets      = {0}{1}', (ConvertFrom-IcingaArrayToString -Array $JeaConfig.Cmdlet.Keys -AddQuotes), "`n");
            continue;
        }
        if ($line -like '*VisibleFunctions*') {
            $NewJeaFile += [string]::Format('    VisibleFunctions    = {0}{1}', (ConvertFrom-IcingaArrayToString -Array $JeaConfig.Function.Keys -AddQuotes), "`n");
            continue;
        }
        $NewJeaFile += $line + "`n";
    }

    Set-Content -Path (Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath 'RoleCapabilities\IcingaForWindows.psrc') -Value $NewJeaFile;
}
