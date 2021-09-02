# Getting Started - Icinga for Windows

Icinga for Windows provides tools and functionality to entirely manage itself. This includes first-time deployment including later installation of new components or updating installed ones. To ensure a smooth setup procedure, we recommend using the by Icinga provided scripts and repositories as baseline for deployment inside environments.

## Requirements

* Windows 2012 R2 or later
* PowerShell Version 4.0 or later
* [Execution Policies](https://docs.microsoft.com/de-de/powershell/module/microsoft.powershell.core/about/about_execution_policies) allowing module/script execution
* Access to [packages.icinga.com](https://packages.icinga.com) at least from one location

## Installation Dependencies

In order to install Icinga for Windows as easy as possible, we will require at least from one location access to [packages.icinga.com](https://packages.icinga.com). On this page we can find the sub-section [IcingaForWindows](https://packages.icinga.com/IcingaForWindows), which contains an installation script [IcingaForWindows.ps1](https://packages.icinga.com/IcingaForWindows/IcingaForWindows.ps1) and our repositories we can fetch our components, including the [Icinga PowerShell Framework](https://github.com/Icinga/icinga-powershell-framework) from.

**Note:** If you already installed Icinga for Windows, you can synchronize the exiting repository from [packages.icinga.com](https://packages.icinga.com/IcingaForWindows) and download and paste the [IcingaForWindows.ps1](https://packages.icinga.com/IcingaForWindows/IcingaForWindows.ps1) with our synced content to an internal webserver, network share or locally on systems. The next steps can then be adjusted depending on your locations.

## Install Icinga for Windows

To install Icinga for Windows from systems with internet access, we can simply run this short PowerShell code inside an `administrative` PowerShell, to download the [IcingaForWindows.ps1](https://packages.icinga.com/IcingaForWindows/IcingaForWindows.ps1) and execute it afterwards:

```powershell
[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11';
$ProgressPreference                         = 'SilentlyContinue';
[string]$ScriptFile                         = 'C:\Users\Public\IcingaForWindows.ps1';

Invoke-WebRequest `
    -UseBasicParsing `
    -Uri 'https://packages.icinga.com/IcingaForWindows/IcingaForWindows.ps1' `
    -OutFile $ScriptFile;

& $ScriptFile
```

This will write the PowerShell scriptfile into `C:\Users\Public`.

Once the script is executed, you will be prompted with several questions on where the Icinga PowerShell Framework should be installed (defaults to `C:\Program Files\WindowsPowerShell\Modules`) and if you would like to run the Icinga Management Console afterwards for completing the installation.

## Automate the installation

To automate the entire process, you can define several arguments during the script call.

### Script arguments

| Argument         | Type   | Description |
| ---              | ---    | ---         |
| IcingaRepository | String | The location (local, web or network share) of your Icinga for Windows repository. Defaults to `https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json` |
| ModuleDirectory  | String | Allows to specify in which PowerShell directory Icinga for Windows will be installed. If left empty, you will be prompted with a dialog, asking on where Icinga for Windows should be installed into. Defaults to `$null` |
| AnswerFile       | String | Allows you to provide an answer file, starting with Icinga for Windows 1.6.0, which will apply the specified configuration after the Framework has been installed. Defaults to `''` |
| InstallCommand   | String | Allows you to provide an install command, starting with Icinga for Windows 1.6.0, which will apply the specified configuration after the Framework has been installed. Defaults to `''` |
| AllowUpdate      | Switch | Defines if the Icinga PowerShell Framework should be updated during the kickstart run, in case it is already installed. Defaults to `$False` |
| SkipWizard       | Switch |Defines to only install the Icinga PowerShell Framework and/or update it if specified. Will skip the question for the installation wizard/Icinga Management Console afterwards and will ignore provided arguments `-AnswerFile` and `-InstallCommand`. Defaults to `$False` |

### Installation Examples

#### Automated installation with skipped wizard

```powershell
[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11';
$ProgressPreference                         = 'SilentlyContinue';
[string]$ScriptFile                         = 'C:\Users\Public\IcingaForWindows.ps1';

Invoke-WebRequest `
    -UseBasicParsing `
    -Uri 'https://packages.icinga.com/IcingaForWindows/IcingaForWindows.ps1' `
    -OutFile $ScriptFile;

& $ScriptFile `
    -ModuleDirectory 'C:\Program Files\WindowsPowerShell\Modules\' `
    -SkipWizard;
```

#### Automated installation with InstallCommand

```powershell
[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11';
$ProgressPreference                         = 'SilentlyContinue';
[string]$ScriptFile                         = 'C:\Users\Public\IcingaForWindows.ps1';

Invoke-WebRequest `
    -UseBasicParsing `
    -Uri 'https://packages.icinga.com/IcingaForWindows/IcingaForWindows.ps1' `
    -OutFile $ScriptFile;

& $ScriptFile `
    -ModuleDirectory 'C:\Program Files\WindowsPowerShell\Modules\' `
    -InstallCommand '{"IfW-DirectorSelfServiceKey":{"Values":["651f889ca5f364e89ed709eabde6237fb02050ff"]},"IfW-DirectorUrl":{"Values":["https://icinga.example.com/icingaweb2/director"]}}';
```

#### Automated installation with InstallCommand and own IcingaRepository

```powershell
[Net.ServicePointManager]::SecurityProtocol = 'tls12, tls11';
$ProgressPreference                         = 'SilentlyContinue';
[string]$ScriptFile                         = 'C:\Users\Public\IcingaForWindows.ps1';

Invoke-WebRequest `
    -UseBasicParsing `
    -Uri 'https://icinga.example.com/IcingaForWindows.ps1' `
    -OutFile $ScriptFile;

& $ScriptFile `
    -ModuleDirectory 'C:\Program Files\WindowsPowerShell\Modules\' `
    -InstallCommand '{"IfW-DirectorSelfServiceKey":{"Values":["651f889ca5f364e89ed709eabde6237fb02050ff"]},"IfW-DirectorUrl":{"Values":["https://icinga.example.com/icingaweb2/director"]}}' `
    -IcingaRepository 'https://icinga.example.com/repositories/stable';
```
