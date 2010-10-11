function ConvertTo-Base64()
{
    param([string]$textToEncode)
    [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($textToEncode))
}

function Generate-BatchFile()
{
    param([string]$fileName='ps.bat',[string]$textToEncode)
    
    $executionData = ConvertTo-Base64 -textToEncode $textToEncode
    
    sc -LiteralPath $fileName -Value "powershell.exe -EncodedCommand `"bABzAA==`""
}