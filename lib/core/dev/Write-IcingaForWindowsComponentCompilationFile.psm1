function Write-IcingaForWindowsComponentCompilationFile()
{
    param (
        [string]$ScriptRootPath   = '',
        [string]$CompiledFilePath = ''
    );

    # Store our current shell location
    [string]$OldLocation = Get-Location;
    # Get the current location and leave this folder
    Set-Location -Path $ScriptRootPath;
    Set-Location -Path '..';

    # Store the location of the current file

    # Now as we are inside the module root, get the name of the module and the path
    [string]$ModulePath = Get-Location;
    [string]$ModuleName = $ModulePath.Split('\')[-1];

    # Fetch all '.psm1' files from this module content
    [array]$ModuleFiles     = Get-ChildItem -Path $ModulePath -Recurse -Filter '*.psm1';
    # Get all public functions
    [array]$FunctionList    = @();
    [array]$VariableList    = @();
    [array]$AliasList       = @();
    [array]$CmdletList      = @();
    # Variable to store all of our module files
    [string]$CompiledModule = '';

    foreach ($entry in $ModuleFiles) {
        # Ensure the compilation file never includes itself
        if ($entry.FullName -eq $CompiledFilePath) {
            continue;
        }

        $FunctionList   += Get-IcingaForWindowsComponentPublicFunctions -FileObject $entry -ModuleName $ModuleName;
        $FileConfig      = (Read-IcingaPowerShellModuleFile -File $entry.FullName);
        $VariableList   += $FileConfig.VariableList;
        $AliasList      += $FileConfig.AliasList;
        $CmdletList     += $FileConfig.ExportCmdlet;
        $CompiledModule += (Get-Content -Path $entry.FullName -Raw -Encoding 'UTF8');
        $CompiledModule += "`r`n";
    }

    if ((Test-Path -Path $CompiledFilePath) -eq $FALSE) {
        New-Item -Path $CompiledFilePath -ItemType File -Force | Out-Null;
    }

    $CompiledModule += "`r`n";
    $CompiledModule += [string]::Format(
        "Export-ModuleMember -Cmdlet @( {0} ) -Function @( {1} ) -Variable @( {2} ) -Alias @( {3} );",
        ((ConvertFrom-IcingaArrayToString -Array ($CmdletList | Select-Object -Unique) -AddQuotes -UseSingleQuotes)),
        ((ConvertFrom-IcingaArrayToString -Array ($FunctionList | Select-Object -Unique) -AddQuotes -UseSingleQuotes)),
        ((ConvertFrom-IcingaArrayToString -Array ($VariableList | Select-Object -Unique) -AddQuotes -UseSingleQuotes)),
        ((ConvertFrom-IcingaArrayToString -Array ($AliasList | Select-Object -Unique) -AddQuotes -UseSingleQuotes))
    );

    Set-Content -Path $CompiledFilePath -Value $CompiledModule -Encoding 'UTF8';

    Import-Module -Name $ModulePath -Force;
    Import-Module -Name $ModulePath -Force -Global;

    # Set our location back to the previous folder
    Set-Location -Path $OldLocation;
}
