# Automated Framework and Component deployment

Installing and configuring the Icinga PowerShell Framework can be done by many different ways. A detailled overview is described in the [installation guide](../02-Installation.md).

## Getting Started

In the [installation guide](../02-Installation.md) we already refered to possible automation options by adding arguments to the [Icinga PowerShell Kickstart](../installation/01-Kickstart-Script.md).

This allows you to deploy the Framework unattended and automated on your Windows machines without having to touch them. The execution of the code snippet could be done by automation tools like SCCM, Puppet, Ansible, PowerShell Remote Execution or any other tool.

To fully automate the entire monitoring deployment on Windows, we will use the argument handling for the [Icinga PowerShell Kickstart](../installation/01-Kickstart-Script.md) and the description on how to use the `Start-IcingaAgentInstallWizard` automation handling as mentioned in [Icinga Agent Agent Wizard guide](../installation/04-Icinga-Agent-Wizard.md).

## Automating the deployment

As we are now aware on how we can setup the arguments for each step of the Kickstart and the Icinga Agent wizard, we move forward to build a small automation handling.

The code snippets we will provide below are build on top of each other. If you simply require a fully finished code block, head to the end of this guide.

### Setting up connection handling

At first we will allow TLS 1.2 and 1.1 in our session to ensure our PowerShell can connect to every system without issues. In addition to that, we will disable possible progress bars to speed up file downloads:

```powershell
# Ensure TLS 1.2 and 1.1 are supported. This will prevent possible HTTPS errors on older systems
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
# Disable any progress bars. In addition, this will speed-up downloads
$ProgressPreference                         = "SilentlyContinue";
```

### Setting Kickstart-Script source location

In the next step we will assign a variable which will point directly to your `kickstart-script.ps1` file. It doesnt matter if the file is available on a web share, local drive or network share:

```powershell
# Ensure TLS 1.2 and 1.1 are supported. This will prevent possible HTTPS errors on older systems
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
# Disable any progress bars. In addition, this will speed-up downloads
$ProgressPreference                         = "SilentlyContinue";
# Destination on where to load our Kickstart-Script file from.
# It doesn't matter if it is a web ressource, local drive or network share
$KickStartScriptFile                        = 'https://example.com/icinga/kickstart-script.ps1';
```

### Fetching the Script content

Now as our base is ready, we have to actually fetch the content of our script file. To ensure it will work for local drives, networks shares and web ressources we will setup an empty `ScriptBlock` variable and depending on our location load the content from our file into it:

```powershell
# Ensure TLS 1.2 and 1.1 are supported. This will prevent possible HTTPS errors on older systems
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
# Disable any progress bars. In addition, this will speed-up downloads
$ProgressPreference                         = "SilentlyContinue";
# Destination on where to load our Kickstart-Script file from.
# It doesn't matter if it is a web ressource, local drive or network share
$KickStartScriptFile                        = 'https://example.com/icinga/kickstart-script.ps1';
# Setup an emptry variable which will contain our code block later
$ScriptBlock                                = $null;

# Now check for your location and use the appropiate method to get the content
if ((Test-Path $KickStartScriptFile)) {
    # Use local drive or network share
    $ScriptBlock = Get-Content -Path $KickStartScriptFile -Raw;
} else {
    # Use our web ressource and download the file
    $ScriptBlock = (Invoke-WebRequest -UseBasicParsing -Uri $KickStartScriptFile).Content;
}
```

### Add function and automation call to our script

As our `ScriptBlock` now contains the downloaded content from either a local drive, network share or web ressource we can continue to work with that. The content in our `ScriptBlock` variable is actual PowerShell code which is parsed as a string. We can use this to later create an executable PowerShell script which will apply all tasks we intend.

Right now we only contain the Icinga Kickstart functionallty, but no actual call to the function `Start-IcingaFrameworkWizard`.

To do so, we can now extend our `ScriptBlock` variable with code like this:

```powershell
$ScriptBlock += "`r`n`r`n Start-IcingaFrameworkWizard;";
```

