# Invoke-WebRequest will fail with self-signed certificates:
#
# <https://connect.microsoft.com/PowerShell/feedback/details/419466/new-webserviceproxy-needs-force-parameter-to-ignore-ssl-errors>
#
# This solution is combined from a few of sources:
#
# <http://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error/15841856>
# <http://powershell.org/wp/forums/topic/trouble-with-invoke-webrequest>
# <https://msdn.microsoft.com/en-us/library/system.net.webclient%28v=vs.110%29.aspx>
#
function download_file($url, $targetfile) {
    # In this case fully-qualified paths are necessary.
    $wc = New-Object System.Net.WebClient
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $wc.Credentials = New-Object System.Net.NetworkCredential($filesHTTPUser, $filesHTTPPassword)
    $wc.DownloadFile($url, $targetfile)
}
