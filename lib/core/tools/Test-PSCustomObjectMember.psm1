function Test-PSCustomObjectMember()
{
    param (
        $PSObject,
        $Name
    );

    if ($null -eq $PSObject) {
        return $FALSE;
    }

    # Lets make sure we also test for hashtables in case our object is a hashtable
    # instead of a PSCustomObject
    if ($PSObject -Is [hashtable]) {
        return ([bool]($PSObject.ContainsKey($Name)));
    }

    return ([bool]($PSObject.PSObject.Properties.Name -eq $Name));
}
