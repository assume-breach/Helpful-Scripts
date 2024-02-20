#!/bin/bash

# Define the directory where you want to perform the git pull
directory="/opt"

# Function to perform git pull recursively
git_pull_recursive() {
    local dir="$1"
    # Loop through each item in the directory
    for item in "$dir"/*; do
        # Check if the item is a directory
        if [ -d "$item" ]; then
            # Check if the directory is a git repository
            if [ -d "$item/.git" ]; then
                echo "Pulling changes in $item"
                # Change to the directory and perform a git pull
                cd "$item" || exit
                git pull
            else
                echo "Checking subdirectory: $item"
                # Recursively call the function for subdirectories
                git_pull_recursive "$item"
            fi
        fi
    done
}

# Check if the directory exists
if [ -d "$directory" ]; then
    # Call the function to start the recursive git pull
    git_pull_recursive "$directory"
else
    echo "Directory $directory does not exist"
    exit 1
fi
