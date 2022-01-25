function Invoke-IcingaNamespaceCmdlets()
{
    param (
        [string]$Command
    );

    [Hashtable]$CommandConfig = @{ };

    if ($Command.Contains('*') -eq $FALSE) {
        $Command = [string]::Format('{0}*', $Command);
    }

    $CommandList = Get-Command $Command;

    foreach ($Cmdlet in $CommandList) {
        try {
            $CommandName = $Cmdlet.Name;
            $Content     = (& $CommandName);

            Add-IcingaHashtableItem `
                -Hashtable $CommandConfig `
                -Key $Cmdlet.Name `
                -Value $Content | Out-Null;
        } catch {
            Write-IcingaEventMessage -EventId 1103 -Namespace 'Framework' -ExceptionObject $_ -Objects $CommandName;
        }
    }

    return $CommandConfig;
}
