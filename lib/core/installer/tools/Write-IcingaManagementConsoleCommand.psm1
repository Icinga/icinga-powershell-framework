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

    $PrintArguments = ConvertTo-IcingaCommandArgumentString -Command $PrintCommand -CommandArguments $DefinedArgs;
    $PrintArguments = $PrintArguments.Replace('$DefaultValues$', ((ConvertFrom-IcingaArrayToString -Array $Values -AddQuotes)));

    if ([string]::IsNullOrEmpty($PrintArguments) -eq $FALSE) {
        $PrintArguments = [string]::Format(' {0}', $PrintArguments);
    }

    Write-IcingaConsolePlain ([string]::Format('PS> {0}{1};', $PrintCommand, $PrintArguments)) -ForeColor Magenta;
    Write-IcingaConsolePlain '';
}
