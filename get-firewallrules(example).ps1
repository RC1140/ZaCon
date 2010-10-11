$rules = get-firewallrules
$rules | ?{ $_.RemotePorts -match 77}| %{ $_.Name} | format-table
$rules | ?{ $_.RemotePorts -match 77}| %{ $_.enabled = $false}