# v0.4  ----------------------------------------------------------------------
# ----------------------  CONFIG LOAD FROM CONFIG FILE  -------------------------------------

# C:\Scripts\veeam_prometheus_info_push.ps1

# Define log file path
$LogDirectory = "C:\Scripts\logs\push"
$LogBaseName = "metrics_push_logs"
$LogExtension = ".txt"

# --- Monthly Log Rotation ---
# Create the dynamic log file path based on the current year and month
$currentMonth = Get-Date -Format "yyyy-MM" # Format as YYYY-MM
$LogFilePath = Join-Path -Path $LogDirectory -ChildPath "$LogBaseName`_$currentMonth$LogExtension"
# Example: C:\Scripts\logs\metrics_wipe_logs_2025-04.txt

# --- Log Cleanup: Keep only the 2 most recent log files ---
try {
    $filterPattern = "$LogBaseName*$LogExtension"
    $logFiles = Get-ChildItem -Path $LogDirectory -Filter $filterPattern | Sort-Object LastWriteTime -Descending

    if ($logFiles.Count -gt 2) {
        $filesToRemove = $logFiles | Select-Object -Skip 2
        foreach ($file in $filesToRemove) {
            Remove-Item -Path $file.FullName -Force
            # Temporarily log directly here since Log-Message might not be available yet
            Write-Host "Old log file deleted: $($file.FullName)"
        }
    }
} catch {
    Write-Error "ERROR: Failed during log cleanup. $_"
}

# Function to write to log file with timestamp
function Log-Message {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    try {
        # Use -Force to ensure the file is created if it doesn't exist for the new month
        # Specify Encoding for broader compatibility
        "$Timestamp - $Message" | Out-File -Append -FilePath $LogFilePath -Force -Encoding UTF8 -ErrorAction Stop
    } catch {
        # If logging fails, write to error stream
        Write-Error "Failed to write to log file '$LogFilePath'. Error: $_"
        # Optionally, add more robust error handling here (e.g., write to event log)
    }
}

# Log script start
Log-Message "------------------------------"
Log-Message "Script started."

# Import the configuration
try {
    . "C:\Scripts\CONFIG.ps1"
    Log-Message "Configuration file loaded successfully."
} catch {
    $ErrorMessage = "Error loading configuration: $_"
    Write-Error $ErrorMessage
    Log-Message "ERROR: $ErrorMessage"
    exit 1
}

# Use the configuration variables
$GROUP = $Config.GROUP
$BASE_URL = $Config.BASE_URL
$SERVER = $Config.SERVER
$JobRunVisualizationWindowSeconds = $Config.JobRunVisualizationWindowSeconds
Log-Message "Configuration variables loaded: GROUP='$GROUP', BASE_URL='$BASE_URL', SERVER='$SERVER'."

# ----------------------------------------------------------------------------
# --------------  Retrieving and preparing Bearer token  ---------------------
# --------------- using CredentialManager and MS Vault)  ---------------------
# ----------------------------------------------------------------------------

 # Retrieve credentials for PushGatewayVault from Windows Credential Manager
 $credential = Get-StoredCredential -Target 'PushGatewayVault' -ErrorAction SilentlyContinue
 Log-Message "Attempted to retrieve credentials for 'PushGatewayVault'."

 # Check if the credentials exist
 if (-not $credential) {
     $ErrorMessage = "No credentials found for 'PushGatewayVault' in Windows Credential Manager."
     Write-Error $ErrorMessage
     Log-Message "ERROR: $ErrorMessage"
     exit 1
 }
 Log-Message "Credentials for 'PushGatewayVault' found. Username: $($credential.UserName)."

 # Extract the username and password from the credential object
 $username = $credential.UserName
 $password = $credential.Password


 # Unlock the MS Vault with password from Credentials manager (stays unlocked for 1h for the session)
 try {
     Unlock-SecretStore  -Password $password
     Log-Message "MS Vault unlocked successfully."
 } catch {
     $ErrorMessage = "Error unlocking MS Vault: $_"
     Write-Error $ErrorMessage
     Log-Message "ERROR: $ErrorMessage"
     exit 1
 }

 # Retrieve the token stored in the vault
 $tokenSecret = Get-Secret -Name "PushgatewayToken" -Vault "PushGatewayVault" -ErrorAction SilentlyContinue
 Log-Message "Attempted to retrieve token 'PushgatewayToken' from vault."

 # Check if the token was retrieved
 if (-not $tokenSecret) {
     $ErrorMessage = "Could not retrieve the token from the vault."
     Write-Error $ErrorMessage
     Log-Message "ERROR: $ErrorMessage"
     exit 1
 }
 Log-Message "Token 'PushgatewayToken' retrieved successfully."

 # Extract token from the secure string
 $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tokenSecret))

 Write-Host "Token retrieved successfully"
 Log-Message "Token retrieved successfully"

