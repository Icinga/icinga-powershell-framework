function Remove-IcingaHashtableItem()
{
    param(
        $Hashtable,
        $Key
    );

    if ($null -eq $Hashtable) {
        return;
    }

    if ($Hashtable.ContainsKey($Key)) {
        $Hashtable.Remove($Key);
    }
}
