Import-IcingaLib core\perfcounter;
Import-IcingaLib icinga\plugin;

function Invoke-IcingaCheckFreePartition()
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
    $DiskPackage = New-IcingaCheckPackage -Name 'Free Disk Space' -OperatorAnd -Verbos $Verbose;
    [array]$CheckedPartitions;

    foreach ($Letter in $DiskFree.Keys) {
        if ($Include.Count -ne 0) {
            $Include = $Include.trim(' :/\');
            if (-Not ($Include.Contains($Letter))) {
                continue;
            }
        }

        $CheckedPartitions+=$Letter

        if ($Exclude.Count -ne 0) {
            $Exclude = $Exclude.trim(' :/\');
            if ($Exclude.Contains($Letter)) {
                continue;
            }
        }

        $IcingaCheck = New-IcingaCheck -Name ([string]::Format('Partition {0}', $Letter)) -Value $DiskFree.([string]::Format($Letter))."Free Space" -Unit '%';
        $IcingaCheck.WarnOutOfRange($Warning).CritOutOfRange($Critical) | Out-Null;
        $DiskPackage.AddCheck($IcingaCheck);
    }

    exit (New-IcingaCheckResult -Name 'Free Disk Space' -Check $DiskPackage -NoPerfData $NoPerfData -Compile);
}
