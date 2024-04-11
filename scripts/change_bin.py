import sys
import struct
import shutil


def parse_changes(changes_file):
    changes = {}
    current_address = None

    with open(changes_file, 'r') as file:
        for line in file:
            line = line.strip()

            if not line:
                current_address = None
            elif line.startswith('0x'):
                if current_address is None:
                    current_address = int(line, 16)
                    changes[current_address] = []
                else:
                    value = int(line, 16)
                    changes[current_address].append(value)

    return changes


def apply_changes(input_file, output_file, changes):
    shutil.copy2(input_file, output_file)

    with open(output_file, 'r+b') as outfile:
        for address, values in changes.items():
            outfile.seek(address)
            for value in values:
                data = struct.pack('<Q', value)
                outfile.write(data)


def main():
    if len(sys.argv) != 4:
        print("Usage: python apply_changes.py <dest.bin> <input.bin> <changes.txt>")
        sys.exit(1)

    dest_file = sys.argv[1]
    input_file = sys.argv[2]
    changes_file = sys.argv[3]

    changes = parse_changes(changes_file)
    apply_changes(input_file, dest_file, changes)

    print(f"Changes applied. Modified binary file saved as {dest_file}.")


if __name__ == '__main__':
    main()