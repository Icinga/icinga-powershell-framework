Import-IcingaLib core\perfcounter;
Import-IcingaLib icinga\plugin;

function Invoke-IcingaCheckUsedPartitionSpace()
{
    param(
        $Warning,
        $Critical,
        [array]$Include               = @(),
        [array]$Exclude               = @(),
        [switch]$NoPerfData,
        $Verbose
    );

    $DiskFree = Get-IcingaDiskPartitions;
    $DiskPackage = New-IcingaCheckPackage -Name 'Used Partition Space' -OperatorAnd -Verbos $Verbose;

    foreach ($Letter in $DiskFree.Keys) {
        if ($Include.Count -ne 0) {
            $Include = $Include.trim(' :/\');
            if (-Not ($Include.Contains($Letter))) {
                continue;
            }
        }


        if ($Exclude.Count -ne 0) {
            $Exclude = $Exclude.trim(' :/\');
            if ($Exclude.Contains($Letter)) {
                continue;
            }
        }

        $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Partition {0}', $Letter)) -Value (100-($DiskFree.([string]::Format($Letter))."Free Space")) -Unit '%';
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $DiskPackage.AddCheck($IcingaCheck);
    }

    return (New-IcingaCheckResult -Check $DiskPackage -NoPerfData $NoPerfData -Compile);
}
