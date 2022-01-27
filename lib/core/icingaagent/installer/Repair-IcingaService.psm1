<#
.SYNOPSIS
    Repairs the Icinga Agent service installation in case the service is no longer present on the system
    caused by update failures
.DESCRIPTION
    Repairs the Icinga Agent service installation in case the service is no longer present on the system
    caused by update failures
.PARAMETER RootFolder
    Specifies the root folder of the Icinga Agent installation, in case a custom location is used for installation
    Default locations are detected automatically
.EXAMPLE
    PS> Repair-IcingaService;
.EXAMPLE
    PS> Repair-IcingaService -RootFolder 'D:\Programs\icinga2';
.NOTES
    https://icinga.com/docs/icinga-for-windows/latest/doc/knowledgebase/IWKB000011/
#>
function Repair-IcingaService()
{
    param (
        [string]$RootFolder = ''
    );

    if ($null -ne (Get-Service 'icinga2' -ErrorAction SilentlyContinue)) {
        Write-IcingaConsoleNotice -Message 'The Icinga Agent service is already installed. If you received the error "The specified service has been marked for deletion", please have a look at https://icinga.com/docs/icinga-for-windows/latest/doc/knowledgebase/IWKB000011/'
        return;
    }

    [string]$IcingaBinaryPath  = 'sbin\icinga2.exe';
    [string]$IcingaServicePath = '';

    if ([string]::IsNullOrEmpty($RootFolder) -eq $FALSE) {
        $IcingaServicePath = Join-Path -Path $RootFolder -ChildPath $IcingaBinaryPath;

        if ((Test-Path $IcingaServicePath) -eq $FALSE) {
            Write-IcingaConsoleError `
                -Message 'The Icinga Agent could not be found at the location "{0}". Please specify only the Icinga Agent root path with "-RootFolder"' `
                -Objects $IcingaServicePath;

            return;
        }
    } else {
        $IcingaServicePath = Join-Path -Path $Env:ProgramFiles -ChildPath ([string]::Format('ICINGA2\{0}', $IcingaBinaryPath));

        if ((Test-Path $IcingaServicePath) -eq $FALSE) {
            $IcingaServicePath = Join-Path -Path ${Env:ProgramFiles(x86)} -ChildPath ([string]::Format('ICINGA2\{0}', $IcingaBinaryPath));

            if ((Test-Path $IcingaServicePath) -eq $FALSE) {
                Write-IcingaConsoleError `
                    -Message 'The Icinga Agent could not be found at the default locations "{0}" or "{1}". If you installed the Icinga Agent into a customer directory, please specify the root folder with "-RootFolder"' `
                    -Objects $Env:ProgramFiles, ${Env:ProgramFiles(x86)};

                return;
            }
        }
    }

    Write-IcingaConsoleNotice `
        -Message 'Repairing Icinga Agent service with location "{0}"' `
        -Objects $IcingaServicePath;

    $IcingaServicePath = [string]::Format('\"{0}\" --scm \"daemon\"', $IcingaServicePath);
    $IcingaService     = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('create icinga2 binPath= "{0}" DisplayName= "Icinga 2" start= auto', $IcingaServicePath));

    if ($IcingaService.ExitCode -ne 0) {
        Write-IcingaConsoleError `
            -Message 'Failed to install Icinga Agent service: {0}{1}' `
            -Objects $IcingaService.Message, $IcingaService.Error;

        return;
    }

    $IcingaData  = Get-IcingaAgentInstallation;
    $ConfigUser  = Get-IcingaPowerShellConfig -Path 'Framework.Icinga.ServiceUser';
    $ServiceUser = $IcingaData.User;

    if ([string]::IsNullOrEmpty($ConfigUser) -eq $FALSE) {
        $ServiceUser = $ConfigUser;
    }

    Set-IcingaServiceUser -User $ServiceUser -SetPermission;
    Update-IcingaServiceUser;

    Write-IcingaConsoleNotice -Message 'Icinga Agent service was successfully repaired. You can start it now with "Start-Service icinga2"';
}
