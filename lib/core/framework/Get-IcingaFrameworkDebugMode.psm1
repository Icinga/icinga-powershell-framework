function Get-IcingaFrameworkDebugMode()
{
    $DebugMode = Get-IcingaPowerShellConfig -Path 'Framework.DebugMode';
    
    if ($null -eq $DebugMode) {
        return $FALSE;
    }

    return $DebugMode;
}
