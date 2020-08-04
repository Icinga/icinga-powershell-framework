function ConvertTo-ByteIEC()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 40)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 50)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Kibibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 40)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Mebibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Gibibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Tebibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 40)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}

function ConvertTo-Pebibyte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 50)); $boolOption = $true; }
        { 'KiB', 'Kibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 40)); $boolOption = $true; }
        { 'MiB', 'Mebibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'GiB', 'Gibibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'TiB', 'Tebibyte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'PiB', 'Pebibyte' -contains $_ } { $result = $Value; $boolOption = $true; }
        default {
            if (-Not $boolOption) {
                Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.ConversionUnitMissing -Force;
            }
        }
    }

    return $result;
}
