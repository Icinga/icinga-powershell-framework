function Read-IcingaForWindowsLog()
{
    param (
        [array]$Source  = @(),
        [array]$Include = @(),
        [array]$Exclude = @()
    );

    Read-IcingaWindowsEventLog -LogName 'Icinga for Windows' -Source $Source -MaxEntries 500 -Include $Include -Exclude $Exclude;
}
