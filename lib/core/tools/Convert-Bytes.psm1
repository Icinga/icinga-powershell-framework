function Convert-Bytes()
{
    param(
       [string]$Value,
       [string]$Unit
    );

    If (($Value -Match "(^[0-9]*) ?(B|b|kb|KB|kB|Kb|mb|Mb|mB|MB|Gb|gB|gb|GB|tb|Tb|tB|TB|PT|pt|pT|Pt)")) {
        [single]$CurrentValue = $Matches[1];
        [string]$CurrentUnit = $Matches[2];

        $CurrentValue = ConvertTo-Byte $CurrentValue $CurrentUnit;
        
        switch ($Unit) {
            { 'B' -contains $_}  { $FinalValue = ConvertTo-Byte $CurrentValue -Unit B;      $boolOption = $true;}
            { 'KB' -contains $_} { $FinalValue = ConvertTo-KiloByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'MB' -contains $_} { $FinalValue = ConvertTo-MegaByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'GB' -contains $_} { $FinalValue = ConvertTo-GigaByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'TB' -contains $_} { $FinalValue = ConvertTo-TeraByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'PT' -contains $_} { $FinalValue = ConvertTo-PetaByte $CurrentValue -Unit B;  $boolOption = $true;}
            default { 
                if (-Not $boolOption) {
                    Throw 'Invalid input';
                } 
            }
        }
        return $FinalValue;
    }
    Throw 'Invalid input';
}