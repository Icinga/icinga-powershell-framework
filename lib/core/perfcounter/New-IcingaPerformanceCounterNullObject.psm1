<#
 # If some informations are missing, it could happen that
 # we are unable to create a Performance Counter.
 # In this case we will use this Null Object, containing
 # the same member functions but allowing us to maintain
 # stability without unwanted exceptions
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
