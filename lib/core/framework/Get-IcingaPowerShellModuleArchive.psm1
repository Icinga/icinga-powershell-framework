function Get-IcingaPowerShellModuleArchive()
{
    param(
        [string]$DownloadUrl = '',
        [string]$ModuleName  = '',
        [string]$Repository  = ''
    );

    $ProgressPreference = "SilentlyContinue";
    $Tag                = 'master';

    if ([string]::IsNullOrEmpty($DownloadUrl)) {
        if ((Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you provide a custom repository for "{0}"?', $ModuleName)) -Default 'n').result -eq 1) {
            $branch = (Get-IcingaAgentInstallerAnswerInput -Prompt 'Which version to you want to install? (snapshot/stable)' -Default 'v' -DefaultInput 'stable').answer
            if ($branch.ToLower() -eq 'snapshot') {
                $DownloadUrl   = [string]::Format('https://github.com/Icinga/{0}/archive/master.zip', $Repository);
            } else {
                $LatestRelease = (Invoke-WebRequest -Uri ([string]::Format('https://github.com/Icinga/{0}/releases/latest', $Repository)) -UseBasicParsing).BaseResponse.ResponseUri.AbsoluteUri;
                $DownloadUrl   = $LatestRelease.Replace('/releases/tag/', '/archive/');
                $Tag           = $DownloadUrl.Split('/')[-1];
                $DownloadUrl   = [string]::Format('{0}/{1}.zip', $DownloadUrl, $Tag);

                $CurrentVersion = Get-IcingaPowerShellModuleVersion $Repository;

                if ($null -ne $CurrentVersion -And $CurrentVersion -eq $Tag) {
                    Write-Host ([string]::Format('Your "{0}" is already up-to-date', $ModuleName));
                    return;
                }
            }
        } else {
            $DownloadUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Please enter the full Url to your "{0}" Zip-Archive', $ModuleName)) -Default 'v').answer;
        }
    }

    try {
        $DownloadDirectory   = New-IcingaTemporaryDirectory;
        $DownloadDestination = (Join-Path -Path $DownloadDirectory -ChildPath ([string]::Format('{0}.zip', $Repository)));
        Write-Host ([string]::Format('Downloading "{0}" into "{1}"', $ModuleName, $DownloadDirectory));

        Invoke-WebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $DownloadDestination;
    } catch {
        Write-Host ([string]::Format('Failed to download "{0}" into "{1}". Starting cleanup process', $ModuleName, $DownloadDirectory));
        Start-Sleep -Seconds 2;
        Remove-Item -Path $DownloadDirectory -Recurse -Force;

        Write-Host 'Starting to re-run the download wizard';

        return Get-IcingaPowerShellModuleArchive -ModuleName $ModuleName -Repository $Repository;
    }

    return @{
        'DownloadUrl' = $DownloadUrl;
        'Version'     = $Tag;
        'Directory'   = $DownloadDirectory;
        'Archive'     = $DownloadDestination;
        'ModuleRoot'  = (Get-IcingaFrameworkRootPath);
    };
}
