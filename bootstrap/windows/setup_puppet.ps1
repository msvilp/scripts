### Setup Puppet and run Puppet Agent

# Include other scripts to reduce repetition
. ".\utils.ps1"
. ".\config.ps1"

# (More or less) static variables
$location = 'C:\Users\Administrator\bootstrap'
$puppetVersion = '3.7.4'
$puppetArch = '-x64'
$puppetBaseUrl = 'https://downloads.puppetlabs.com/windows'
$puppetInstallerBaseName = "puppet-$puppetVersion$puppetArch.msi"
$puppetUrl = "$puppetBaseUrl/$puppetInstallerBaseName"
$puppetConfBasename = 'puppet.conf'
$puppetConfUrl = "$filesBaseUrl/common/$puppetConfBaseName"
$puppetBat = 'C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat'

### Script begin

New-Item -ItemType directory -Path $location -Force
Set-Location $location

### Download files

Invoke-WebRequest -Uri $puppetUrl -OutFile $puppetInstallerBaseName
download_file $puppetConfUrl "$location\$puppetConfBaseName"

### Setup Puppet

& msiexec.exe /qn /i $location\$puppetInstallerBaseName | Out-Null

Copy-Item $puppetConfBaseName "${Env:ProgramData}\PuppetLabs\puppet\etc\$puppetConfBaseName"

& $puppetBat agent --test --waitforcert 10 --certname test.example.com | Out-Null
