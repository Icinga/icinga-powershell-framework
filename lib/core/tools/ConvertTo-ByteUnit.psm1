function ConvertTo-Byte()
{
    param(
        [single]$Value, 
        [string]$Unit #Validation PT PetaByte
    );

    switch ($Unit) {
        Byte { 
                $result = $Value;
                break; 
        }
        KiloByte {
                $result = ($Value * [math]::Pow(10, 3));
                break;
        }
        MegaByte {
                $result = ($Value * [math]::Pow(10, 6));
                break;
        }
        GigaByte {
                $result = ($Value * [math]::Pow(10, 9));
                break;
        }
        TeraByte {
                $result = ($Value * [math]::Pow(10, 12));
                break;
        }
        PetaByte {
                $result = ($Value * [math]::Pow(10, 15));
                break;
        }
        Default {}
    }
    
    return $result;
}
function ConvertTo-KiloByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        Byte { 
                $result = ($Value / 1000);
                break; 
        }
        KiloByte {
                $result = $Value;
                break;
        }
        MegaByte {
                $result = ($Value * [math]::Pow(10, 3));
                break;
        }
        GigaByte {
                $result = ($Value * [math]::Pow(10, 6));
                break;
        }
        TeraByte {
                $result = ($Value * [math]::Pow(10, 9));
                break;
        }
        PetaByte {
                $result = ($Value * [math]::Pow(10, 12));
                break;
        }
        Default {}
    }
    
    return $result;
}

function ConvertTo-MegaByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        Byte { 
                $result = ($Value / [math]::Pow(10, 6));
                break; 
        }
        KiloByte {
                $result = ($Value / [math]::Pow(10, 3));
                break;
        }
        MegaByte {
                $result = $Value;
                break;
        }
        GigaByte {
                $result = ($Value * [math]::Pow(10, 3));
                break;
        }
        TeraByte {
                $result = ($Value * [math]::Pow(10, 6));
                break;
        }
        PetaByte {
                $result = ($Value * [math]::Pow(10, 9));
                break;
        }
        Default {}
    }
    
    return $result;
}

function ConvertTo-GigaByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        Byte { 
                $result = ($Value / [math]::Pow(10, 9)); 
                break;
        }
        KiloByte {
                $result = ($Value / [math]::Pow(10, 6));
                break;
        }
        MegaByte {
                $result = ($Value / [math]::Pow(10, 3));
                break;
        }
        GigaByte {
                $result = $Value;
                break;
        }
        TeraByte {
                $result = ($Value * [math]::Pow(10, 3));
                break;
        }
        PetaByte {
                $result = ($Value * [math]::Pow(10, 6));
                break;
        }
        Default {}
    }
    
    return $result;
}

function ConvertTo-TeraByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        Byte { 
                $result = ($Value / [math]::Pow(10, 12)); 
                break;
        }
        KiloByte {
                $result = ($Value / [math]::Pow(10, 9));
                break;
        }
        MegaByte {
                $result = ($Value / [math]::Pow(10, 6));
                break;
        }
        GigaByte {
                $result = ($Value / [math]::Pow(10, 3));
                break;
        }
        TeraByte {
                $result = $Value;
                break;
        }
        PetaByte {
                $result = ($Value * [math]::Pow(10, 3));
                break;
        }
        Default {}
    }
    
    return $result;
}

function ConvertTo-PetaByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        Byte { 
                $result = ($Value / [math]::Pow(10, 15));
                break; 
        }
        KiloByte {
                $result = ($Value / [math]::Pow(10, 12));
                break;
        }
        MegaByte {
                $result = ($Value / [math]::Pow(10, 9));
                break;
        }
        GigaByte {
                $result = ($Value / [math]::Pow(10, 6));
                break;
        }
        TeraByte {
                $result = ($Value / [math]::Pow(10, 3));
                break;
        }
        PetaByte {
                $result = $Value;
                break;
        }
        Default {}
    }
    
    return $result;
}