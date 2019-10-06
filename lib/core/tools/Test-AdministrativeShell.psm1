function Test-AdministrativeShell()
{
    $WindowsPrincipcal = New-Object System.Security.Principal.WindowsPrincipal(
        [System.Security.Principal.WindowsIdentity]::GetCurrent()
    );

    if ($WindowsPrincipcal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $TRUE;
    }
    return $FALSE;
}
