Import-Module $IncludeDir\provider\enums;

function Show-IcingaBiosData()
{
    # Lets load some bios informations
    $BIOSInformation = Get-CimInstance Win32_BIOS;
    [hashtable]$BIOSData = @{};

    foreach ($bios_properties in $BIOSInformation) {
        foreach($bios in $bios_properties.CimInstanceProperties) {
            $BIOSData.Add($bios.Name, $bios.Value);
        }
    }

    return $BIOSData;
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

# Primary Bios seems to be relevant in dual-bios context
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

function Get-IcingaBiosCharacteristics()
{
    param([switch]$Sorted);

    $bios = Get-CimInstance WIN32_BIOS;
    [hashtable]$BIOSCharacteristics = @{};

    foreach ($id in $bios.BiosCharacteristics) {
        $BIOSCharacteristics.Add([int]$id, $ProviderEnums.BiosCharacteristics.([int]$id));
    }

    $output = $BIOSCharacteristics;

    if ($sorted) {
        $output = $BIOSCharacteristics.GetEnumerator() | Sort-Object name;
    }

    return @{'value' = $output; 'name' = 'BiosCharacteristics'};
}
