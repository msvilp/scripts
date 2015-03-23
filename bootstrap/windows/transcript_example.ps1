### Example of Powershell script transcript and log

$logBaseName = "bootstrap-log.txt"
$transcriptBaseName = "bootstrap-transcript.txt"

Start-Transcript -Path $transcriptBaseName -Force

Add-Content $logBaseName -value "Initializing"
Add-Content $logBaseName -value "Downloading files"
Add-Content $logBaseName -value "Setting up an application"

Stop-Transcript
