# Flush Icinga Agent API Directory

In some cases it might be helpful or required to flush the local Icinga Agent API directory from the disk. To assist with this process, there is a simple Cmdlet available.

## Delete the API Directory Content

To flush the content, you will have to stop the Icinga Agent service and run the following Cmdlet within an Icinga Shell:

```powershell
Clear-IcingaAgentApiDirectory
```

## Delete API Directory with automated Icinga Agent handling

In case you want to automate the process, you can add the `-Force` argument which will stop the Icinga Agent service for you, flush the API directory content and start the Icinga Agent afterwards again:

```powershell
Clear-IcingaAgentApiDirectory -Force
```
