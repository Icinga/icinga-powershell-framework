# Developer Guide: Fetching Cim-Instance and Wmi-Object data

The easiest way of fetching certain information about a Windows system is by using the PowerShell cmdlet `Get-WmiObject` or `Get-CimInstance`. Both functions provide a huge amount of data for monitoring the host.

How ever, as the Icinga for Windows solutions is trying to keep the effort as low as possible including the error handling we implemented a wrapper function to handle most common issues.

## The Problem with WMI and CIM calls

In general it doesn't matter if you are using `Get-WmiObject` or `Get-CimInstance` to fetch data. How ever, the return output could vary a little including on how to loop certain content.

```powershell
Get-CimInstance Win32_ComputerSystem;

Name     PrimaryOwnerName Domain TotalPhysicalMemory Model   Manufacturer
----     ---------------- ------ ------------------- -----   ------------
testhost icinga           ICINGA 34304962560         MS-7C35 Micro-Star International Co., Ltd.
```

```powershell
Get-WmiObject Win32_ComputerSystem;

Domain              : ICINGA
Manufacturer        : Micro-Star International Co., Ltd.
Model               : MS-7C35
Name                : testhost
PrimaryOwnerName    : icinga
TotalPhysicalMemory : 34304962560
```

As long as we are not running in any kind of error, the fetching is straight forward. Once we run how ever into errors we will have to handle these and ensure our plugins are executed properly. One example would either be a permission error or a not found class. This could look like this

```powershell
Use-Icinga;
Invoke-IcingaCheckMemory;
```

```powershell
Get-CimInstance: Access denied
RuntimeException: Attempted to divide by zero.
MethodInvocationException: Exception calling "Format" with "2" argument(s): "Value cannot be null.
Parameter name: args"
[OK] Check package "Memory Usage"
| 'memory_percent_used'=%;;;0;100 'used_bytes'=0B;;;0
```

Now of course we do not want to have some sort of error within our plugin output or corrupted data to work with. The goal would be to achieve something like this:

```powershell
[UNKNOWN]: Icinga Permission Error was thrown: CimInstance: Win32_PhysicalMemory

The user you are running this command as does not have permission to access the requested Cim-Object. To fix this, please add the user the Agent is running with to the "Remote Management Users" groups and grant access to the WMI branch "root/cimv2" and add the permission "Remote enable".
```

## Easy fetching of data

To ensure the above mentioned funtionality is made easy, we added the wrapper function `Get-IcingaWindowsInformation`. This function will by default use the `Get-CimInstance` Cmdlet and as fallback `Get-WmiObject`:

```powershell
Get-IcingaWindowsInformation Win32_ComputerSystem;
```

```powershell
Name     PrimaryOwnerName Domain TotalPhysicalMemory Model   Manufacturer
----     ---------------- ------ ------------------- -----   ------------
testhost icinga           ICINGA 34304962560         MS-7C35 Micro-Star International Co., Ltd.
```

If required you can also force the usage of `WMI` over `CIM`:

```powershell
Get-IcingaWindowsInformation Win32_ComputerSystem -ForceWMI;
```

```powershell
Domain              : ICINGA
Manufacturer        : Micro-Star International Co., Ltd.
Model               : MS-7C35
Name                : testhost
PrimaryOwnerName    : icinga
TotalPhysicalMemory : 34304962560
```

## Build-in error handling

In addition to make fetching itself easier we also ensure a proper standardized error handling. Instead of throwing an exception the developer has to take care of

```powershell
Get-CimInstance Win32_NotExistingClass;

Get-CimInstance : Invalid Class
Line:1 Symbol:1
+ Get-CimInstance Win32_NotExistingClass
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : MetadataError: (root\cimv2:Win32_NotExistingClass:String) [Get-CimInstance], CimException
    + FullyQualifiedErrorId : HRESULT 0x80041010,Microsoft.Management.Infrastructure.CimCmdlets.GetCimInstanceCommand
```

we exit the plugin call and output a proper status information including the correct status code:

```powershell
Use-Icinga;
Get-IcingaWindowsInformation Win32_NotExistingClass;

[UNKNOWN]: Icinga Invalid Input Error was thrown: CimClassNameUnknown: Win32_NotExistingClass

The provided class name you try to fetch with Get-CimInstance is not known on this system.
```

## Usage of filters

As for `Get-CimInstance` or `Get-WmiObject` you can also use the `-Filter` argument to search for certain content wihtin the return output and only return specific content:

```powershell
Use-Icinga;
Get-IcingaWindowsInformation Win32_Service -Filter "Name='icinga2'";

ProcessId Name    StartMode State   Status ExitCode
--------- ----    --------- -----   ------ --------
14360     icinga2 Automatic Running OK     0
```
