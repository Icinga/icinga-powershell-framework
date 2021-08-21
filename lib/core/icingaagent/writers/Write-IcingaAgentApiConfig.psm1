function Write-IcingaAgentApiConfig()
{
    param(
        [int]$Port = 5665
    );

    [string]$ApiConf = '';

    $ApiConf = [string]::Format('{0}object ApiListener "api" {1}{2}', $ApiConf, '{', "`r`n");
    $ApiConf = [string]::Format('{0}    accept_commands = true;{1}', $ApiConf, "`r`n");
    $ApiConf = [string]::Format('{0}    accept_config = true;{1}', $ApiConf, "`r`n");
    $ApiConf = [string]::Format('{0}    bind_host = "::";{1}', $ApiConf, "`r`n");
    $ApiConf = [string]::Format('{0}    bind_port = {1};{2}', $ApiConf, $Port, "`r`n");
    $ApiConf = [string]::Format('{0}{1}{2}{2}', $ApiConf, '}', "`r`n");

    $ApiConf = $ApiConf.Substring(0, $ApiConf.Length - 4);

    Write-IcingaFileSecure -File (Join-Path -Path (Get-IcingaAgentConfigDirectory) -ChildPath 'features-available\api.conf') -Value $ApiConf;
    Write-IcingaConsoleNotice 'Api configuration has been written successfully';
}
