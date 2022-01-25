# Developer Guide - General Information

This guide will introduce you on how to write custom PowerShell modules (described as Icinga for Windows components) and how certain aspects of the architecture work.

## PowerShell Module Architecture

Each single PowerShell module has to be installed inside a module directory of Windows. You can view a list of current available locations by using `$Env:PSModulePath`. By default, we are going to use the directory `C:\Program Files\WindowsPowerShell\Modules`.

### Folder Structure

To create a new module, you can create a custom folder within the PowerShell module folder. This folder is the namespace of your module and is required for later creating the `RootModule` and `Manifest`.

Within your module folder, you are free to create as many sub-directories as you want and place script and module files there, which are shipped and used by your module.

### Manifest And RootModule

To provide all basic information, you will require to create at least a `Manifest` file, which has the file ending `.psd1`. The name of the file has to match the folder name you choose as namespace for your module in the previous section.

Our `RootModule` is using the file ending `.psm1` and can use the same name as your folder, but is not required to, as long as a valid `.psd1` file is present. Within our manifest, we can define the path on where the `.psm1` can be found.

### Nested Modules

While writing your own module, you will add additional code and possible different files to your project. By adding additional `.psm1` files for easier loading of functions, we can use the `NestedModules` attribute within our `.psd1` file, to add them to our known module list.

Please note that it is only required to use the relative path, starting with `.\` to use the root directory of your module as base.

Lets assume we have the following file structure:

```text
module
  |_ plugin.psd1
  |_ plugin.psm1
  |_ provider
     |_ custom_provider.psm1
  |_ plugin
     |_ custom_plugin.psm1
```

In this case, our `NestedModules` variable within our `.psd1` file requires the following values

```powershell
    NestedModules = @(
        '.\provider\custom_provider.psm1',
        '.\provider\custom_plugin.psm1'
    )
