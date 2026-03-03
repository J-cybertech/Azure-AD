$ou = "OU=Users,OU=NYC,DC=lab,DC=local"

$password = Read-Host "Enter Password" -AsSecureString

New-ADUser -Name "Alice Johnson" `
-GivenName Alice `
-Surname Johnson `
-SamAccountName ajohnson `
-UserPrincipalName ajohnson@lab.local `
-Path $ou `
-AccountPassword $password `
-Enabled $true

New-ADUser -Name "Bob Martinez" `
-GivenName Bob `
-Surname Martinez `
-SamAccountName bmartinez `
-UserPrincipalName bmartinez@lab.local `
-Path $ou `
-AccountPassword $password `
-Enabled $true

New-ADUser -Name "Chris Walker" `
-GivenName Chris `
-Surname Walker `
-SamAccountName cwalker `
-UserPrincipalName cwalker@lab.local `
-Path $ou `
-AccountPassword $password `
-Enabled $true
