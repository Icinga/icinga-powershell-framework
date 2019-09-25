Import-IcingaLib icinga\plugin;
Import-IcingaLib provider\windows;
Import-IcingaLib core\tools;

function Invoke-IcingaCheckUptime()
{
    param(
        $Warning,
        $Critical,
        [switch]$NoPerfData,
        [int]$Verbose
    );

    $WindowsData = Get-IcingaWindows;
    $Name        = ([string]::Format('Windows Uptime: {0}', (ConvertFrom-TimeSpan -Seconds $WindowsData.windows.metadata.uptime.value)));

    $IcingaCheck = New-IcingaCheck -Name 'Windows Uptime' -Value $WindowsData.windows.metadata.uptime.value -Unit 's';
    $IcingaCheck.WarnOutOfRange(
        (ConvertTo-SecondsFromIcingaThresholds -Threshold $Warning)
    ).CritOutOfRange(
        (ConvertTo-SecondsFromIcingaThresholds -Threshold $Critical)
    ) | Out-Null;

    $CheckPackage = New-IcingaCheckPackage -Name $Name -OperatorAnd -Checks $IcingaCheck -Verbose $Verbose;

    return (New-IcingaCheckresult -Check $CheckPackage -NoPerfData $NoPerfData -Compile);
}
