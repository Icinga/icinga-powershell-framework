function Get-IcingaAgentArchitecture()
{
    $IcingaAgent = Get-IcingaAgentInstallation;

    return $IcingaAgent.Architecture;
}
