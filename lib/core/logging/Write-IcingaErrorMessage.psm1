function Write-IcingaErrorMessage()
{
    param(
        [int]$EventId     = 0,
        [string]$Message  = $null
    );

    if ($EventId -eq 0 -Or [string]::IsNullOrEmpty($Message)) {
        return;
    }

    Write-EventLog -LogName Application -Source 'Icinga for Windows' -EntryType Error -EventId $EventId -Message $Message;
}
