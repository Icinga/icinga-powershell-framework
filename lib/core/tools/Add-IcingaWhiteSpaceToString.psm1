function Add-IcingaWhiteSpaceToString()
{
    param (
        [string]$Text = '',
        [int]$Length  = 0
    );

    [int]$LengthOffset = $Length - $Text.Length;

    while ($LengthOffset -ge 0) {
        $Text += ' ';
        $LengthOffset -= 1;
    }

    return $Text;
}
