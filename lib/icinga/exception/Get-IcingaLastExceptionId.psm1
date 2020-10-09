<#
.SYNOPSIS
    This function returns the HRESULT unique value thrown by the last exception
.DESCRIPTION
    This function returns the HRESULT unique value thrown by the last exception
.OUTPUTS
    System.String
#>
function Get-IcingaLastExceptionId()
{
    if ([string]::IsNullOrEmpty($Error)) {
        return '';
    }

    [string]$ExceptionId = ([string]($Error.FullyQualifiedErrorId)).Split(',')[0].Split(' ')[1];
    $Error.Clear();

    return $ExceptionId;
}
