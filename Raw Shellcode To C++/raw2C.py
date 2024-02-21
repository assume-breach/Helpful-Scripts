def format_shellcode(input_file, output_file):
    with open(input_file, 'rb') as f:
        raw_shellcode = f.read()

    formatted_shellcode = ', '.join("0x{:02x}".format(byte) for byte in raw_shellcode)

    with open(output_file, 'w') as f:
        f.write(formatted_shellcode)

if __name__ == "__main__":
    input_file = input("Enter the path to the input file containing raw shellcode: ")
    output_file = input("Enter the path to the output file for the formatted shellcode: ")

    format_shellcode(input_file, output_file)
    print(f"Formatted shellcode has been written to {output_file}")
