Import-IcingaLib core\tools;
# year month week days hours minutes seconds milliseconds

function ConvertTo-Seconds()
{
    param(
        [string]$Value
    );

    [string]$NumberPart = '';
    [string]$UnitPart   = '';
    [bool]$Negate       = $FALSE;

    foreach($char in $Value.ToCharArray()) {
        if ((Test-Numeric $char)) {
            $NumberPart += $char;
        } else {
            if ($char -eq '-') {
                $Negate = $TRUE;
            } elseif ($char -eq '.' -Or $char -eq ',') {
                $NumberPart += '.';
            } else {
                $UnitPart += $char;
            }
        }
    }

    [single]$ValueSplitted = $NumberPart;
    $result             = 0;

    if ($Negate) {
        $ValueSplitted *= -1;
    }

    [string]$errorMsg   = (
        [string]::Format('Invalid unit type "{0}" specified for convertion. Allowed units: ms, s, m, h, d, w, M, y', $UnitPart)
    );

    if ($UnitPart -Match 'ms') {
        $result = ($ValueSplitted / [math]::Pow(10, 3));
    } else {
        if ($UnitPart.Length -gt 1) {
            Throw $errorMsg;
        }

        switch ([int][char]$UnitPart) {
            { 115 -contains $_ } { $result = $ValueSplitted; break; } # s
            { 109 -contains $_ } { $result = $ValueSplitted * 60; break; } # m
            { 104 -contains $_ } { $result = $ValueSplitted * 3600; break; } # h
            { 100 -contains $_ } { $result = $ValueSplitted * 86400; break; } # d
            { 119 -contains $_ } { $result = $ValueSplitted * 604800; break; } # w
            { 77  -contains $_ } { $result = $ValueSplitted * 2592000; break; } # M
            { 121 -contains $_ } { $result = $ValueSplitted * 31536000; break; } # y
            default { 
                Throw $errorMsg;
                break;
            }
        }
    }

    return $result;
}
