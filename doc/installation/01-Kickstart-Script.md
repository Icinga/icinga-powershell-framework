Install the framework with the Kickstart Script
===

The easiest way to install the framework is by using the Kickstart Script provided from [this repository](https://github.com/Icinga/icinga-framework-kickstart).

The code provided there will ask questions on where to install the framework and where the framework files are provided from. The code below is a straight copy of the initial required code-block. Simply open a PowerShell instance as administrator and copy the following code block into it:

Getting Started
---

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

Next Steps
---

Once the above step is completed, simply follow the instructions and answer the questions the wizard will ask you. Once the framework is installed, the wizard will ask you if you wish to continue with the Agent installation wizard.

The entire purpose is to offer a fluent and seamless installation experience.
