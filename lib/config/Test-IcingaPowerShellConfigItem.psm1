function Test-IcingaPowerShellConfigItem()
{
    param(
        $ConfigObject,
        $ConfigKey
    );

    return ([bool]($ConfigObject.PSobject.Properties.Name -eq $ConfigKey) -eq $TRUE);
}
