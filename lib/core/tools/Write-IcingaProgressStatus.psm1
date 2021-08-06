function Write-IcingaProgressStatus()
{
    param (
        [int]$CurrentValue = 0,
        [int]$MaxValue     = 1,
        [string]$Message   = 'Processing Icinga for Windows',
        [string]$Status    = "{0}% Complete",
        [switch]$Details   = $FALSE
    );

    if ($CurrentValue -le -99) {
        $CurrentValue = 0;
        return;
    }

    if ($MaxValue -le 0) {
        $MaxValue = 1;
    }

    $ProgressValue = [math]::Round($CurrentValue / $MaxValue * 100, 0);

    if ($Details) {
        $Message = [string]::Format('{0}: {1}/{2}', $Message, $CurrentValue, $MaxValue);
    }

    $ProgressPreference = 'Continue';

    if ($ProgressValue -ge 100) {
        $ProgressValue = 100;
        Write-Progress -Activity $Message -Status ([string]::Format($Status, $ProgressValue)) -PercentComplete $ProgressValue -Completed;
        $CurrentValue = -99;

        return $CurrentValue;
    }

    Write-Progress -Activity $Message -Status ([string]::Format($Status, $ProgressValue)) -PercentComplete $ProgressValue;

    return ($CurrentValue += 1);
}
