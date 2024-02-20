#!/bin/bash

# Prompt the user for input
read -p "Enter a string: " input_string

# Generate a random 4-7 character string for NtDe
ntde_length=$((RANDOM % 4 + 4))
ntde=$(cat /dev/urandom | tr -dc 'a-zA-Z' | head -c $ntde_length)

# Loop through each character in the input string
output_array=""
for ((i=0; i<${#input_string}; i++)); do
    # Append each character to the output array
    output_array+=" '${input_string:$i:1}',"
done

# Add a null terminator and close the array
output_array+=" 0x0 };"

# Print the final array declaration
printf "unsigned char ${ntde}[] = {${output_array}\n"
