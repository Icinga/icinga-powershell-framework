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
