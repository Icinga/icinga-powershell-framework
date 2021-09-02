function New-IcingaThreadInstance()
{
    param (
        [string]$Name,
        $ThreadPool,
        [ScriptBlock]$ScriptBlock,
        [string]$Command,
        [hashtable]$CmdParameters,
        [array]$Arguments,
        [Switch]$Start
    );

    if ([string]::IsNullOrEmpty($Name)) {
        $Name = New-IcingaThreadHash -ShellScript $ScriptBlock -Arguments $Arguments;
    }

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Creating new thread instance {0}{1}Arguments:{1}{2}',
            $Name,
            "`r`n",
            ($Arguments | Out-String)
        )
    );

    $Shell              = [PowerShell]::Create();
    $Shell.RunSpacePool = $ThreadPool;
    [string]$CodeHash   = '';

    if ([string]::IsNullOrEmpty($Command) -eq $FALSE) {

        [void]$Shell.AddCommand('Use-Icinga');
        [void]$Shell.AddParameter('-LibOnly', $TRUE);
        [void]$Shell.AddParameter('-Daemon', $TRUE);

        [void]$Shell.AddCommand($Command);

        $CodeHash = $Command;

        foreach ($cmd in $CmdParameters.Keys) {
            $Value = $CmdParameters[$cmd];

            Write-IcingaDebugMessage -Message 'Adding new argument to thread command' -Objects $cmd, $value, $Command;

            [void]$Shell.AddParameter($cmd, $value);

            $Arguments += $cmd;
            $Arguments += $value;
        }
    }

    if ($null -ne $ScriptBlock) {
        Write-IcingaDeprecated -Function 'New-IcingaThreadInstance' -Argument 'ScriptBlock';
        $CodeHash = $ScriptBlock;

        [void]$Shell.AddScript($ScriptBlock);
        foreach ($argument in $Arguments) {
            [void]$Shell.AddArgument($argument);
        }
    }

    $Thread = New-Object PSObject;
    Add-Member -InputObject $Thread -MemberType NoteProperty -Name Shell -Value $Shell;

    if ($Start) {
        Write-IcingaDebugMessage -Message 'Starting shell instance' -Objects $Command, $Shell, $Thread;
        try {
            $ShellData = $Shell.BeginInvoke();
        } catch {
            Write-IcingaDebugMessage -Message 'Failed to start Icinga thread instance' -Objects $Command, $_.Exception.Message;
        }
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Handle -Value ($ShellData);
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Started -Value $TRUE;
    } else {
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Handle -Value $null;
        Add-Member -InputObject $Thread -MemberType NoteProperty -Name Started -Value $FALSE;
    }

    if ($global:IcingaDaemonData.IcingaThreads.ContainsKey($Name) -eq $FALSE) {
        $global:IcingaDaemonData.IcingaThreads.Add($Name, $Thread);
    } else {
        $global:IcingaDaemonData.IcingaThreads.Add(
            (New-IcingaThreadHash -ShellScript $CodeHash -Arguments $Arguments),
            $Thread
        );
    }
}
