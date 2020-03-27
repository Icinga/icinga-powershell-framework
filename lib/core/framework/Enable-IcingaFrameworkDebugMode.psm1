function Enable-IcingaFrameworkDebugMode()
{
    $global:IcingaDaemonData.DebugMode = $TRUE;
    Set-IcingaPowerShellConfig -Path 'Framework.DebugMode' -Value $TRUE;
}
