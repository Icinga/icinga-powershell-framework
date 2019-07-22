Import-IcingaLib provider\enums;
function Get-IcingaBios()
{
    <# Collects the most important BIOS informations,
    e.g. name, version, manufacturer#>
    $BIOSInformation = Get-CimInstance Win32_BIOS;
    [hashtable]$BIOSCharacteristics = @{};
    [hashtable]$BIOSData = @{};

    foreach ($id in $BIOSInformation.BiosCharacteristics) {
        $BIOSCharacteristics.Add([string]$id, $ProviderEnums.BiosCharacteristics.Item([int]$id));
    }

        $BIOSData.Add(
            'bios', @{
                'metadata' = @{
                    'Name' = $BIOSInformation.Name;
                    'Caption' = $BIOSInformation.Caption;
                    'Manufacturer' = $BIOSInformation.Manufacturer;
                    'PrimaryBIOS' = $BIOSInformation.PrimaryBIOS;
                    'SerialNumber' = $BIOSInformation.SerialNumber;
                    'SMBIOSBIOSVersion' = $BIOSInformation.SMBIOSBIOSVersion;
                    'SoftwareElementID' = $BIOSInformation.SoftwareElementID;
                    'Status' = $BIOSInformation.Status;
                    'Version' = $BIOSInformation.Version;
                    'BiosCharacteristics' = $BIOSCharacteristics;
                }
            }
        );
        return $BIOSData;
    }


function Get-IcingaBiosCharacteristics()
{    
    param([switch]$Sorted);
    
    $bios = Get-CimInstance WIN32_BIOS;
    [hashtable]$BIOSCharacteristics = @{};

    foreach ($id in $bios.BiosCharacteristics) {
        $BIOSCharacteristics.Add([string]$id, $ProviderEnums.BiosCharacteristics.Item([int]$id));
    }
    
    $output = $BIOSCharacteristics;
    
    if ($sorted) {
        $output = $BIOSCharacteristics.GetEnumerator() | Sort-Object name;
    }

    return @{'value' = $output; 'name' = 'BiosCharacteristics'};
}
function Get-IcingaBiosCharacteristics()
{
    param([switch]$Sorted);

    $bios = Get-CimInstance WIN32_BIOS;
    [hashtable]$BIOSCharacteristics = @{};

    foreach ($id in $bios.BiosCharacteristics) {
        $BIOSCharacteristics.Add([string]$id, $ProviderEnums.BiosCharacteristics.Item([int]$id));
    }

    $output = $BIOSCharacteristics;

    if ($sorted) {
        $output = $BIOSCharacteristics.GetEnumerator() | Sort-Object name;
    }

    return @{'value' = $output; 'name' = 'BiosCharacteristics'};
}
function Get-IcingaBiosSerialNumber()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.SerialNumber; 'name' = 'SerialNumber'};
}

function Get-IcingaBiosVersion()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.Version; 'name' = 'Version'};
}

function Get-IcingaBiosManufacturer()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.Manufacturer; 'name' = 'Manufacturer'};
}

# Primary Bios might be more relevant in dual bios context
function Get-IcingaBiosPrimaryBios()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.PrimaryBIOS; 'name' = 'PrimaryBIOS'};
}

function Get-IcingaBiosName()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.Name; 'name' = 'Name'};
}

function Get-IcingaBiosStatus()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.Status; 'name' = 'Status'};
}

function Get-IcingaBiosCaption()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.Caption; 'name' = 'Caption'};
}

function Get-IcingaBiosSMBIOSBIOSVersion()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.SMBIOSBIOSVersion; 'name' = 'SMBIOSBIOSVersion'};
}

function Get-IcingaBiosSoftwareElementID()
{
    $bios = Get-CimInstance Win32_BIOS;
    return @{'value' = $bios.SoftwareElementID; 'name' = 'SoftwareElementID'};
}