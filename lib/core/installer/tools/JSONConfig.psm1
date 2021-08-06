function Convert-IcingaForwindowsManagementConsoleJSONConfig()
{
    param (
        $Config
    );

    [int]$Index                 = 0;
    $MaxIndex                   = $Config.PSObject.Properties.Count;
    [string]$Menu               = '';
    [hashtable]$ConvertedConfig = @{ };

    while ($Index -lt $MaxIndex.Count) {
        foreach ($entry in $Config.PSObject.Properties) {

            if ($index -eq [int]$entry.Value.Index) {
                $ConvertedConfig.Add(
                    $entry.Name,
                    @{
                        'Selection'   = $entry.Value.Selection;
                        'Values'      = $entry.Value.Values;
                        'Index'       = $index;
                        'Parent'      = $entry.Value.Parent;
                        'ParentEntry' = $entry.Value.ParentEntry;
                        'Hidden'      = $entry.Value.Hidden;
                        'Password'    = $entry.Value.Password;
                        'Advanced'    = $entry.Value.Advanced;
                        'Modified'    = $entry.Value.Modified;
                    }
                );

                if ($entry.Value.Advanced -eq $FALSE) {
                    $global:Icinga.InstallWizard.LastParent.Add($entry.Name) | Out-Null;
                }
            }
        }
        $Index += 1;
    }

    return $ConvertedConfig;
}
