function Test-PSCustomObjectMember()
{
    param(
        $PSObject,
        $Name
    );

    if ($null -eq $PSObject) {
        return $FALSE;
    }

    return ([bool]($PSObject.PSobject.Properties.Name -eq $Name));
}
