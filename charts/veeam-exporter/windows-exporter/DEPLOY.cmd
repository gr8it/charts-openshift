@echo off

:: Checking if the script is run as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo - Success: Administrative permissions confirmed.
) else (
    echo - ERROR: RUN AS ADMINISTRATOR
    pause
    exit /B
)

echo - Checking if C:\Scripts folder exists, creating it if not
if not exist "C:\Scripts\" (
    mkdir C:\Scripts
    echo - C:\Scripts folder created.
) else (
    echo - C:\Scripts folder already exists.
)

:: Copy the necessary scripts to C:\Scripts
echo - Copying CONFIG.ps1 to C:\Scripts
robocopy "%~dp0\" "C:\Scripts" "CONFIG.ps1" /NDL /NJH /NJS
:: Check if the file was copied successfully
if not exist "C:\Scripts\CONFIG.ps1" (
    echo - ERROR: CONFIG.ps1 was not copied correctly to C:\Scripts.
    pause
    exit /B
)

echo - Copying veeam_prometheus_info_push.ps1 to C:\Scripts
robocopy "%~dp0\" "C:\Scripts" "veeam_prometheus_info_push.ps1" /NDL /NJH /NJS
:: Check if the file was copied successfully
if not exist "C:\Scripts\veeam_prometheus_info_push.ps1" (
    echo - ERROR: veeam_prometheus_info_push.ps1 was not copied correctly to C:\Scripts.
    pause
    exit /B
)

echo - Copying pushgw_metrics_wipe.ps1 to C:\Scripts
robocopy "%~dp0\" "C:\Scripts" "pushgw_metrics_wipe.ps1" /NDL /NJH /NJS
:: Check if the file was copied successfully
if not exist "C:\Scripts\pushgw_metrics_wipe.ps1" (
    echo - ERROR: pushgw_metrics_wipe.ps1 was not copied correctly to C:\Scripts.
    pause
    exit /B
)

:: Copying encrypt-token.ps1 to C:\Scripts
echo - Copying encrypt-token.ps1 to C:\Scripts
robocopy "%~dp0\" "C:\Scripts" "encrypt-token.ps1" /NDL /NJH /NJS
:: Check if the file was copied successfully
if not exist "C:\Scripts\encrypt-token.ps1" (
    echo - ERROR: encrypt-token.ps1 was not copied correctly to C:\Scripts.
    pause
    exit /B
)
:: Copying PS-MODULES.ps1 to C:\Scripts
echo - Copying PS-MODULES.ps1 to C:\Scripts
robocopy "%~dp0\" "C:\Scripts" "PS-MODULES.ps1" /NDL /NJH /NJS
:: Check if the file was copied successfully
if not exist "C:\Scripts\PS-MODULES.ps1" (
    echo - ERROR: PS-MODULES.ps1 was not copied correctly to C:\Scripts.
    pause
    exit /B
)
:: Copying the ps_modules folder to C:\Scripts
echo - Copying ps_modules folder to C:\Scripts
robocopy "%~dp0\ps_modules" "C:\Scripts\ps_modules" /E /NDL /NJH /NJS
:: Check if the folder was copied successfully
if not exist "C:\Scripts\ps_modules" (
    echo - ERROR: ps_modules folder was not copied correctly to C:\Scripts.
    pause
    exit /B
)

:: Create the logs folder inside C:\Scripts if it doesn't exist
echo - Checking if C:\Scripts\logs folder exists, creating it if not
if not exist "C:\Scripts\logs\" (
    mkdir C:\Scripts\logs
    echo - C:\Scripts\logs folder created.
) else (
    echo - C:\Scripts\logs folder already exists.
)

:: Create the wipe subfolder inside C:\Scripts\logs if it doesn't exist
echo - Checking if C:\Scripts\logs\wipe folder exists, creating it if not
if not exist "C:\Scripts\logs\wipe\" (
    mkdir C:\Scripts\logs\wipe
    echo - C:\Scripts\logs\wipe folder created.
) else (
    echo - C:\Scripts\logs\wipe folder already exists.
)

:: Create the push subfolder inside C:\Scripts\logs if it doesn't exist
echo - Checking if C:\Scripts\logs\push folder exists, creating it if not
if not exist "C:\Scripts\logs\push\" (
    mkdir C:\Scripts\logs\push
    echo - C:\Scripts\logs\push folder created.
) else (
    echo - C:\Scripts\logs\push folder already exists.
)

:: Importing scheduled tasks if they don't already exist
if exist C:\Windows\System32\Tasks\veeam_prometheus_info_push (
    echo - scheduled task veeam_prometheus_info_push already exists, skipping
    echo - delete the task in taskschd.msc if you want a fresh import.
) else (
    echo - importing scheduled task veeam_prometheus_info_push
    schtasks.exe /Create /XML "%~dp0\veeam_prometheus_info_push.xml" /tn "veeam_prometheus_info_push"
)

if exist C:\Windows\System32\Tasks\pushgw_metrics_wipe (
    echo - scheduled task pushgw_metrics_wipe already exists, skipping
    echo - delete the task in taskschd.msc if you want a fresh import.
) else (
    echo - importing scheduled task pushgw_metrics_wipe
    schtasks.exe /Create /XML "%~dp0\pushgw_metrics_wipe.xml" /tn "pushgw_metrics_wipe"
)

:: Changing PowerShell ExecutionPolicy to RemoteSigned
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy RemoteSigned -Scope Process -Force"

:: Unblocking the PowerShell scripts
if exist "C:\Scripts\veeam_prometheus_info_push.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -Path 'C:\Scripts\veeam_prometheus_info_push.ps1'"
) else (
    echo - ERROR: veeam_prometheus_info_push.ps1 not found in C:\Scripts.
    pause
    exit /B
)

if exist "C:\Scripts\pushgw_metrics_wipe.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Unblock-File -Path 'C:\Scripts\pushgw_metrics_wipe.ps1'"
) else (
    echo - ERROR: pushgw_metrics_wipe.ps1 not found in C:\Scripts.
    pause
    exit /B
)

:: Run PowerShell ISE as Administrator and open both scripts
powershell -Command "Start-Process powershell_ise.exe -ArgumentList 'C:\Scripts\PS-MODULES.ps1,C:\Scripts\encrypt-token.ps1' -Verb RunAs"

echo.
echo - PowerShell ISE has been opened with the required scripts as Administrator. Please review and run them manually.
echo - This terminal can be closed.
pause
