Developer Guide: Custom Daemons
===

By [installing the PowerShell Framework as service](../service/01-Install-Service.md) you have the possibility to [register custom daemons](../service/02-Register-Daemons.md) which are executed in the background. This developer guide article will assist you in creating custom daemons.

Creating A New Module
---

The best approach for creating a custom daemon is by creating an independent module which is installed in your PowerShell modules directly. This will ensure you are not overwriting your custom data with possible framework updates.

In this guide, we will assume the name of the module is `icinga-powershell-agentservice`.

At first we will have to create a new module. Navigate to the PowerShell modules folder the Framework itself is installed to. In this tutorial we will assume the location is

```powershell
C:\Program Files\WindowsPowerShell\Modules
```

Now create a new folder with the name `icinga-powershell-agentservice` and navigate into it.

As we require a `psm1` file which contains our code, we will create a new file with the name `icinga-powershell-agentservice.psm1`. This will allow the PowerShell autoloader to load the module automaticly.

**Note:** It could be possible, depending on your [execution policies](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6), that your module is not loaded properly. If this is the case, you can try to unblock the file by opening a PowerShell and use the `Unblock-File` Cmdelet

```powershell
Unblock-File -Path 'C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-agentservice\icinga-powershell-agentservice.psm1'
```

Testing The Module
---

Once the modules files are created and unblocked, we can start testing if the autoloader is properly working and our module is detected.

For this open the file `icinga-powershell-agentservice.psm1` in your prefered editor and add the following code snippet

```powershell
function Test-MyIcingaAgentServiceCommand()
{
    Write-Host 'Module was loaded';
}
```

Now open a **new** PowerShell terminal or write `powershell` into an already open PowerShell prompt and execute the command `Test-MyIcingaAgentServiceCommand`.

If everything went properly, you should now read the output `Module was loaded` in our prompt. If not, you can try to import the module by using

```powershell
Import-Module 'C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-agentservice\icinga-powershell-agentservice.psm1';
```

inside your console prompt. After that try again to execute the command `Test-MyIcingaAgentServiceCommand` and check if it works this time. If not, you might check the naming of your module to ensure `folder name` and `.psm1 file name` is identical.

Create A New function
---

Once everything is working properly we can create our starting function we will later use for [registering our daemon](../service/02-Register-Daemons.md).

For naming guidelines we will have to begin with the `Start` naming and an identifier of what are going to achieve with our daemon. In our example we will frequently check if the Icinga 2 agent service is active and running. In case it failed, we will restart the service.

So lets get started with the function

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our code belongs here
}
```

Basic Daemon Architecture
---

A basic daemon contains of two parts. At first we require a `ScriptBlock` with our code to execute and second a `new thread` we can create with the Cmdlet `New-IcingaThreadInstance`.

Each daemon must spawn within an own thread to ensure we are not blocking the execution of other deamons and interfere with the framework loader.

Writing Our ScriptBlock
---

As we start a new thread, we will require at first a variable to contain our actual code we wish to execute inside the thread. This can be done by using `ScriptBlocks`.

At first we will create a variable inside our `Start-IcingaAgentServiceTest` function.

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our ScriptBlock for the code being executed inside the thread
    [ScriptBlock]$IcingaServiceTest = {
        # Everything which will be executed inside the thread
        # belongs here
    };
}
```

Depending on our daemon, later usage and possible sharing of data between all loaded daemons might be required. In addition we might want to spawn child threads as single tasks being executed. To do so, we will parse the frameworks `global` data to the thread.

Our recommendation is to always do this for every daemon, as later changes might be more complicated and time consuming.

