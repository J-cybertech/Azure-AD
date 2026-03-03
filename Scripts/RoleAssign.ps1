$groupsOU = "OU=Groups,OU=NYC,DC=lab,DC=local"

#creates an HR,Accounting,Medical group.

New-ADGroup -Name "HR" `
-GroupScope Global `
-GroupCategory Security `
-Path $groupsOU

New-ADGroup -Name "Accounting" `
-GroupScope Global `
-GroupCategory Security `
-Path $groupsOU

New-ADGroup -Name "Medical" `
-GroupScope Global `
-GroupCategory Security `
-Path $groupsOU

#Assign group to these users.

Add-ADGroupMember -Identity "HR" -Members ajohnson
Add-ADGroupMember -Identity "Accounting" -Members bmartinez
Add-ADGroupMember -Identity "Medical" -Members cwalker
