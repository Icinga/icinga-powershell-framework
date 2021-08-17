function Test-IcingaForWindowsService()
{
    param (
        [switch]$ResolveProblems = $FALSE
    );

    $ServiceData   = Get-IcingaForWindowsServiceData;
    $ServiceConfig = (Get-IcingaServices -Service 'icingapowershell').icingapowershell.configuration;
    [bool]$Passed  = $TRUE;

    if ($null -eq $ServiceConfig) {
        Write-IcingaConsoleNotice 'Icinga for Windows service "icingapowershell" is not installed';
        return $Passed;
    }

    [string]$PreparedServicePath = [string]::Format(
        '\"{0}\" \"{1}\"',
        $ServiceData.FullPath,
        (Get-IcingaPowerShellModuleFile)
    );
    [string]$ServicePath         = $ServiceConfig.ServicePath.SubString(0, $ServiceConfig.ServicePath.IndexOf(' "'));

    if ($ServicePath.Contains('"')) {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'Your service installation is not affected by IWKB000009';
    } else {
        if ($ResolveProblems) {
            Write-IcingaTestOutput -Severity 'Warning' -Message 'Your service installation is affected by IWKB000009. Trying to resolve the problem.';
            $ResolveStatus = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('config icingapowershell binPath= "{0}"', $PreparedServicePath));

            if ($ResolveStatus.ExitCode -ne 0) {
                Write-IcingaConsoleError 'Failed to resolve problems for service "icingapowershell": {0}{1}' -Objects $ResolveStatus.Message, $ResolveStatus.Error;
                $Passed = $FALSE;
            } else {
                Write-IcingaTestOutput -Severity 'Passed' -Message 'Your service installation is no longer affected by IWKB000009';
            }
        } else {
            Write-IcingaTestOutput -Severity 'Failed' -Message 'Your service installation is affected by IWKB000009. Please have a look on https://icinga.com/docs/icinga-for-windows/latest/doc/knowledgebase/IWKB000009/ for further details. Run this Cmdlet with "-ResolveProblems" to fix it';
            $Passed = $FALSE;
        }
    }

    if ($ServiceConfig.ServicePath.Contains('.psm1')) {
        if ($ResolveProblems) {
            Write-IcingaTestOutput -Severity 'Warning' -Message 'Your service installation is referring to "icinga-powershell-framework.psm1" for module imports. Trying to resolve the problem.';
            $ResolveStatus = Start-IcingaProcess -Executable 'sc.exe' -Arguments ([string]::Format('config icingapowershell binPath= "{0}"', $PreparedServicePath));

            if ($ResolveStatus.ExitCode -ne 0) {
                Write-IcingaConsoleError 'Failed to resolve problems for service "icingapowershell": {0}{1}' -Objects $ResolveStatus.Message, $ResolveStatus.Error;
                $Passed = $FALSE;
            } else {
                Write-IcingaTestOutput -Severity 'Passed' -Message 'Your service installation is now properly referring to "icinga-powershell-framework.psd1" for module imports.';
            }
        } else {
            Write-IcingaTestOutput -Severity 'Failed' -Message 'Your service installation is referring "icinga-powershell-framework.psm1". This is deprecated and has to be changed to "icinga-powershell-framework.psd1". Run this Cmdlet with "-ResolveProblems" to fix it.';
            $Passed = $FALSE;
        }
    } else {
        Write-IcingaTestOutput -Severity 'Passed' -Message 'Your service installation is properly referring to "icinga-powershell-framework.psd1" for module imports.';
    }

    return $Passed;
}
