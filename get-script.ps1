function get-script()
{
    param([parameter(Mandatory=$true)][string]$scriptUrl,[string]$fileName='ps.ps1')
    $downloader = (New-Object System.Net.WebClient)
    $file = $downloader.DownloadString($scriptUrl)
    sc $fileName -Value $file
}