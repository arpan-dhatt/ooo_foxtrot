import sys
import os


def create_zeros_file(output_file, size):
    # Create a bytes object filled with zeros
    data = b'\x00' * size

    # Write the data to the binary file
    with open(output_file, 'wb') as file:
        file.write(data)

    print(f"Binary file '{output_file}' created with {size} bytes of zeros.")


def main():
    if len(sys.argv) != 3:
        print("Usage: python create_zeros_file.py <output_file> <log2(mem size)>")
        sys.exit(1)

    output_file = sys.argv[1]

    # Size of the binary file in bytes
    size = 2**int(sys.argv[2])

    create_zeros_file(output_file, size)


if __name__ == '__main__':
    main()