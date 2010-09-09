<#
. SYNOPSIS
Generates the password hash for a RDP password using Win32 Calls
. EXAMPLE
PS > $passWordHash = .\encrypter.ps1
PS > $passWordHash 
01000000D08C9DDF0115D1118C7A00C04FC297EB0100000080630FB7A06C204FAF5B37C7ECAA094
90000000008000000700073007700000003660000C0000000100000007551E07D8A0434083A36FF
F65ADED0BD0000000004800000A0000000100000004B20BB957F6B6D3CFA6D262B007B9EC110000
00042E2390CCBCDB2B0EABD8B42D3C596D1140000002344525A56B99ECC5EBAF4E6A85B2174B041
F101
#>
function encryptPassword()
{
	param([string]$password)
	#Setup dll imports
	$dllimport = '[StructLayout ( LayoutKind.Sequential, CharSet = CharSet.Unicode )]
	public struct DATA_BLOB
	{
		public int cbData;
		public IntPtr pbData;
	}

	[DllImport ( "crypt32.dll", SetLastError = true,
	CharSet = System.Runtime.InteropServices.CharSet.Auto )]
	public static extern bool CryptProtectData (
	ref DATA_BLOB pPlainText,
	[MarshalAs ( UnmanagedType.LPWStr )]string szDescription,
	IntPtr pEntroy,
	IntPtr pReserved,
	IntPtr pPrompt,
	int dwFlags,
	ref DATA_BLOB pCipherText );'
			
	#Add the definitions
	try{
	$type = Add-Type -MemberDefinition $dllimport -Name Win32Utils -Namespace CryptProtectData -UsingNamespace System.Text -PassThru -IgnoreWarnings
	}catch{}
	write-host "Importing Complete"

	#Get the password to encrypt this is a byte array
	$passToEncrypt = [System.Text.Encoding]::Unicode.GetBytes($password)
	write-host "Password Converted To Bytes"
	#Setup the dllImport Vars
	$dataIn = New-Object CryptProtectData.Win32Utils+DATA_BLOB
	$dataout =  New-Object CryptProtectData.Win32Utils+DATA_BLOB
	$nullptr = [IntPtr]::Zero
	write-host "Variables Setup"
	#Initialise the dataIn variable , add extra checks here if we cant allocate
	$dataIn.pbData = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($passToEncrypt.Length)
	$dataIn.cbData = $passToEncrypt.Length
	[System.Runtime.InteropServices.Marshal]::Copy($passToEncrypt,0,$dataIn.pbData,$passToEncrypt.Length)
	write-host "Password Copied"
	#Try and encrypt the data 
	$success = $type[0]::CryptProtectData([ref] $dataIn,"psw",$nullptr,$nullptr,$nullptr,0x1,[ref] $dataout)
	write-host "Password Encrypted $success"

	if($success)
	{
		$encryptedBytes = New-Object byte[] $dataout.cbData
		[System.Runtime.InteropServices.Marshal]::Copy($dataOut.pbData,$encryptedBytes,0,$dataout.cbData)
		$encryptedByteString = [BitConverter]::ToString($encryptedBytes).replace("-","")
		#Clean Up
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($dataIn.pbData)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($dataout.pbData)
		write-host "Cleanup done"
		$encryptedByteString	
	}
	else
	{
		[System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
	}
}

. encryptPassword -password 'test'