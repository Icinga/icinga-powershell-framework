function ConvertTo-Byte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        B { 
                $result = $Value; 
        }
        KB {
                $result = ($Value * [math]::Pow(10, 3));
        }
        MB {
                $result = ($Value * [math]::Pow(10, 6));
        }
        GB {
                $result = ($Value * [math]::Pow(10, 9));
        }
        TB {
                $result = ($Value * [math]::Pow(10, 12));
        }
        PB {
                $result = ($Value * [math]::Pow(10, 15));
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
        B { 
                $result = ($Value / 1000); 
        }
        KB {
                $result = $Value;
        }
        MB {
                $result = ($Value * [math]::Pow(10, 3));
        }
        GB {
                $result = ($Value * [math]::Pow(10, 6));
        }
        TB {
                $result = ($Value * [math]::Pow(10, 9));
        }
        PB {
                $result = ($Value * [math]::Pow(10, 12));
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
        B { 
                $result = ($Value / [math]::Pow(10, 6)); 
        }
        KB {
                $result = ($Value / [math]::Pow(10, 3));
        }
        MB {
                $result = $Value;
        }
        GB {
                $result = ($Value * [math]::Pow(10, 3));
        }
        TB {
                $result = ($Value * [math]::Pow(10, 6));
        }
        PB {
                $result = ($Value * [math]::Pow(10, 9));
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
        B { 
                $result = ($Value / [math]::Pow(10, 9)); 
        }
        KB {
                $result = ($Value / [math]::Pow(10, 6))
        }
        MB {
                $result = ($Value / [math]::Pow(10, 3));
        }
        GB {
                $result = $Value;
        }
        TB {
                $result = ($Value * [math]::Pow(10, 3));
        }
        PB {
                $result = ($Value * [math]::Pow(10, 6));
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
        B { 
                $result = ($Value / [math]::Pow(10, 12)); 
        }
        KB {
                $result = ($Value / [math]::Pow(10, 9));
        }
        MB {
                $result = ($Value / [math]::Pow(10, 6));
        }
        GB {
                $result = ($Value / [math]::Pow(10, 3));
        }
        TB {
                $result = $Value;
        }
        PB {
                $result = ($Value * [math]::Pow(10, 3));
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
        B { 
                $result = ($Value / [math]::Pow(10, 15)); 
        }
        KB {
                $result = ($Value / [math]::Pow(10, 12));
        }
        MB {
                $result = ($Value / [math]::Pow(10, 9));
        }
        GB {
                $result = ($Value / [math]::Pow(10, 6));
        }
        TB {
                $result = ($Value / [math]::Pow(10, 3));
        }
        PB {
                $result = $Value;
        }
        Default {}
    }
    
    return $result;
}