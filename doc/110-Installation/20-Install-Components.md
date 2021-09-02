# Install Icinga for Windows Components

Icinga for Windows uses repositories, containing components which can be installed to extend the functionality of the monitoring and the capabilities of Icinga for Windows itself.

To use these repositories, you have to add them to your environment first.

## Add Official Icinga Repositories

By default, no repository is configured on Icinga for Windows after installation. The default repository `https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json` is added in case not being changed after a successful [IMC installation](03-Installation-with-IMC.md).

Of course you can also add the repositories manually.

### Add Official Icinga Stable Repository

For the latest stable releases, you can use this command:

```powershell
Add-IcingaRepository `
    -Name 'Icinga Stable' `
    -RemotePath 'https://packages.icinga.com/IcingaForWindows/stable/ifw.repo.json';
```

### Add Official Icinga Snapshot Repository

You can also add a snapshot repository to get the latest snapshot builds for components:

```powershell
Add-IcingaRepository `
    -Name 'Icinga Snapshot' `
    -RemotePath 'https://packages.icinga.com/IcingaForWindows/snapshot/ifw.repo.json';
```

### Add Official Icinga Development Repository for Components

In case you want to test out a certain feature which is currently in development, you can add a repository for this specific component including the development branch, the feature is developed in:

```powershell
[string]$Project = 'icinga-powershell-framework';
[string]$Branch  = 'feature/adds_jea_profile_handling';

Add-IcingaRepository `
    -Name "$Project/$Branch" `
    -RemotePath "https://packages.icinga.com/IcingaForWindows/snapshot/$Project/$Branch/ifw.repo.json";
```

Unlike other components, you can then install directly this development feature by using the branch name as version:

#### Code with variable placeholders

```powershell
Install-IcingaComponent -Name $Project.Replace('icinga-powershell-', '') -Version $Branch -Snapshot -Force;
```

#### Code with direct names


```powershell
Install-IcingaComponent -Name 'framework' -Version 'feature/adds_jea_profile_handling' -Snapshot -Force;
```

### Add Own/Non-Official Repositories

You can create your [own repositories](../120-Repository-Manager/07-Create-Own-Repositories.md) or [sync existing repositories](../120-Repository-Manager/02-Sync-Repositories.md) as well, to install components from. Please have a look on the individual documentation pages.

## Install Component

You can use the [repository search](../120-Repository-Manager/04-Search-Repository.md) to lookup the repository and find components to install. Once you have the name, you can run the installation with the following command as example:

```powershell
Install-IcingaComponent -Name 'plugins';
```

You can find a detailed description of the command on the [install components documentation](../120-Repository-Manager/05-Install-Components.md).