```

### Data Management

Icinga for Windows is using one global variable `$Global:Icinga`, to store information for daemons and other tasks. This variable is split into three different categories, which you can read more on below. The general architecture of this construct is a simple `hashtable`.
You can interact with this variable and sub-entries like you would with normal `hashtables`, making data stored a lot easier to access and maintain.

#### Private

Everything which should be stored while a daemon is running internally or within a PowerShell session and **not** being shared with other daemons, is stored within the `$Global:Icinga.Private` space.

The following entries are set by default within the `Private` space:

| Category           | Description |
| ---                | ---         |
| Timers             | All created timers by using `Start-IcingaTimer` are stored under this environment variable |
| Scheduler          | Once plugins are executed, performance data, check results and exit codes are stored in this section, in case the PowerShell instance is set to run as daemon |
| Daemons            | This is a place where all daemon data should be added and stored, separated by a namespace for each module as entry. This data is **not** shared between other daemons |
| PerformanceCounter | A space to share all PerformanceCounter information between threads, which counters are already created for internal usage |

#### Example Data

```powershell
$Global:Icinga.Private.Timers.DefaultTimer
```

```powershell
$Global:Icinga.Private.Scheduler.CheckResults
```

```powershell
$Global:Icinga.Private.Daemons.ServiceCheck.PerformanceCache
```

#### Public

Everything stored within the `Public` space of `$Global:Icinga` is automatically shared between all threads of the current PowerShell instance. If you run the `ServiceCheckDaemon` in addition with the `RestAPI` for example, metrics over time will be read from the public shared space from the `RestApi` and used during check execution.

There is no manual configuration required to share the information, as Icinga for Windows will deal with this for you, once a new thread instance is created.

The following entries are set by default within the `Public` space:

| Category    | Description |
| ---         | ---         |
| ThreadPools | A list of all thread pools available to create new thread limits for certain background daemons |
| Daemons     | A place to store shared information for each single daemon within a namespace, making data accessible to other threads |
| Threads     | A list of all started and available threads running by Icinga for Windows |

##### Example Data

```powershell
$Global:Icinga.Public.ThreadPools.MainPool
```

```powershell
$Global:Icinga.Public.Daemons.RESTApi.ClientBlacklist
```

```powershell
$Global:Icinga.Public.Threads.'Start-IcingaForWindowsDaemon::Add-IcingaForWindowsDaemon::Main::0'
```

#### Protected

This is a section reserved for Icinga for Windows and Icinga developers in general. This space will store general information for Icinga for Windows, determining on how the PowerShell instance is handling internal requests and procedures.

As custom module developer, you can **read** from this space but are in genetal **not** allowed to store information there. Please use the `Private` and `Public` space for this.

The following entries are set by default within the `Protected` space:

| Category    | Description |
| ---         | ---         |
| JEAContext  | Tells Icinga for Windows that the current environment is running within a JEA context |
| RunAsDaemon | Tells Icinga for Windows that the current PowerShell instance is running as daemon, changing behaviors on error and plugin execution handling |
| DebugMode   | Enables the debug mode of Icinga for Windows, printing additional details during operations or tasks |
| Minimal     | Changes certain behavior regarding check execution and internal error handling |

## Using Icinga for Windows Dev Tools

Maintaining the entire structure above seems to be complicated at the beginning, especially when considering to update the `NestedModules` section whenever you make changes. To mitigate this, Icinga for Windows provides a bunch of Cmdlets to help with the process

### Create New Components

To create new components, you can use the command `New-IcingaForWindowsComponent`. It will create a new PowerShell module inside the same module directory, were you installed the Framework itself.

The command ships with a bunch of configurations to modify the created `.psd1` in addition, with a different author, copyright, and so on. the most important arguments how ever are `Name` and `ComponentType`.

| Argument      | Type   | Description                                     |
| ---           | ---    | ---                                             |
| Name          | String | The name of your Icinga for Windows component. This will create a new module in the following syntax: `icinga-powershell-{name}` |
| ComponentType | String | The type of component you want to create for Icinga for Windows with different base-modules and code available to get started quickly. Available types: `plugins`, `apiendpoint`, `daemon`, `library` |
| OpenInEditor  | Switch | Will directly open the module after creation inside an editor for editing |

### Publish/Update Components

Once you have started to write your own code, you can use the Cmdlet `Publish-IcingaForWindowsComponent` to update the `NestedModules` attribute inside the `.psd1` file automatically, including the documentation in case the module is of type plugin.

In addition, you ca create a `.zip` file for this module which can be integrated directly into the [Repository Manager](..\120-Repository-Manager\01-Add-Repositories.md). By default, created `.zip` files will be created in your home folder, the path can how ever be changed while executing the command.

| Argument             | Type   | Description                                     |
| ---                  | ---    | ---                                             |
| Name                 | String | The name of your Icinga for Windows component to update information from |
| ReleasePackagePath   | String | The path on where the `.zip` file will be created in. Defaults to the current users home folder |
| CreateReleasePackage | Switch | This will toggle the `.zip` file creation of the specified package |

### Testing Your Component

In order to validate if your module can be loaded and is working properly, you can use the command `Test-IcingaForWindowsComponent`. In addition to an import check, it will also validate the code styling and give you an overview if and how many issues there are with your code.

By default, only a summary of possible issues is added to the output, you can how ever use an argument flag to print a list of possible found issues, allowing you to resolve them more easily.

| Argument   | Type   | Description                                     |
| ---        | ---    | ---                                             |
| Name       | String | The name of your Icinga for Windows component to test |
| ShowIssues | Switch | Prints a list of all possible found issues into the console |

### Open Components

A quick and easy way for opening components inside an editor is to use the command `Open-IcingaForWindowsComponentInEditor`. You simply require to specify the name of the component and the editor is opening.

At the moment, only [Visual Studio Code](https://code.visualstudio.com/) is supported. More editors will follow in the future.

| Argument | Type   | Description                                     |
| ---      | ---    | ---                                             |
| Name     | String | The name of your Icinga for Windows component to open |
| Editor   | String | Allows to specify, which editor the component should be opened with. Supported values: `code` |
