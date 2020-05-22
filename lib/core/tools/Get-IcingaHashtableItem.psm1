function Get-IcingaHashtableItem()
{
    param(
        $Hashtable,
        $Key,
        $NullValue = $null
    );

    if ($null -eq $Hashtable) {
        return $NullValue;
    }

    if ($Hashtable.ContainsKey($Key) -eq $FALSE) {
        return $NullValue;
    }

    return $Hashtable[$Key];
}
