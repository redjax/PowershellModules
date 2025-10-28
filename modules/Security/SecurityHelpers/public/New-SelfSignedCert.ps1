function New-SelfSignedCert {
    [CmdletBinding()]
    param(
        [string]$CertName = $null,
        [string]$CertStorePath = "Cert:\CurrentUser\My",
        [int]$CertKeyLength = 4096,
        [string]$CertAlgorithm = "RSA",
        [string]$CertHashAlgorithm = "SHA256",
        [string]$CertOutputDir = "C:\Temp"
    )

    if (-not $CertName) {
        Write-Error "You must give the certificate a name with -CertName."
        return
    }

    Write-Output "Generating certificate: $CertName"
    $Cert = New-SelfSignedCertificate `
        -Subject "CN=$CertName" `
        -CertStoreLocation "$($CertStorePath)" `
        -KeyExportPolicy Exportable `
        -KeySpec Signature `
        -KeyLength $CertKeyLength `
        -HashAlgorithm $CertHashAlgorithm

    if (-not (Test-Path -Path $CertOutputDir -Type Container)) {
        Write-Warning "Certificate output path does not exist: $CertOutputDir. Creating path."

        try {
            New-Item -ItemType Directory -Path "$($CertOutputDir)"
        }
        catch {
            Write-Error "Error creating certificate output path: $($CertOutputDir). Details: $($_.Exception.Message)"
            exit 1
        }
    }

    $CertFile = Join-Path $CertOutputDir "$($CertName).cer"
    Write-Output "Exporting certificate to $($CertFile)"

    try {
        Export-Certificate -Cert $Cert -FilePath "$($CertFile)"
        Write-Output "Certificate saved to path: $($CertFile)"
    }
    catch {
        Write-Error "Error saving certificate to path: $($CertFile). Details: $($_.Exception.Message)"
        exit 1
    }
}
