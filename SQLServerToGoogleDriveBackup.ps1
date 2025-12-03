#Imports necessary modules
Import-Module SQLPS

# CONFIGURATION
$serverInstance = "WSAMZN-KF9MQ2K4\PHDWIN"  # Change to your SQL Server instance
$backupRoot = "C:\Program Files\Microsoft SQL Server\MSSQL15.PHDWIN\MSSQL\Backup"             # Local backup folder
$gDriveSyncFolder = "D:\Users\ayers_petroleum\SQLServerBackups"  # Synced Google Drive folder
# Timestamp for backup filenames
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$zipFile = "$backupRoot\SQLBackups_$timestamp.zip"

# Ensure backup folder exists
if (!(Test-Path -Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot
}

# Ensure sync drive exists
if (!(Test-Path -Path $gDriveSyncFolder)) {
    New-Item -ItemType Directory -Path $gDriveSyncFolder 
}

# Get all user databases (excluding system databases)
$databases = Get-SqlDatabase -ServerInstance $serverInstance | Where-Object { $_.IsSystemObject -eq $false }


# Backup each database
foreach ($db in $databases) {
    $backupFile = Join-Path $backupRoot "$($db.Name)_$timestamp.bak"
    Backup-SqlDatabase -Database $db.Name -ServerInstance $serverInstance -BackupFile $backupFile -Initialize
    Write-Host "Backed up $($db.Name) to $backupFile"
    Compress-Archive -Path "$backupRoot\*.bak" -DestinationPath $zipFile -Update
    Remove-Item -Path $backupFile
}



# Copy to Google Drive sync folder
Move-Item -Path $zipFile -Destination $gDriveSyncFolder -Force
#Write-Host "Backup archive copied to Google Drive folder: $gDriveSyncFolder"
