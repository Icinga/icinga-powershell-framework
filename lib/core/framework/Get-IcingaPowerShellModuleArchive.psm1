<#
.SYNOPSIS
   Download a PowerShell Module from a custom source or from GitHub
   by providing a repository and the user space
.DESCRIPTION
   Download a PowerShell Module from a custom source or from GitHub
   by providing a repository and the user space
.FUNCTIONALITY
   Download and install a PowerShell module from a custom or GitHub source
.EXAMPLE
   PS>Get-IcingaPowerShellModuleArchive -ModuleName 'Plugins' -Repository 'icinga-powershell-plugins' -Release 1;
.EXAMPLE
   PS>Get-IcingaPowerShellModuleArchive -ModuleName 'Plugins' -Repository 'icinga-powershell-plugins' -Release 1 -DryRun 1;
.PARAMETER DownloadUrl
   The Url to a ZIP-Archive to download from (skips the wizard)
.PARAMETER ModuleName
   The name which is used inside output messages
.PARAMETER Repository
   The repository to download the ZIP-Archive from
.PARAMETER GitHubUser
   The user from which a repository is downloaded from
.PARAMETER Release
   Download the latest release
.PARAMETER Snapshot
   Download the latest package from the master branch
.PARAMETER DryRun
   Only return the finished build Url including the version to install but
   do not modify the system in any way
.INPUTS
   System.String
.OUTPUTS
   System.Hashtable
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function Get-IcingaPowerShellModuleArchive()
{
    param(
        [string]$DownloadUrl = '',
        [string]$ModuleName  = '',
        [string]$Repository  = '',
        [string]$GitHubUser  = 'Icinga',
        [bool]$Release       = $FALSE,
        [bool]$Snapshot      = $FALSE,
        [bool]$DryRun        = $FALSE
    );

    Set-IcingaTLSVersion;
    $ProgressPreference = "SilentlyContinue";
    $Tag                = 'master';
    [bool]$SkipRepo     = $FALSE;

    if ($Release -Or $Snapshot) {
        $SkipRepo = $TRUE;
    }

    # Fix TLS errors while connecting to GitHub with old PowerShell versions
    [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";

    if ([string]::IsNullOrEmpty($DownloadUrl)) {
        if ($SkipRepo -Or (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Do you provide a custom repository for "{0}"?', $ModuleName)) -Default 'n').result -eq 1) {
            if ($Release -eq $FALSE -And $Snapshot -eq $FALSE) {
                $branch = (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Which version of the "{0}" do you want to install? (release/snapshot)', $ModuleName)) -Default 'v' -DefaultInput 'release').answer;
            } elseif ($Release) {
                $branch = 'release';
            } else {
                $branch = 'snapshot'
            }
            if ($branch.ToLower() -eq 'snapshot') {
                $DownloadUrl   = [string]::Format('https://github.com/{0}/{1}/archive/master.zip', $GitHubUser, $Repository);
            } else {
                $WebResponse = Invoke-IcingaWebRequest -Uri 'https://github.com/{0}/{1}/releases/latest' -Objects $GitHubUser, $Repository -UseBasicParsing;

                if ($null -eq $WebResponse.HasErrors -Or $WebResponse.HasErrors -eq $FALSE) {
                    $LatestRelease = $WebResponse.BaseResponse.ResponseUri.AbsoluteUri;
                    $DownloadUrl   = $LatestRelease.Replace('/releases/tag/', '/archive/');
                    $Tag           = $DownloadUrl.Split('/')[-1];
                } else {
                    Write-IcingaConsoleError -Message 'Failed to fetch latest release for "{0}" from GitHub. Either the module or the GitHub account do not exist' -Objects $ModuleName;
                }

                $DownloadUrl   = [string]::Format('{0}/{1}.zip', $DownloadUrl, $Tag);

                $CurrentVersion = Get-IcingaPowerShellModuleVersion $Repository;

                if ($null -ne $CurrentVersion -And $CurrentVersion -eq $Tag) {
                    Write-IcingaConsoleNotice -Message 'Your "{0}" is already up-to-date' -Objects $ModuleName;
                    return @{
                        'DownloadUrl' = $DownloadUrl;
                        'Version'     = $Tag;
                        'Directory'   = '';
                        'Archive'     = '';
                        'ModuleRoot'  = (Get-IcingaForWindowsRootPath);
                        'Installed'   = $FALSE;
                    };
                }
            }
        } else {
            $DownloadUrl = (Get-IcingaAgentInstallerAnswerInput -Prompt ([string]::Format('Please enter the full path of the custom repository for the "{0}" (location of zip file)', $ModuleName)) -Default 'v').answer;
        }
    }

    if ($DryRun) {
        return @{
            'DownloadUrl' = $DownloadUrl;
            'Version'     = $Tag;
            'Directory'   = '';
            'Archive'     = '';
            'ModuleRoot'  = (Get-IcingaForWindowsRootPath);
            'Installed'   = $FALSE;
        };
    }

    $DownloadDirectory   = New-IcingaTemporaryDirectory;
    $DownloadDestination = (Join-Path -Path $DownloadDirectory -ChildPath ([string]::Format('{0}.zip', $Repository)));
    Write-IcingaConsoleNotice ([string]::Format('Downloading "{0}" into "{1}"', $ModuleName, $DownloadDirectory));

    if ((Invoke-IcingaWebRequest -UseBasicParsing -Uri $DownloadUrl -OutFile $DownloadDestination).HasErrors) {
        Write-IcingaConsoleError ([string]::Format('Failed to download "{0}" into "{1}". Starting cleanup process', $ModuleName, $DownloadDirectory));
        Start-Sleep -Seconds 2;
        Remove-Item -Path $DownloadDirectory -Recurse -Force;

        Write-IcingaConsoleNotice 'Starting to re-run the download wizard';

        return Get-IcingaPowerShellModuleArchive -ModuleName $ModuleName -Repository $Repository;
    }

    return @{
        'DownloadUrl' = $DownloadUrl;
        'Version'     = $Tag;
        'Directory'   = $DownloadDirectory;
        'Archive'     = $DownloadDestination;
        'ModuleRoot'  = (Get-IcingaForWindowsRootPath);
        'Installed'   = $TRUE;
    };
}
