function Install-IcingaAgentBaseFeatures()
{
    Disable-IcingaAgentFeature -Feature 'checker';
    Disable-IcingaAgentFeature -Feature 'notification';
    Enable-IcingaAgentFeature -Feature 'api';
}
