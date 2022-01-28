function Get-IcingaCommandDependency()
{
    param (
        $DependencyList          = (New-Object PSCustomObject),
        [hashtable]$CompiledList = @{ },
        [string]$CmdName         = '',
        [string]$CmdType         = ''
    );

    # Function, Cmdlet, Alias, Modules, Application
    if ([string]::IsNullOrEmpty($CmdType)) {
        return $CompiledList;
    }

    # Create the list container for our object type if not existing
    # => Function, Cmdlet, Alias, Modules, Application
    if ($CompiledList.ContainsKey($CmdType) -eq $FALSE) {
        $CompiledList.Add($CmdType, @{ });
    }

    # e.g. Invoke-IcingaCheckCPU
    if ($CompiledList[$CmdType].ContainsKey($CmdName)) {
        $CompiledList[$CmdType][$CmdName] += 1;

        return $CompiledList;
    }

    # Add the command this function is called with
    $CompiledList[$CmdType].Add($CmdName, 0);

    # The command is not known in our Framework dependency list -> could be a native Windows command
    if ((Test-PSCustomObjectMember -PSObject $DependencyList -Name $CmdName) -eq $FALSE) {
        return $CompiledList;
    }

    # Loop our entire dependency list for every single command
    foreach ($CmdList in $DependencyList.$CmdName.PSObject.Properties.Name) {
        # $Cmd     => The list of child commands
        # $CmdList => Function, Cmdlet, Alias, Modules, Application
        $Cmd = $DependencyList.$CmdName.$CmdList;

        # Create the list container for our object type if not existing
        # => Function, Cmdlet, Alias, Modules, Application
        if ($CompiledList.ContainsKey($CmdList) -eq $FALSE) {
            $CompiledList.Add($CmdList, @{ });
        }

        # Loop all commands within our child list for this command
        foreach ($entry in $Cmd.PSObject.Properties.Name) {

            # $entry => The command name e.g. Write-IcingaConsolePlain
            if ($CompiledList[$CmdList].ContainsKey($entry) -eq $FALSE) {
                $CompiledList = Get-IcingaCommandDependency `
                    -DependencyList $DependencyList `
                    -CompiledList $CompiledList `
                    -CmdName $entry `
                    -CmdType $CmdList;
                } else {
                    $CompiledList[$CmdList][$entry] += 1;
                }
        }
    }

    return $CompiledList;
}
