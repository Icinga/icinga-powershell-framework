function Set-IcingaServiceUser()
{
    param (
        [string]$User,
        [securestring]$Password,
        [string]$Service        = 'icinga2',
        [switch]$SetPermission
    );

    if ([string]::IsNullOrEmpty($User)) {
        Write-IcingaConsoleError -Message 'Please specify a username to modify the service user';
        return $FALSE;
    }

    if ($null -eq (Get-Service $Service -ErrorAction SilentlyContinue)) {
        return $FALSE;
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

        if ($SetPermission) {
            Set-IcingaAgentServicePermission | Out-Null;
            Set-IcingaUserPermissions;
        }

        Write-IcingaConsoleNotice 'Service User "{0}" for service "{1}" successfully updated' -Objects $User, $Service;
        return $TRUE;
    } else {
        Write-IcingaConsoleError ([string]::Format('Failed to update the service user: {0}', $Output.Message));
        return $FALSE;
    }
}

Set-Alias -Name 'Set-IcingaAgentServiceUser' -Value 'Set-IcingaServiceUser';
