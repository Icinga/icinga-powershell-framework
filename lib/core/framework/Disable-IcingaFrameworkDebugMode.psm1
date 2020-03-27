function Disable-IcingaFrameworkDebugMode()
{
    $global:IcingaDaemonData.DebugMode = $FALSE;
    Set-IcingaPowerShellConfig -Path 'Framework.DebugMode' -Value $FALSE;
}
