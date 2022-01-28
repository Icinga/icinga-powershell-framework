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

    $CallStack     = Get-PSCallStack;
    $SourceCommand = $CallStack[1].Command;

    if ([string]::IsNullOrEmpty($Name)) {
        $Name = New-IcingaThreadHash -ShellScript $ScriptBlock -Arguments $Arguments;
    }

    $ThreadName = [string]::Format('{0}::{1}::{2}::0', $SourceCommand, $Command, $Name);

    Write-IcingaDebugMessage -Message (
        [string]::Format(
            'Creating new thread instance {0}{1}Arguments:{1}{2}',
            $ThreadName,
            "`r`n",
            ($Arguments | Out-String)
        )
    );

    $Shell              = [PowerShell]::Create();
    $Shell.RunSpacePool = $ThreadPool;
    [string]$CodeHash   = '';

    if ([string]::IsNullOrEmpty($Command) -eq $FALSE) {

        # Initialize the Icinga for Windows environment in each thread
        [void]$Shell.AddCommand('Use-Icinga');
        [void]$Shell.AddParameter('-LibOnly', $TRUE);
        [void]$Shell.AddParameter('-Daemon', $TRUE);

        # Share our public data between all threads
        if ($null -ne $Global:Icinga -And $Global:Icinga.ContainsKey('Public')) {
            [void]$Shell.AddCommand('Set-IcingaEnvironmentGlobal');
            [void]$Shell.AddParameter('GlobalEnvironment', $Global:Icinga.Public);
        }

        # Set the JEA context for all threads
        if ($null -ne $Global:Icinga -And $Global:Icinga.ContainsKey('Protected') -And $Global:Icinga.Protected.ContainsKey('JEAContext')) {
            [void]$Shell.AddCommand('Set-IcingaEnvironmentJEA');
            [void]$Shell.AddParameter('JeaEnabled', $Global:Icinga.Protected.JEAContext);
        }

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

    [int]$ThreadIndex = 0;

    while ($TRUE) {

        if ($Global:Icinga.Public.Threads.ContainsKey($ThreadName) -eq $FALSE) {
            $Global:Icinga.Public.Threads.Add($ThreadName, $Thread);
            break;
        }

        $ThreadIndex += 1;
        $ThreadName   = [string]::Format('{0}::{1}::{2}::{3}', $SourceCommand, $Command, $Name, $ThreadIndex);
    }
}
