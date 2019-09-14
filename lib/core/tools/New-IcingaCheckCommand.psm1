function New-IcingaCheckCommand()
{
    param(
        [string]$Name = '',
        [array]$Arguments    = @(
            'Warning',
            'Critical',
            '[switch]NoPerfData',
            'Verbose'
        ),
        [array]$ImportLib    = @()
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
        '{0}.psm1',
        $CommandName
    );

    [string]$ScriptFile = Join-Path -Path (Get-IcingaPluginDir) -ChildPath $CommandFile;

    if ((Test-Path $ScriptFile) -eq $TRUE) {
        throw 'This Check-Command does already exist.';
    }

    Add-Content -Path $ScriptFile -Value 'Import-IcingaLib icinga\plugin;';

    foreach ($Library in $ImportLib) {
        Add-Content -Path $ScriptFile -Value "Import-IcingaLib $Library;";
    }

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
    Add-Content -Path $ScriptFile -Value "}";

    Write-Host ([string]::Format('The Check-Command "{0}" was successfully added.', $CommandName));

    # Try to open the default Editor for the new Cmdlet
    $DefaultEditor = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.psm1\OpenWithList' -Name a).a;
    #$DefaultEditor = $DefaultEditor.Replace('.exe', '');

    Write-Host ([string]::IsNullOrEmpty($DefaultEditor));
    Write-Host ((Get-Command $DefaultEditor -ErrorAction SilentlyContinue));
    Write-Host ((Test-Path $DefaultEditor));

    if ([string]::IsNullOrEmpty($DefaultEditor) -eq $FALSE -And ((Get-Command $DefaultEditor -ErrorAction SilentlyContinue) -eq $null) -And ((Test-Path $DefaultEditor) -eq $FALSE)) {
        Write-Host 'No default editor for .psm1 files found. Specify a default editor to automaticly open the newly generated check plugin.';
        return;
    }

    & $DefaultEditor "$ScriptFile";
}
