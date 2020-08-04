function Pop-IcingaArrayListItem()
{
    param(
        [System.Collections.ArrayList]$Array
    );

    if ($null -eq $Array) {
        return $null;
    }

    if ($Array.Count -eq 0) {
        return $null;
    }

    $Content = $Array[0];
    $Array.RemoveAt(0);

    return $Content;
}
