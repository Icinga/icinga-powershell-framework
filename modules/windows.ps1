param($Config = $null);

function ClassWindows
{
    param($Config = $null);
    $WindowsInformations = Get-CimInstance Win32_OperatingSystem;

    $windows_datails = @{};
    foreach($cpu_core in $WindowsInformations.CimInstanceProperties) {
        $windows_datails.Add($cpu_core.Name, $cpu_core.Value);
    }

    return $windows_datails;
}

return ClassWindows -Config $Config;