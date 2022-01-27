function Complete-IcingaProgressStatus()
{
    param (
        [string]$Name = ''
    );

    if ([string]::IsNullOrEmpty($Name)) {
        Write-IcingaConsoleError -Message 'Failed to complete progress status. You have to specify a name.';
        return;
    }

    if ($Global:Icinga.Private.ProgressStatus.ContainsKey($Name) -eq $FALSE) {
        return;
    }

    if ($Global:Icinga.Private.ProgressStatus[$Name].Details) {
        $Message = [string]::Format('{0}: {1}/{2}', $Global:Icinga.Private.ProgressStatus[$Name].Message, $Global:Icinga.Private.ProgressStatus[$Name].MaxValue, $Global:Icinga.Private.ProgressStatus[$Name].MaxValue);
    } else {
        $Message = $Global:Icinga.Private.ProgressStatus[$Name].Message;
    }

    $ProgressPreference = 'Continue';
    Write-Progress -Activity $Message -Status ([string]::Format($Global:Icinga.Private.ProgressStatus[$Name].Status, 100)) -PercentComplete 100 -Completed;

    $Global:Icinga.Private.ProgressStatus.Remove($Name);

    $ProgressPreference = 'SilentlyContinue';
}
