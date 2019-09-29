function Get-IcingaAgentVersion()
{
    $IcingaAgent = Get-IcingaAgentInstallation;

    return $IcingaAgent.Version;
}