To be able to parse an argument to your script block, we will use the `param` argument.

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our ScriptBlock for the code being executed inside the thread
    [ScriptBlock]$IcingaServiceTest = {
        # Allow us to parse the framework global data to this thread
        param($IcingaDaemonData);

        # Everything which will be executed inside the thread
        # belongs here
    };
}
```

Now as the basic part is finished, we will require to make our framework libraries aavailable within this thread. To do so, we will initialse the framework with the `Use-Icinga` Cmdlet, do however only import libraries and tell the framework that the wish to utilize it as `daemon`. The last part is important, as this will change the handling for writing console outputs and instead of an `exit` for certain failures the module will log them internally.

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our ScriptBlock for the code being executed inside the thread
    [ScriptBlock]$IcingaServiceTest = {
        # Allow us to parse the framework global data to this thread
        param($IcingaDaemonData);

        # Import the framework library components and initialise it
        # as daemon
        Use-Icinga -LibOnly -Daemon;
    };
}
```

As we will parse the `global` framework data anyways, we should already make use of it. In this case, we will write the current service state of Icinga 2 into a global `synchronized` hashtable. Before we can do this, we will have to add a new hashtable to our background daemons

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our ScriptBlock for the code being executed inside the thread
    [ScriptBlock]$IcingaServiceTest = {
        # Allow us to parse the framework global data to this thread
        param($IcingaDaemonData);

        # Import the framework library components and initialise it
        # as daemon
        Use-Icinga -LibOnly -Daemon;

        # Add a synchronized hashtable to the global data background
        # daemon hashtable to write data to. In addition it will
        # allow to share data collected from this daemon with others
        $IcingaDaemonData.BackgroundDaemon.Add(
            'TestIcingaAgentService',
            [hashtable]::Synchronized(@{})
        );
        # This will add another hashtable to our previous
        # TestIcingaAgentService hashtable to store actual service
        # information
        $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.Add(
            'ServiceState',
            [hashtable]::Synchronized(@{})
        );
    };
}
```

As now our base skeleton for daemon is ready we can start to write the actual part which will execute the code to check for our Icinga Agent service state.

Because the code is executed as separate thread, we will have to ensure it will run as long as the PowerShell service is being executed. This will be done with a simple `while` loop

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our ScriptBlock for the code being executed inside the thread
    [ScriptBlock]$IcingaServiceTest = {
        # Allow us to parse the framework global data to this thread
        param($IcingaDaemonData);

        # Import the framework library components and initialise it
        # as daemon
        Use-Icinga -LibOnly -Daemon;

        # Add a synchronized hashtable to the global data background
        # daemon hashtable to write data to. In addition it will
        # allow to share data collected from this daemon with others
        $IcingaDaemonData.BackgroundDaemon.Add(
            'TestIcingaAgentService',
            [hashtable]::Synchronized(@{})
        );
        # This will add another hashtable to our previous
        # TestIcingaAgentService hashtable to store actual service
        # information
        $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.Add(
            'ServiceState',
            [hashtable]::Synchronized(@{})
        );

        # Keep our code excuted as long as the PowerShell service is
        # being executed. This is required to ensure we will execute
        # the code frequently instead of only once
        while ($TRUE) {
        }
    };
}
```

