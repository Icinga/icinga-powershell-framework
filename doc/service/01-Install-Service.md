Run the PowerShell Framework as Windows Service
===

Requirements
---

As PowerShell Scripts / Modules can not be installed directly as Windows Service, we will require a little assistance here.

In order to make this work, you will require the Icinga Windows Service which can be downloaded directly from the [GitHub Repository](https://github.com/Icinga/icinga-powershell-service).

Benefits
---

Running the PowerShell Framework as background service will add the possibility to register certain functions which are executed depending on their configuration / coding. One example would be to frequently collect monitoring metrics from the installed plugins, allowing you to receive an average of time for the CPU load for example.

Install the Service
---

A detailed documentation on how to download and install the service and be found directly on the services [installation guide](https://icinga.com/docs/windows/latest/service/doc/02-Installation/).

Register Functions
---

As the service is now installed we can start to [register daemons](02-Register-Daemons.md) which are executed within an own thread within a PowerShell session. Depending on the registered function/module, additional configuration may be required.

Background Service Check
---

Once you registered the Daemon `Start-IcingaServiceCheckDaemon` with the [register functions](02-Register-Daemons.md) feature you will be able to [register service checks](10-Register-Service-Checks.md) which are frequently executed to collect metrics from plugins.
