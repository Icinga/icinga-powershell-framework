function Set-IcingaAgentNodeName()
{
    param(
        $Hostname
    );

    if ([string]::IsNullOrEmpty($Hostname)) {
        throw 'You have to specify a hostname in order to change the Icinga Agent NodeName';
    }

    $ConfigDir     = Get-IcingaAgentConfigDirectory;
    $ConstantsConf = Join-Path -Path $ConfigDir -ChildPath 'constants.conf';

    $ConfigContent = Get-Content -Path $ConstantsConf;

    if ($ConfigContent.Contains('//const NodeName = "localhost"')) {
        $ConfigContent = $ConfigContent.Replace(
            '//const NodeName = "localhost"',
            [string]::Format('const NodeName = "{0}"', $Hostname)
        );
    } else {
        [string]$NewConfigContent = '';
        foreach ($line in $ConfigContent) {
            if ($line.Contains('const NodeName =')) {
                $line = [string]::Format('const NodeName = "{0}"', $Hostname);
            }
            $NewConfigContent = [string]::Format('{0}{1}{2}', $NewConfigContent, $line, "`r`n");
        }
        $ConfigContent = $NewConfigContent;
    }

    Set-Content -Path $ConstantsConf -Value $ConfigContent;

    Write-Host ([string]::Format('Your hostname was successfully changed to "{0}"', $Hostname));
}
