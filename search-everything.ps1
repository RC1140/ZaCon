param($searchVal)

$objConnection = New-Object -ComObject adodb.connection
$objrecordset = New-Object -ComObject adodb.recordset
$objconnection.open("Provider=Search.CollatorDSO;Extended Properties='Application=Windows';")
$objrecordset.open("SELECT System.ItemName, System.ItemTypeText, System.Size FROM SystemIndex", $objConnection)
$objrecordset.MoveFirst()
$GLOBAL:SE_results = @()

write-host 'Searching'

do
{
    $val = ($objrecordset.Fields.Item("System.ItemName")).value
    #$val.tostring()
    if($val.tostring() -match $searchVal){$GLOBAL:SE_results += $val} 
    #$objrecordset.Fields.Item("System.ITemTypeText")
    #$objrecordset.Fields.Item("System.SIze")
    $objrecordset.MoveNext()
} Until ($objrecordset.EOF)

write-host 'Search Complete'

$objrecordset.Close()
$objConnection.Close()
$objrecordset = $null
$objConnection = $null
[gc]::collect()
