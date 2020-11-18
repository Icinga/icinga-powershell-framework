<#
.SYNOPSIS
    Tests if a specific WMI class including the Namespace can be accessed and returns status codes for possible errors/exceptions that might occur.
    Returns binary operator values for easier comparison. In case no errors occurred it will return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok
.DESCRIPTION
    Tests if a specific WMI class including the Namespace can be accessed and returns status codes for possible errors/exceptions that might occur.
    Returns binary operator values for easier comparison. In case no errors occurred it will return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok
.ROLE
    ### WMI Permissions

    No special permissions required as this Cmdlet will validate all input data and reports back the result.
.OUTPUTS
    Name                           Value
    ----                           -----
    Ok                             1
    EmptyClass                     2
    PermissionError                4
    ObjectNotFound                 8
    InvalidNameSpace               16
    UnhandledException             32
    NotSpecified                   64
    CimNotInstalled                128
.LINK
    https://github.com/Icinga/icinga-powershell-framework
#>
function Test-IcingaWindowsInformation()
{
    param (
        [string]$ClassName,
        [string]$NameSpace = 'Root\Cimv2'
    );

    if ([string]::IsNullOrEmpty($ClassName)) {
        return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.EmptyClass;
    }

    # Check with Get-CimClass for the specified WMI class and in the specified namespace default root\cimv2
    if ((Test-IcingaFunction 'Get-CimInstance') -eq $FALSE ) {
        return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.CimNotInstalled;
    }

    # We clear all previous errors so that we can catch the last error message from this try/catch in the plugins.
    $Error.Clear();

    try {
        Get-CimInstance -ClassName $ClassName -Namespace $NameSpace -ErrorAction Stop | Out-Null;
    } catch {

        Write-IcingaConsoleDebug `
            -Message "WMIClass: '{0}' : Namespace : {1} {2} {3}" `
            -Objects $ClassName, $NameSpace, (New-IcingaNewLine), $_.Exception.Message;

        if ($_.CategoryInfo.Category -like 'MetadataError') {
            return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.InvalidNameSpace;
        }

        if ($_.CategoryInfo.Category -like 'ObjectNotFound') {
            return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.ObjectNotFound;
        }

        if ($_.CategoryInfo.Category -like 'NotSpecified') {
            return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.NotSpecified;
        }

        if ($_.CategoryInfo.Category -like 'PermissionDenied') {
            return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.PermissionError;
        }

        return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.UnhandledException;
    }

    return $TestIcingaWindowsInfoEnums.TestIcingaWindowsInfo.Ok;
}
