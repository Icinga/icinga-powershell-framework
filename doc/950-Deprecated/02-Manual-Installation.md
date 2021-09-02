# Install the Framework manually

To install the module manually we will at first fetch information on where we can actually install the module into. PowerShell provides some default directories, which can however also extended manually.

Get the latest Version from [GitHub](https://github.com/Icinga/icinga-powershell-framework/releases/latest) or [PowerShell Gallery](https://www.powershellgallery.com/packages/icinga-powershell-framework).

## Getting Started

To do this, we can run the following command within PowerShell

```powershell
echo $env:PSModulePath
```

***We do recommend to use the Program Files folder (in case it's present) to install the module into, which will make the installation as service easier***

To be able to use the module, you will require to have named the folder **exactly** as the .psm1 and .psd1 files inside the repository.

Example folder path:

```powershell
C:\Program Files\WindowsPowerShell\Modules\icinga-powershell-framework
```

To validate if the module is installed properly, you can start a **new** PowerShell instance and type the following command

```powershell
Get-Module -ListAvailable -Name icinga-powershell-framework
```

If you receive an output stating that the module is installed, you are fine to continue.

## Execution Policies and File Blocking

In order to be able to run the module on certain Windows Hosts, it might be required to either update the execution policies and/or unblock the module script files.

The preferred way is to simply unblock the script files, allowing them to be executed on the system. This can be done by running a PowerShell instance as **Administrator** and enter the following command (we assume the module is installed at `C:\Program Files\WindowsPowershell\Modules\icinga-powershell-framework`. If not, please modify the command with the correct location)

```powershell
Get-ChildItem -Path 'C:\Program Files\WindowsPowershell\Modules\icinga-powershell-framework' -Recurse | Unblock-File
```

Once done, please try again if you are now able to run the module on your host. If you are still not able to run the module and/or its scripts, please have a look at the Microsoft documentation for the [Set-Execution-Policy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6) Cmdlet to modify the Execution Policy for running PowerShell modules on your host, matching your internal guidelines.

## Execute the Icinga Agent installation wizard

Once the entire Framework is installed and the module is runnable, you can start the Icinga Agent installation wizard. Please follow the [Icinga Agent Wizard](04-Icinga-Agent-Wizard.md) guide for examples and usage.
