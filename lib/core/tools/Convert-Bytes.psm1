function Convert-Bytes()
{
    param(
       [string]$Value,
       [string]$Unit
    );

    If (($Value -Match "(^[\d\.]*) ?(B|KB|MB|GB|TB|PT|Kibi|Mibi|Gibi|Tibi|Pibi)")) {
        [single]$CurrentValue = $Matches[1];
        [string]$CurrentUnit = $Matches[2];

        switch ($CurrentUnit) {
            { 'KiBi', 'Mibi', 'Gibi', 'Tibi', 'Pibi' -contains $_} { $CurrentValue = ConvertTo-ByteIEC $CurrentValue $CurrentUnit; $boolOption = $true;}
            { 'KB', 'MB', 'GB', 'TB', 'PB' -contains $_} { $CurrentValue = ConvertTo-ByteSI $CurrentValue $CurrentUnit; $boolOption = $true;}
        }
    
        
        switch ($Unit) {
            { 'B' -contains $_}  { $FinalValue = $CurrentValue;      $boolOption = $true;}
            { 'KB' -contains $_} { $FinalValue = ConvertTo-KiloByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'MB' -contains $_} { $FinalValue = ConvertTo-MegaByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'GB' -contains $_} { $FinalValue = ConvertTo-GigaByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'TB' -contains $_} { $FinalValue = ConvertTo-TeraByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'PT' -contains $_} { $FinalValue = ConvertTo-PetaByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'Kibi' -contains $_} { $FinalValue = ConvertTo-KibiByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'Mibi' -contains $_} { $FinalValue = ConvertTo-MibiByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'Gibi' -contains $_} { $FinalValue = ConvertTo-GibiByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'Tibi' -contains $_} { $FinalValue = ConvertTo-TibiByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'Piti' -contains $_} { $FinalValue = ConvertTo-PetaByte $CurrentValue -Unit B;  $boolOption = $true;}

            default { 
                if (-Not $boolOption) {
                    Throw 'Invalid input';
                } 
            }
        }
        return @{'value' = $FinalValue; 'pastunit' = $CurrentUnit; 'endunit' = $Unit};
    }
    Throw 'Invalid input';
}