function Get-IcingaMaxTextLength()
{
    param (
        [array]$TextArray = ''
    );

    [int]$MaxLength = 0;

    foreach ($text in $TextArray) {
        if ($MaxLength -lt $text.Length) {
            $MaxLength = $text.Length;
        }
    }

    return $MaxLength;
}
