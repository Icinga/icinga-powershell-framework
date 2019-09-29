function Install-IcingaAgentBaseFeatures()
{
    Disable-IcingaAgentFeature -Feature 'checker';
    Enable-IcingaAgentFeature -Feature 'api';
}
