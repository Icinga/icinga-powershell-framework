function Write-IcingaDebugMessage()
{
    param(
        [string]$Message
    );

    if ($global:IcingaDaemonData.DebugMode -eq $FALSE) {
        return;
    }

    Write-EventLog -LogName Application -Source 'Icinga for Windows' -EntryType Information -EventId 1000 -Message $Message;
}
