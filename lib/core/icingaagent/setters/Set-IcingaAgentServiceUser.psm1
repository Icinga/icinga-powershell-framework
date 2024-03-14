function Set-IcingaServiceUser()
{
    param (
        [string]$User           = 'NT Authority\NetworkService',
        [securestring]$Password,
        [string]$Service        = 'icinga2',
        [switch]$SetPermission  = $FALSE
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError -Message 'Please specify a username to modify the service user';
        return $FALSE;
    }

    switch ($Service.ToLower()) {
        'icinga2' {
            if ($Global:Icinga.Protected.Environment.'Icinga Service'.Present -eq $FALSE) {
                Write-IcingaConsoleDebug -Message 'Trying to update user for service "icinga2" while the service is not installed yet';
                return $FALSE;
            }
            break;
        };
        'icingapowershell' {
            if ($Global:Icinga.Protected.Environment.'PowerShell Service'.Present -eq $FALSE) {
                Write-IcingaConsoleDebug -Message 'Trying to update user for service "icingapowershell" while the service is not installed yet';
                return $FALSE;
            }
            break;
        };
        default {
            if ($null -eq (Get-Service $Service -ErrorAction SilentlyContinue)) {
                return $FALSE;
            }
        };
    }

    if ($User.Contains('@')) {
        $UserData = $User.Split('@');
        $User     = [string]::Format('{0}\{1}', $UserData[1], $UserData[0]);
    } elseif ($User.Contains('\') -eq $FALSE) {
        $User = [string]::Format('.\{0}', $User);
    }

    $ArgString = 'config {0} obj= "{1}" password= "{2}"';
    if ($null -eq $Password) {
        $ArgString = 'config {0} obj= "{1}"{2}';
    }

    $Output = Start-IcingaProcess `
        -Executable 'sc.exe' `
        -Arguments ([string]::Format($ArgString, $Service, $User, (ConvertFrom-IcingaSecureString $Password))) `
        -FlushNewLines $TRUE;

    if ($Output.ExitCode -eq 0) {

        switch ($Service.ToLower()) {
            'icinga2' {
                $Global:Icinga.Protected.Environment.'Icinga Service'.User = $User;
                break;
            };
            'icingapowershell' {
                $Global:Icinga.Protected.Environment.'PowerShell Service'.User = $User;
                break;
            };
        }

        if ($SetPermission) {
            Set-IcingaAgentServicePermission | Out-Null;
            Set-IcingaUserPermissions -IcingaUser $User;
        }

        Write-IcingaConsoleNotice 'Service User "{0}" for service "{1}" successfully updated' -Objects $User, $Service;
        return $TRUE;
    } else {
        Write-IcingaConsoleError ([string]::Format('Failed to update the service user: {0}', $Output.Message));
        return $FALSE;
    }
}

Set-Alias -Name 'Set-IcingaAgentServiceUser' -Value 'Set-IcingaServiceUser';
