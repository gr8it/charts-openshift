 # Run PowerShell as Admin before executing this script!

# Set source directory where .nupkg files are located
$ModulePath = "$PSScriptRoot\ps_modules"

# Set the global PowerShell module installation path (requires admin rights)
$DestPath = "C:\Program Files\WindowsPowerShell\Modules"

# Ensure the destination module folder exists
if (!(Test-Path -Path $DestPath)) {
    New-Item -ItemType Directory -Path $DestPath -Force
}

# Process each .nupkg file in the folder
Get-ChildItem -Path $ModulePath -Filter "*.nupkg" | ForEach-Object {
    $nupkgFile = $_.FullName
    $moduleName = $_.BaseName  # Extract module name from filename

    Write-Host "Processing module: $moduleName" -ForegroundColor Cyan

    # Extract the .nupkg file (renaming to .zip first)
    $zipFile = "$ModulePath\$moduleName.zip"
    Rename-Item -Path $nupkgFile -NewName $zipFile -Force
    Expand-Archive -Path $zipFile -DestinationPath "$ModulePath\$moduleName" -Force

    # Find the actual module folder (look for the .psd1 manifest file)
    $extractedPath = "$ModulePath\$moduleName"
    $psd1File = Get-ChildItem -Path $extractedPath -Filter "*.psd1" -Recurse | Select-Object -First 1

    if ($psd1File) {
        $actualModuleName = $psd1File.BaseName
        Write-Host "Detected module name: $actualModuleName" -ForegroundColor Yellow
        $destModulePath = "$DestPath\$actualModuleName"
    } else {
        Write-Host "No .psd1 file found, using extracted folder name instead!" -ForegroundColor Red
        $destModulePath = "$DestPath\$moduleName"
    }

    # Check if module already exists
    if (Test-Path -Path $destModulePath) {
        Write-Host "Module '$actualModuleName' is already installed. Skipping..." -ForegroundColor Blue
    } else {
        # Ensure the target module directory exists
        New-Item -ItemType Directory -Path $destModulePath -Force | Out-Null
        Write-Host "Moving module '$actualModuleName' to $DestPath ..." -ForegroundColor Yellow
        Move-Item -Path "$extractedPath\*" -Destination $destModulePath -Force -ErrorAction Stop
        Write-Host "Module '$actualModuleName' installed successfully!" -ForegroundColor Green
    }

    # Cleanup extracted files and ZIP
    Remove-Item -Path $zipFile -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $extractedPath -Recurse -Force -ErrorAction SilentlyContinue
}
