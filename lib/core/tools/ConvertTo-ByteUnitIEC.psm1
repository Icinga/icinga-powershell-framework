function ConvertTo-ByteIEC()
{
    param(
       [single]$Value,
       [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'Kibi', 'KibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'Mibi', 'MibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }        
        { 'Gibi', 'GibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        { 'Tibi', 'TibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 40)); $boolOption = $true; }
        { 'Piti', 'PitiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 50)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Throw 'Invalid input';
            } 
        }
    }

    return $result;
}

function ConvertTo-KibiByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'Kibi', 'KibiByte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'Mibi', 'MibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }        
        { 'Gibi', 'GibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        { 'Tibi', 'TibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        { 'Piti', 'PitiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 40)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Throw 'Invalid input';
            }  
        }
    }
    
    return $result;
}

function ConvertTo-MibiByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'Kibi', 'KibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'Mibi', 'MibiByte' -contains $_ } { $result = $Value; $boolOption = $true; }       
        { 'Gibi', 'GibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'Tibi', 'TibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        { 'Piti', 'PitiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 30)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Throw 'Invalid input';
            } 
        }
    }
    
    return $result;
}

function ConvertTo-GibiByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'Kibi', 'KibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'Mibi', 'MibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'Gibi', 'GibiByte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'Tibi', 'TibiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        { 'Piti', 'PitiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 20)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Throw 'Invalid input';
            }  
        }
    }
    
    return $result;
}

function ConvertTo-TibiByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 40)); $boolOption = $true; }
        { 'Kibi', 'KibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'Mibi', 'MibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'Gibi', 'GibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'Tibi', 'TibiByte' -contains $_ } { $result = $Value; $boolOption = $true; }
        { 'Piti', 'PitiByte' -contains $_ } { $result = ($Value * [math]::Pow(2, 10)); $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Throw 'Invalid input';
            }  
        }
    }
    
    return $result;
}

function ConvertTo-PitiByte()
{
    param(
        [single]$Value,
        [string]$Unit
    );

    switch ($Unit) {
        { 'B', 'Byte' -contains $_ } { $result = ($Value / [math]::Pow(2, 50)); $boolOption = $true; }
        { 'Kibi', 'KibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 40)); $boolOption = $true; }
        { 'Mibi', 'MibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 30)); $boolOption = $true; }
        { 'Gibi', 'GibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 20)); $boolOption = $true; }
        { 'Tibi', 'TibiByte' -contains $_ } { $result = ($Value / [math]::Pow(2, 10)); $boolOption = $true; }
        { 'Piti', 'PitiByte' -contains $_ } { $result = $Value; $boolOption = $true; }
        default { 
            if (-Not $boolOption) {
                Throw 'Invalid input';
            }  
        }
    }
    
    return $result;
}
