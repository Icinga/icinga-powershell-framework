function Get-IcingaAgentRootDirectory()
{
    $IcingaAgent = Get-IcingaAgentInstallation;
    if ($IcingaAgent.Installed -eq $FALSE) {
        return '';
    }

    return $IcingaAgent.RootDir;
}
