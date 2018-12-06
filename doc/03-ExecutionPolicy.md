Setting Execution Policies
=====================================

In order to be able to run the module on certain Windows Hosts, it might be required to either update the execution policies and/or unblock the module script files.

The prefered way is to simply unblock the script files, allowing them to be executed on the system. This can be done by running a PowerShell instance as **Administrator** and enter the following command (we assume the module is installed at `C:\Program Files\WindowsPowershell\Modules\icinga-module-windows`. If not, please modify the command with the correct location)

```powershell
    Get-ChildItem -Path 'C:\Program Files\WindowsPowershell\Modules\icinga-module-windows' -Recurse | Unblock-File 
```

Once done, please try again if you are now able to run the module on your host. If you are still not able to run the module and/or its scripts, please have a look on the Microsoft documentation for the [Set-Execution-Policy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-6) Cmdlet to modify the Execution Policy for running PowerShell modules on your host, matching your internal guidelines.