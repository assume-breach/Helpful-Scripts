# Prompt the user for the directory to start in
$directory = Read-Host "Enter the directory to start in"

# Function to perform git pull recursively
function GitPullRecursive {
    param (
        [string]$dir
    )

    # Loop through each item in the directory
    $items = Get-ChildItem -Path $dir
    foreach ($item in $items) {
        # Check if the item is a directory
        if ($item.PSIsContainer) {
            # Check if the directory is a git repository
            if (Test-Path "$($item.FullName)\.git" -PathType Container) {
                Write-Output "Pulling changes in $($item.FullName)"
                # Change to the directory and perform a git pull
                Set-Location -Path $item.FullName
                git pull
            }
            else {
                Write-Output "Checking subdirectory: $($item.FullName)"
                # Recursively call the function for subdirectories
                GitPullRecursive $item.FullName
            }
        }
    }
}

# Check if the directory exists
if (Test-Path $directory -PathType Container) {
    # Call the function to start the recursive git pull
    GitPullRecursive $directory
}
else {
    Write-Output "Directory $directory does not exist"
    exit 1
}
