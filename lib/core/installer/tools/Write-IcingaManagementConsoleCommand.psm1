function Write-IcingaManagementConsoleCommand()
{
    param (
        $Entry  = $null,
        $Values = @()
    );

    if ($null -eq $Entry -Or $Entry.ContainsKey('Action') -eq $FALSE) {
        return '';
    }

    [string]$PrintArguments = '';
    [string]$PrintCommand   = '';
    [hashtable]$DefinedArgs = @{ };

    if ($entry.Action.ContainsKey('Arguments') -And $entry.Action.Arguments.ContainsKey('-Command')) {
        $PrintCommand = $Entry.Action.Arguments['-Command'];
        if ($Entry.Action.Arguments.ContainsKey('-CmdArguments')) {
            $DefinedArgs = $Entry.Action.Arguments['-CmdArguments'];
        }
    } elseif ($entry.Action.ContainsKey('Command')) {
        $PrintCommand = $entry.Action.Command;
        if ($Entry.Action.ContainsKey('Arguments')) {
            $DefinedArgs = $Entry.Action.Arguments;
        }
    }

    foreach ($cmdArg in $DefinedArgs.Keys) {
        $PrintValue        = $DefinedArgs[$cmdArg];
        [string]$StringArg = ([string]$cmdArg).Replace('-', '');
        if ($PrintValue.GetType().Name -eq 'Boolean') {
            if ((Get-Command $PrintCommand).Parameters.$StringArg.ParameterType.Name -eq 'SwitchParameter') {
                $PrintValue = '';
            } else {
                if ($PrintValue) {
                    $PrintValue = '$TRUE';
                } else {
                    $PrintValue = '$FALSE';
                }
            }
        } elseif ($PrintValue.GetType().Name -eq 'String') {
            $PrintValue = (ConvertFrom-IcingaArrayToString -Array $PrintValue -AddQuotes -UseSingleQuotes);
        }
        if ([string]::IsNullOrEmpty($PrintValue)) {
            $PrintArguments += ([string]::Format('{0} ', $cmdArg));
        } else {
            $PrintArguments += ([string]::Format('{0} {1} ', $cmdArg, $PrintValue));
        }
    }

    $PrintArguments = $PrintArguments.Replace('$DefaultValues$', ((ConvertFrom-IcingaArrayToString -Array $Values -AddQuotes)));

    while ($PrintArguments[-1] -eq ' ') {
        $PrintArguments = $PrintArguments.SubString(0, $PrintArguments.Length - 1);
    }

    if ([string]::IsNullOrEmpty($PrintArguments) -eq $FALSE) {
        $PrintArguments = [string]::Format(' {0}', $PrintArguments);
    }

    Write-IcingaConsolePlain ([string]::Format('PS> {0}{1};', $PrintCommand, $PrintArguments)) -ForeColor Magenta;
    Write-IcingaConsolePlain '';
}
