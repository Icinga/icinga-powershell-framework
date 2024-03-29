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

    $IfWEventLog = Get-WinEvent -ListLog 'Icinga for Windows';
    # Set the size to 20MiB
    $IfWEventLog.MaximumSizeInBytes = 20971520;
    $IfWEventLog.SaveChanges();
}
