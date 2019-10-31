function Set-IcingaAgentServiceUser()
{
    param(
        [string]$User,
        [securestring]$Password,
        [string]$Service        = 'icinga2'
    );

    if ([string]::IsNullOrEmpty($User)) {
        throw 'Please specify a username to modify the service user';
        return $FALSE;
    }

    if ($User.Contains('\') -eq $FALSE) {
        $User = [string]::Format('.\{0}', $User);
    }

    $ArgString = 'config {0} obj= "{1}" password="{2}"';
    if($null -eq $Password) {
        $ArgString = 'config {0} obj= "{1}"{2}';
    }

    $Output = Start-IcingaProcess `
        -Executable 'sc.exe' `
        -Arguments ([string]::Format($ArgString, $Service, $User, (ConvertFrom-IcingaSecureString $Password))) `
        -FlushNewLines $TRUE;

    if ($Output.ExitCode -eq 0) {
        Write-Host 'Service User successfully updated'
        return $TRUE;
    } else {
        Write-Host ([string]::Format('Failed to update the service user: {0}', $Output.Message));
        return $FALSE;
    }
}
