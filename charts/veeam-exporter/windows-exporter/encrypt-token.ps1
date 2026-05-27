# Check if the credentials for PushGatewayVault already exist in Windows Credential Manager
$credential = Get-StoredCredential -Target 'PushGatewayVault' -ErrorAction SilentlyContinue

if ($credential) {
    Write-Host "Credentials for 'PushGatewayVault' already exist in Windows Credential Manager. Skipping credential creation."
    Write-Host "To recreate the credentials, remove them first using Remove-StoredCredential -Target "PushGatewayVault""
    Write-Host ""
} else {
    Write-Host "Creating credentials in Windows Credential Manager for unlocking the MS local Vault"
    $username = 'VeeamAdmin'  # Set statically to the username you want to use
    $password = Read-Host "Enter the password for PushGatewayVault" 
    
    
    try {
        # Creating the credentials in the Windows Credential Manager
        $cred = New-Object System.Management.Automation.PSCredential ("VeeamAdmin", (ConvertTo-SecureString $password -AsPlainText -Force))
        $cred | New-StoredCredential -Target "PushGatewayVault" -Persist LocalMachine
        Write-Host "Credentials created successfully in Windows Credential Manager."
    } catch {
        Write-Host "ERROR: Failed to create credentials in Windows Credential Manager."
        Write-Host $_.Exception.Message
        exit 1
    }
}

# Check if the vault "PushGatewayVault" is registered, if not, register it
if (-not (Get-SecretVault -Name "PushGatewayVault" -ErrorAction SilentlyContinue)) {
    Write-Host "Vault 'PushGatewayVault' not found. Registering SecretStore vault..."
    
    # Register the SecretStore vault
    try {
        Register-SecretVault -Name "PushGatewayVault" -Module Microsoft.PowerShell.SecretStore -DefaultVault
        Write-Host "Vault 'PushGatewayVault' registered successfully."
    } catch {
        Write-Host "ERROR: Failed to register 'PushGatewayVault' vault."
        Write-Host $_.Exception.Message
        exit 1
    }
}

# Check if the PushgatewayToken already exists in the vault
$credential = Get-StoredCredential -Target 'PushGatewayVault' -ErrorAction SilentlyContinue
Unlock-SecretStore  -Password $credential.Password 
$existingToken = Get-Secret -Name "PushgatewayToken" -Vault "PushGatewayVault" -ErrorAction SilentlyContinue

if ($existingToken) {
    Write-Host "Pushgateway token already exists in PushGatewayVault. Skipping token creation."
    Write-Host "To recreate the token, remove it first using:`nRemove-Secret -Name 'PushgatewayToken' -Vault 'PushGatewayVault'"

} else {
    # Prompt for the token directly (this will handle copy-paste properly)
    $token = Read-Host "Please enter your Pushgateway token" -AsSecureString

    # Ensure the token is not empty
    if (-not $token) {
        Write-Host "ERROR: Token cannot be empty."
        exit 1
    }

    # Store the token securely using SecretManagement
    try {
        $credential = Get-StoredCredential -Target 'PushGatewayVault' -ErrorAction SilentlyContinue
        Unlock-SecretStore  -Password $credential.Password
        Set-Secret -Name "PushgatewayToken" -Secret $token -Vault "PushGatewayVault"
        Write-Host "Token securely stored in PushGatewayVault."
        Write-Host "To recreate the token, remove it first using:`nRemove-Secret -Name 'PushgatewayToken' -Vault 'PushGatewayVault'"
        Write-Host ""
    } catch {
        Write-Host "ERROR: Failed to store token securely."
        Write-Host $_.Exception.Message
        exit 1
    }
}
