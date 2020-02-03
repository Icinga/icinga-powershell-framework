function Convert-Bytes()
{
    param(
       [string]$Value,
       [string]$Unit
    );

    If (($Value -Match "(^[\d\.]*) ?(B|KB|MB|GB|TB|PT|KiB|MiB|GiB|TiB|PiB)")) {
        [single]$CurrentValue = $Matches[1];
        [string]$CurrentUnit = $Matches[2];

        switch ($CurrentUnit) {
            { 'KiB', 'MiB', 'GiB', 'TiB', 'PiB' -contains $_} { $CurrentValue = ConvertTo-ByteIEC $CurrentValue $CurrentUnit; $boolOption = $true;}
            { 'KB', 'MB', 'GB', 'TB', 'PB' -contains $_} { $CurrentValue = ConvertTo-ByteSI $CurrentValue $CurrentUnit; $boolOption = $true;}
        }
    
        
        switch ($Unit) {
            { 'B' -contains $_}  { $FinalValue = $CurrentValue;      $boolOption = $true;}
            { 'KB' -contains $_} { $FinalValue = ConvertTo-KiloByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'MB' -contains $_} { $FinalValue = ConvertTo-MegaByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'GB' -contains $_} { $FinalValue = ConvertTo-GigaByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'TB' -contains $_} { $FinalValue = ConvertTo-TeraByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'PB' -contains $_} { $FinalValue = ConvertTo-PetaByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'KiB' -contains $_} { $FinalValue = ConvertTo-KiBByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'MiB' -contains $_} { $FinalValue = ConvertTo-MiBByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'GiB' -contains $_} { $FinalValue = ConvertTo-GiBByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'TiB' -contains $_} { $FinalValue = ConvertTo-TiBByte $CurrentValue -Unit B;  $boolOption = $true;}
            { 'PiB' -contains $_} { $FinalValue = ConvertTo-PetaByte $CurrentValue -Unit B;  $boolOption = $true;}

            default { 
                if (-Not $boolOption) {
                    Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
                } 
            }
        }
        return @{'value' = $FinalValue; 'pastunit' = $CurrentUnit; 'endunit' = $Unit};
    }

    Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
}