This will add two new lines to the end of the script file and call the function `Start-IcingaFrameworkWizard`. As described in the [Icinga PowerShell Kickstart](../installation/01-Kickstart-Script.md) guide you can of course add arguments to this call. In our example we will download version 1.1.2 of the Icinga PowerShell Framework, install it into `C:\Program Files\WindowsPowerShell\modules`, allow updates and skip the Icinga Agent wizard:

```powershell
# Ensure TLS 1.2 and 1.1 are supported. This will prevent possible HTTPS errors on older systems
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
# Disable any progress bars. In addition, this will speed-up downloads
$ProgressPreference                         = "SilentlyContinue";
# Destination on where to load our Kickstart-Script file from.
# It doesn't matter if it is a web ressource, local drive or network share
$KickStartScriptFile                        = 'https://example.com/icinga/kickstart-script.ps1';
# Setup an emptry variable which will contain our code block later
$ScriptBlock                                = $null;

# Now check for your location and use the appropiate method to get the content
if ((Test-Path $KickStartScriptFile)) {
    # Use local drive or network share
    $ScriptBlock = Get-Content -Path $KickStartScriptFile -Raw;
} else {
    # Use our web ressource and download the file
    $ScriptBlock = (Invoke-WebRequest -UseBasicParsing -Uri $KickStartScriptFile).Content;
}

# Start our Kickstart wizard with our installation arguments for the Framework.
# This will ensure an automated run later on
$ScriptBlock += "`r`n`r`n Start-IcingaFrameworkWizard -RepositoryUrl 'https://github.com/Icinga/icinga-powershell-framework/archive/v1.1.2.zip' -ModuleDirectory 'C:\Program Files\WindowsPowerShell\modules\' -AllowUpdate 1 -SkipWizard;";
```

### Additional automation tasks

With the above code we have very good foundation and can now continue directly to install our Icinga Agent including other components. To do so, we will extend the `ScriptBlock` variable again with our function call to `Start-IcingaAgentInstallWizard` and provide all arguments for our automation tasks. To make things easier, we will use the Icinga Director Self-Service API and install the PowerShell Framework as service. For this we will download the release `.zip` from `https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip` and use `C:\Program Files\icinga-framework-service\` as location for your service binary.

Additional examples can be found in the [Icinga Agent Agent Wizard guide](../installation/04-Icinga-Agent-Wizard.md).

```powershell
# Ensure TLS 1.2 and 1.1 are supported. This will prevent possible HTTPS errors on older systems
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
# Disable any progress bars. In addition, this will speed-up downloads
$ProgressPreference                         = "SilentlyContinue";
# Destination on where to load our Kickstart-Script file from.
# It doesn't matter if it is a web ressource, local drive or network share
$KickStartScriptFile                        = 'https://example.com/icinga/kickstart-script.ps1';
# Setup an emptry variable which will contain our code block later
$ScriptBlock                                = $null;

# Now check for your location and use the appropiate method to get the content
if ((Test-Path $KickStartScriptFile)) {
    # Use local drive or network share
    $ScriptBlock = Get-Content -Path $KickStartScriptFile -Raw;
} else {
    # Use our web ressource and download the file
    $ScriptBlock = (Invoke-WebRequest -UseBasicParsing -Uri $KickStartScriptFile).Content;
}

# Start our Kickstart wizard with our installation arguments for the Framework.
# This will ensure an automated run later on
$ScriptBlock += "`r`n`r`n Start-IcingaFrameworkWizard -RepositoryUrl 'https://github.com/Icinga/icinga-powershell-framework/archive/v1.1.2.zip' -ModuleDirectory 'C:\Program Files\WindowsPowerShell\modules\' -AllowUpdate 1 -SkipWizard;";

