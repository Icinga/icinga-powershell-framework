function Clear-IcingaInternalServiceInformation()
{
    $Global:Icinga.Protected.ServiceRestartLock = $FALSE;
    $Global:Icinga.Protected.IcingaServiceUser  = '';
    $Global:Icinga.Protected.IfWServiceUser     = '';
    $Global:Icinga.Protected.IcingaServiceState = '';
    $Global:Icinga.Protected.IfWServiceState    = '';
}
