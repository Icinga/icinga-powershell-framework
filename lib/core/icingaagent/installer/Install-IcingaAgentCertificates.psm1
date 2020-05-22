function Install-IcingaAgentCertificates()
{
    param(
        [string]$Hostname,
        [string]$Endpoint,
        [int]$Port        = 5665,
        [string]$CACert,
        [string]$Ticket,
        [switch]$Force    = $FALSE
    );

    if ([string]::IsNullOrEmpty($Hostname)) {
        throw 'Failed to install Icinga Agent certificates. Please provide a hostname';
    }

    # Default for Icinga 2.8.0 and above
    [string]$NewCertificateDirectory = (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\var\lib\icinga2\certs\');
    [string]$OldCertificateDirectory = (Join-Path -Path $Env:ProgramData -ChildPath 'icinga2\etc\icinga2\pki\');
    [string]$CertificateDirectory    = $NewCertificateDirectory;
    if ((Compare-IcingaVersions -RequiredVersion '2.8.0') -eq $FALSE) {
        # Certificate path for versions older than 2.8.0
        $CertificateDirectory = $OldCertificateDirectory;
        Move-IcingaAgentCertificates -Source $NewCertificateDirectory -Destination $OldCertificateDirectory;
    } else {
        Move-IcingaAgentCertificates -Source $OldCertificateDirectory -Destination $NewCertificateDirectory;
    }

    if (-Not (Test-IcingaAgentCertificates -CertDirectory $CertificateDirectory -Hostname $Hostname -Force $Force)) {
        Write-IcingaConsoleNotice ([string]::Format('Generating host certificates for host "{0}"', $Hostname));

        $arguments = [string]::Format('pki new-cert --cn {0} --key {1}{0}.key --cert {1}{0}.crt',
            $Hostname,
            $CertificateDirectory
        );

        if ((Start-IcingaAgentCertificateProcess -Arguments $arguments) -eq $FALSE) {
            throw 'Failed to generate host certificate';
        }
    }

    if ([string]::IsNullOrEmpty($Endpoint) -And [string]::IsNullOrEmpty($CACert)) {
        Write-IcingaConsoleNotice 'Your host certificates have been generated successfully. Please either specify an endpoint to connect to or provide the path to a valid ca.crt.';
        return $TRUE;
    }

    if (-Not [string]::IsNullOrEmpty($Endpoint)) {
        if (-Not (Test-IcingaAgentCertificates -CertDirectory $CertificateDirectory -Hostname $Hostname -TestTrustedParent -Force $Force)) {

            Write-IcingaConsoleNotice ([string]::Format('Fetching trusted master certificate from "{0}"', $Endpoint));

            # Argument --key for save-cert is deprecated starting with Icinga 2.12.0
            if (Compare-IcingaVersions -RequiredVersion '2.12.0') {
                $arguments = [string]::Format('pki save-cert --trustedcert {0}trusted-parent.crt --host {1} --port {2}',
                    $CertificateDirectory,
                    $Endpoint,
                    $Port
                );
            } else {
                $arguments = [string]::Format('pki save-cert --key {0}{1}.key --trustedcert {0}trusted-parent.crt --host {2} --port {3}',
                    $CertificateDirectory,
                    $Hostname,
                    $Endpoint,
                    $Port
                );
            }

            if ((Start-IcingaAgentCertificateProcess -Arguments $arguments) -eq $FALSE) {
                Write-IcingaConsoleError 'Unable to connect to your provided Icinga CA. Please verify the entered configuration is correct.' `
                            'If you are not able to connect to your Icinga CA from this machine, you will have to provide the path' `
                            'to your Icinga ca.crt and use the CA-Proxy certificate handling.';
                return $TRUE;
            }
        }

        if (-Not (Test-IcingaAgentCertificates -CertDirectory $CertificateDirectory -Hostname $Hostname -TestCACert -Force $Force)) {
            [string]$PKIRequest = 'pki request --host {0} --port {1} --ticket {4} --key {2}{3}.key --cert {2}{3}.crt --trustedcert {2}trusted-parent.crt --ca {2}ca.crt';

            if ([string]::IsNullOrEmpty($Ticket)) {
                $PKIRequest = 'pki request --host {0} --port {1} --key {2}{3}.key --cert {2}{3}.crt --trustedcert {2}trusted-parent.crt --ca {2}ca.crt';
            }

            $arguments = [string]::Format($PKIRequest,
                $Endpoint,
                $Port,
                $CertificateDirectory,
                $Hostname,
                $Ticket
            );

            if ((Start-IcingaAgentCertificateProcess -Arguments $arguments) -eq $FALSE) {
                throw 'Failed to sign Icinga certificate';
            }

            if ([string]::IsNullOrEmpty($Ticket)) {
                Write-IcingaConsoleNotice 'Your certificates were generated successfully. Please sign the certificate now on your Icinga CA master. You can lookup open requests with "icinga2 ca list"';
            } else {
                Write-IcingaConsoleNotice 'Icinga certificates successfully installed';
            }
        }

        return $TRUE;
    } elseif (-Not [string]::IsNullOrEmpty($CACert)) {
        if (-Not (Copy-IcingaAgentCACertificate -CAPath $CACert -Desination $CertificateDirectory)) {
            return $FALSE;
        }
        Write-IcingaConsoleNotice 'Host-Certificates and ca.crt are present. Please start your Icinga Agent now and manually sign your certificate request on your CA master. You can lookup open requests with "icinga2 ca list"';
    }

    return $TRUE;
}

function Start-IcingaAgentCertificateProcess()
{
    param(
        $Arguments
    );

    $Binary  = Get-IcingaAgentBinary;
    $Process = Start-IcingaProcess -Executable $Binary -Arguments $Arguments;

    if ($Process.ExitCode -ne 0) {
        Write-IcingaConsoleError ([string]::Format('Failed to create certificate.{0}Arguments: {1}{0}Error:{2} {3}', "`r`n", $Arguments, $Process.Message, $Process.Error));
        return $FALSE;
    }

    Write-IcingaConsoleNotice $Process.Message;
    return $TRUE;
}

function Move-IcingaAgentCertificates()
{
    param(
        [string]$Source,
        [string]$Destination
    );

    $SourceDir = Join-Path -Path $Source -ChildPath '\*';
    $TargetDir = Join-Path -Path $Destination -ChildPath '\';

    Move-Item -Path $SourceDir -Destination $TargetDir;
}

function Test-IcingaAgentCertificates()
{
    param(
        [string]$CertDirectory,
        [string]$Hostname,
        [switch]$TestCACert,
        [switch]$TestTrustedParent,
        [bool]$Force
    );

    if ($Force) {
        return $FALSE;
    }

    if ($TestCACert) {
        if (Test-Path (Join-Path -Path $CertDirectory -ChildPath 'ca.crt')) {
            Write-IcingaConsoleNotice 'Your ca.crt is present. No generation or fetching required';
            return $TRUE;
        } else {
            Write-IcingaConsoleWarning 'Your ca.crt is not present. Manuall copy or fetching from your Icinga CA is required.';
            return $FALSE;
        }
    }

    if ($TestTrustedParent) {
        if (Test-Path (Join-Path -Path $CertDirectory -ChildPath 'trusted-parent.crt')) {
            Write-IcingaConsoleNotice 'Your trusted-parent.crt is present. No fetching or generation required';
            return $TRUE;
        } else {
            Write-IcingaConsoleWarning 'Your trusted master certificate is not present. Fetching from your CA server is required';
            return $FALSE;
        }
    }

    if ((-Not (Test-Path ((Join-Path -Path $CertDirectory -ChildPath $Hostname) + '.key'))) `
        -Or -Not (Test-Path ((Join-Path -Path $CertDirectory -ChildPath $Hostname) + '.crt'))) {
        return $FALSE;
    }

    [string]$hostCRT = [string]::Format('{0}.crt', $Hostname);
    [string]$hostKEY = [string]::Format('{0}.key', $Hostname);

    $certificates = Get-ChildItem -Path $CertDirectory;
    # Now loop each file and match their name with our hostname
    foreach ($cert in $certificates) {
        if ($cert.Name.toLower() -eq $hostCRT.toLower() -Or $cert.Name.toLower() -eq $hostKEY.toLower()) {
            $file = $cert.Name.Replace('.key', '').Replace('.crt', '');
            if (-Not ($file -clike $Hostname)) {
                Write-IcingaConsoleWarning ([string]::Format('Certificate file {0} is not matching the hostname {1}. Certificate generation is required.', $cert.Name, $Hostname));
                return $FALSE;
            }
        }
    }

    Write-IcingaConsoleNotice 'Icinga host certificates are present and valid. No generation required';

    return $TRUE;
}

function Copy-IcingaAgentCACertificate()
{
    param(
        [string]$CAPath,
        [string]$Desination
    );

    # Copy ca.crt from local path or network share to certificate path
    if ((Test-Path $CAPath)) {
        Copy-Item -Path $CAPath -Destination (Join-Path -Path $Desination -ChildPath 'ca.crt') | Out-Null;
        Write-IcingaConsoleNotice ([string]::Format('Copied ca.crt from "{0}" to "{1}', $CAPath, $Desination));
    } else {
        # It could also be a web ressource
        try {
            $response   = Invoke-WebRequest $CAPath -UseBasicParsing;
            [int]$Index = $response.RawContent.IndexOf("`r`n`r`n") + 4;

            [string]$CAContent = $response.RawContent.SubString(
                $Index,
                $response.RawContent.Length - $Index
            );
            Set-Content -Path (Join-Path $Desination -ChildPath 'ca.crt') -Value $CAContent;
            Write-IcingaConsoleNotice ([string]::Format('Downloaded ca.crt from "{0}" to "{1}', $CAPath, $Desination))
        } catch {
            Write-IcingaConsoleError 'Failed to load any provided ca.crt ressource';
            return $FALSE;
        }
    }

    return $TRUE;
}

Export-ModuleMember -Function @('Install-IcingaAgentCertificates');
