function New-IcingaCheckCommand()
{
    param(
        [string]$Name = '',
        [array]$Arguments    = @(
            'Warning',
            'Critical',
            '[switch]NoPerfData',
            '[int]Verbose'
        )
    );

    if ([string]::IsNullOrEmpty($Name) -eq $TRUE) {
        throw 'Please specify a command name';
    }

    if ($Name -match 'Invoke' -or $Name -match 'IcingaCheck') {
        throw 'Please specify a command name only without PowerShell Cmdlet naming';
    }

    [string]$CommandName = [string]::Format(
        'Invoke-IcingaCheck{0}',
        (Get-Culture).TextInfo.ToTitleCase($Name.ToLower())
    );

    [string]$CommandFile = [string]::Format(
        'icinga-powershell-{0}.psm1',
        $Name.ToLower()
    );
    [string]$PSDFile = [string]::Format(
        'icinga-powershell-{0}.psd1',
        $Name.ToLower()
    );

    [string]$ModuleFolder = Join-Path -Path (Get-IcingaFrameworkRootPath) -ChildPath (
        [string]::Format('icinga-powershell-{0}', $Name.ToLower())
    );
    [string]$ScriptFile   = Join-Path -Path $ModuleFolder -ChildPath $CommandFile;
    [string]$PSDFile      = Join-Path -Path $ModuleFolder -ChildPath $PSDFile;

    if ((Test-Path $ModuleFolder) -eq $TRUE) {
        throw 'This module folder does already exist.';
    }

    if ((Test-Path $ScriptFile) -eq $TRUE) {
        throw 'This check command does already exist.';
    }

    New-Item -Path $ModuleFolder -ItemType Directory | Out-Null;

    Add-Content -Path $ScriptFile -Value '';
    Add-Content -Path $ScriptFile -Value "function $CommandName()";
    Add-Content -Path $ScriptFile -Value "{";

    if ($Arguments.Count -ne 0) {
        Add-Content -Path $ScriptFile -Value "    param(";
        [int]$index = $Arguments.Count - 1;
        foreach ($argument in $Arguments) {

            if ($argument.Contains('$') -eq $FALSE) {
                if ($argument.Contains(']') -eq $TRUE) {
                    $splittedArguments = $argument.Split(']');
                    $argument = [string]::Format('{0}]${1}', $splittedArguments[0], $splittedArguments[1]);
                } else {
                    $argument = [string]::Format('${0}', $argument);
                }
            }

            if ($index -ne 0) {
                [string]$content = [string]::Format('{0},', $argument);
            } else {
                [string]$content = [string]::Format('{0}', $argument);
            }
            Add-Content -Path $ScriptFile -Value "        $content";

            $index -= 1;
        }
        Add-Content -Path $ScriptFile -Value "    );";
    }

    Add-Content -Path $ScriptFile -Value "";
    Add-Content -Path $ScriptFile -Value '    <# Icinga Basic Check-Plugin Template. Below you will find an example structure. #>';
    Add-Content -Path $ScriptFile -Value ([string]::Format('    $CheckPackage = New-IcingaCheckPackage -Name {0}New Package{0} -OperatorAnd -Verbose $Verbose;', "'"));
    Add-Content -Path $ScriptFile -Value ([string]::Format('    $IcingaCheck  = New-IcingaCheck -Name {0}New Check{0} -Value 10 -Unit {0}%{0}', "'"));
    Add-Content -Path $ScriptFile -Value ([string]::Format('    $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;', "'"));
    Add-Content -Path $ScriptFile -Value ([string]::Format('    $CheckPackage.AddCheck($IcingaCheck);', "'"));
    Add-Content -Path $ScriptFile -Value "";
    Add-Content -Path $ScriptFile -Value ([string]::Format('    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);', "'"));

    Add-Content -Path $ScriptFile -Value "}";

    Write-IcingaConsoleNotice ([string]::Format('The Check-Command "{0}" was successfully added.', $CommandName));

    # Try to open the default Editor for the new Cmdlet
    $DefaultEditor = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.psm1\OpenWithList' -Name a).a;
    $DefaultEditor = $DefaultEditor.Replace('.exe', '');

    New-ModuleManifest `
        -Path $PSDFile `
        -ModuleToProcess $CommandFile `
        -RequiredModules @('icinga-powershell-framework') `
        -FunctionsToExport @('*') `
        -CmdletsToExport @('*') `
        -VariablesToExport '*' | Out-Null;

    Unblock-IcingaPowerShellFiles -Path $ModuleFolder;

    Import-Module $ScriptFile -Global;

    if ([string]::IsNullOrEmpty($DefaultEditor) -eq $FALSE -And ($null -eq (Get-Command $DefaultEditor -ErrorAction SilentlyContinue)) -And ((Test-Path $DefaultEditor) -eq $FALSE)) {
        Write-IcingaConsoleWarning 'No default editor for .psm1 files found. Specify a default editor to automatically open the newly generated check plugin.';
        return;
    }

    & $DefaultEditor "$ScriptFile";
}