# Define the URL for pushing metrics
$MetricsUrl = "$BASE_URL/metrics/job/$GROUP/instance/$SERVER"
Log-Message "Metrics URL defined: $MetricsUrl"

# ----------------------------------------------------------------------------
# ----------------------  GENERIC USEFUL STUFF  ------------------------------
# ----------------------------------------------------------------------------

# ANY ERROR WILL CAUSE SCRIPT TO TERMINATE EXECUTION
$ErrorActionPreference = "Stop"

# WHEN USING HTTPS THIS FORCES TLS 1.2 INSTEAD OF POWERSHELL DEFAULT 1.0
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Log-Message "TLS 1.2 enforced."

# RETURNS EPOCH TIME, SECONDS SINCE 1.1.1970, UTC
Function GetUnixTimeUTC([AllowNull()][Nullable[DateTime]] $ttt) {
    if (!$ttt) { return 0 }
    [int]$unixtime = (get-date -Date $ttt.ToUniversalTime() -UFormat %s).`
    Substring(0,10)
    return $unixtime
}

# ----------------------------------------------------------------------------
# ----------------------  VBR FUNCTIONS USED LATER  --------------------------
# ----------------------------------------------------------------------------

# JOB DOES NOT HAVE RESTORE POINTS, IT'S TASKS DO
# IF ALL GOES WELL THEY HAVE THE SAME NUMBER, BUT THE FUNCTION RETURNS THE LOWEST
function GetNumberOfRestorePoints($JobObject) {
    $Type = $JobObject.info.JobType

    if ($Type -eq 'NasBackup') {  
        # Despite new CMDlet, is VBRUnstructuredBackup, (Get-VBRJob).info.jobtype is still NasBackup
        $NasBackups =  Get-VBRUnstructuredBackup | ? {$_.JobId -eq $JobObject.Id}
        if (-not $NasBackups) {
            Write-Warning "No backup exists for job: $($JobObject.Name)"
            return 0
        }
        $RestorePoints = Get-VBRUnstructuredBackupRestorePoint -Backup $NasBackups
        $Grouped = $RestorePoints | Group-Object -Property {$_.NASServerName}
    } else {
        $Backup = Get-VBRBackup | Where-Object { $_.JobId -eq $JobObject.Id }
        if (-not $Backup) {
            Write-Warning "No backup exists for job: $($JobObject.Name)"
            return 0
        }
        $RestorePoints = Get-VBRRestorePoint -Backup $Backup
        $Grouped = $RestorePoints | Group-Object -Property {$_.Name}
    }

    $Sorted = $Grouped | Sort-Object -Property Count -Descending
    if (-not $Sorted) {
        Write-Warning "No restore points found for job: $($JobObject.Name)"
        return 0
    }
    return $Sorted[-1].Count
}

# CHECKS TASK LOGS IF A FULL BACKUP WAS DONE
function WasLastRunFullActiveOrFullSynt($SessionTasks) {
    # Check if $SessionTasks is null
    if ($SessionTasks -eq $null) {
        Write-Warning "Session tasks are null."
        return $false
    }

    try {
        # Attempt to retrieve the log records
        $Log = $SessionTasks.Logger.GetLog()
        if ($Log -eq $null) {
            Write-Warning "Log is null for session tasks."
            return $false
        }

        $LastTasksLogs = $Log.UpdatedRecords.Title
        if ($LastTasksLogs -eq $null) {
            Write-Warning "No log titles found."
            return $false
        }
    } catch {
        Write-Warning "Failed to retrieve or process logs for session tasks: $_"
        return $false
    }

    $SyntText = 'Synthetic full backup created successfully'
    $ActiveFullText = 'Active Full backup created'
    return (($LastTasksLogs -Contains $SyntText) -or ($LastTasksLogs -Contains $ActiveFullText))
}
# ----------------------------------------------------------------------------
# ----------------------  REPOSITORY INFO  -----------------------------------
# ----------------------------------------------------------------------------

$Repos = Get-VBRBackupRepository
foreach ($Repo in $Repos)
{

$REPO_ID = $Repo.Id
$REPO_NAME = $Repo.Name
echo $REPO_NAME
$TOTALSIZE = $Repo.GetContainer().CachedTotalSpace.InBytes
$FREESPACE = $Repo.GetContainer().CachedFreeSpace.InBytes

# PROMETHEUS REQUIRES LINUX LINE ENDINGS, SO \r\n IS REPLACED WITH \n
# ALSO POWERSHELL FEATURE "Here-Strings" IS USED, @""@ DEFINES BLOCK OF TEXT
# THE EMPTY LINE IS REQUIRED
$body = @"
veeam_repo_total_size_bytes $TOTALSIZE
veeam_repo_free_space_bytes $FREESPACE

"@.Replace("`r`n","`n")

# --------------  SEND DATA TO PUSHGATEWAY  -------------------------
try {
    Invoke-RestMethod `
        -Method PUT `
        -Uri "$BASE_URL/metrics/job/veeam_repo_report/instance/$REPO_ID/group/$GROUP/server/$SERVER/name/$REPO_NAME" `
        -Body $body `
        -Headers @{ Authorization = "Bearer $token" }
    Log-Message "Repository '$REPO_NAME' - Data sent to Pushgateway successfully."
} catch {
    Write-Error "Error sending repository data to Pushgateway: $_"
    Log-Message "ERROR: Error sending repository '$REPO_NAME' data to Pushgateway: $_"
}

}
# ----------------------------------------------------------------------------
# ----------------  JOBS INFO EXCEPT AGENT BASED BACKUPS AND Backup Copy -----
# ----------------------------------------------------------------------------

