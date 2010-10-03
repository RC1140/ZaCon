function search-everything()
{
    param($searchVal)

    $objConnection = New-Object -ComObject adodb.connection
    $objrecordset = New-Object -ComObject adodb.recordset
    $objconnection.open("Provider=Search.CollatorDSO;Extended Properties='Application=Windows';")
    $objrecordset.open("SELECT System.ItemName, System.ItemTypeText, System.Size,System.ItemPathDisplay  FROM SystemIndex", $objConnection)
    $objrecordset.MoveFirst()
    $GLOBAL:SE_results = @()

    write-host 'Searching'

    do
    {
        $val = ($objrecordset.Fields.Item("System.ItemName"))
        if($val.value.tostring() -match $searchVal){
            $GLOBAL:SE_results += $val;
            $objrecordset.Fields.Item("System.ItemPathDisplay").Value
        } 
        #$objrecordset.Fields.Item("System.ITemTypeText")
        #$objrecordset.Fields.Item("System.SIze")
        $objrecordset.MoveNext()
    #    write-host '.' -NoNewLine

    } Until ($objrecordset.EOF)

    write-host 'Search Complete'
    write-host $GLOBAL:SE_Results.Length + ' Item/s found , query $SE_Results for details'

    $objrecordset.Close()
    $objConnection.Close()
    $objrecordset = $null
    $objConnection = $null
    [gc]::collect()
}