<#
.SYNOPSIS
    Creates a new Performance Counter object based on given input filters.
    Returns a PSObject with custom members to access the data of the counter
.DESCRIPTION
    Creates a new Performance Counter object based on given input filters.
    Returns a PSObject with custom members to access the data of the counter
.FUNCTIONALITY
    Creates a new Performance Counter object based on given input filters.
    Returns a PSObject with custom members to access the data of the counter
.EXAMPLE
    PS>New-IcingaPerformanceCounterObject -FullName '\Processor(*)\% processor time' -Category 'Processor' -Instance '*' -Counter '% processor time';

    Category    : Processor
    Instance    : *
    Counter     : % processor time
    PerfCounter : System.Diagnostics.PerformanceCounter
    SkipWait    : False
.EXAMPLE
    PS>New-IcingaPerformanceCounterObject -FullName '\Processor(*)\% processor time' -Category 'Processor' -Instance '*' -Counter '% processor time' -SkipWait;

    Category    : Processor
    Instance    : *
    Counter     : % processor time
    PerfCounter : System.Diagnostics.PerformanceCounter
    SkipWait    : True
.PARAMETER FullName
    The full path to the Performance Counter
.PARAMETER Category
    The name of the category of the Performance Counter
.PARAMETER Instance
    The instance of the Performance Counter
.PARAMETER Counter
    The actual name of the counter to fetch
.PARAMETER SkipWait
    Set this if no sleep is intended for initialising the counter. This can be useful
    if multiple counters are fetched during one call with this function if the sleep
    is done afterwards manually. A sleep is set to 500ms to ensure counter data is
    valid and contains an offset from previous/current values
.INPUTS
    System.String
.OUTPUTS
    System.PSObject
.LINK
   https://github.com/Icinga/icinga-powershell-framework
#>

function New-IcingaPerformanceCounterObject()
{
    param(
        [string]$FullName  = '',
        [string]$Category  = '',
        [string]$Instance  = '',
        [string]$Counter   = '',
        [boolean]$SkipWait = $FALSE
    );

    $pc_instance = New-Object -TypeName PSObject;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'FullName'    -Value $FullName;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'Category'    -Value $Category;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'Instance'    -Value $Instance;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'Counter'     -Value $Counter;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'PerfCounter' -Value $Counter;
    $pc_instance | Add-Member -MemberType NoteProperty -Name 'SkipWait'    -Value $SkipWait;

    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Init' -Value {

        Write-IcingaConsoleDebug `
            -Message 'Creating new Counter for Category "{0}" with Instance "{1}" and Counter "{2}". Full Name "{3}"' `
            -Objects $this.Category, $this.Instance, $this.Counter, $this.FullName;

        # Create the Performance Counter object we want to access
        $this.PerfCounter              = New-Object System.Diagnostics.PerformanceCounter;
        $this.PerfCounter.CategoryName = $this.Category;
        $this.PerfCounter.CounterName  = $this.Counter;

        # Only add an instance in case it is defined
        if ([string]::IsNullOrEmpty($this.Instance) -eq $FALSE) {
            $this.PerfCounter.InstanceName = $this.Instance
        }

        # Initialise the counter
        try {
            $this.PerfCounter.NextValue() | Out-Null;
        } catch {
            # Nothing to do here, will be handled later
        }

        <#
        # For some counters we require to wait a small amount of time to receive proper data
        # Other counters do not need these informations and we do also not require to wait
        # for every counter we use, once the counter is initialised within our environment.
        # This will allow us to skip the sleep to speed up loading counters
        #>
        if ($this.SkipWait -eq $FALSE) {
            Start-Sleep -Milliseconds 500;
        }
    }

    # Return the name of the counter as string
    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Name' -Value {
        return $this.FullName;
    }

    <#
    # Return a hashtable containing the counter value including the
    # Sample values for the counter itself. In case we run into an error,
    # keep the counter construct but add an error message in addition.
    #>
    $pc_instance | Add-Member -MemberType ScriptMethod -Name 'Value' -Value {
        [hashtable]$CounterData = @{ };

        try {
            [string]$CounterType = $this.PerfCounter.CounterType;
            $CounterData.Add('value', ([math]::Round([decimal]$this.PerfCounter.NextValue(), 6)));
            $CounterData.Add('sample', $this.PerfCounter.NextSample());
            $CounterData.Add('help', $this.PerfCounter.CounterHelp);
            $CounterData.Add('type', $CounterType);
            $CounterData.Add('error', $null);
        } catch {
            $CounterData = @{ };
            $CounterData.Add('value', $null);
            $CounterData.Add('sample', $null);
            $CounterData.Add('help', $null);
            $CounterData.Add('type', $null);
            $CounterData.Add('error', $_.Exception.Message);
        }

        return $CounterData;
    }

    # Initialise the entire counter and internal handlers
    $pc_instance.Init();

    # Return this custom object
    return $pc_instance;
}
