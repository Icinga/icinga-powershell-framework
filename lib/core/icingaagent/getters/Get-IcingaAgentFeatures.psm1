function Get-IcingaAgentFeatures()
{
    $Binary       = Get-IcingaAgentBinary;
    $ConfigResult = Start-IcingaProcess -Executable $Binary -Arguments 'feature list';

    $DisabledFeatures = ($ConfigResult.Message.SubString(
        0,
        $ConfigResult.Message.IndexOf('Enabled features')
    )).Replace('Disabled features: ', '').Replace("`r`n", '').Replace("`r", '').Replace("`n", '');

    $EnabledFeatures  = ($ConfigResult.Message.SubString(
        $ConfigResult.Message.IndexOf('Enabled features'),
        $ConfigResult.Message.Length - $ConfigResult.Message.IndexOf('Enabled features')
    )).Replace('Enabled features: ', '').Replace("`r`n", '').Replace("`r", '').Replace("`n", '');

    return @{
        'Enabled'  = ($EnabledFeatures.Split(' '));
        'Disabled' = ($DisabledFeatures.Split(' '));
    }
}
