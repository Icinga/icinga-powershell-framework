function Set-IcingaTLSVersion()
{
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
}
