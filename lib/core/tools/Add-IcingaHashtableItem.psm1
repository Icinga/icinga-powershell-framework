function Add-IcingaHashtableItem()
{
    param(
        $Hashtable,
        $Key,
        $Value,
        [switch]$Override
    );

    if ($null -eq $Hashtable) {
        return $FALSE;
    }

    if ($Hashtable.ContainsKey($Key) -eq $FALSE) {
        $Hashtable.Add($Key, $Value);
        return $TRUE;
    } else {
        if ($Override) {
            $Hashtable.Remove($Key);
            $Hashtable.Add($Key, $Value);
            return $TRUE;
        }
    }
    return $FALSE;
}
