function ConvertTo-IcingaCommandArgumentString()
{
    param (
        [string]$Command  = '',
        $CommandArguments = $null
    );

    [hashtable]$Arguments = @{ };

    if ($CommandArguments -Is [PSCustomObject]) {
        foreach ($entry in $CommandArguments.PSObject.Properties) {
            $Arguments.Add($entry.Name, $entry.Value);
        }
    } elseif ($CommandArguments -Is [hashtable]) {
        $Arguments = $CommandArguments;
    } else {
        return '';
    }

    foreach ($cmdArg in $Arguments.Keys) {
        $PrintValue        = $Arguments[$cmdArg];
        [string]$StringArg = ([string]$cmdArg).Replace('-', '');

        if ($PrintValue.GetType().Name -eq 'Boolean') {
            if ((Get-Command $Command).Parameters.$StringArg.ParameterType.Name -eq 'SwitchParameter') {
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
        }  elseif ($PrintValue.GetType().Name -eq 'Object[]') {
            $PrintValue = (ConvertFrom-IcingaArrayToString -Array $PrintValue -AddQuotes -UseSingleQuotes);
        }
        if ([string]::IsNullOrEmpty($PrintValue)) {
            $PrintArguments += ([string]::Format('{0} ', $cmdArg));
        } else {
            $PrintArguments += ([string]::Format('{0} {1} ', $cmdArg, $PrintValue));
        }
    }

    while ($PrintArguments[-1] -eq ' ') {
        $PrintArguments = $PrintArguments.SubString(0, $PrintArguments.Length - 1);
    }

    return $PrintArguments;
}
