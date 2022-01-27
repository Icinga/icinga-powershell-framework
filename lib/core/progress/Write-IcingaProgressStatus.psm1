function Write-IcingaProgressStatus()
{
    param (
        [string]$Name        = '',
        [int]$AddValue       = 1,
        [switch]$PrintErrors = $FALSE
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError -Message 'Failed to write progress status. You have to specify a name.' -DropMessage:$(-Not $PrintErrors);
        return;
    }

    if ($Global:Icinga.Private.ProgressStatus.ContainsKey($Name) -eq $FALSE) {
        Write-IcingaConsoleError -Message 'Failed to write progress status. A progress status with the name "{0}" does not exist. You have to create it first with "New-IcingaProgressStatus".' -Objects $Name -DropMessage:$(-Not $PrintErrors);
        return;
    }

    $Global:Icinga.Private.ProgressStatus[$Name].CurrentValue += $AddValue;

    $ProgressValue = [math]::Round($Global:Icinga.Private.ProgressStatus[$Name].CurrentValue / $Global:Icinga.Private.ProgressStatus[$Name].MaxValue * 100, 0);

    if ($Global:Icinga.Private.ProgressStatus[$Name].Details) {
        $Message = [string]::Format('{0}: {1}/{2}', $Global:Icinga.Private.ProgressStatus[$Name].Message, $Global:Icinga.Private.ProgressStatus[$Name].CurrentValue, $Global:Icinga.Private.ProgressStatus[$Name].MaxValue);
    } else {
        $Message = $Global:Icinga.Private.ProgressStatus[$Name].Message;
    }

    if ($ProgressValue -ge 100) {
        Complete-IcingaProgressStatus -Name $Name;
        return;
    }

    $ProgressPreference = 'Continue';

    Write-Progress -Activity $Message -Status ([string]::Format($Global:Icinga.Private.ProgressStatus[$Name].Status, $ProgressValue)) -PercentComplete $ProgressValue;
}
