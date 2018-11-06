$AdminShell = New-Object -TypeName PSObject;
$AdminShell | Add-Member -membertype ScriptMethod -name 'IsAdminShell' -value {
    $CurrentIdentity  = [System.Security.Principal.WindowsIdentity]::GetCurrent();
    $WindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($CurrentIdentity);

    if (-Not $WindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
        return $FALSE;
    }
    return $TRUE;
}

return $AdminShell;