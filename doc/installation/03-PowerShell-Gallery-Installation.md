# Install the Framework with PowerShell Gallery

PowerShell Gallery provides a collection of PowerShell modules and scripts which can easily be intalled on target machines. For a further description, please have a look on the [PowerShell Gallery website](https://www.powershellgallery.com/).

## Getting Started

Icinga is providing PowerShell Gallery packages within the [Icinga Profile](https://www.powershellgallery.com/profiles/Icinga) for the Framework itself and other related components.

To install the Icinga PowerShell Framework you can simpy use `Install-Module` in case it is available and configured on your system:

```powershell
Install-Module -Name icinga-powershell-framework;
```

## Execute the Icinga Agent installation wizard

Once the entire Framework is installed and the module is runnable, you can start the Icinga Agent installation wizard. Please follow the [Icinga Agent Wizard](04-Icinga-Agent-Wizard.md) guide for examples and usage.
