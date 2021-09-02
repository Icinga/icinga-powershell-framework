function Write-IcingaManagementConsoleCommand()
{
    param (
        $Entry  = $null,
        $Values = @()
    );

    if ($null -eq $Entry) {
        return;
    }

    if ($Entry.Action -And ($Entry.Action.ContainsKey('Command') -Or ($Entry.Action.ContainsKey('Arguments') -And $Entry.Action.Arguments.ContainsKey('-Command')))) {
        $PrintArguments = '';
        $PrintCommand   = ''
        if ($null -ne $Entry.Action.Arguments -And $Entry.Action.Arguments.ContainsKey('-CmdArguments')) {
            $PrintCommand = $Entry.Action.Arguments['-Command'];
            foreach ($cmdArg in $Entry.Action.Arguments['-CmdArguments'].Keys) {
                $PrintValue        = $Entry.Action.Arguments['-CmdArguments'][$cmdArg];
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
                } elseif ($PrintValue.GetType().Name -eq 'String' -And $PrintValue.Contains(' ')) {
                    $PrintValue = (ConvertFrom-IcingaArrayToString -Array $PrintValue -AddQuotes);
                }
                $PrintArguments += ([string]::Format('{0} {1} ', $cmdArg, $PrintValue));
            }
        } else {
            $PrintCommand = $Entry.Action.Command;
            if ($null -ne $Entry.Action.Arguments) {
                foreach ($cmdArg in $Entry.Action.Arguments.Keys) {
                    $PrintValue        = $Entry.Action.Arguments[$cmdArg];
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
                    } elseif ($PrintValue.GetType().Name -eq 'String' -And $PrintValue.Contains(' ')) {
                        $PrintValue = (ConvertFrom-IcingaArrayToString -Array $PrintValue -AddQuotes);
                    }
                    $PrintArguments += ([string]::Format('{0} {1} ', $cmdArg, $PrintValue));
                }
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
}
