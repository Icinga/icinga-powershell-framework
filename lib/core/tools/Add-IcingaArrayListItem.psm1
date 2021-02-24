function Add-IcingaArrayListItem()
{
    param (
        [System.Collections.ArrayList]$Array,
        $Element
    );

    if ($null -eq $Array -Or $null -eq $Element) {
        return;
    }

    $Array.Add($Element) | Out-Null;
}
