function Get-IcingaForWindowsManagementConsoleAlias()
{
    param (
        [string]$Command
    );

    if ([string]::IsNullOrEmpty($Command)) {
        return '';
    }

    $ParentEntry = $null;

    if ($Command.Contains(':')) {
        $KeyValue    = $Command.Split(':');
        $Command     = $KeyValue[0];
        $ParentEntry = $KeyValue[1];
    }

    $CommandAlias = Get-Alias -Definition $Command -ErrorAction SilentlyContinue;

    if ($null -ne $CommandAlias) {
        $Command = $CommandAlias.Name;
    }

    if ([string]::IsNullOrEmpty($ParentEntry) -eq $FALSE) {
        $Command = [string]::Format('{0}:{1}', $Command, $ParentEntry);
    }

    return $Command;
}
