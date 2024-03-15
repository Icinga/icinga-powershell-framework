function Deny-IcingaJEACommand()
{
    param (
        [string]$Command      = $null,
        [string]$FileComments = $null
    );

    if ([string]::IsNullOrEmpty($Command) -eq $FALSE) {
        # Ensure certain commands are not added to the JEA profile
        switch ($Command.ToLower()) {
            'Register-ScheduledTask'.ToLower() {
                return $TRUE;
            };
            'Start-ScheduledTask'.ToLower() {
                return $TRUE;
            };
            'Unregister-ScheduledTask'.ToLower() {
                return $TRUE;
            };
            'New-ScheduledTaskAction'.ToLower() {
                return $TRUE;
            };
            'Invoke-IcingaWindowsScheduledTask'.ToLower() {
                return $TRUE;
            };
            'Start-IcingaWindowsScheduledTaskRenewCertificate'.ToLower() {
                return $TRUE;
            };
            'Register-IcingaWindowsScheduledTaskRenewCertificate'.ToLower() {
                return $TRUE;
            };
            'Stop-Process'.ToLower() {
                return $TRUE;
            };
            'Remove-EventLog'.ToLower() {
                return $TRUE;
            };
            'Unregister-IcingaEventLog'.ToLower() {
                return $TRUE;
            };
            'Remove-Item'.ToLower() {
                return $TRUE;
            };
            'Remove-ItemSecure'.ToLower() {
                return $TRUE;
            };
            'Stop-Service'.ToLower() {
                return $TRUE;
            };
            'Restart-Service'.ToLower() {
                return $TRUE;
            };
            'Copy-ItemSecure'.ToLower() {
                return $TRUE;
            };
            'Copy-Item'.ToLower() {
                return $TRUE;
            };
            'Move-Item'.ToLower() {
                return $TRUE;
            };
            'Restart-IcingaService'.ToLower() {
                return $TRUE;
            };
            'Restart-IcingaForWindows'.ToLower() {
                return $TRUE;
            };
            'Stop-IcingaWindowsService'.ToLower() {
                return $TRUE;
            };
            'Stop-IcingaService'.ToLower() {
                return $TRUE;
            };
            'Restart-IcingaService'.ToLower() {
                return $TRUE;
            };
            'Restart-IcingaForWindows'.ToLower() {
                return $TRUE;
            };
            'Remove-IcingaPowerShellConfig'.ToLower() {
                return $TRUE;
            };
            'Add-Content'.ToLower() {
                return $TRUE;
            };
        }
    }

    if ([string]::IsNullOrEmpty($FileComments) -eq $FALSE) {
        if ($FileComments.ToLower().Contains('ignorejea')) {
            return $TRUE;
        }
    }

    return $FALSE;
}
