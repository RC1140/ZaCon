$firstTry = read-host "Is this the first time connecting to this server (y/n)"
$ip = read-host "Enter the ip of the server you are trying to connect to"
if($firstTry){
	Add-Type -assembly Microsoft.VisualBasic
	.\remoteServer.rdp
	sleep 1
	[Microsoft.VisualBasic.Interaction]::AppActivate("Remote Desktop Connection")
	[System.Windows.Forms.SendKeys]::SendWait("+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}+{TAB}")
	[System.Windows.Forms.SendKeys]::SendWait(" {ENTER}")
	#Only use the line below to check if there was a valid connection made
	#if there was the title will contain the ip of the pc we are connecting to
	$title = ps mstsc |%{$_.mainwindowtitle}
}