# We will call our Start-IcingaAgentInstallWizard and provide automation arguments to install
# and configure the Icinga Agent by using the Icinga Director Self-Service API. In addition,
# we will install the Framework as service
$ScriptBlock += "`r`n`r`n Start-IcingaAgentInstallWizard -SelfServiceAPIKey '56756378658n56t85679765n97649m7649m76' -UseDirectorSelfService 1 -DirectorUrl 'https://example.com/icingaweb2/director/' -OverrideDirectorVars 0 -ConvertEndpointIPConfig 1 -Ticket '' -EmptyTicket 1 -InstallFrameworkPlugins 0 -InstallFrameworkService 1 -FrameworkServiceUrl 'https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip' -ServiceDirectory 'C:\Program Files\icinga-framework-service\' -RunInstaller;"
```

### Add Framework component installation tasks

You might have realised that we are not installing the Icinga PowerShell Plugins with `Start-IcingaAgentInstallWizard`. Instead, we will use the component installer of the Icinga PowerShell Framework to install them. You can repeat this newly added line for any additional Framework component you want to install:

```powershell
# Ensure TLS 1.2 and 1.1 are supported. This will prevent possible HTTPS errors on older systems
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
# Disable any progress bars. In addition, this will speed-up downloads
$ProgressPreference                         = "SilentlyContinue";
# Destination on where to load our Kickstart-Script file from.
# It doesn't matter if it is a web ressource, local drive or network share
$KickStartScriptFile                        = 'https://example.com/icinga/kickstart-script.ps1';
# Setup an emptry variable which will contain our code block later
$ScriptBlock                                = $null;

# Now check for your location and use the appropiate method to get the content
if ((Test-Path $KickStartScriptFile)) {
    # Use local drive or network share
    $ScriptBlock = Get-Content -Path $KickStartScriptFile -Raw;
} else {
    # Use our web ressource and download the file
    $ScriptBlock = (Invoke-WebRequest -UseBasicParsing -Uri $KickStartScriptFile).Content;
}

# Start our Kickstart wizard with our installation arguments for the Framework.
# This will ensure an automated run later on
$ScriptBlock += "`r`n`r`n Start-IcingaFrameworkWizard -RepositoryUrl 'https://github.com/Icinga/icinga-powershell-framework/archive/v1.1.2.zip' -ModuleDirectory 'C:\Program Files\WindowsPowerShell\modules\' -AllowUpdate 1 -SkipWizard;";

# We will call our Start-IcingaAgentInstallWizard and provide automation arguments to install
# and configure the Icinga Agent by using the Icinga Director Self-Service API. In addition,
# we will install the Framework as service
$ScriptBlock += "`r`n`r`n Start-IcingaAgentInstallWizard -SelfServiceAPIKey '56756378658n56t85679765n97649m7649m76' -UseDirectorSelfService 1 -DirectorUrl 'https://example.com/icingaweb2/director/' -OverrideDirectorVars 0 -ConvertEndpointIPConfig 1 -Ticket '' -EmptyTicket 1 -InstallFrameworkPlugins 0 -InstallFrameworkService 1 -FrameworkServiceUrl 'https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip' -ServiceDirectory 'C:\Program Files\icinga-framework-service\' -RunInstaller;"

# Install the Icinga PowerShell Plugins by using the Framework component installer
$ScriptBlock += "`r`n`r`n Install-IcingaFrameworkComponent -Name 'plugins' -Release;";
```

### Create the Script-Block and make it executable

Now as our PowerShell code itself is finished and we added our automation tasks, we can create a working script block based on our `ScriptBlock` variable and execute it.

```powershell
# Ensure TLS 1.2 and 1.1 are supported. This will prevent possible HTTPS errors on older systems
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
# Disable any progress bars. In addition, this will speed-up downloads
$ProgressPreference                         = "SilentlyContinue";
# Destination on where to load our Kickstart-Script file from.
# It doesn't matter if it is a web ressource, local drive or network share
$KickStartScriptFile                        = 'https://example.com/icinga/kickstart-script.ps1';
# Setup an emptry variable which will contain our code block later
$ScriptBlock                                = $null;

# Now check for your location and use the appropiate method to get the content
if ((Test-Path $KickStartScriptFile)) {
    # Use local drive or network share
    $ScriptBlock = Get-Content -Path $KickStartScriptFile -Raw;
} else {
    # Use our web ressource and download the file
    $ScriptBlock = (Invoke-WebRequest -UseBasicParsing -Uri $KickStartScriptFile).Content;
}

