$Cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2("p:\certs\soho-codesign\soho.pfx", "")
Set-AuthenticodeSignature -FilePath p:\Github\inno-openvpn\openvpn-installer-2.6.14.20250616-x64.exe -Certificate $Cert -TimeStampServer http://timestamp.digicert.com

