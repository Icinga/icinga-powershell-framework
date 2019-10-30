function New-StringTree()
{
    param(
        [int]$Spacing
    )
    
    if ($Spacing -eq 0) {
        return '';
    }

    [string]$spaces = '\_ ';
    
    while ($Spacing -gt 1) {
        $Spacing -= 1;
        $spaces = '   ' + $spaces;
    }

    return $spaces;
}
