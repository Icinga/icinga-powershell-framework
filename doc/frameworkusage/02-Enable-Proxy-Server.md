# Enable Proxy Server

With Icinga PowerShell Framework v1.3.0 we added support for using Proxy servers while using web requests to download and fetch information. For this we added a custom function `Invoke-IcingaWebRequest` as wrapper function for `Invoke-WebRequest`.

## Enable Proxy Server Support

To enable the proxy server support, you simply have to use the Cmdlet `Set-IcingaFrameworkProxyServer` and set your proxy server:

```powershell
Set-IcingaFrameworkProxyServer -Server 'http://example.com:8080';
```

Once set, the Framework will automatically use this server configuration for all web requests.

## Disable Proxy Server Support

To disable the proxy server, you can use the same Cmdlet again, but leaving the argument empty.

```powershell
Set-IcingaFrameworkProxyServer;
```

Now all web requests are executed without the proxy server.
