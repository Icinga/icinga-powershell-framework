<#
.SYNOPSIS
    Allows to query Wmi information by either using Wmi directly or Cim. This provides a save handling
    to call Wmi classes, as we are catching possible errors including missing permissions for better
    and improved error output during plugin execution.
.DESCRIPTION
    Allows to query Wmi information by either using Wmi directly or Cim. This provides a save handling
    to call Wmi classes, as we are catching possible errors including missing permissions for better
    and improved error output during plugin execution.
.PARAMETER ClassName
    The Wmi class to fetch information from
.PARAMETER Filter
    Allows to filter only for specific Wmi information. The syntax is identical to Get-WmiObject and Get-CimInstance
.PARAMETER Namespace
    The Wmi namespace to lookup additional information. The syntax is identical to Get-WmiObject and Get-CimInstance
.PARAMETER ForceWMI
    Forces the usage of `Get-WmiObject` instead of `Get-CimInstance`
.EXAMPLE
    PS>Get-IcingaWindowsInformation -ClassName Win32_Service;
.EXAMPLE
    PS>Get-IcingaWindowsInformation -ClassName Win32_Service -ForceWMI;
.EXAMPLE
    PS>Get-IcingaWindowsInformation -ClassName MSFT_NetAdapter -NameSpace 'root\StandardCimv2';
.EXAMPLE
    PS>Get-IcingaWindowsInformation Win32_LogicalDisk -Filter 'DriveType = 3';
.INPUTS
    System.String
.OUTPUTS
    System.Boolean
#>

function Get-IcingaWindowsInformation()
{
    param (
        [string]$ClassName,
        $Filter,
        $Namespace,
        [switch]$ForceWMI  = $FALSE
    );

    $Arguments = @{
        'ClassName' = $ClassName;
    }

    if ([string]::IsNullOrEmpty($Filter) -eq $FALSE) {
        $Arguments.Add(
            'Filter', $Filter
        );
    }
    if ([string]::IsNullOrEmpty($Namespace) -eq $FALSE) {
        $Arguments.Add(
            'Namespace', $Namespace
        );
    }

    if ($ForceWMI -eq $FALSE -And (Get-Command 'Get-CimInstance' -ErrorAction SilentlyContinue)) {
        try {
            return (Get-CimInstance @Arguments -ErrorAction Stop);
        } catch {
            $ErrorName    = $_.Exception.NativeErrorCode;
            $ErrorMessage = $_.Exception.Message;
            $ErrorCode    = $_.Exception.StatusCode;

            if ([string]::IsNullOrEmpty($Namespace)) {
                $Namespace = 'root/cimv2';
            }

            switch ($ErrorCode) {
                # Permission error
                2 {
                    Exit-IcingaThrowException -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.CimInstance -CustomMessage ([string]::Format('Class: "{0}", Namespace: "{1}"', $ClassName, $Namespace)) -Force;
                };
                # InvalidClass
                5 {
                    Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.CimClassNameUnknown -CustomMessage $ClassName -Force;
                };
                # All other errors
                default {
                    Exit-IcingaThrowException -ExceptionType 'Custom' -InputString $ErrorMessage -CustomMessage ([string]::Format('CimInstanceUnhandledError: Class "{0}": Error "{1}": Id "{2}"', $ClassName, $ErrorName, $ErrorCode)) -Force;
                }
            }
        }
    }

    if ((Get-Command 'Get-WmiObject' -ErrorAction SilentlyContinue)) {
        try {
            return (Get-WmiObject @Arguments -ErrorAction Stop);
        } catch {
            $ErrorName    = $_.CategoryInfo.Category;
            $ErrorMessage = $_.Exception.Message;
            $ErrorCode    = ($_.Exception.HResult -band 0xFFFF);

            if ([string]::IsNullOrEmpty($Namespace)) {
                $Namespace = 'root/cimv2';
            }

            switch ($ErrorName) {
                # Permission error
                'InvalidOperation' {
                    Exit-IcingaThrowException -ExceptionType 'Permission' -ExceptionThrown $IcingaExceptions.Permission.WMIObject -CustomMessage ([string]::Format('Class: "{0}", Namespace: "{1}"', $ClassName, $Namespace)) -Force;
                };
                # Invalid Class
                'InvalidType' {
                    Exit-IcingaThrowException -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.WmiObjectClassUnknown -CustomMessage $ClassName -Force;
                };
                # All other errors
                default {
                    Exit-IcingaThrowException -ExceptionType 'Custom' -InputString $ErrorMessage -CustomMessage ([string]::Format('WmiObjectUnhandledError: Class "{0}": Error "{1}": Id "{2}"', $ClassName, $ErrorName, $ErrorCode)) -Force;
                }
            }
        }
    }

    # Exception
    Exit-IcingaThrowException -ExceptionType 'Custom' -InputString 'Failed to fetch Windows information by using CimInstance or WmiObject. Both commands are not present on the system.' -CustomMessage ([string]::Format('CimWmiUnhandledError: Class "{0}"', $ClassName)) -Force;
}
