function Disable-IcingaFrameworkDebugMode()
{
    $global:IcingaDaemonData.DebugMode = $FALSE;
}
