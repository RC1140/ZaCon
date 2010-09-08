function setIp()
{
	param($ip);
	#Always edit a filed called remoteServer as this is the template we use
	$rdpFile = gc .\remoteServer.rdp
	$firstLine = 'full address:s:'+$ip
	$rdpFile[0] = $firstLine
	sc .\remoteServer.rdp $rdpFile
}

function main()
{
	$firstTry = read-host "Is this the first time connecting to this server (y/n)"
	$ip = read-host "Enter the ip of the server you are trying to connect to"
	if($firstTry -eq "y"){
		Add-Type -assembly Microsoft.VisualBasic
		if($ip){setIp $ip}
		invoke-expression .\remoteServer.rdp
		#Wait a second to the rdp to make a connection
		sleep 1
		[Microsoft.VisualBasic.Interaction]::AppActivate("Remote Desktop Connection")
		#Accept the default warning , which asks if you want to really connect to this server
		[System.Windows.Forms.SendKeys]::SendWait("+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}")
		[System.Windows.Forms.SendKeys]::SendWait(" {ENTER}")
		#Only use the line below to check if there was a valid connection made
		#if there was the title will contain the ip of the pc we are connecting to
		$title = ps mstsc |%{$_.mainwindowtitle}
		if($title -match $ip)
		{
			write-host "Connection Succeded :)"
		}
		else
		{
			#Kill any remaining rdp's if a connection wasnt made
			ps mstsc | kill
		}
	}
	else
	{
		if($ip)
		{
			setIp $ip
		}
		else
		{
			$rdpFile = gc .\remoteServer.rdp
			$ip = $rdpFile[0].Substring(15)
		}
		invoke-expression '.\remoteServer.rdp'
		sleep 1
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
		}
		else
		{
			write-host "Did not find server pass"
			#Kill any remaining rdp's if a connection wasnt made
			ps mstsc | kill		
		}
	}
}

. main