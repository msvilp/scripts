### Install OpenVPN and connect to a VPN server to get access to intranet 
### resources

# Include other scripts to reduce repetition
. ".\utils.ps1"
. ".\config.ps1"

# (More or less) static variables
$location = 'C:\Users\Administrator\bootstrap'
$openvpnVersion = '2.3.6'
$openvpnBuild = 'I603'
$openvpnArch = 'x86_64'
$openvpnBaseUrl = 'http://swupdate.openvpn.org/community/releases'
$openvpnInstallerBaseName = "openvpn-install-$openvpnVersion-$openvpnBuild-$openvpnArch.exe"
$openvpnUrl = "$openvpnBaseUrl/$openvpnInstallerBaseName"

$ovpnCertBaseName = 'openvpn.cer'
$ovpnCertUrl = "$filesBaseUrl/windows/$ovpnCertBaseName"
$ovpnConfBasename = 'client.ovpn'
$ovpnConfUrl = "$filesBaseUrl/common/$ovpnConfBaseName"
$ovpnPassBaseName = 'client.pass'
$ovpnPassUrl = "$filesBaseUrl/common/$ovpnPassBaseName"

### Script begin
New-Item -ItemType directory -Path $location -Force
Set-Location $location

### Download files

Invoke-WebRequest -Uri $openvpnUrl -OutFile "$openvpnInstallerBaseName"
Invoke-WebRequest -Uri $puppetUrl -OutFile $puppetInstallerBaseName
download_file $ovpnCertUrl "$location\$ovpnCertBaseName"
download_file $ovpnConfUrl "$location\$ovpnConfBaseName"
download_file $ovpnPassUrl "$location\$ovpnPassBaseName"

### Setup OpenVPN

# Import OpenVPN publisher certificate so that tap-windows6 driver installation does not give a warning
Import-Certificate -FilePath $ovpnCertBaseName -CertStoreLocation cert:\LocalMachine\TrustedPublisher

& $location\$openvpnInstallerBaseName /S | Out-Null

Copy-Item $ovpnConfBaseName "${Env:ProgramFiles}\openvpn\config\$ovpnConfBaseName"
Copy-Item $ovpnPassBaseName "${Env:ProgramFiles}\openvpn\config\$ovpnPassBaseName"

Start-Service OpenVPNService
Set-Service OpenVPNService -StartupType Automatic
