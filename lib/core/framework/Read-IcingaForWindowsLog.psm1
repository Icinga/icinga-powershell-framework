function Read-IcingaForWindowsLog()
{
    param (
        [array]$Source = @()
    );

    Read-IcingaWindowsEventLog -LogName 'Icinga for Windows' -Source $Source -MaxEntries 500;
}
