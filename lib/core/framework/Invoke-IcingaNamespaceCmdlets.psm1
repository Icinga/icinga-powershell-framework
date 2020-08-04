function Invoke-IcingaNamespaceCmdlets()
{
    param (
        [string]$Command
    );

    [Hashtable]$CommandConfig = @{};

    if ($Command.Contains('*') -eq $FALSE) {
        $Command = [string]::Format('{0}*', $Command);
    }

    $CommandList = Get-Command $Command;

    foreach ($Cmdlet in $CommandList) {
        try {
            $CmmandName = $Cmdlet.Name;
            Import-Module $Cmdlet.Module.Path -WarningAction SilentlyContinue -ErrorAction Stop;

            $Content = (& $CmmandName);
            Add-IcingaHashtableItem `
                -Hashtable $CommandConfig `
                -Key $Cmdlet.Name `
                -Value $Content | Out-Null;
        } catch {
            # TODO: Add event log logging on exceptions
        }
    }

    return $CommandConfig;
}
