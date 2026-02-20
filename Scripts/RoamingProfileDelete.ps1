#Grabs the Users in the folder
Get-ChildItem C:\Users
#Profiles to keep
$profilesToKeep = @("Administrator", "Public", "TEMP", "Default")
#Get all profiles in the "C:\Users" directory
$allProfiles = Get-ChildItem C:\Users -Directory
#Exclude profiles to keep
$profilesToDelete = $allProfiles | Where-Object { $_.Name -notin $profilesToKeep }
# Delete the remaining profiles
foreach ($profile in $profilesToDelete) { $profilePath = $profile.FullName
Write-Host "Deleting Profile: $profilePath"
Remove-Item -Path $profilePath -Recurse -Force }
#Deploy Disk Cleanup
cleanmgr.exe /sagerun:1 
# Specify the registry key path
$registryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"

# Get all subkeys under the specified registry key
$subkeys = Get-Item -LiteralPath $registryKeyPath | Get-ItemProperty | ForEach-Object { $_.PSChildName }

# Specify the condition to match (e.g., profiles containing ".pak")
$condition = ".pak"

# Filter subkeys based on the condition
$profilesToDelete = $subkeys | Where-Object { $_ -like "$condition" }

# Delete the matching registry entries
foreach ($profile in $profilesToDelete) {
    $profilePath = Join-Path -Path $registryKeyPath -ChildPath $profile
    Write-Host "Deleting registry entry: $profilePath"
    Remove-Item -Path $profilePath -Recurse -Force
}

Write-Host "Registry entries deleted based on the specified condition."
# Schedule a daily restart at 7 am
$trigger = New-ScheduledTaskTrigger -Daily -At 7am

# Create a new action to restart the computer
$action = New-ScheduledTaskAction -Execute 'shutdown' -Argument '/r /f /t 0'

# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DailyRestart" -Description "Daily restart at 7 am"
