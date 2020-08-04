#
# This function will load all available Categories of Performance Counters
# from the registry and outputs them. This will ensure we can fetch the real
# english names instead of the localiced ones
#
function Show-IcingaPerformanceCounterCategories()
{
    $RegistryData    = Get-ItemProperty `
        -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Perflib\009' `
        -Name 'counter' | Select-Object -ExpandProperty Counter;
    [array]$Counters = @();

    # Now lets loop our registry data and fetch only for counter categories
    # Ignore everything else and drop the information
    foreach ($counter in $RegistryData) {
        # First filter out the ID's of the performance counter
        if (-Not ($counter -match "^[\d\.]+$") -And [string]::IsNullOrEmpty($counter) -eq $FALSE) {
            # Now check if the value we got is a counter category
            if ([System.Diagnostics.PerformanceCounterCategory]::Exists($counter) -eq $TRUE) {
                $Counters += $counter;
            }
        }
    }

    return $Counters;
}
