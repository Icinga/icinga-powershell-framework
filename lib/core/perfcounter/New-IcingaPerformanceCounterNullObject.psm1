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
     $pc_instance | Add-Member -membertype NoteProperty -name 'FullName'     -value $FullName;
     $pc_instance | Add-Member -membertype NoteProperty -name 'ErrorMessage' -value $ErrorMessage;

     $pc_instance | Add-Member -membertype ScriptMethod -name 'Name' -value {
         return $this.FullName;
     }

     $pc_instance | Add-Member -membertype ScriptMethod -name 'Value' -value {
         [hashtable]$ErrorMessage = @{};

         $ErrorMessage.Add('value',  $null);
         $ErrorMessage.Add('sample', $null);
         $ErrorMessage.Add('help',   $null);
         $ErrorMessage.Add('type',   $null);
         $ErrorMessage.Add('error',  $this.ErrorMessage);

         return $ErrorMessage;
     }

     return $pc_instance;
 }
 