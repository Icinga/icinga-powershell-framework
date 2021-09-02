function Get-IcingaCommandDependency()
{
    param (
        $DependencyList          = (New-Object PSCustomObject),
        [hashtable]$CompiledList = @{ },
        [string]$CmdName         = '',
        [string]$CmdType         = ''
    );

    if ([string]::IsNullOrEmpty($CmdType)) {
        return $CompiledList;
    }

    if ($CompiledList.ContainsKey($CmdType) -eq $FALSE) {
        $CompiledList.Add($CmdType, @{ });
    }

    if ($CompiledList[$CmdType].ContainsKey($CmdName)) {
        $CompiledList[$CmdType][$CmdName] += 1;
        return $CompiledList;
    }

    $CompiledList[$CmdType].Add($CmdName, 0);

    if ((Test-PSCustomObjectMember -PSObject $DependencyList -Name $CmdName) -eq $FALSE) {
        return $CompiledList;
    }

    foreach ($CmdList in $DependencyList.$CmdName.PSObject.Properties.Name) {
        $Cmd = $DependencyList.$CmdName.$CmdList;

        if ($CompiledList.ContainsKey($CmdList) -eq $FALSE) {
            $CompiledList.Add($CmdList, @{ });
        }

        foreach ($entry in $Cmd.PSObject.Properties.Name) {
            if ($CompiledList[$CmdList].ContainsKey($entry) -eq $FALSE) {
                $CompiledList[$CmdList].Add($entry, 0);

                $CompiledList = Get-IcingaCommandDependency `
                    -DependencyList $DependencyList `
                    -CompiledList $CompiledList `
                    -CmdName $entry;
            } else {
                $CompiledList[$CmdList][$entry] += 1;
            }
        }
    }

    return $CompiledList;
}
