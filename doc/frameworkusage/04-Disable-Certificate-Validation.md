# Disable Certificate Validation

In some cases it might be required to disable checks for certificates while performing web requests. This is especially true while using self signed certificates which are not installed on the local Windows machine.

## Disable Validation

To disable the certificate check for the entire certificate chain, you can simply use the following command within an Icinga Shell:

```powershell
Enable-IcingaUntrustedCertificateValidation
```

Once enabled, certificates will no longer be checked while using this PowerShell instance. Web calls by using `Invoke-WebRequest` or `Invoke-IcingaWebRequest` will proceed, regardless of the certificate behind and possible SSL/TLS errors.

## Enable Validation

To enable the validation again, you will have to close the PowerShell session and create a new one. There is no Cmdlet available to enable it again.