# GET AN ARRAY OF VEEAM JOBS, SORTED BY TYPE and NAME,
# EXCLUDE AGENT BASED BACKUPS
# AS IN FUTURE VEEAM VERSIONS Get-VBRJob WILL NOT RETURN THEM
$VeeamJobs = @(Get-VBRJob | Sort-Object typetostring, name | `
  ? {$_.BackupPlatform.Platform -ne 'ELinuxPhysical' `
  -and $_.BackupPlatform.Platform -ne 'EEndPoint' `
  -and $_.JobType -ne 'SimpleBackupCopyPolicy' `  #Removing Backup Copy Jobs as they do not have LastSession- FindLastSession() and therefore LastSessionTasks - Get-VBRTaskSession 
  })

# FOR EVERY JOB GATHER BASIC INFO
foreach ($Job in $VeeamJobs)
{
    $LastSession = $Job.FindLastSession()
    if ($LastSession -eq $null) {
        Write-Warning "No last session found for job $($Job.Name)"
    }

    $LastSessionTasks = Get-VBRTaskSession -Session $LastSession
    if ($LastSessionTasks -eq $null) {
        Write-Warning "No task sessions found for the last session of job $($Job.Name)"
    } elseif ($LastSessionTasks.Count -eq 0) {
        Write-Warning "Task sessions array is empty for job $($Job.Name)"
    } else {
        Write-Output "Task sessions retrieved successfully for job $($Job.Name):"
        $LastSessionTasks
    }

# --------------  JOB ID, JOB NAME, JOB TYPE  -----------------------

$JOB_ID = $Job.Id
$JOB_NAME = $Job.Name
$JOB_TYPE = $Job.JobType

# --------------  JOB START AND STOP TIME  --------------------------

$START_TIME_UTC_EPOCH = GetUnixTimeUTC($LastSession.progress.StartTimeLocal)
$STOP_TIME_UTC_EPOCH = GetUnixTimeUTC($LastSession.progress.StopTimeLocal)

# --------------  JOB LAST RESULT  ----------------------------------

# OFFICIAL VBR RESULT CODES: SUCCESS=0 | WARNING=1 | FAILED=2 | RUNNING=-1
# ADDED: DISABLED_OR_NOT_SCHEDULED=99 | RUNNING FULL OR SYNT_FULL BACKUP=-11
$LAST_SESSION_RESULT_CODE = $Job.GetLastResult().value__

# Options.JobOptions.RunManually -
#   TRUE IF THE JOB HAS UNCHECKED CHECKBOX - Run the job automatically
# IsScheduleEnabled -
#   FALSE IF THE JOB IS SET TO DISABLED
if ($Job.Options.JobOptions.RunManually) { $LAST_SESSION_RESULT_CODE = 99}
if (!$Job.IsScheduleEnabled) { $LAST_SESSION_RESULT_CODE = 99}

# TO VISUALIZE WHEN THE JOB RUN HAPPENED IN GRAPH
$SecondsAgoFromStart = (GetUnixTimeUTC(Get-Date)) - $START_TIME_UTC_EPOCH
if ($SecondsAgoFromStart -le $JobRunVisualizationWindowSeconds) {
    # ------  JOB RUN STARTED WITHIN THE LAST HOUR  -------
    $LAST_SESSION_RESULT_CODE = -1
}

# TO MARK RUN BEING A FULL BACKUP OR A FULL SYNTHETIC BACKUP
# BECAUSE ONLY AFTER BACKUP IS DONE WE KNOW
$SecondsAgoFromEnd = (GetUnixTimeUTC(Get-Date)) - $START_TIME_UTC_EPOCH
if ($SecondsAgoFromEnd -le $JobRunVisualizationWindowSeconds) {

    if (WasLastRunFullActiveOrFullSynt $LastSessionTasks) {
        $LAST_SESSION_RESULT_CODE = -11
    }
}

# --------------  JOB DATA SIZE AND BACKUP SIZE  ---------------------

$DATA_SIZE = 0
foreach ($Task in $LastSessionTasks) {
    $DATA_SIZE += $Task.Progress.TotalUsedSize
}

$BACKUP_SIZE = $LastSession.Info.BackupTotalSize

# --------------  GET NUMBER OF RESTORE POINTS  ---------------------

$NUMBER_OF_RESTORE_POINTS = GetNumberOfRestorePoints $Job

# PROMETHEUS REQUIRES LINUX LINE ENDINGS, SO \r\n IS REPLACED WITH \n
# ALSO POWERSHELL FEATURE "Here-Strings" IS USED, @""@ DEFINES BLOCK OF TEXT
# THE EMPTY LINE IS REQUIRED
$body = @"
veeam_job_result_info $LAST_SESSION_RESULT_CODE
veeam_job_start_time_timestamp_seconds $START_TIME_UTC_EPOCH
veeam_job_end_time_timestamp_seconds $STOP_TIME_UTC_EPOCH
veeam_job_data_size_bytes $DATA_SIZE
veeam_job_backup_size_bytes $BACKUP_SIZE
veeam_job_restore_points_total $NUMBER_OF_RESTORE_POINTS

"@.Replace("`r`n","`n")

# SEND GATHERED DATA TO PROMETHEUS PUSHGATEWAY
Invoke-RestMethod `
    -Method PUT `
    -Uri "$BASE_URL/metrics/job/veeam_job_report/instance/$JOB_ID/group/$GROUP/type/$JOB_TYPE/name/$JOB_NAME/server/$SERVER" `
    -Body $body `
    -Headers @{ Authorization = "Bearer $token" }

}

# ----------------------------------------------------------------------------
# --------------------  AGENT BASED JOBS  ------------------------------------
# ----------------------------------------------------------------------------

$AgentJobs = Get-VBRComputerBackupJob

# FOR EVERY AGENT JOB GATHER BASIC INFO
foreach ($Job in $AgentJobs)
{

# --------------  AGENT JOB LAST SESSION  ---------------------------

# CREATE A VARIABLE IDENTIFYING IF THE JOB IS A POLICY OR NOT
$IsPolicy = $False
if ($Job.Mode -eq 'ManagedByAgent') { $IsPolicy = $True }

# NOT ALL POLICY SESSIONS ARE BACKUPS, LOT OF CONFIG UPDATES THERE
# TO FILTER IT TO JUST ACTUAL BACKUPS THE NAME HAS WILDCARDS ADDED
# https://forums.veeam.com/post434804.html
$JobNameForQuery = $Job.Name
if ($IsPolicy) { $JobNameForQuery = '{0}?*' -f $Job.Name }
$Sessions = Get-VBRComputerBackupJobSession -Name $JobNameForQuery
$LastSession = $Sessions[0]
$LastSessionTasks = Get-VBRTaskSession -Session $LastSession

# --------------  AGENT JOB ID, NAME, TYPE  -------------------------

$JOB_ID = $Job.Id
$JOB_NAME = $Job.Name

if ($IsPolicy) {
    $JOB_TYPE = 'EpAgentPolicy'
} else {
    $JOB_TYPE = 'EpAgentBackup'
}

# --------------  AGENT JOB START AND STOP TIME  --------------------

$START_TIME_UTC_EPOCH = GetUnixTimeUTC($LastSession.CreationTime)
$STOP_TIME_UTC_EPOCH = GetUnixTimeUTC($LastSession.EndTime)

# --------------  AGENT JOB LAST SESSION RESULT  --------------------

# AGENT JOBS HAVE DIFFERENT RESULT CODES THAN REGULAR JOBS
#     RUNNING=0 | SUCCESS=1 | WARNING=2 | FAILED=3
# THEREFORE RESULT value__ WILL NOT BE USED, INSTEAD A HASHTABLE TRANSLATION

# HASHTABLE THAT EASES TRANSLATION OF RESULTS FROM A WORD TO A NUMBER
# 'NONE' RESULT APPEARS WHEN THE JOB IS RUNNING
$ResultsTable = @{"Success"=0;"Warning"=1;"Failed"=2;"None"=-1}

# OFFICIAL VBR RESULT CODES: SUCCESS=0 | WARNING=1 | FAILED=2 | RUNNING=-1
# ADDED: DISABLED_OR_NOT_SCHEDULED=99 | RUNNING_FULL_OR_SYNT_FULL_BACKUP=-11
$LAST_SESSION_RESULT_CODE = $ResultsTable[$LastSession.Result.ToString()]

if (!$Job.ScheduleEnabled) { $LAST_SESSION_RESULT_CODE = 99}
if (!$Job.JobEnabled) { $LAST_SESSION_RESULT_CODE = 99}

# TO VISUALIZE WHEN THE JOB RUN HAPPENED IN GRAPH
$SecondsAgoFromStart = (GetUnixTimeUTC(Get-Date)) - $START_TIME_UTC_EPOCH
if ($SecondsAgoFromStart -le $JobRunVisualizationWindowSeconds) {
    # ------  JOB RUN STARTED WITHIN THE LAST HOUR  -------
    $LAST_SESSION_RESULT_CODE = -1
}

# TO MARK RUN BEING A FULL BACKUP OR A FULL SYNTHETIC BACKUP
# BECAUSE ONLY AFTER BACKUP IS DONE WE KNOW
$SecondsAgoFromEnd = (GetUnixTimeUTC(Get-Date)) - $START_TIME_UTC_EPOCH
if ($SecondsAgoFromEnd -le $JobRunVisualizationWindowSeconds) {

    if (WasLastRunFullActiveOrFullSynt $LastSessionTasks) {
        $LAST_SESSION_RESULT_CODE = -11
    }
}

# --------------  AGENT JOB DATA SIZE  ------------------------------

$DATA_SIZE = 0

# THIS WORKS FOR FULL VOLUME BACKUPS AND ENTIRE MACHINE BACKUPS
foreach ($Task in $LastSessionTasks) {
    $DATA_SIZE += $Task.Progress.TotalUsedSize
}

# BACKUP MODE WHERE SELECTED FOLDERS ARE BACKED UP LACK CORRECT SIZE INFO
# TO GET AT LEAST ROUGH IDEA IS TO REPORT SIZE OF THE LAST FULL BACKUP - VBK
# IT WILL BE JUST APPROXIMATION AND IT MIGHT BE OLD INFO
if ($Job.BackupType -eq 'SelectedFiles') {
    $AgentBackup = Get-VBRBackup -Name $Job.Name
    $RestorePoints = Get-VBRRestorePoint -Backup $AgentBackup | `
                     Sort-Object -Property CreationTimeUtc -Descending
    $RestorePointsOnlyFull = $RestorePoints | ? {$_.IsFull}

    if ($RestorePointsOnlyFull.count -gt 0) {
        $Storage = $RestorePointsOnlyFull[0].FindStorage()
        $VbkSize = $Storage.Stats.BackupSize
        $DATA_SIZE = [int64]($VbkSize * 1.3)
    }
}