*ALWAYS* ensure you add some sort for `sleep` at the end of the `while` loop to allow your CPU some breaks. If you do not do this, you might suffer from high CPU loads. The `sleep duration` interval can depend either on a simple CPU cycle break or by telling the daemon to execute tasks only in certain intervalls. In our case we wish to execute the daemon every `5 seconds`.

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our ScriptBlock for the code being executed inside the thread
    [ScriptBlock]$IcingaServiceTest = {
        # Allow us to parse the framework global data to this thread
        param($IcingaDaemonData);

        # Import the framework library components and initialise it
        # as daemon
        Use-Icinga -LibOnly -Daemon;

        # Add a synchronized hashtable to the global data background
        # daemon hashtable to write data to. In addition it will
        # allow to share data collected from this daemon with others
        $IcingaDaemonData.BackgroundDaemon.Add(
            'TestIcingaAgentService',
            [hashtable]::Synchronized(@{})
        );
        # This will add another hashtable to our previous
        # TestIcingaAgentService hashtable to store actual service
        # information
        $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.Add(
            'ServiceState',
            [hashtable]::Synchronized(@{})
        );

        # Keep our code excuted as long as the PowerShell service is
        # being executed. This is required to ensure we will execute
        # the code frequently instead of only once
        while ($TRUE) {
            # ALWAYS add some sort of sleep at the end. Either to
            # break the CPU cycle and give it some break or to
            # ensure daemon tasks are executed on a certain interval
            Start-Sleep -Seconds 5;
        }
    };
}
```

This is basicly the foundation of every single daemon you will write. Now we will add the actual task our daemon will execute while it is running. As mentioned before, we will test if our Icinga 2 Agent service is running and restart it if it is stopped. To keep track of the current status and possible errors during restart, we will add additional `synchronized` hashtables to store the `value` of the current service status and possible `restart_error` counts. To count the `restart_error` we will have to initiliase a single variable we name `$RestartErrors` before we enter our `while` loop.

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our ScriptBlock for the code being executed inside the thread
    [ScriptBlock]$IcingaServiceTest = {
        # Allow us to parse the framework global data to this thread
        param($IcingaDaemonData);

        # Import the framework library components and initialise it
        # as daemon
        Use-Icinga -LibOnly -Daemon;

        # Add a synchronized hashtable to the global data background
        # daemon hashtable to write data to. In addition it will
        # allow to share data collected from this daemon with others
        $IcingaDaemonData.BackgroundDaemon.Add(
            'TestIcingaAgentService',
            [hashtable]::Synchronized(@{})
        );
        # This will add another hashtable to our previous
        # TestIcingaAgentService hashtable to store actual service
        # information
        $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.Add(
            'ServiceState',
            [hashtable]::Synchronized(@{})
        );

        # Initialise our error counter variable
        [int]$RestartErrors = 0;

        # Keep our code excuted as long as the PowerShell service is
        # being executed. This is required to ensure we will execute
        # the code frequently instead of only once
        while ($TRUE) {
            # Get the current service information. If the service is
            # not installed, continue silently to return $null
            $ServiceState = Get-Service 'icinga2' -ErrorAction SilentlyContinue;

            # Only execute our code if the Icinga Agent service is
            # installed
            if ($null -ne $ServiceState) {
                # Add the current service state to our hashtable.
                Add-IcingaHashtableItem `
                    -Hashtable $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.ServiceState `
                    -Key 'value' `
                    -Value $ServiceState.Status `
                    -Override | Out-Null;

                # Restart the service if it is not running
                if ($ServiceState.Status -ne 'Running') {
                    try {
                        # Try to restart the service
                        Restart-Service 'icinga2';
                    } catch {
                        # Add an error counter in case we failed
                        $RestartErrors += 1;
                        Add-IcingaHashtableItem `
                            -Hashtable $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.ServiceState `
                            -Key 'restart_error' `
                            -Value $RestartErrors `
                            -Override | Out-Null;
                    }
                }
            }
            # ALWAYS add some sort of sleep at the end. Either to
            # break the CPU cycle and give it some break or to
            # ensure daemon tasks are executed on a certain interval
            Start-Sleep -Seconds 5;
        }
    };
}
```

Calling Our ScriptBlock
---

Once our SciptBlock is completed we only require to call it once our daemon is registered. Do to so, we will use the Cmdlet `New-IcingaThreadInstance`.

As arguments we will have to add a unique `name` to use for this thread as well as a `thread pool` we will add add the thread to. In our case we will use the Frameworks default pool. Last but not least we require to parse our `ScriptBlock`, possible `Arguments` and tell the thread to `Start` right after being created. For the arguments we will parse the frameworks `global` `IcingaDaemonData` we also use inside our ScriptBlock to store data in.

The function will be a added at the very bottom of our `Start-IcingaAgentServiceTest` function

