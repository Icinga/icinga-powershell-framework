function Register-IcingaEventLog()
{
    param (
        [string]$LogName = $null
    );

    if ([string]::IsNullOrEmpty($LogName)) {
        New-EventLog -LogName 'Icinga for Windows' -Source 'IfW::Framework' -ErrorAction SilentlyContinue;
        New-EventLog -LogName 'Icinga for Windows' -Source 'IfW::Service' -ErrorAction SilentlyContinue;
        New-EventLog -LogName 'Icinga for Windows' -Source 'IfW::Debug' -ErrorAction SilentlyContinue;
    } else {
        $LogName = [string]::Format('IfW::{0}', $LogName);

        New-EventLog -LogName 'Icinga for Windows' -Source $LogName -ErrorAction SilentlyContinue;
    }
}
