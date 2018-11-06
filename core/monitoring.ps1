param(
    [array]$Include                     = @(),
    [array]$Exclude                     = @(),
    [boolean]$ListModules               = $FALSE,
    $Config                             = $null,
    [string]$AgentRoot                  = ''
)

function ClassMonitoring()
{
    param(
        [array]$Include                     = @(),
        [array]$Exclude                     = @(),
        [boolean]$ListModules               = $FALSE,
        $Config                             = $null,
        [string]$AgentRoot                  = ''
    )

    [string]$ModuleDirectory = Join-Path $AgentRoot -ChildPath 'modules';
    [hashtable]$ModuleList   = @{};
    [array]$AvailableModules = @();
    $ResultList              = New-Object psobject -prop @{};

    # Let's do a small fix here: We have defined 'include' within the URL, but
    # we haven't specified any values. So lets assume we want to load all
    # modules
    if ($Include.Count -eq 1 -And [string]::IsNullOrEmpty($Include[0])) {
        $Include[0] = '*';
    }

    # In case no includes are specified, lets include everything
    if ($Include.Count -eq 0) {
        $Include += '*';
    }

    <#
    # In case no filter is specified, we asume we want to collect everything.
    # Lets fetch all PowerShell Scripts within our module Directory
    # Will also be used to return a list of installed modules
    #>
    if (($Include.Count -eq 1 -And $Include[0] -eq '*') -Or $ListModules) {
        Get-ChildItem $ModuleDirectory -Filter *.ps1 | 
            Foreach-Object {
                $path = $_.FullName
                $name = $_.Name.Replace('.ps1', '').ToLower();

                $ModuleList.Add($name, $path);
                $AvailableModules += $name;
            }

        if ($ListModules) {
            return $AvailableModules;
        }
    } else {
        # In case we provided a filter, try to locate these modules
        foreach ($module in $Include) {
            # Just to ensure we skip this argument in case it is provided
            if ($module -eq '*') {
                continue;
            }
            $module = $module.ToLower();
            [string]$file = [string]::Format('{0}.ps1', $module);
            [string]$path = Join-Path $ModuleDirectory -ChildPath $file;

            if ($ModuleList.ContainsKey($module) -eq $FALSE) {
                $ModuleList.Add($module, $path);
            }
        }
    }

    foreach ($module in $Exclude) {
        if ($ModuleList.ContainsKey($module)) {
            $ModuleList.Remove($module);
        }
    }

    [System.Diagnostics.Stopwatch]$ModuleTimer = New-Object System.Diagnostics.Stopwatch;
    # Now as we have our module list available, lets execute them to fetch informations
    foreach ($module in $ModuleList.Keys) {
        $ModuleTimer.Start();
        [string]$path            = $ModuleList[$module];
        [hashtable]$ModuleResult = @{};
        $moduleConfig            = $null;

        if ($Config -ne $null -AND $Config.$module -ne $null) {
            $moduleConfig = $Config.$module;
        }

        # First test if the specified module is available
        if (Test-Path ($path)) {
            try {
                # If it is, execute the script and return the output
                $ModuleResult.Add('output', (&$path -Config $moduleConfig));
                $ModuleResult.Add('response', 200);
                $ModuleResult.Add('error', $null);
            } catch {
                # In case the script we tried to execute runs into a failure, return the exception message as result
                $ModuleResult.Add('output', $null);
                $ModuleResult.Add('response', 500);
                $ModuleResult.Add('error', [string]::Format('Failed to execute module "{0}". Exeception: {1}', $module, $_.Exception.Message));
            }
        } else {
            # Include the module to our output with a small notify message
            $ModuleResult.Add('output', $null);
            $ModuleResult.Add('response', 404);
            $ModuleResult.Add('error', 'Module not found');
        }

        $ModuleResult.Add('execution', $ModuleTimer.Elapsed.TotalSeconds);
        $ModuleTimer.Stop();

        $ResultList | Add-Member -Name $module -Type NoteProperty -Value $ModuleResult;
    }

    return $ResultList;
}

return ClassMonitoring -Include $Include -Exclude $Exclude -ListModules $ListModules -Config $Config -AgentRoot $AgentRoot;