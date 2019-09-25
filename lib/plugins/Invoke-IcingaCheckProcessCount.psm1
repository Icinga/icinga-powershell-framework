Import-IcingaLib provider\process;
Import-IcingaLib icinga\plugin;

function Invoke-IcingaCheckProcessCount()
{
    param(
        $Warning,
        $Critical,
        [array]$Process,
        [switch]$NoPerfData,
        $Verbose
    );

    $ProcessInformation = (Get-IcingaProcessData -Name $Process)

    $ProcessPackage = New-icingaCheckPackage -Name "Process Check" -OperatorAnd -Verbose $Verbose -NoPerfData $NoPerfData;

    if ($Process.Count -eq 0) {
        $ProcessCount = $ProcessInformation['Process Count'];
        $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Process Count')) -Value $ProcessCount;
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $ProcessPackage.AddCheck($IcingaCheck);
    } else {
        foreach ($proc in $process) {
            $ProcessCount = $ProcessInformation."Processes".$proc.processlist.Count;
            $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Process Count "{0}"', $proc)) -Value $ProcessCount;
            $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
            $ProcessPackage.AddCheck($IcingaCheck);
        }
    }


    return (New-IcingaCheckResult -Check $ProcessPackage -NoPerfData $NoPerfData -Compile);
}
