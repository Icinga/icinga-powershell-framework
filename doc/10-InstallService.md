Run the PowerShell Module as Windows Service
===

Requirements
---

As PowerShell Scripts / Modules can not be installed directly as Windows Service, we will require a little assistance here.

In order to make this work, you will require the Icinga Windows Service which can be downloaded directly from the [GitHub Repository](https://github.com/Icinga/icinga-powershell-service).

Install the Service
---

At first you will require the Service Binary from the [Icinga Windows Service GitHub Repository](https://github.com/Icinga/icinga-powershell-service) and copy the binary locally to your system. A recommended path would be your Program Files / Program Files (x86) directory.

Any other custom location is fully supported, has to be however accessible from the Windows Service Environment.

Once you have found a location, the PowerShell Module will assist you with setting up the service itself. In this documentation we will assume the path you have chosen to copy the binary to is

```powershell
C:\Program Files\Icinga-Framework-Service
```

and the binary name is

```powershell
icinga-service.exe
```

Now lets install the service with the help of the PowerShell Module:

```powershell
Install-IcingaFrameworkService -ServicePath 'C:\Program Files\Icinga-Framework-Service\icinga-service.exe'
```

You can validate if the service has been installed properly by using the Get Service Cmdlet:

```powershell
Get-IcingaFrameworkService
```

Of course there are more Cmdlets available, making the management of this Icinga Service alot easier, which should be self explaining:

* Start-IcingaFrameworkService
* Stop-IcingaFrameworkService
* Restart-IcingaFrameworkService
* Uninstall-IcingaFrameworkService

Each enabled background daemon component is afterwards being started and executed.
