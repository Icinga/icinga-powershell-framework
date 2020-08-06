function Register-IcingaEventLog()
{
    try {
        # Run this in a Try-Catch-Block, as we will run into an exception if it is not
        # present in the Application where it should be once we try to load the
        # Security log. If it is not found in the "public" Event-Log data, the
        # App is not registered
        $Registered = [System.Diagnostics.EventLog]::SourceExists(
            'Icinga for Windows'
        );

        if ($Registered) {
            return;
        }

        New-EventLog -LogName Application -Source 'Icinga for Windows';
    } catch {
        Exit-IcingaThrowException -ExceptionType 'Configuration' -ExceptionThrown $IcingaExceptions.Configuration.EventLogNotInstalled -Force;
    }
}
