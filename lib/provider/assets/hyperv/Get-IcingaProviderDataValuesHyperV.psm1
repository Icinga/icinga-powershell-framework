function Get-IcingaProviderDataValuesHyperV()
{
    param (
        [switch]$IncludeDetails = $FALSE
    );

    $HyperVData = New-IcingaProviderObject -Name 'Hyper-V';

    # Check if the Hyper-V is installed. If not, we will simply return an empty object
    if ($null -eq (Get-Service -Name 'vmms' -ErrorAction SilentlyContinue)) {
        $HyperVData.FeatureInstalled = $FALSE;

        return $HyperVData;
    }

    $HyperVData.Metrics                    | Add-Member -MemberType NoteProperty -Name 'ClusterData'   -Value (New-Object PSCustomObject);
    $HyperVData.Metrics                    | Add-Member -MemberType NoteProperty -Name 'BlackoutTimes' -Value (New-Object PSCustomObject);
    $HyperVData.Metrics.BlackoutTimes      | Add-Member -MemberType NoteProperty -Name 'Information'   -Value (New-Object PSCustomObject);
    $HyperVData.Metrics.BlackoutTimes      | Add-Member -MemberType NoteProperty -Name 'Warning'       -Value (New-Object PSCustomObject);
    $HyperVData.Metrics.ClusterData        | Add-Member -MemberType NoteProperty -Name 'NodeCount'     -Value 1; # We always have at least 1 node
    $HyperVData.Metrics.ClusterData        | Add-Member -MemberType NoteProperty -Name 'VMList'        -Value (New-Object PSCustomObject);
    $HyperVData.Metrics.ClusterData.VMList | Add-Member -MemberType NoteProperty -Name 'Duplicates'    -Value (New-Object PSCustomObject);
    $HyperVData.Metrics.ClusterData.VMList | Add-Member -MemberType NoteProperty -Name 'VMs'           -Value (New-Object PSCustomObject);

    try {
        if (Test-IcingaFunction 'Get-ClusterNode') {
            $ClusterInformation = Get-ClusterNode -Cluster '.' -ErrorAction Stop;

            $HyperVData.Metrics.ClusterData.NodeCount = $ClusterInformation.Count;
        }

        [array]$VMRessources = @();

        if (Test-IcingaFunction 'Get-ClusterResource') {
            [array]$VMRessources = Get-ClusterResource -Cluster '.' -ErrorAction Stop | Where-Object ResourceType -EQ 'Virtual Machine';
        } else {
            [array]$VMRessources = Get-VM -ErrorAction Stop;
        }

        if ($null -ne $VMRessources -And $VMRessources.Count -ne 0) {
            foreach ($VMRessource in $VMRessources) {
                if ((Test-PSCustomObjectMember -PSObject $HyperVData.Metrics.ClusterData.VMList.VMs -Name $VMRessource.Name) -eq $FALSE) {
                    $HyperVData.Metrics.ClusterData.VMList.VMs | Add-Member -MemberType NoteProperty -Name $VMRessource.Name -Value 1;
                } else {
                    $HyperVData.Metrics.ClusterData.VMList.VMs.($VMRessource.Name) += 1;

                    if ((Test-PSCustomObjectMember -PSObject $HyperVData.Metrics.ClusterData.VMList.Duplicates -Name $VMRessource.Name) -eq $FALSE) {
                        $HyperVData.Metrics.ClusterData.VMList.Duplicates | Add-Member -MemberType NoteProperty -Name $VMRessource.Name -Value 0;
                    }
                    $HyperVData.Metrics.ClusterData.VMList.Duplicates.($VMRessource.Name) = $HyperVData.Metrics.ClusterData.VMList.VMs.($VMRessource.Name);
                }
            }
        }

        # Blackout Times
        # => Info
        [array]$InformationBlackoutTimes = Get-WinEvent -FilterHashtable @{ 'LogName'='Microsoft-Windows-Hyper-V-VMMS-Admin'; 'Id' = '20415'; } -MaxEvents 300 -ErrorAction SilentlyContinue;

        if ($null -ne $InformationBlackoutTimes -Or $InformationBlackoutTimes.Count -ne 0) {
            foreach ($event in $InformationBlackoutTimes) {
                $XMLEventData = ([xml]$event.ToXml()).Event;

                if ((Test-PSCustomObjectMember -PSObject $HyperVData.Metrics.BlackoutTimes.Information -Name $XMLEventData.UserData.VmlEventLog.Parameter0) -eq $FALSE) {
                    $EventObject = New-Object PSCustomObject;
                    $EventObject | Add-Member -MemberType NoteProperty -Name 'Timestamp'    -Value $event.TimeCreated;
                    $EventObject | Add-Member -MemberType NoteProperty -Name 'BlackoutTime' -Value $XMLEventData.UserData.VmlEventLog.Parameter2;

                    $HyperVData.Metrics.BlackoutTimes.Information | Add-Member -MemberType NoteProperty -Name $XMLEventData.UserData.VmlEventLog.Parameter0 -Value $EventObject;
                }
            }
        }

        # Blackout Times
        # => Warning
        [array]$WarningBlackoutTimes = Get-WinEvent -FilterHashtable @{ 'LogName'='Microsoft-Windows-Hyper-V-VMMS-Admin'; 'Id' = '20417'; } -MaxEvents 300 -ErrorAction SilentlyContinue;

        if ($null -ne $WarningBlackoutTimes -Or $WarningBlackoutTimes.Count -ne 0) {
            foreach ($event in $WarningBlackoutTimes) {
                $XMLEventData = ([xml]$event.ToXml()).Event;

                if ((Test-PSCustomObjectMember -PSObject $HyperVData.Metrics.BlackoutTimes.Warning -Name $XMLEventData.UserData.VmlEventLog.Parameter0) -eq $FALSE) {
                    $EventObject = New-Object PSCustomObject;
                    $EventObject | Add-Member -MemberType NoteProperty -Name 'Timestamp'    -Value $event.TimeCreated;
                    $EventObject | Add-Member -MemberType NoteProperty -Name 'BlackoutTime' -Value $XMLEventData.UserData.VmlEventLog.Parameter2;

                    [bool]$IsAcknowledged = $FALSE;

                    foreach ($InfoBlackoutTime in $HyperVData.Metrics.BlackoutTimes.Information.PSObject.Properties.Name) {
                        if ($InfoBlackoutTime -eq $XMLEventData.UserData.VmlEventLog.Parameter0) {
                            if($HyperVData.Metrics.BlackoutTimes.Information.$InfoBlackoutTime.Timestamp -gt $event.TimeCreated) {
                                $IsAcknowledged = $TRUE;
                                break;
                            }
                        }
                    }

                    if ($IsAcknowledged) {
                        continue;
                    }

                    $HyperVData.Metrics.BlackoutTimes.Warning | Add-Member -MemberType NoteProperty -Name $XMLEventData.UserData.VmlEventLog.Parameter0 -Value $EventObject;
                }
            }
        }

        if ($null -ne $InformationBlackoutTimes) {
            $InformationBlackoutTimes.Dispose();
            $InformationBlackoutTimes = $null;
        }

        if ($null -ne $WarningBlackoutTimes) {
            $WarningBlackoutTimes.Dispose();
            $WarningBlackoutTimes = $null;
        }
    } catch {
        Exit-IcingaThrowException -ExceptionType 'Custom' -CustomMessage 'Hyper-V Error' -ExceptionThrown $_.Exception.Message -Force;
    }

    return $HyperVData;
}
