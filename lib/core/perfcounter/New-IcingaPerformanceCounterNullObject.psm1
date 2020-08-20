<#
.SYNOPSIS
    This will create a Performance Counter object in case a counter instance
    does not exis, but still returning default members to allow us to smoothly
    execute our code
.DESCRIPTION
    This will create a Performance Counter object in case a counter instance
    does not exis, but still returning default members to allow us to smoothly
    execute our code
.FUNCTIONALITY
    This will create a Performance Counter object in case a counter instance
    does not exis, but still returning default members to allow us to smoothly
    execute our code
.EXAMPLE
    PS>New-IcingaPerformanceCounterNullObject '\Processor(20)\%processor time' -ErrorMessage 'This counter with instance 20 does not exist';

    FullName                       ErrorMessage
    --------                       ------------
    \Processor(20)\%processor time This counter with instance 20 does not exist
.PARAMETER FullName
    The full path/name of the Performance Counter which does not exist
.PARAMETER ErrorMessage
    The error message which is included within the 'error' member of the Performance Counter
.INPUTS
    System.String
.OUTPUTS
    System.PSObject
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterNullObject()
{
    param(
        [string]$FullName     = '',
        [string]$ErrorMessage = ''
    );

    $pc_instance = New-Object -TypeName PSObject;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'FullName'     -Value $FullName;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'ErrorMessage' -Value $ErrorMessage;

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Name' -Value {
        return $this.FullName;
    }

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Value' -Value {
        [hashtable]$ErrorMessage = @{};

        $ErrorMessage.Add('value', $null);
        $ErrorMessage.Add('sample', $null);
        $ErrorMessage.Add('help', $null);
        $ErrorMessage.Add('type', $null);
        $ErrorMessage.Add('error', $this.ErrorMessage);

        return $ErrorMessage;
    }

    return $pc_instance;
}
