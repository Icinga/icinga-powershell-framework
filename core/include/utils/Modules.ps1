<#
 # Helper class for accessing and handling modules in a
 # more easier and managed way
 #>

$Modules = New-Object -TypeName PSObject;

$Modules | Add-Member -membertype ScriptMethod -name 'LoadIncludes' -value {
    param([string]$modulename, $Config);

    $modulename = $modulename.ToLower();
    $modulename = $modulename.Replace('.ps1', '');

    [string]$ModuleDir = Join-Path `
    -Path      $Icinga2.App.RootPath `
    -ChildPath (
        [string]::Format(
            '\modules\include\{0}',
            $modulename
        )
    )

    [hashtable]$ModuleIndludes = @{};

    if ( (Test-Path $ModuleDir) -eq $FALSE) {
        return $ModuleIndludes;
    }

    Get-ChildItem $ModuleDir -Filter *.ps1 | 
        Foreach-Object {
            [string]$name = $_.Name.ToLower().Replace(
                '.ps1',
                ''
            );
            try {
                $ModuleIndludes.Add(
                    $name,
                    (& $_.FullName -Config $Config)
                );
            } catch {
                $ModuleIndludes.Add(
                    $name,
                    [string]::Format(
                        'Failed to execute include "{0}" for module "{1}". Exception: {2}',
                        $name,
                        $modulename,
                        $_.Exception.Message
                    )
                );
            }
        }

    return $ModuleIndludes;
}

$Modules | Add-Member -membertype ScriptMethod -name 'FlushModuleCache' -value {
    param([string]$modulename);

    if ($Icinga2.Cache.Modules.ContainsKey($modulename) -eq $FALSE) {
        return;
    }

    $Icinga2.Cache.Modules[$modulename] = @{ };
}

$Modules | Add-Member -membertype ScriptMethod -name 'AddCacheElement' -value {
    param([string]$modulename, [string]$cachename, $value);

    if ($Icinga2.Cache.Modules.ContainsKey($modulename) -eq $FALSE) {
        $Icinga2.Cache.Modules.Add($modulename, @{ });
    }

    if ($Icinga2.Cache.Modules[$modulename].ContainsKey($cachename) -eq $FALSE) {
        $Icinga2.Cache.Modules[$modulename].Add($cachename, $value);
    } else {
        $Icinga2.Cache.Modules[$modulename][$cachename] = $value;
    }
}

$Modules | Add-Member -membertype ScriptMethod -name 'GetCacheElement' -value {
    param([string]$modulename, [string]$cachename);

    if ($Icinga2.Cache.Modules.ContainsKey($modulename) -eq $FALSE) {
        return @{ };
    }

    if ($Icinga2.Cache.Modules[$modulename].ContainsKey($cachename) -eq $FALSE) {
        return @{ };
    }

    return $Icinga2.Cache.Modules[$modulename][$cachename];
}

$Modules | Add-Member -membertype ScriptMethod -name 'GetHashtableDiff' -value {
    param([hashtable]$new, [hashtable]$cache, [array]$addkeys);

    [hashtable]$DiffTable    = @{
        FullList = @{ };
        Removed  = @( );
        Added    = $null;
        Modified = @{ };
    }

    if ($cache -eq $null -or $cache.Count -eq 0) {
        $DiffTable.FullList = $new;
    } else {
        # Each additional call will only send the diffs to the server
        $int = 0;
        foreach ($cachedProcess in $cache.Keys) {
            $oldProcess = $cache[$cachedProcess];

            # In case a service is no longer present on our system, send the process Id
            # only so we can delete it from our database
            if ($new.ContainsKey($cachedProcess) -eq $FALSE) {
                $DiffTable['Removed'] += $oldProcess.ProcessId;
            } else {
                # If we know about a process, only send the values which have been updated
                # since the last check
                $newProcess = $new[$cachedProcess];

                foreach ($entry in $newProcess.Keys) {
                    $oldValue = $oldProcess[$entry];
                    $newValue = $newProcess[$entry];

                    if ($oldValue -ne $newValue) {
                        if ($DiffTable['Modified'].ContainsKey($cachedProcess) -eq $FALSE) {
                            $DiffTable['Modified'].Add($cachedProcess, @{ });
                        }
                        $DiffTable['Modified'][$cachedProcess].Add($entry, $newValue);
                    }
                }

                if ($DiffTable['Modified'].ContainsKey($cachedProcess) -eq $TRUE) {
                    foreach($entry in $addkeys) {
                        if ($DiffTable['Modified'][$cachedProcess].ContainsKey($entry) -eq $FALSE -and
                            $newProcess.ContainsKey($entry) -eq $TRUE) {

                            $DiffTable['Modified'][$cachedProcess].Add($entry, $newProcess[$entry]);
                        }
                    }
                }

                $new.Remove($cachedProcess);
            }
        }

        # All other processes are new and should be added
        $DiffTable['Added'] = $new;
    }

    return $DiffTable;
}
 
return $Modules;