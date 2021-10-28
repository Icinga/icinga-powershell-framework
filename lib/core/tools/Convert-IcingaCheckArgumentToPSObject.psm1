function Convert-IcingaCheckArgumentToPSObject()
{
    param (
        $Parameter    = $null,
        $CheckCommand = $null
    );

    $ParamValue = New-Object -TypeName PSObject;

    if ($null -eq $parameter) {
        return $ParamValue;
    }

    $ParameterName = $Parameter.name;

    if ([string]::IsNullOrEmpty($CheckCommand) -eq $FALSE) {
        $CmdData = Get-Command $CheckCommand;
        if ($CmdData.Parameters.ContainsKey($ParameterName)) {
            if ($CmdData.Parameters[$ParameterName].Aliases.Count -ne 0) {
                $ParameterName = $CmdData.Parameters[$ParameterName].Aliases[0];
            }
        }
    }

    $ParamValue | Add-Member -MemberType NoteProperty -Name 'type'                   -Value (New-Object -TypeName PSObject);
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'Description'            -Value (New-Object -TypeName PSObject);
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'Attributes'             -Value (New-Object -TypeName PSObject);
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'position'               -Value $Parameter.position;
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'Name'                   -Value $ParameterName;
    $ParamValue | Add-Member -MemberType NoteProperty -Name 'required'               -Value $Parameter.required;
    $ParamValue.type | Add-Member -MemberType NoteProperty -Name 'name'              -Value $Parameter.type.name;
    $ParamValue.Description | Add-Member -MemberType NoteProperty -Name 'Text'       -Value $Parameter.Description.Text;
    $ParamValue.Attributes | Add-Member -MemberType NoteProperty -Name 'ValidValues' -Value $null;

    return $ParamValue;
}
