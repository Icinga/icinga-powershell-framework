# year month week days hours minutes seconds milliseconds

function ConvertTo-Seconds()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'ms', 'milliseconds' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 's', 'seconds' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'm', 'minutes' -contains $_ } { $result = ($Value * 60); $boolOption = $true; }
        { 'h', 'hours' -contains $_ } { $result = ($Value * 3600); $boolOption = $true; }
        { 'd', 'day' -contains $_ } { $result = ($Value * 86400); $boolOption = $true; }
        { 'W', 'Week' -contains $_ } { $result = ($Value * 604800); $boolOption = $true; }
        { 'M', 'Month' -contains $_ } { $result = ($Value * [math]::Pow(2.628, 6)); $boolOption = $true; }
        { 'Y', 'Year' -contains $_ } { $result = ($Value * [math]::Pow(10, 7)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Throw 'Invalid input';
            } 
        }
    }
    
    return $result;
}