# Start our Kickstart wizard with our installation arguments for the Framework.
# This will ensure an automated run later on
$ScriptBlock += "`r`n`r`n Start-IcingaFrameworkWizard -RepositoryUrl 'https://github.com/Icinga/icinga-powershell-framework/archive/v1.1.2.zip' -ModuleDirectory 'C:\Program Files\WindowsPowerShell\modules\' -AllowUpdate 1 -SkipWizard;";

# We will call our Start-IcingaAgentInstallWizard and provide automation arguments to install
# and configure the Icinga Agent by using the Icinga Director Self-Service API. In addition,
# we will install the Framework as service
$ScriptBlock += "`r`n`r`n Start-IcingaAgentInstallWizard -SelfServiceAPIKey '56756378658n56t85679765n97649m7649m76' -UseDirectorSelfService 1 -DirectorUrl 'https://example.com/icingaweb2/director/' -OverrideDirectorVars 0 -ConvertEndpointIPConfig 1 -Ticket '' -EmptyTicket 1 -InstallFrameworkPlugins 0 -InstallFrameworkService 1 -FrameworkServiceUrl 'https://github.com/Icinga/icinga-powershell-service/releases/download/v1.1.0/icinga-service-v1.1.0.zip' -ServiceDirectory 'C:\Program Files\icinga-framework-service\' -RunInstaller;"

# Install the Icinga PowerShell Plugins by using the Framework component installer
$ScriptBlock += "`r`n`r`n Install-IcingaFrameworkComponent -Name 'plugins' -Release;";

# Create a script block based on our ScriptBlock variable and execute the code
Invoke-Command -ScriptBlock ([Scriptblock]::Create($ScriptBlock));
```

This is it - your automation task is completed and every single component is installed and configured.

### Create a Script/Module file with above mentioned code

Last but not least we can do some additional tweaks/improvements to the above mentioned code. This how ever depends on your internal policies and systems you are using.

#### PowerShell Remote Execution

You can run the entire above code on different machines. For this you can simply add `-ComputerName "FQDN of your target machine"` as argument to `Invoke-Command`. The `ScriptBlock` itself will be entirely build and constructed on your local machine, the actual code how ever will be executed on the remote host.

#### Create a Script-File to download

You can put all of the above mentioned code inside an own `.ps1` file and make it downloadable on a local ressource, network share of web resource. Afterwards you can use the above code as example to have less lines for execution. Lets assume you have stored the file as `icinga-automation.ps1` on the same location as the Kickstart script file mentioned above:

```powershell
# Ensure TLS 1.2 and 1.1 are supported. This will prevent possible HTTPS errors on older systems
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
# Disable any progress bars. In addition, this will speed-up downloads
$ProgressPreference                         = "SilentlyContinue";
# Destination on where to load our Kickstart-Script file from.
# It doesn't matter if it is a web ressource, local drive or network share
$KickStartScriptFile                        = 'https://example.com/icinga/icinga-automation.ps1';
# Setup an emptry variable which will contain our code block later
$ScriptBlock                                = $null;

# Now check for your location and use the appropiate method to get the content
if ((Test-Path $KickStartScriptFile)) {
    # Use local drive or network share
    $ScriptBlock = Get-Content -Path $KickStartScriptFile -Raw;
} else {
    # Use our web ressource and download the file
    $ScriptBlock = (Invoke-WebRequest -UseBasicParsing -Uri $KickStartScriptFile).Content;
}

# Create a script block based on our ScriptBlock variable and execute the code
Invoke-Command -ScriptBlock ([Scriptblock]::Create($ScriptBlock));
```

As you see the code is identical, we do how ever download the `icinga-automation.ps1` which contains the entire code examle with your Icinga Agent installation arguments including the additional Framework components. To make global changes, we can now simply modify our `icinga-automation.ps1` and have effect it our entire infrastructure at once.

#### Create a PowerShell Module

To make things a lot easier you can create an own module based on the code above with a custom installation function. The function then would allow you to parse arguments to, enabling a better and more dynamic configuration for each host. In addition, you would make use of the PowerShell Remote Execution handling to parse target hosts as arguments to connect to and deploy Icinga for Windows solution.

This could be used on a local automation host which will simply execute the local module, connect to the remote host and deploy the intended configuration.
