 # C:\Scripts\pushgw_metrics_wipe.ps1

# Define log file path
$LogDirectory = "C:\Scripts\logs\wipe"
$LogBaseName = "metrics_wipe_logs"
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
Log-Message "Script running under user: $((Get-WmiObject -Class Win32_Process -Filter "ProcessID=$PID").GetOwner().User)"
Log-Message "Current Execution Policy: $(Get-ExecutionPolicy)"

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


 # Unlock the MS Vault with password from Credentials manager
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

 Write-Host "Token retrieved successfully" # Keep for interactive testing if needed
 Log-Message "Token retrieved successfully"

# Define the URL for wiping metrics
$wipeUrl = "$BASE_URL/api/v1/admin/wipe"
Log-Message "Wipe URL defined: $wipeUrl"

# Function to wipe metrics
function Wipe-PrometheusMetrics {
    param (
        [string]$Url,
        [string]$Token
    )

    try {
        # Invoke the REST method with Bearer authentication
        $response = Invoke-RestMethod -Uri $Url -Method Put -ContentType 'application/json' -Verbose -Headers @{ Authorization = "Bearer $token" }

        if ($response) {
            Write-Host "Metrics wiped successfully from $Url" # Keep for interactive testing
            Log-Message "Metrics wiped successfully from $Url"
        } else {
            Write-Host "Metrics wipe request sent, but no response was received." # Keep for interactive testing
            Log-Message "Metrics wipe request sent, but no response was received."
        }
    } catch {
        $ErrorMessage = "Failed to wipe metrics: $_"
        Write-Error $ErrorMessage
        Log-Message "ERROR: $ErrorMessage"
    }
}

# Run the function with the token
Log-Message "Attempting to wipe metrics."
Wipe-PrometheusMetrics -Url $wipeUrl -Token $token
Log-Message "Metrics wipe process completed."

# Log script finish
Log-Message "Script finished." 
