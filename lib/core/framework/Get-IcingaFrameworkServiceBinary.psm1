function Get-IcingaFrameworkServiceBinary()
{
    param(
        [string]$FrameworkServiceUrl,
        [string]$ServiceDirectory
    );

    $ProgressPreference = "SilentlyContinue";

    if ([string]::IsNullOrEmpty($FrameworkServiceUrl)) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt 'Do you provide a custom source of the service binary?' -Default 'n').result -eq 1) {
            $LatestRelease       = (Invoke-WebRequest -Uri 'https://github.com/LordHepipud/icinga-windows-service/releases/latest' -UseBasicParsing).BaseResponse.ResponseUri.AbsoluteUri;
            $FrameworkServiceUrl = $LatestRelease.Replace('/tag/', '/download/');
            $Tag                 = $FrameworkServiceUrl.Split('/')[-1];
            $FrameworkServiceUrl = [string]::Format('{0}/icinga-service-{1}.zip', $FrameworkServiceUrl, $Tag);
        } else {
            $FrameworkServiceUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the full path to your service binary repository' -Default 'v').answer;
        }
    }

    if ([string]::IsNullOrEmpty($ServiceDirectory)) {
        $ServiceDirectory = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Please enter the path you wish to install the service to' -Default 'v' -DefaultInput 'C:\Program Files\icinga-framework-service\').answer;
    }

    if ((Test-Path $ServiceDirectory) -eq $FALSE) {
        New-Item -Path $ServiceDirectory -Force -ItemType Directory | Out-Null;
    }

    $ZipArchive = Join-Path -Path $ServiceDirectory -ChildPath ($FrameworkServiceUrl.Split('/')[-1]);
    $ServiceBin = Join-Path -Path $ServiceDirectory -ChildPath 'icinga-service.exe';

    Invoke-WebRequest -Uri $FrameworkServiceUrl -UseBasicParsing -OutFile $ZipArchive;

    if ((Test-Path $ServiceBin)) {
        Write-Host 'Icinga Service Binary already present. Skipping extrating';

        return @{
            'FrameworkServiceUrl' = $FrameworkServiceUrl;
            'ServiceDirectory'    = $ServiceDirectory;
            'ServiceBin'          = $ServiceBin;
        };
    }

    if ((Expand-IcingaZipArchive -Path $ZipArchive -Destination $ServiceDirectory) -eq $FALSE) {
        throw 'Failed to expand the downloaded ZIP archive';
    }

    if ((Test-IcingaZipBinaryChecksum -Path $ServiceBin) -eq $FALSE) {
        throw 'The checksum of the downloaded file and the required MD5 hash are not matching';
    }

    return @{
        'FrameworkServiceUrl' = $FrameworkServiceUrl;
        'ServiceDirectory'    = $ServiceDirectory;
        'ServiceBin'          = $ServiceBin;
    };
}
