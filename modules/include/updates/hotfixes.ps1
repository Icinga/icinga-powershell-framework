param($Config = $null);

[hashtable]$HotfixInfo      = @{};
[hashtable]$HotfixNameCache = @{};

# First fetch all of our hotfixes
$Hotfixes = Get-Hotfix;

foreach ($property in $Hotfixes) {
    [hashtable]$HotfixData  = @{};
    foreach ($hotfix in $property.Properties) {
        $HotfixData.Add($hotfix.Name, $hotfix.Value);
    }

    [string]$name = [string]::Format('{0} [{1}]', $HotfixData.HotFixID, $HotfixData.InstalledOn);

    if ($HotfixNameCache.ContainsKey($name) -eq $FALSE) {
        $HotfixNameCache.Add($name, 1);
    } else {
        $HotfixNameCache[$name] += 1;
        $name = [string]::Format('{0} ({1})', $name, $HotfixNameCache[$name]);
    }

    $HotfixInfo.Add($name, $HotfixData);
}

return $HotfixInfo;