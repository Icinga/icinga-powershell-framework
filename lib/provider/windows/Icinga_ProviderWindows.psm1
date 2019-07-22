Import-IcingaLib provider\enums;

function Get-IcingaWindows()
{
    $WindowsInformations = Get-CimInstance Win32_OperatingSystem;

    $OSProductSuite = @();
    $ProviderEnums.WindowsOSProductSuite.Keys | Where-Object { 
        $_ -band $WindowsInformations.OSProductSuite 
    } | ForEach-Object { 
        $OSProductSuite += $ProviderEnums.WindowsOSProductSuite.Get_Item($_); 
    };

    $windows_datails = @{};
    $windows_datails.Add(
        'windows', @{
            'metadata' = @{
                'Version' = $WindowsInformations.Version;
                'CurrentTimeZone' = $WindowsInformations.CurrentTimeZone;
                'InstallDate' = $WindowsInformations.InstallDate;
                'SystemDevice' = $WindowsInformations.SystemDevice;
                'SystemDirectory' = $WindowsInformations.SystemDirectory;
                'BuildType' = $WindowsInformations.BuildType;
                'BuildNumber' = $WindowsInformations.BuildNumber;
                'OSArchitecture' = $WindowsInformations.OSArchitecture;
                'NumberOfUsers' = $WindowsInformations.NumberOfUsers;
                'OSType' = @{
                    'raw' = $WindowsInformations.OSType;
                    'value' = $ProviderEnums.WindowsOSType[[int]$WindowsInformations.OSType];
                };
                'OSProductSuite' = @{
                    'raw' = $WindowsInformations.OSProductSuite;
                    'value' = $OSProductSuite;
                };
                'ProductType' = @{
                    'raw' = $WindowsInformations.ProductType;
                    'value' = $ProviderEnums.WindowsProductType[[int]$WindowsInformations.ProductType];
                };
            };
            'language' = @{
                'CountryCode' = $WindowsInformations.CountryCode;
                'OSLanguage' = $WindowsInformations.OSLanguage;
                'Locale' = $WindowsInformations.Locale;
            }
        }
    );

    return $windows_datails;
}