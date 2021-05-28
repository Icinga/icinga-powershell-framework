function Get-IcingaNextUnitIteration()
{
    param (
        [string]$Unit = '',
        [array]$Units = @()
    );

    [bool]$Found = $FALSE;

    foreach ($entry in $Units) {
        if ($Found) {
            return $entry;
        }
        if ($entry -eq $Unit) {
            $Found = $TRUE;
        }
    }

    return '';
}
