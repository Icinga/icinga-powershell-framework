function Add-PSCustomObjectMember()
{
    param (
        $Object,
        $Key,
        $Value
    );

    if ($null -eq $Object) {
        return $Object;
    }

    $Object | Add-Member -MemberType NoteProperty -Name $Key -Value $Value;

    return $Object;
}
