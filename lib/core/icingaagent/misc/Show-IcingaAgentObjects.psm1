function Show-IcingaAgentObjects()
{
    $Binary = Get-IcingaAgentBinary;
    $Output = Start-IcingaProcess -Executable $Binary -Arguments 'object list';

    if ($Output.ExitCode -ne 0) {
        Write-Host ([string]::Format('Failed to fetch Icinga Agent objects list: {0}{1}', $Output.Message, $Output.Error));
        return $null;
    }

    return $Output.Message;
}
