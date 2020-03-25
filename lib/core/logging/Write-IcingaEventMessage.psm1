function Write-IcingaEventMessage()
{
    param(
        [int]$EventId      = 0,
        [string]$Namespace = $null
    );

    if ($EventId -eq 0 -Or $null -eq $Namespace) {
        return;
    }

    $EntryType = $IcingaEventLogEnums[$Namespace][$EventId].EntryType;
    $Message   = $IcingaEventLogEnums[$Namespace][$EventId].Message;

    if ($null -eq $EntryType -Or $null -eq $Message) {
        return;
    }

    Write-EventLog -LogName Application `
                   -Source 'Icinga for Windows' `
                   -EntryType $EntryType `
                   -EventId $EventId `
                   -Message $Message;
}
