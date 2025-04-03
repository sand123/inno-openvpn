$Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("p:\certs\soho-codesign\soho.pfx", "")
Set-AuthenticodeSignature -FilePath p:\Github\inno-openvpn\openvpn-installer-2.6.13.20250401-x64.exe -Certificate $Cert -TimeStampServer http://timestamp.digicert.com

