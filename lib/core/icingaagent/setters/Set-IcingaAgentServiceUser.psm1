function Set-IcingaAgentServiceUser()
{
    param(
        [string]$User,
        [securestring]$Password
    );

    if ([string]::IsNullOrEmpty($User)) {
        throw 'Please specify a username to modify the service user';
        return $FALSE;
    }

    $ArgString = 'config icinga2 obj= "{0}" password="{1}"';
    if($null -eq $Password) {
        $ArgString = 'config icinga2 obj= "{0}"{1}';
    }

    $Output = Start-IcingaProcess `
        -Executable 'sc.exe' `
        -Arguments ([string]::Format($ArgString, $User, (ConvertFrom-IcingaSecureString $Password))) `
        -FlushNewLines $TRUE;

    if ($Output.ExitCode -eq 0) {
        Write-Host 'Service User successfully updated'
        return $TRUE;
    } else {
        Write-Host ([string]::Format('Failed to update the service user: {0}', $Output.Message));
        return $FALSE;
    }
}
