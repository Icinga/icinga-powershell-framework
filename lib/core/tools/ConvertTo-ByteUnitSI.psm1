<#
.SYNOPSIS
   Converts unit sizes to byte.
.DESCRIPTION
   This module converts a given unit size to byte.
   e.g Kilobyte to Byte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Byte -Unit TB 200
   200000000000000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-ByteSI()
{
    param(
       [single]$Value,
       [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'KB', 'KiloByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'MB', 'MegaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }        
        { 'GB', 'GigaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
        { 'TB', 'TeraByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 12)); $boolOption = $true; }
        { 'PB', 'PetaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 15)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            } 
        }
    }

    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to kilobyte.
.DESCRIPTION
   This module converts a given unit size to kilobyte.
   e.g byte to kilobyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-KiloByte -Unit TB 200
   200000000000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-KiloByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'KB', 'KiloByte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'MB', 'MegaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }        
        { 'GB', 'GigaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        { 'TB', 'TeraByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
        { 'PB', 'PetaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 12)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }  
        }
    }
    
    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to megabyte.
.DESCRIPTION
   This module converts a given unit size to megabyte.
   e.g byte to megabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-KiloByte -Unit TB 200
   200000000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-MegaByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'KB', 'KiloByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'MB', 'MegaByte' -contains $_ } { $result = $Value; $boolOption = $true; }       
        { 'GB', 'GigaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'TB', 'TeraByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        { 'PB', 'PetaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            } 
        }
    }
    
    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to gigabyte.
.DESCRIPTION
   This module converts a given unit size to gigabyte.
   e.g byte to gigabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-GigaByte -Unit TB 200
   200000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-GigaByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'KB', 'KiloByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'MB', 'MegaByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'GB', 'GigaByte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'TB', 'TeraByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'PB', 'PetaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }  
        }
    }
    
    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to terabyte.
.DESCRIPTION
   This module converts a given unit size to terabyte.
   e.g byte to terabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-TeraByte -Unit GB 2000000
   2000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-TeraByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 12)); $boolOption = $true; }
        { 'KB', 'KiloByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'MB', 'MegaByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'GB', 'GigaByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'TB', 'TeraByte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'PB', 'PetaByte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }  
        }
    }
    
    return $result;
}

<#
.SYNOPSIS
   Converts unit sizes to petabyte.
.DESCRIPTION
   This module converts a given unit size to petabyte.
   e.g byte to petabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-PetaByte -Unit GB 2000000
   2
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-PetaByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 15)); $boolOption = $true; }
        { 'KB', 'KiloByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 12)); $boolOption = $true; }
        { 'MB', 'MegaByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'GB', 'GigaByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'TB', 'TeraByte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'PB', 'PetaByte' -contains $_ } { $result = $Value; $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }  
        }
    }
    
    return $result;
}
