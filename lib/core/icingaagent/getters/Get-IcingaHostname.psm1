function Get-IcingaHostname()
{
    param(
        [string]$Hostname,
        [bool]$AutoUseFQDN     = $FALSE,
        [bool]$AutoUseHostname = $FALSE,
        [bool]$UpperCase       = $FALSE,
        [bool]$LowerCase       = $FALSE,
        [switch]$ReadConstants = $FALSE
    );

    [string]$UseHostname = '';

    if ($ReadConstants) {
        if (Test-Path -Path (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\etc\icinga2\constants.conf')) {
            # Read the constants conf
            $FileContent = Get-Content -Path (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\etc\icinga2\constants.conf') -Encoding 'UTF8';

            foreach ($line in $FileContent) {
                if ($line.Contains('NodeName') -eq $FALSE) {
                    continue;
                }

                if ($line.Contains('const') -eq $FALSE -Or $line.Contains('=') -eq $FALSE -Or $line.Contains('"') -eq $FALSE) {
                    continue;
                }

                [int]$ValueIndex = $line.IndexOf('"') + 1;

                $UseHostname = $line.SubString($ValueIndex, $line.Length - $ValueIndex);

                if ($UseHostname[-1] -eq '"') {
                    $UseHostname = $UseHostname.Substring(0, $UseHostname.Length - 1);
                }

                break;
            }

            return $UseHostname
        }
    }

    if ([string]::IsNullOrEmpty($Hostname) -eq $FALSE) {
        $UseHostname = $Hostname;
    } elseif ($AutoUseFQDN) {
        $UseHostname = [System.Net.Dns]::GetHostEntry("localhost").HostName;
    } else {
        $UseHostname = [System.Net.Dns]::GetHostName();
    }

    if ($UpperCase) {
        $UseHostname = $UseHostname.ToUpper();
    } elseif ($LowerCase) {
        $UseHostname = $UseHostname.ToLower();
    }

    return $UseHostname;
}
