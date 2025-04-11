# Icinga for Windows

Icinga for Windows is the default and official supported solution for monitoring Windows environments and tools. We provide a variety of components to ensure not only the initial installation and configuration is taken care of, but also the update of components including the actual monitoring.

Get the latest Version from [GitHub](https://github.com/Icinga/icinga-powershell-framework/releases/latest) or [PowerShell Gallery](https://www.powershellgallery.com/packages/icinga-powershell-framework).

## Architecture of the solution

Icinga for Windows is simply an umbrella name for a bunch of PowerShell modules which have to be installed on the machines directly. Each module is designed to cover certain tasks and use cases, to ensure there is not one huge solution which adds functionality you usually wont use.

To make sure the solution is extendable, you can install different modules in parallel making use of the other installed Icinga PowerShell modules and extend the abilities or develop your own custom modules.

## The heart of the solution: Icinga PowerShell Framework

The Icinga PowerShell Framework is the basic requirement to manage the Icinga Agent and to provide the tool set to execute the PowerShell plugins provided by Icinga. Instead of compiled and complex plugins shipped with the Agent itself, each functionality is separated as module file and loaded during the initialization of the Framework.

The real benefit is to provide standardized functionality across the board for all current and future plugins/extensions to come including the Icinga Agent management. By doing so, the Framework itself is a huge collection of functions, but decreases the amount of work developers have to invest for creating own plugins or modules.

## Easy extendability

Besides the Icinga PowerShell Framework a bunch of different PowerShell modules are already available. They are installed in addition to the Framework and can make use of already available functions - either shipped by the Framework itself or other modules.

The main goal is to extend the entire Windows monitoring space with a default set of tools every one can use later on to customize the monitoring based on the own needs.

## Coverage of Icinga for Windows

### Supported Operating Systems

We officially support Windows machines running the following operating systems:

* Windows 8
* Windows 8.1
* Windows 10
* Windows 11
* Windows Server 2012
* Windows Server 2012 R2
* Windows Server 2016
* Windows Server 2019
* Windows Server 2022
* Windows Server 2025

It may work on the following systems, but is currently untested, not supported and certain features may not work as expected:

* Windows 7
* Windows 2008 R2

### Requirements

#### Minimum Requirements

In order to make Icinga for Windows work on the above supported machines you will require at least

* PowerShell 4.0 or later
* .NET Framework 4.0 or later

If you intend to use the Icinga Agent with the solution, you will require `.NET Framework 4.6 or later` being installed

#### Recommended

The recommended environment should contain

* PowerShell 5.1 or later
* .NET Framework 4.7 or later

## Available Modules/Extensions

Below you will find a list of currently available modules published by the Icinga Team.

### Core Modules

| Icinga PowerShell Kickstart | Icinga PowerShell Framework | Icinga PowerShell Plugins |
| --- | --- | --- |
| [![Kickstart](images/02_icons/kickstart.png)](https://github.com/Icinga/icinga-powershell-kickstart) | [![Frame](images/02_icons/framework.png)](https://icinga.com/docs/icinga-for-windows/latest/doc/110-Installation/01-Getting-Started/) | [![Frame](images/02_icons/plugins.png)](https://icinga.com/docs/windows/latest/plugins/doc/01-Introduction/) |

### Extensions

| Icinga PowerShell Inventory |
| --- |
| [![Inventory](images/02_icons/inventory.png)](https://icinga.com/docs/windows/latest/inventory/doc/01-Introduction/) | |

### Additional Plugins

| Icinga PowerShell Hyper-V | Icinga PowerShell MSSQL |  Icinga PowerShell Cluster | Icinga PowerShell IIS |
| --- | --- | --- |  --- |
| [![Hyper-V](images/02_icons/hyperv.png)](https://icinga.com/docs/icinga-for-windows/latest/hyperv/doc/01-Introduction/) | [![MSSQL](images/02_icons/mssql.png)](https://icinga.com/docs/windows/latest/mssql/doc/01-Introduction/) | [![Cluster](images/02_icons/hyperv.png)](https://icinga.com/docs/icinga-for-windows/latest/cluster/doc/01-Introduction/) | [![IIS](images/02_icons/iis.png)](https://icinga.com/docs/icinga-for-windows/latest/iis/doc/01-Introduction/) |
