# year month week days hours minutes seconds milliseconds

function ConvertTo-Seconds()
{
    param(
        [string]$Value,
        [char]$Unit,
        [switch]$Milliseconds
    );

    #100 D
    #100 D
    $Unit = $Value.Substring($Value.get_Length()-2)[0];
    [single]$ValueSplitted = $Value;
    #$Name.Substring($Name.get_Length()-1);
    #$Name.Substring(0,$Name.get_Length()-1);
    switch ([int][char]$Unit) {
#       { 'ms', 'milliseconds' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 115 -contains $_ } { $result = $ValueSplitted; $boolOption = $true; }
        { 109 -contains $_ } { $result = ($ValueSplitted * 60); $boolOption = $true; }
        { 104 -contains $_ } { $result = ($ValueSplitted * 3600); $boolOption = $true; }
        { 100 -contains $_ } { $result = ($ValueSplitted * 86400); $boolOption = $true; }
        { 87  -contains $_ } { $result = ($ValueSplitted * 604800); $boolOption = $true; }
        { 77  -contains $_ } { $result = ($ValueSplitted * (2.5[math]::Pow(10, 6))); $boolOption = $true; }
        { 89  -contains $_ } { $result = ($ValueSplitted * (3.10[math]::Pow(10, 7))); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Throw 'Invalid input';
            } 
        }
    }
    
    return $result;
}