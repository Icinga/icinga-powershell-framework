function Read-IcingaForWindowsLog()
{
    Read-IcingaWindowsEventLog -LogName 'Application' -Source 'Icinga for Windows' -MaxEntries 500;
}