```powershell
function Start-IcingaAgentServiceTest()
{
    # Our ScriptBlock for the code being executed inside the thread
    [ScriptBlock]$IcingaServiceTest = {
        # Allow us to parse the framework global data to this thread
        param($IcingaDaemonData);

        # Import the framework library components and initialise it
        # as daemon
        Use-Icinga -LibOnly -Daemon;

        # Add a synchronized hashtable to the global data background
        # daemon hashtable to write data to. In addition it will
        # allow to share data collected from this daemon with others
        $IcingaDaemonData.BackgroundDaemon.Add(
            'TestIcingaAgentService',
            [hashtable]::Synchronized(@{})
        );
        # This will add another hashtable to our previous
        # TestIcingaAgentService hashtable to store actual service
        # information
        $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.Add(
            'ServiceState',
            [hashtable]::Synchronized(@{})
        );

        # Initialise our error counter variable
        [int]$RestartErrors = 0;

        # Keep our code excuted as long as the PowerShell service is
        # being executed. This is required to ensure we will execute
        # the code frequently instead of only once
        while ($TRUE) {
            # Get the current service information. If the service is
            # not installed, continue silently to return $null
            $ServiceState = Get-Service 'icinga2' -ErrorAction SilentlyContinue;

            # Only execute our code if the Icinga Agent service is
            # installed
            if ($null -ne $ServiceState) {
                # Add the current service state to our hashtable.
                Add-IcingaHashtableItem `
                    -Hashtable $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.ServiceState `
                    -Key 'value' `
                    -Value $ServiceState.Status `
                    -Override | Out-Null;

                # Restart the service if it is not running
                if ($ServiceState.Status -ne 'Running') {
                    try {
                        # Try to restart the service
                        Restart-Service 'icinga2';
                    } catch {
                        # Add an error counter in case we failed
                        $RestartErrors += 1;
                        Add-IcingaHashtableItem `
                            -Hashtable $IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.ServiceState `
                            -Key 'restart_error' `
                            -Value $RestartErrors `
                            -Override | Out-Null;
                    }
                }
            }
            # ALWAYS add some sort of sleep at the end. Either to
            # break the CPU cycle and give it some break or to
            # ensure daemon tasks are executed on a certain interval
            Start-Sleep -Seconds 5;
        }
    };

    # Now create a new thread for our ScriptBlock, assign a name and
    # parse all required arguments to it. Last but not least start it
    # directly
    New-IcingaThreadInstance `
        -Name "Icinga_PowerShell_IcingaAgent_StateCheck" `
        -ThreadPool $global:IcingaDaemonData.IcingaThreadPool.BackgroundPool `
        -ScriptBlock $IcingaServiceTest `
        -Arguments @( $global:IcingaDaemonData ) `
        -Start;
}
```

Register Our Daemon
---

Now as our daemon is ready we can simply [register it](../service/02-Register-Daemons.md) by using the Framework commands

```powershell
Register-IcingaBackgroundDaemon -Command 'Start-IcingaAgentServiceTest';
```

Once registered, you will have to restart the PowerShell service itselfs to apply the changes

```powershell
Restart-IcingaService 'icingapowershell';
```

Thats it! Now the daemon is loaded with every start, checking for the Agent state and restart it if it is not running.

**Note:** In order to restart the Icinga Agent service, the user the PowerShell service is running with requires these kind of priviliges. Otherwise it will throw an error and the error counter will increase

Developer Console
---

During development you might want to test the current implementation and check if everything is working as intended. To do so, you require to open a PowerShell terminal as `administrator`. We would recommend to `stop` the PowerShell service in this case to prevent possible daemons writing files to the system and overwriting each others.

Once the service is stopped and your `administrative PowerShell` is open, we will have to initialise the Framework and start the background daemon component

```powershell
Use-Icinga;
Start-IcingaPowerShellDaemon;
```

Once done you will receive back your prompt, however all registered background daemons are running. To access the collected data from daemons, you can print the content of the `global` framework data. If you wish to check if your daemon was loaded properly and data is actually written, we can access our created hashtable and get the current service state of it

```powershell
$global:IcingaDaemonData.BackgroundDaemon.TestIcingaAgentService.ServiceState['value'];
```

In case your Icinga Agent service is intalled and your daemon is running properly, this should print the current state of the service.

Of course for more complex daemons you are able to manipulate data directly or add more detailed debug output.
