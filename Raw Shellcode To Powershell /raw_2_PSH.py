def format_shellcode(input_file, output_file):
    # Read the raw shellcode from the input file
    with open(input_file, 'rb') as f:
        raw_shellcode = f.read()

    # Convert each byte to a string representation in the format 0xXX
    formatted_shellcode = ",".join("0x{:02x}".format(byte) for byte in raw_shellcode)

    # Write the formatted shellcode to the output file
    with open(output_file, 'w') as f:
        f.write(formatted_shellcode)

if __name__ == "__main__":
    input_file = input("Enter the path to the input file containing raw shellcode: ")
    output_file = input("Enter the path to the output file for the formatted shellcode: ")

    format_shellcode(input_file, output_file)
    print(f"Formatted shellcode has been written to {output_file}")
