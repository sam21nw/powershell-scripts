# rename folders or files in a folder

Write-Host "Rename Files and Folders."

$ReplaceString = Read-Host -Prompt 'Input the string to be replaced'
$WithString = Read-Host -Prompt 'Input String to be replaced with'

Get-ChildItem | Rename-Item -NewName { $_.name -replace "$ReplaceString", "$WithString" }

Get-ChildItem