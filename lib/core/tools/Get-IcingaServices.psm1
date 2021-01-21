function Get-IcingaServices()
{
    param (
        [array]$Service,
        [array]$Exclude = @()
    );

    $ServiceInformation = Get-Service -Name $Service -ErrorAction SilentlyContinue;
    $ServiceWmiInfo     = $null;

    if ($Service.Count -eq 0) {
        $ServiceWmiInfo = Get-IcingaWindowsInformation Win32_Service;
    } else {
        $ServiceWmiInfo = Get-IcingaWindowsInformation Win32_Service | Where-Object { $Service -Contains $_.Name } | Select-Object StartName, Name;
    }

    if ($null -eq $ServiceInformation) {
        return $null;
    }

    [hashtable]$ServiceData = @{};

    foreach ($service in $ServiceInformation) {

        [array]$DependentServices = $null;
        [array]$DependingServices = $null;
        $ServiceExitCode          = 0;
        [string]$ServiceUser      = '';
        [int]$StartModeId         = 5;
        [string]$StartMode        = 'Unknown';

        if ($Exclude -contains $service.ServiceName) {
            continue;
        }

        foreach ($wmiService in $ServiceWmiInfo) {
            if ($wmiService.Name -eq $service.ServiceName) {
                $ServiceUser     = $wmiService.StartName;
                $ServiceExitCode = $wmiService.ExitCode;
                if ([string]::IsNullOrEmpty($wmiService.StartMode) -eq $FALSE) {
                    $StartModeId = ([int]$IcingaEnums.ServiceWmiStartupType[$wmiService.StartMode]);
                    $StartMode   = $IcingaEnums.ServiceStartupTypeName[$StartModeId];
                }
                break;
            }
        }

        #Dependent / Child
        foreach ($dependency in $service.DependentServices) {
            if ($null -eq $DependentServices) {
                $DependentServices = @();
            }
            $DependentServices += $dependency.Name;
        }

        #Depends / Parent
        foreach ($dependency in $service.ServicesDependedOn) {
            if ($null -eq $DependingServices) {
                $DependingServices = @();
            }
            $DependingServices += $dependency.Name;
        }

        $ServiceData.Add(
            $service.Name, @{
                'metadata'      = @{
                    'DisplayName'   = $service.DisplayName;
                    'ServiceName'   = $service.ServiceName;
                    'Site'          = $service.Site;
                    'Container'     = $service.Container;
                    'ServiceHandle' = $service.ServiceHandle;
                    'Dependent'     = $DependentServices;
                    'Depends'       = $DependingServices;
                };
                'configuration' = @{
                    'CanPauseAndContinue' = $service.CanPauseAndContinue;
                    'CanShutdown'         = $service.CanShutdown;
                    'CanStop'             = $service.CanStop;
                    'Status'              = @{
                        'raw'   = [int]$service.Status;
                        'value' = $service.Status;
                    };
                    'ServiceType'         = @{
                        'raw'   = [int]$service.ServiceType;
                        'value' = $service.ServiceType;
                    };
                    'ServiceHandle'       = $service.ServiceHandle;
                    'StartType'           = @{
                        'raw'   = $StartModeId;
                        'value' = $StartMode;
                    };
                    'ServiceUser'         = $ServiceUser;
                    'ExitCode'            = $ServiceExitCode;
                }
            }
        );
    }
    return $ServiceData;
}
