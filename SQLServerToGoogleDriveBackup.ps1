#This can be executed with this command
#   powershell.exe -ExecutionPolicy Bypass -File "D:\Users\ayers_petroleum\Documents\SQL Server Management Studio\SQLServerBackup.ps1"
#Imports necessary modules
Import-Module SQLPS

# CONFIGURATION
$serverInstance = "WSAMZN-KF9MQ2K4\PHDWIN"  # Change to your SQL Server instance
$backupRoot = "C:\Program Files\Microsoft SQL Server\MSSQL15.PHDWIN\MSSQL\Backup"             # Local backup folder
$gDriveSyncFolder = "C:\MyDrive\SQLBackups"  # Synced Google Drive folder

# Ensure backup folder exists
if (!(Test-Path -Path $backupRoot)) {
    New-Item -ItemType Directory -Path $backupRoot
}

# Get the SQL Server instance object
$instance = Get-SqlInstance -ServerInstance $serverInstance

# Get all user databases (excluding system databases)
$databases = Get-SqlDatabase -ServerInstance $serverInstance | Where-Object { $_.IsSystemObject -eq $false }


# Timestamp for backup filenames
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

# Backup each database
foreach ($db in $databases) {
    $backupFile = Join-Path $backupRoot "$($db.Name)_$timestamp.bak"
    Backup-SqlDatabase -Database $db.Name -ServerInstance $serverInstance -BackupFile $backupFile -Initialize
    Write-Host "Backed up $($db.Name) to $backupFile"

}

# OPTIONAL: Compress backups
$zipFile = "$backupRoot\SQLBackups_$timestamp.zip"
Compress-Archive -Path "$backupRoot\*.bak" -DestinationPath $zipFile

# Copy to Google Drive sync folder
Copy-Item -Path $zipFile -Destination $gDriveSyncFolder -Force
Write-Host "Backup archive copied to Google Drive folder: $gDriveSyncFolder"
