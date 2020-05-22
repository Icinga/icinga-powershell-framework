function Register-IcingaEventLog()
{
    $Registered = [System.Diagnostics.EventLog]::SourceExists(
        'Icinga for Windows'
    );

    if ($Registered) {
        return;
    }

    New-EventLog -LogName Application -Source 'Icinga for Windows';
}
