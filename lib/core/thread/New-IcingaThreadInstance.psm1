function New-IcingaThreadInstance()
{
    param(
        [string]$Name,
        $ThreadPool,
        [ScriptBlock]$ScriptBlock,
        [array]$Arguments,
        [Switch]$Start
    );

    if ([string]::IsNullOrEmpty($Name)) {
        $Name = New-IcingaThreadHash -ShellScript $ScriptBlock -Arguments $Arguments;
    }

    $Shell = [PowerShell]::Create();
    $Shell.RunspacePool = $ThreadPool;
    [void]$Shell.AddScript($ScriptBlock);
    foreach ($argument in $Arguments) {
        [void]$Shell.AddArgument($argument);
    }

    $Thread = New-Object PSObject;
    Add-Member -InputObject $Thread -MemberType NoteProperty -Name Shell -Value $Shell;
    if ($Start) {
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Handle -Value ($Shell.BeginInvoke());
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Started -Value $TRUE;
    } else {
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Handle -Value $null;
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Started -Value $FALSE;
    }
    
    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Name) -eq $FALSE) {
        $global:IcingaDaemonData.IcingaThreads.Add($Name, $Thread);
    } else {
        $global:IcingaDaemonData.IcingaThreads.Add(
            (New-IcingaThreadHash -ShellScript $ScriptBlock -Arguments $Arguments),
            $Thread
        );
    }
}
