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

    foreach ($proc in $process) {
        $ProcessCount = $ProcessInformation."Processes".$proc.processlist.Count;
        $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Process Count "{0}"', $proc)) -Value $ProcessCount;
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $ProcessPackage.AddCheck($IcingaCheck);
    }


    exit (New-IcingaCheckResult -Check $ProcessPackage -NoPerfData $TRUE -Compile);
}
