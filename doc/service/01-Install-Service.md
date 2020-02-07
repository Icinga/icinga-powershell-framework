Run the PowerShell Framework as Windows Service
===

Requirements
---

As PowerShell Scripts / Modules can not be installed directly as Windows Service, we will require a little assistance here.

In order to make this work, you will require the Icinga Windows Service which can be downloaded directly from the [GitHub Repository](https://github.com/Icinga/icinga-powershell-service).

Benefits
---

Running the PowerShell Framework as background service will add the possibility to register certain functions which are executed depending on their configuration / coding. One example would be to frequently collect monitoring metrics from the installed plugins, allowing you to receice an average of time for the CPU load for example.

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
Install-IcingaFrameworkService -Path 'C:\Program Files\Icinga-Framework-Service\icinga-service.exe'
```

You can validate if the service has been installed properly by using the Get Service Cmdlet:

Each enabled background daemon component is afterwards being started and executed.

Register Functions
---

As the service is now installed we can start to [register daemons](02-Register-Daemons.md) which are executed within an own thread within a PowerShell session. Depending on the registered function/module, additional configuration may be required.

Background Service Check
---

Once you registered the Daemon `Start-IcingaServiceCheckDaemon` with the [register functions](02-Register-Daemons.md) feature you will be able to [register service checks](10-Register-Service-Checks.md) which are frequently executed to collect metrics from plugins.
