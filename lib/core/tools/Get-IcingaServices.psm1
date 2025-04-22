function Get-IcingaServices()
{
    param (
        [array]$Service = @(),
        [array]$Exclude = @()
    );

    $ServiceInformation = Get-Service;
    $ServiceWmiInfo     = $null;
    $ServiceFilter      = New-Object System.Text.StringBuilder;

    if ($Service.Count -gt 0) {
        $ServiceFilter.Append('(') | Out-Null;

        foreach ($svc in $Service) {
            if ($ServiceFilter.Length -gt 1) {
                $ServiceFilter.Append(' OR ') | Out-Null;
            }

            $ServiceFilter.Append(
                [string]::Format(
                    'Name LIKE "{0}"',
                    $svc.Replace('*', '%')
                )
            ) | Out-Null;
        }

        $ServiceFilter.Append(')') | Out-Null;
    }

    if ($Exclude.Count -gt 0) {
        if ($ServiceFilter.Length -gt 0) {
            $ServiceFilter.Append(' AND (') | Out-Null;
        } else {
            $ServiceFilter.Append('(') | Out-Null;
        }

        [bool]$First = $TRUE;

        foreach ($svc in $Exclude) {
            if ($First -eq $FALSE) {
                $ServiceFilter.Append(' AND ') | Out-Null;
            }

            $First = $FALSE;

            $ServiceFilter.Append(
                [string]::Format(
                    'NOT Name LIKE "{0}"',
                    $svc.Replace('*', '%')
                )
            ) | Out-Null;
        }

        $ServiceFilter.Append(')') | Out-Null;
    }

    try {
        $ServiceWmiInfo = Get-IcingaWindowsInformation -ClassName Win32_Service -Filter $ServiceFilter.ToString() | Select-Object StartName, Name, ExitCode, StartMode, PathName;
    } catch {
        Exit-IcingaThrowException -InputString $_.Exception.Message -StringPattern 'wildcard' -ExceptionType 'Input' -ExceptionThrown $IcingaExceptions.Inputs.RegexError;
        Exit-IcingaThrowException -CustomMessage $_.Exception.Message -ExceptionType 'Input' -ExceptionThrown $_.Exception.Message;
        return $null;
    }

    if ($null -eq $ServiceInformation) {
        return $null;
    }

    [hashtable]$ServiceData = @{ };

    foreach ($si in $ServiceInformation) {

        [array]$DependentServices = $null;
        [array]$DependingServices = $null;
        $ServiceExitCode          = 0;
        [string]$ServiceUser      = '';
        [string]$ServicePath      = '';
        [int]$StartModeId         = 5;
        [string]$StartMode        = 'Unknown';

        if ((Test-IcingaArrayFilter -InputObject $si.ServiceName -Include $Service -Exclude $Exclude) -eq $FALSE) {
            continue;
        }

        foreach ($wmiService in $ServiceWmiInfo) {
            if ($wmiService.Name -eq $si.ServiceName) {
                $ServiceUser     = $wmiService.StartName;
                $ServicePath     = $wmiService.PathName;
                $ServiceExitCode = $wmiService.ExitCode;
                if ([string]::IsNullOrEmpty($wmiService.StartMode) -eq $FALSE) {
                    $StartModeId = ([int]$IcingaEnums.ServiceWmiStartupType[$wmiService.StartMode]);
                    $StartMode   = $IcingaEnums.ServiceStartupTypeName[$StartModeId];
                }
                break;
            }
        }

        #Dependent / Child
        foreach ($dependency in $si.DependentServices) {
            if ($null -eq $DependentServices) {
                $DependentServices = @();
            }
            $DependentServices += $dependency.Name;
        }

        #Depends / Parent
        foreach ($dependency in $si.ServicesDependedOn) {
            if ($null -eq $DependingServices) {
                $DependingServices = @();
            }
            $DependingServices += $dependency.Name;
        }

        $ServiceData.Add(
            $si.Name, @{
                'metadata'      = @{
                    'DisplayName'   = $si.DisplayName;
                    'ServiceName'   = $si.ServiceName;
                    'Site'          = $si.Site;
                    'Container'     = $si.Container;
                    'ServiceHandle' = $si.ServiceHandle;
                    'Dependent'     = $DependentServices;
                    'Depends'       = $DependingServices;
                };
                'configuration' = @{
                    'CanPauseAndContinue' = $si.CanPauseAndContinue;
                    'CanShutdown'         = $si.CanShutdown;
                    'CanStop'             = $si.CanStop;
                    'Status'              = @{
                        'raw'   = [int]$si.Status;
                        'value' = $si.Status;
                    };
                    'ServiceType'         = @{
                        'raw'   = [int]$si.ServiceType;
                        'value' = $si.ServiceType;
                    };
                    'ServiceHandle'       = $si.ServiceHandle;
                    'StartType'           = @{
                        'raw'   = $StartModeId;
                        'value' = $StartMode;
                    };
                    'ServiceUser'         = $ServiceUser;
                    'ServicePath'         = $ServicePath;
                    'ExitCode'            = $ServiceExitCode;
                }
            }
        );
    }
    return $ServiceData;
}
