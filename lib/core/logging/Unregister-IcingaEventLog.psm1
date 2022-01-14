function Unregister-IcingaEventLog()
{
    # Icinga for Windows v1.8.0 or later
    Remove-EventLog -LogName 'Icinga for Windows' -ErrorAction SilentlyContinue;

    # Older versions
    Remove-EventLog -Source 'Icinga for Windows' -ErrorAction SilentlyContinue;
    # Icinga for Windows v1.8.0 or later - required a second time to ensure
    # everything is removed for legacy versions
    Remove-EventLog -LogName 'Icinga for Windows' -ErrorAction SilentlyContinue;
}