# --------------  GET AGENT JOB BACKUP SZE  -------------------------

$AgentBackup = Get-VBRBackup -Name $Job.Name
$RestorePoints = Get-VBRRestorePoint -Backup $AgentBackup
$BACKUP_SIZE = 0
foreach ($r in $RestorePoints) {
    $Storage = $r.FindStorage()
    $BACKUP_SIZE += $Storage.Stats.BackupSize
}

# --------------  GET NUMBER OF RESTORE POINTS  ---------------------

$NUMBER_OF_RESTORE_POINTS = GetNumberOfRestorePoints $Job

# --------------  SEND DATA TO PUSHGATEWAY  -------------------------

# PROMETHEUS REQUIRES LINUX LINE ENDINGS, SO \r\n IS REPLACED WITH \n
# ALSO POWERSHELL FEATURE "Here-Strings" IS USED, @""@ DEFINES BLOCK OF TEXT
# THE EMPTY LINE IS REQUIRED
$body = @"
veeam_job_result_info $LAST_SESSION_RESULT_CODE
veeam_job_start_time_timestamp_seconds $START_TIME_UTC_EPOCH
veeam_job_end_time_timestamp_seconds $STOP_TIME_UTC_EPOCH
veeam_job_data_size_bytes $DATA_SIZE
veeam_job_backup_size_bytes $BACKUP_SIZE
veeam_job_restore_points_total $NUMBER_OF_RESTORE_POINTS

"@.Replace("`r`n","`n")

# SEND GATHERED DATA TO PROMETHEUS PUSHGATEWAY
Invoke-RestMethod `
    -Method PUT `
    -Uri "$BASE_URL/metrics/job/veeam_job_report/instance/$JOB_ID/group/$GROUP/type/$JOB_TYPE/name/$JOB_NAME/server/$SERVER" `
    -Body $body `
    -Headers @{ Authorization = "Bearer $token" }
}

# Log script finish
Log-Message "Script finished."
