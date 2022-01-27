function New-IcingaProgressStatus()
{
    param (
        [string]$Name      = '',
        [int]$CurrentValue = 0,
        [int]$MaxValue     = 1,
        [string]$Message   = 'Processing Icinga for Windows',
        [string]$Status    = '{0}% Complete',
        [switch]$Details   = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError -Message 'Failed to create new progress status. You have to specify a name.';
        return;
    }

    if ($MaxValue -le 0) {
        Write-IcingaConsoleError -Message 'Failed to create new progress status. The maximum value has to be larger than 0.';
        return;
    }

    if ($Global:Icinga.Private.ProgressStatus.ContainsKey($Name)) {
        Write-IcingaConsoleError -Message 'Failed to create new progress status. A progress status with this name is already active. Use "Complete-IcingaProgressStatus" to remove it.';
        return;
    }

    $Global:Icinga.Private.ProgressStatus.Add(
        $Name,
        @{
            'CurrentValue' = $CurrentValue;
            'MaxValue'     = $MaxValue;
            'Message'      = $Message;
            'Status'       = $Status;
            'Details'      = ([bool]$Details);
        }
    );

    $ProgressPreference = 'Continue';
}
