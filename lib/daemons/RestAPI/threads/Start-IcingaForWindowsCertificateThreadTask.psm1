function Start-IcingaForWindowsCertificateThreadTask()
{
    New-IcingaThreadInstance `
        -Name 'CertificateRenewThread' `
        -ThreadPool (New-IcingaThreadPool -MaxInstances 1) `
        -Command 'New-IcingaForWindowsCertificateThreadTaskInstance' `
        -Start;
}
