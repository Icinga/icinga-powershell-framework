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
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }        
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 12)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 15)); $boolOption = $true; }
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
   Converts unit sizes to Kilobyte.
.DESCRIPTION
   This module converts a given unit size to Kilobyte.
   e.g byte to Kilobyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Kilobyte -Unit TB 200
   200000000000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Kilobyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }        
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 12)); $boolOption = $true; }
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
   Converts unit sizes to Megabyte.
.DESCRIPTION
   This module converts a given unit size to Megabyte.
   e.g byte to Megabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Kilobyte -Unit TB 200
   200000000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Megabyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = $Value; $boolOption = $true; }       
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 9)); $boolOption = $true; }
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
   Converts unit sizes to Gigabyte.
.DESCRIPTION
   This module converts a given unit size to Gigabyte.
   e.g byte to Gigabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Gigabyte -Unit TB 200
   200000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Gigabyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 6)); $boolOption = $true; }
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
   Converts unit sizes to Terabyte.
.DESCRIPTION
   This module converts a given unit size to Terabyte.
   e.g byte to Terabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Terabyte -Unit GB 2000000
   2000
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Terabyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 12)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = ($Value * [math]::Pow(10, 3)); $boolOption = $true; }
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
   Converts unit sizes to Petabyte.
.DESCRIPTION
   This module converts a given unit size to Petabyte.
   e.g byte to Petabyte.

   More Information on https://github.com/Icinga/icinga-powershell-framework
.EXAMPLE
   PS> ConvertTo-Petabyte -Unit GB 2000000
   2
.LINK
   https://github.com/Icinga/icinga-powershell-framework
.NOTES
#>

function ConvertTo-Petabyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(10, 15)); $boolOption = $true; }
        { 'KB', 'Kilobyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 12)); $boolOption = $true; }
        { 'MB', 'Megabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 9)); $boolOption = $true; }
        { 'GB', 'Gigabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 6)); $boolOption = $true; }
        { 'TB', 'Terabyte' -contains $_ } { $result = ($Value / [math]::Pow(10, 3)); $boolOption = $true; }
        { 'PB', 'Petabyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }  
        }
    }
    
    return $result;
}
