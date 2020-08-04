function Get-IcingaRESTPathElement()
{
    param(
        [Hashtable]$Request = @{},
        [int]$Index         = 0
    );

    if ($null -eq $Request -Or $Request.Count -eq 0) {
        return '';
    }

    if ($Request.ContainsKey('RequestPath') -eq $FALSE) {
        return '';
    }

    if (($Index + 1) -gt $Request.RequestPath.PathArray.Count) {
        return '';
    }

    return $Request.RequestPath.PathArray[$Index];
}
