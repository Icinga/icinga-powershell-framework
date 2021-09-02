# Install the Framework with the Kickstart Script

The easiest way to install the framework is by using the Kickstart Script provided from [this repository](https://github.com/Icinga/icinga-powershell-kickstart).

The code provided there will ask questions on where to install the framework and where the framework files are provided from. The code below is a straight copy of the initial required code-block. Simply open a PowerShell instance as administrator and copy the following code block into it:

## Getting Started

```powershell
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11";
$ProgressPreference = "SilentlyContinue";

$global:IcingaFrameworkKickstartSource = 'https://raw.githubusercontent.com/Icinga/icinga-powershell-kickstart/master/script/icinga-powershell-kickstart.ps1';

$Script = (Invoke-WebRequest -UseBasicParsing -Uri $global:IcingaFrameworkKickstartSource).Content;
$Script += "`r`n`r`n Start-IcingaFrameworkWizard;";

Invoke-Command -ScriptBlock ([Scriptblock]::Create($Script));
```

What this block will do is to download the PowerShell Script from the repository, add it into a ScriptBlock to allow execution and finally execute it.

The ServicePointManager part will ensure communication is possible to GitHub for example, as by default PowerShell will be unable to open a secure connection otherwise.
Last but not least we will set the progress preference to `SilentlyContinue`, ensuring the PowerShell progress bar will not slow down our installation.

The Script file from `https://raw.githubusercontent.com/Icinga/icinga-powershell-kickstart/master/script/icinga-powershell-kickstart.ps1` will be downloaded and executed within your current PowerShell instance. It will ask a bunch of questions on where the Icinga PowerShell Framework should be downloaded from and where it should be installed.

Once completed, the kickstart will ask if you want to continue with the Icinga Agent installation wizard.

## Offline Installation

Of course you can also use the kickstart script file for offline installation in case you have no access to the internet. For this you will have to download the script file manually once and place it either on an internal web server from which the kickstart script can fetch the `.ps1` file or provide it by a network share or local drive.

### Offline Internal Web-Server

If you are using an internal web server for the kickstart script you simply have to modify the line

```powershell
$global:IcingaFrameworkKickstartSource = 'https://raw.githubusercontent.com/Icinga/icinga-powershell-kickstart/master/script/icinga-powershell-kickstart.ps1';
```

from the script above to match your internal web server location. This could for example be:

```powershell
$global:IcingaFrameworkKickstartSource = 'https://example.com/icinga-kickstart/icinga-powershell-kickstart.ps1';
```

Once you copy the modified script block into your PowerShell, it will download the kickstart from your internal ressource and execute the code in the same way as before - just without requiring an internet connection.

### Offline Network Share/Local Location

To use the kickstart script from a local file ressource like a network share or on a local drive on your machine, you can run this code snippet to load it from there. Just replace the path to the kickstart file with the actual path in your enrivonment:

```powershell
$global:IcingaFrameworkKickstartSource = 'C:\icinga\kickstart\icinga-powershell-kickstart.ps1';

$Script = Get-Content -Path $global:IcingaFrameworkKickstartSource -Raw;
$Script += "`r`n`r`n Start-IcingaFrameworkWizard;";

Invoke-Command -ScriptBlock ([Scriptblock]::Create($Script));
```

As with the web installation process, the kickstart wizard will then guide you through the installation.

## Note on Start-IcingaFrameworkWizard and automation

Every example above contains the following code part:

```powershell
$Script += "`r`n`r`n Start-IcingaFrameworkWizard;";
```

This snippet will ensure that once the kickstart script is downloaded it will be executed and asks a bunch of questions:

* Where to download the Icinga PowerShell Framework from
* Where to install the Icinga PowerShell Framework to
* Are updates of the Framework allowed
* Should the Icinga Agent installation and configuration wizard be started afterwards

### Automation with the Kickstart-Script

To automate the entire process once the kickstart script is executed, you can add aditional arguments to the call to manage the configuration.  The following arguments are supported

| Argument         | Type   | Description |
| ---              | ---    | ---         |
| -RepositoryUrl   | String | A web, local or network path path pointing the Icinga PowerShell Framework .zip file |
| -ModuleDirectory | String | The target on which the Icinga PowerShell Framework will be installed into |
| -AllowUpdate     | Bool   | Defines if an existing version of the Framework should be upgraded/downgraded |
| -SkipWizard      | Switch | Defines if the Icinga Agent installation wizard should be skipped |

You can simply update the line

```powershell
$Script += "`r`n`r`n Start-IcingaFrameworkWizard;";
```

to match your configuration properly.

#### Automation Example 1: Use local web server for Framework download

We will download the Icinga PowerShell Framework from a local web server and install it in the recommended module directory. In addition we want to allow updates and do not want to start the Icinga Agent wizard afterwards:

```powershell
$Script += "`r`n`r`n Start-IcingaFrameworkWizard -RepositoryUrl 'https://example.com/icingaforwindows/icinga-powershell-framework.zip' -ModuleDirectory 'C:\Program Files\WindowsPowerShell\modules\' -AllowUpdate 1 -SkipWizard;";
```

#### Automation Example 2: Use local/network path for Framework "download"

We will use a local drive or a network share to fetch the Icinga PowerShell Framework from and install it in the recommended module directory. In addition we want to allow updates and do not want to start the Icinga Agent wizard afterwards:

```powershell
$Script += "`r`n`r`n Start-IcingaFrameworkWizard -RepositoryUrl 'C:\icinga\icinga-powershell-framework.zip' -ModuleDirectory 'C:\Program Files\WindowsPowerShell\modules\' -AllowUpdate 1 -SkipWizard;";
```

## Execute the Icinga Agent installation wizard

Depending on how you used the kickstart script above, you are either directly asked if you want to continue with the Icinga Agent installation wizard or not. Even if you hit `no`, you are still able to execute it afterwards. Please follow the [Icinga Agent Wizard](04-Icinga-Agent-Wizard.md) guide for examples and usage.
