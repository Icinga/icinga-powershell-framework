param($Config = $null);

function ClassDisk()
{
    param($Config = $null);
    # The storage variables we require to store our data
    [hashtable]$StructuredDiskData = @{};

    # This will return a hashtable with every single counter
    # we specify within the array. Instead of returning all
    # the values in the returned hashtable, we will rebuild
    # the result a little to have a improved output which
    # is more user friendly and allows us to check for
    # certain disks / volumes in details with a simpler
    # accessing possibility
    $counter = Get-Icinga-Counter -CounterArray @(
        '\PhysicalDisk(*)\% Disk Read Time',
        '\PhysicalDisk(*)\Current Disk Queue Length',
        '\PhysicalDisk(*)\Avg. Disk Bytes/Transfer',
        '\PhysicalDisk(*)\Split IO/sec',
        '\PhysicalDisk(*)\Disk Reads/sec',
        '\PhysicalDisk(*)\Disk Writes/sec',
        '\PhysicalDisk(*)\Disk Bytes/sec',
        '\PhysicalDisk(*)\Avg. Disk Read Queue Length',
        '\PhysicalDisk(*)\Avg. Disk sec/Write',
        '\PhysicalDisk(*)\% Disk Time',
        '\PhysicalDisk(*)\Avg. Disk sec/Transfer',
        '\PhysicalDisk(*)\Avg. Disk Bytes/Write',
        '\PhysicalDisk(*)\% Disk Write Time',
        '\PhysicalDisk(*)\Avg. Disk Queue Length',
        '\PhysicalDisk(*)\Disk Write Bytes/sec',
        '\PhysicalDisk(*)\Avg. Disk sec/Read',
        '\PhysicalDisk(*)\Disk Read Bytes/sec',
        '\PhysicalDisk(*)\Disk Transfers/sec',
        '\PhysicalDisk(*)\% Idle Time',
        '\PhysicalDisk(*)\Avg. Disk Write Queue Length',
        '\PhysicalDisk(*)\Avg. Disk Bytes/Read'
    );

    $logicalCounter = Get-Icinga-Counter -CounterArray @(
        '\LogicalDisk(*)\Free Megabytes',
        '\LogicalDisk(*)\% Free Space'
    );

    # This function will help us to build a structured output based on
    # volumes / disks found within the instances. We will use our
    # LogicalDisk as 'index' to assign our performance Counters to.
    # In addition we then provide the hashtable of counters we fetched
    # above. Last but not least we cleanup the instances name to replace
    # 'HarddiskVolume1' for '1' for example, to ensure the mapping of disk
    # informations is working as intended
    [hashtable]$DiskData = Get-Icinga-Counter `
                            -CreateStructuredOutputForCategory 'PhysicalDisk' `
                            -StructuredCounterInput $counter;

    foreach ($counters in $logicalCounter.Keys) {
        foreach ($counter in $logicalCounter[$counters].Keys) {
            [string]$instance = $counter;
            if ($instance.Contains('(') -And $instance.Contains(')')) {
                [int]$bracketStart = $instance.IndexOf('(') + 1;
                [int]$bracketEnd = $instance.IndexOf(')');
                $instance = $instance.Substring($bracketStart, $bracketEnd - $bracketStart);
                $instanceArray = $counter.Split('\');
                $counterName = $instanceArray[$instanceArray.Length - 1];
                foreach ($disk in $DiskData.Keys) {
                    if ($disk.Contains($instance)) {
                        $DiskData[$disk].Add(
                            $counterName,
                            $logicalCounter[$counters][$counter]
                        );
                    }
                }
            }
        }
    }

    # Rewrite our output a little to  make it more user friendly
    # This is unique for disks, as we want to remove the ':' from
    # Drive Letters and add back the HarddiskVolume label to volumes
    # to prevent having only a numeric table keys. Example:
    # '1' => 'HarddiskVolume1'
    foreach ($disk in $DiskData.Keys) {
        $NewKey = $disk.Replace(':', '');
        if ($NewKey -match "^[\d\.]+$") {
            $NewKey = [string]::Format('HarddiskVolume{0}', $NewKey);
        }
        if ($NewKey[0] -match "^[\d\.]+$") {
            $NewKey = $NewKey.Substring(2, $NewKey.Length - 2);
        }
        $StructuredDiskData.Add($NewKey, $DiskData[$disk]);
    }

    return $StructuredDiskData;
}

return ClassDisk -Config $Config;