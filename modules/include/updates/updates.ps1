param($Config = $null);

# Fetch all informations about installed updates and add them
$WindowsUpdates               = New-Object -ComObject "Microsoft.Update.Session";
$SearchIndex                  = $WindowsUpdates.CreateUpdateSearcher();
[hashtable]$UpdateList        = @{};
[hashtable]$UpdateInstalled   = @{};
[hashtable]$UpdateUninstalled = @{};
[hashtable]$UpdateOther       = @{};

# Operation ID's
# 1: Installed
# 2: Uninstalled
# 3: Other

# At first get a list of our Windows Update history
$Updates = $SearchIndex.QueryHistory(0, $SearchIndex.GetTotalHistoryCount()) |
        Select-Object Operation, ResultCode, HResult, Date, Title, Description, ServiceID, SupportUrl;

foreach ($update in $Updates) {
    [string]$UpdateKey = [string]::Format('{0} [{1}|{2}]', $update.Title, $update.Date, $update.HResult);
    switch ($update.Operation) {
        1 {
            if ($UpdateInstalled.ContainsKey($UpdateKey) -eq $FALSE) {
                $UpdateInstalled.Add($UpdateKey, $update);
            } else {
                $Icinga2.Log.Write(
                    $Icinga2.Enums.LogState.Warning,
                    [string]::Format(
                        'Unable to add update "{0}" to update list. The key with content "{1}" is already present',
                        $UpdateKey,
                        $update
                    )
                );
            }
        };
        2 {
            if ($UpdateUninstalled.ContainsKey($UpdateKey) -eq $FALSE) {
                $UpdateUninstalled.Add($UpdateKey, $update);
            } else {
                $Icinga2.Log.Write(
                    $Icinga2.Enums.LogState.Warning,
                    [string]::Format(
                        'Unable to add update "{0}" to update list. The key with content "{1}" is already present',
                        $UpdateKey,
                        $update
                    )
                );
            }
        };
        default {
            if ($UpdateOther.ContainsKey($UpdateKey) -eq $FALSE) {
                $UpdateOther.Add($UpdateKey, $update);
            } else {
                $Icinga2.Log.Write(
                    $Icinga2.Enums.LogState.Warning,
                    [string]::Format(
                        'Unable to add update "{0}" to update list. The key with content "{1}" is already present',
                        $UpdateKey,
                        $update
                    )
                );
            }
        };
    }
}

$UpdateList.Add('installed', $UpdateInstalled);
$UpdateList.Add('uninstalled', $UpdateUninstalled);
$UpdateList.Add('other', $UpdateOther);

return $UpdateList;