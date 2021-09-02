# Developer Guide: Working with Performance Counters

For every Windows system there are Performance Counters available which will deliver information and details about the state of the general health of certain components of Windows itself but also disks, drivers, software and network interfaces for example.

To get to know more about them in general, you can have a look on the [Microsoft Documentation for Performance Counters](https://docs.microsoft.com/en-us/windows/win32/perfctrs/performance-counters-portal).

## Structure of Performance Counters

In order to fetch Performance Counters data by using the Icinga PowerShell Framework, we have to first clarify on how to access counters. Every counter is split into two mandatory components:

* Category
* Counter

Each `Category` can provide a various amount of different `Counter` objects you can access to read data out. An example counter is

```powershell
'\Memory\available mbytes'
```

The notation is always a leading `\` followed by the `Category`, another `\` and the `Counter` itself.

In this example, `Memory` is the `Category` and `available mbytes` is the counter we can fetch data from. It contains available Megabytes for allocation to a process or for system use.

Now in addition to the previous mentioned structure, there is one exception when a counter contains multiple `Instances`. An `Instance` is used for example by processor, disk or network interfaces, on which multiple values are stored for different disks, processor cores or network interfaces.

To access a certain `Instance` you will have to extend the `Category` with brackets `()` and write the name of the `Instance` into it. You can use `*` to fetch data for all `Instances`.

```powershell
'\Processor(*)\% processor time'
```

Please keep in mind that not all counters will require instances.

## Fetching available Performance Counters Categories

The way the Icinga PowerShell Framework is designed allows the global usage of the counters with their english name. This means it doesn't matter which language your Windows system is running it. How ever, localised systems will often print localised names of the counters, making it hard to use them on systems running a different language.

To fetch a list of available counters on a specific system with their english names, there is a Cmdlet avaialble in the Framework itself:

```powershell
Show-IcingaPerformanceCounterCategories;
```

```text
System
Memory
Browser
Cache
Process
Thread
PhysicalDisk
LogicalDisk
...
```

## Fetching available Performance Counters from Categories

As we now know which `Categories` are available on our system, we can have a look on them which `Counter` are present. For this there is also a Cmdlet avaialble directly within the Framework:

```powershell
Show-IcingaPerformanceCounters 'Memory';
```

```text
\Memory\committed bytes
\Memory\pool nonpaged bytes
\Memory\page writes/sec
\Memory\transition faults/sec
...
```

Note that the Cmdlet will output the counters with the correct notation already which means you can simply copy & paste them into your code for usage. The same applies for counters with instances:

```powershell
Show-IcingaPerformanceCounters 'Processor';
```

```text
\Processor(*)\dpcs queued/sec
\Processor(*)\% c1 time
\Processor(*)\% idle time
\Processor(*)\c3 transitions/sec
...
```

## Fetching available Performance Counters Instances

Last but not least you can fetch all available `Instances` for a Performance Counter with a custom Cmdlet introduced with Icinga PowerShell Framework version 1.2.0:

```powershell
Show-IcingaPerformanceCounterInstances '\Processor(*)\% processor time';
```

```text
Name                           Value
----                           -----
_Total                         \Processor(_Total)\% processor time
0                              \Processor(0)\% processor time
1                              \Processor(1)\% processor time
```

Not only will it print you the name of the `Instance` but also the full path to use for fetching the value of a specific Performance Counter.

## Access Performance Counters

By using `New-IcingaPerformanceCounterArray`, you can provide multiple Performance Counters and fetch them all at once. This is the recommended way, as some counters will require a certain `Sleep` interval to have valid data available. By using the array handling, all counters will be loaded and initialised at once, reducing the overall required sleep duration to an absolute minimum. 

### Example 1: Fetch multiple Performance Counters

You can add multiple Performance Counter paths to the Cmdlet. All of them will be fetched at once;

```powershell
New-IcingaPerformanceCounterArray '\Processor(*)\% processor time', '\Memory\committed bytes', '\Memory\available mbytes';
```

```text
Name                           Value
----                           -----
\Processor(*)\% processor time {\Processor(_Total)\% processor time, \Processor(0)\% processor time, \Processor(10)\...
\Memory\available mbytes       {error, sample, type, value...}
\Memory\committed bytes        {error, sample, type, value...}
```

You can access the values directly by using the specific Performance Counter as index:

```powershell
$Counter = New-IcingaPerformanceCounterArray '\Processor(*)\% processor time', '\Memory\committed bytes', '\Memory\available mbytes';
$Counter['\Processor(*)\% processor time'];
```

```text
Name                           Value
----                           -----
\Processor(_Total)\% proces... {error, sample, type, value...}
\Processor(0)\% processor time {error, sample, type, value...}
\Processor(10)\% processor ... {error, sample, type, value...}
\Processor(20)\% processor ... {error, sample, type, value...}
...
```

Now you can access the values with their `Instance` path:

```powershell
$Counter['\Processor(*)\% processor time']['\Processor(_Total)\% processor time'];
```

```text
Name                           Value
----                           -----
error
sample                         System.Diagnostics.CounterSample
type                           Timer100NsInverse
value                          0
help                           % Processor Time is the percentage of elapsed time that the processor spends to execu...
```

And of course the value itself

```powershell
$Counter['\Processor(*)\% processor time']['\Processor(_Total)\% processor time'].value;
```

### Example 2: Fetch Single Instance Performance Counter

Of course you can also access a single `Instance` of a Performance Counter or using a Performance Counter not having any `Instances` at all:

```powershell
$Counter = New-IcingaPerformanceCounterArray '\Processor(_Total)\% processor time';
$Counter['\Processor(_Total)\% processor time'].value;
```

## Create a structured Performance Counter output

### The Problem: Messy output with multiple Instances

Plenty of `Counters` provide `Instances`, which are required to allow the specific assignment of values to an object. Such examples are Network Interface `Counters` for different interfaces or PhysicalDisk/LogicalDisk counters for each installed disk.

By simply fetching all informations from a counter, like `\LogicalDisk(*)\free megabytes`, we receive each disk value within our output. This is fine in general, is however problematic in the following scenario:

```powershell
$Counter = New-IcingaPerformanceCounterArray '\LogicalDisk(*)\free megabytes', '\LogicalDisk(*)\% idle time';
```

Of course we will receive the correct amount of data, but the output is not something we can effectively work with, because the parent of our access is always the specified counter with all instances below. You will have to access both of these objects to receive informations of your C disk for example:

```powershell
$Counter['\LogicalDisk(*)\free megabytes']['\LogicalDisk(C:)\free megabytes'].value;
$Counter['\LogicalDisk(*)\% idle time']['\LogicalDisk(C:)\% idle time'].value;
```

As you can see, the *problem* is not that big, but imagine you have 10 counters you wish to include for your disk. This is not something you wish to handle manually.

### The Solution: Structured Output

As we just learned in general this usage is fine, requires how ever some effort to display and use `Counter` properly. To resolve this, we will create a structured object now with automatic sorting of the data.

To make the example a little more interesting, lets do as much automation as possible.

At first we will create a variable and store all Counters inside the system provides:

```powershell
$CounterList = Show-IcingaPerformanceCounters 'LogicalDisk';
```

The `Show-IcingaPerformanceCounters` Cmdlet is returning all available Performance Counters. We can now use this output and create an array with our `New-IcingaPerformanceCounterArray` Cmdlet:

```powershell
$Counters = New-IcingaPerformanceCounterArray $CounterList;
```

Now we have initialised all `Counters` and `Instances` and loaded them into our variable. This is quite fine, but we still have the same result as described within our problem scenario:

```text
Name                           Value
----                           -----
\LogicalDisk(*)\free megabytes {\LogicalDisk(HarddiskVolume30)\free megabytes, \LogicalDisk(R:)\free megabytes, \Log...
\LogicalDisk(*)\% disk read... {\LogicalDisk(HarddiskVolume1)\% disk read time, \LogicalDisk(_Total)\% disk read tim...
\LogicalDisk(*)\avg. disk w... {\LogicalDisk(HarddiskVolume13)\avg. disk write queue length, \LogicalDisk(R:)\avg. d...
\LogicalDisk(*)\disk transf... {\LogicalDisk(_Total)\disk transfers/sec, \LogicalDisk(G:)\disk transfers/sec, \Logic...
...
```

Now let the Framework do the magic and organice the entire `Counter` hashtable based on a group parent. As we fetch `LogicalDisk` data, lets group them by the `Instances` of the category and add our previous loaded counters to the call

```powershell
$Result = New-IcingaPerformanceCounterStructure -CounterCategory 'LogicalDisk' -PerformanceCounterHash $Counters;
```

Inside our `$Result` variable we have not sorted all Performance Counters properly based on their `Instance` and every single `Counter` is now available by the `name of the Counter` itself:

```powershell
Name                           Value
----                           -----
Name                           Value
----                           -----
HarddiskVolume13               {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
HarddiskVolume15               {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
HarddiskVolume30               {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
_Total                         {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
HarddiskVolume1                {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
G:                             {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
R:                             {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
HarddiskVolume24               {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
C:                             {avg. disk queue length, % free space, avg. disk sec/transfer, avg. disk bytes/read...}
```

Our `$Result` variable is a simple `hashtable` which contains all above mentioned data. By using the `Instance` as first index and the `Counter` as second index, you can directly access the values:

```powershell
$Result['C:']['avg. disk queue length'].value;
$Result['C:']['% disk time'].value;
$Result['C:']['avg. disk bytes/transfer'].value;
```
