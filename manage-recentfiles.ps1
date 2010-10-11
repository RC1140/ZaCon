function get-recentItems(){
    Get-ChildItem $([environment]::GetFolderPath('Recent'))
}

function clear-recentItems(){
    Get-ChildItem $([environment]::GetFolderPath('Recent')) | Remove-Item
}