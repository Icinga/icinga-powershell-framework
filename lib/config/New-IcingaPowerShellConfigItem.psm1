function New-IcingaPowerShellConfigItem()
{
    param(
        $ConfigObject,
        [string]$ConfigKey,
        $ConfigValue       = $null
    );

    if ($null -eq $ConfigValue) {
        $ConfigValue = (New-Object -TypeName PSOBject);
    }

    $ConfigObject | Add-Member -MemberType NoteProperty -Name $ConfigKey -Value $ConfigValue;
}
